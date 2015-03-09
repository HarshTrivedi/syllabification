require "awesome_print"
require "csv"
require File.join( Dir.pwd , "vowel_syllabifications.rb")
require File.join( Dir.pwd , "probabilistic_random.rb")

legal_onsets = CSV.read('legal_onsets.csv')
$legal_onsets_hash = Hash[*legal_onsets.flatten(1)]



diphtong_hiatus_freq = CSV.read('diphtong_hiatus_freqs.csv')
$diphtong_hiatus_freq = Hash[*diphtong_hiatus_freq.map{|x| [x[0] , [x[1] , x[2]]]}.flatten(1)]


$vowel_cluster_syllabification_freqs = CSV.read('vowel_cluster_syllabification_freqs.csv')
# example element of array above: [ "aa", "a-a", "10"]


$prefix_frequencies = CSV.read("prefix_scores_92000.csv")
$prefix_frequencies = $prefix_frequencies.select{|x| x.last.to_f > 0.50}
$prefix_frequencies_hash =  Hash[*$prefix_frequencies.flatten(1)]

$suffix_frequencies = CSV.read("suffix_scores_92000.csv")
$suffix_frequencies = $suffix_frequencies.select{|x| x.last.to_f >= 0.50}

$suffix_frequencies_hash =  Hash[*$suffix_frequencies.flatten(1)]


def split_suffix(word)
	suffixes_possible = $suffix_frequencies.select{|suffix|  not word.match(/#{suffix[0]}$/).to_a.empty? }
	suffix = suffixes_possible.sort_by{|x| x[1].to_i}.last.first rescue ""
	word_dup = word.dup
	word_dup.gsub!(/#{suffix}$/ , "") if not suffix.empty?
	return word_dup , suffix 
end


def split_prefix(word)
	prefixes_possible = $prefix_frequencies.select{|prefix|  not word.match(/^#{prefix[0]}/).to_a.empty? }
	prefix = prefixes_possible.sort_by{|x| x[1]}.last.first rescue ""
	word_dup = word.dup
	word_dup.gsub!(/^#{prefix}/ , "") if not prefix.empty?
	return prefix , word_dup
end




def is_vowel(char)
 	not char.gsub(/[aeiou]/).to_a.empty?
end

def is_consonant(char)
 	not char.gsub(/[^aeiou]/).to_a.empty?
end

def hyphenate(word)
	# ap "WORD IS #{word}"
	parts = []
	chars = word.split("")
	types = ["vowel" , "consonant"]
	types.reverse! if not eval("is_#{types.first}(chars.first)")
	part = []
	for char in chars
		if not eval("is_#{types.first}(char) ")
			types.reverse!	
			parts << part
			part = [char]
		else
			part << char
		end
	end
	parts << part
	
	hyphenated_word = parts.map(&:join).join("-")
	# #Solve diphtong , hyatus prbolem
	# match = hyphenated_word.gsub(/[aeiou][aeiou]/).to_a.first
	# if match and ($diphtong_hiatus_freq[match][0] < $diphtong_hiatus_freq[match][1])
	# 	hyphenated_word[ hyphenated_word.gsub(/[aeiou][aeiou]/).to_a.first]="#{match[0]}-#{match[1]}"
	# end
	# return hyphenated_word


	# Solve Vowel Cluster problem
	# Each vowel-cluster gets replaced by most appropriate split for it.
	# hyphenated_word.gsub!(/[aeiou][aeiou]+/) do |match|
	# 	# ap "match : #{match}"
	# 	vowel_syllabifications = get_possible_vowel_syllabifications(match)
	# 	# ap vowel_syllabifications
	# 	vowel_syllabification_frequencies =  vowel_syllabifications.map{|vowel_syllabification|  $vowel_cluster_syllabification_freqs.select{|x| x[1] == vowel_syllabification}.first[2] rescue 1   }
	# 	# ap vowel_syllabification_frequencies
	# 	base_frequency = $vowel_cluster_syllabification_freqs.select{|x| x[0] == match}.inject(0){|sum , i| sum + i[2].to_i }
	# 	# ap "Vowel freq #{vowel_syllabification_frequencies}"
	# 	# ap "base freq #{base_frequency}"
	# 	probabilities = vowel_syllabification_frequencies.map{|x| (x.to_f / (base_frequency.to_f + 1))} 
	# 	# ap probabilities.inspect
	# 	probabilistic_random_index = probabilistic_random(probabilities)
	# 	# ap probabilistic_random_index
	# 	# ap "selected :#{vowel_syllabifications[probabilistic_random_index]}"
	# 	vowel_syllabifications[probabilistic_random_index]
	# end
	# ap hyphenated_word
	return hyphenated_word
end



def is_legal_onset(right)
	not $legal_onsets_hash[right].nil?
end

def frequency_of_onset(right)
	return 0 if $legal_onsets_hash[right].nil?
	$legal_onsets_hash[right].to_i
	# ap $legal_onsets_hash
end

def tag(word)
	###
	prefix , word = split_prefix(word)
	word , suffix = split_suffix(word)
	return [prefix , suffix].join("-") if word.empty?
	####

	hyphenated_word = hyphenate(word)
	# ap hyphenated_word
	parts = hyphenated_word.split("-")
	# ap parts
	character_tag_array = parts.join().split("")
	character_tag_array.map!{|x| [x , "undefined"]}
	current_char_index = 0
	nuclie_count = 1
	
	confusing_parts = []
	# ap "parts #{parts}"
	parts.each do |part| 
		# ap part
		if part == parts.first and is_consonant(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Onset:#{nuclie_count}"
				current_char_index += 1
			}
		elsif part == parts.last and is_consonant(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Coda:#{nuclie_count - 1}"
				current_char_index += 1
			}
		elsif is_vowel(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Nucleus:#{nuclie_count}"
				current_char_index += 1
			}
			nuclie_count += 1
		else
			confusing_parts << [ current_char_index , current_char_index + part.size - 1 , "#{nuclie_count-1}-#{nuclie_count}" ,  part ]
			current_char_index += part.size		
		end
	end

	##Solve the confusing part using MOP
	# ap "character_tag_array"
	# ap character_tag_array
	# ap "confusing_parts"
	# ap confusing_parts
	for confusing_part in confusing_parts
 		left = [] ; right = confusing_part.slice(3,1).first.split("")
 		# while( not is_legal_onset(right.join() ) )do
		# For trying different threshold values : uncomment this
		while( frequency_of_onset(right.join()) <= 150 and right.size != 1)do
 			left = left.dup
 			right = right.dup
 			left.push(right.shift) 			
 			# ap right
 		end
 		confusing_indices = (confusing_part[0]..confusing_part[1]).to_a
 		confusing_indices_left = confusing_indices.take(left.size)
 		confusing_indices_right = confusing_indices - confusing_indices_left
 		left_syllable_index , right_syllable_index = confusing_part[2].split("-").map(&:to_i)

 		confusing_indices_left.each{|index| character_tag_array[index][1] = "Coda:#{left_syllable_index}" }
 		confusing_indices_right.each{|index| character_tag_array[index][1] = "Onset:#{right_syllable_index}" }
 		
 	end

	word = hyphenated_word.split("-").join("")
	nos = character_tag_array.map{|x| x[1].split(":")[1].to_i }
	syllabified = []
	word.size.times do |i|
		syllabified << word[i]			
		syllabified << "-" if nos[i+1] != nos[i]
	end
	syllabified.tap(&:pop).join("")
	syllabified = syllabified.join("")


	# ap "#{prefix}  : #{syllabified}  :  #{suffix}"

	if suffix.empty? and prefix.empty?
		syllabified_word = syllabified
	elsif prefix.empty?
		syllabified_word = [ syllabified , suffix].join("-") if prefix.empty?
	elsif suffix.empty?
		syllabified_word = [ prefix , syllabified ].join("-")	
	else
		syllabified_word = [ prefix , syllabified , suffix].join("-")
	end
	return syllabified_word
	ap syllabified_word



	# # ##Solve the confusing part using HYBRID MOP

 # 	for confusing_part in confusing_parts
 # 		left = [] ; right = confusing_part.slice(3,1).first.split("")
 # 		combinations = []
 # 		combinations << [left , right]
 # 		while not right.empty? do
 # 			left = left.dup
 # 			right = right.dup
 # 			left.push(right.shift)
 # 			combinations << [left , right] 			
 # 		end

 # 		max_freq = combinations.map{|combination| frequency_of_onset(combination[1].join()).to_i }.max
 # 		max_probable_combination = combinations.select{|combination| frequency_of_onset(combination[1].join()).to_i == max_freq }.first

 # 		left , right = max_probable_combination[0] , max_probable_combination[1]
 # 		# ap "For confusing_part #{confusing_part}  max probable combination is : #{max_probable_combination}"
 # 		###############

 # 		confusing_indices = (confusing_part[0]..confusing_part[1]).to_a
 # 		confusing_indices_left = confusing_indices.take(left.size)
 # 		confusing_indices_right = confusing_indices - confusing_indices_left
 # 		left_syllable_index , right_syllable_index = confusing_part[2].split("-").map(&:to_i)

 # 		confusing_indices_left.each{|index| character_tag_array[index][1] = "Coda:#{left_syllable_index}" }
 # 		confusing_indices_right.each{|index| character_tag_array[index][1] = "Onset:#{right_syllable_index}" }
 		
 # 	end

	# word = hyphenated_word.split("-").join("")
	# nos = character_tag_array.map{|x| x[1].split(":")[1].to_i }
	# syllabified = []
	# word.size.times do |i|
	# 	syllabified << word[i]			
	# 	syllabified << "-" if nos[i+1] != nos[i]
	# end
	# syllabified.tap(&:pop).join("")
	# syllabified.join
	# # ap syllabified






end

ap tag("vulgarism")
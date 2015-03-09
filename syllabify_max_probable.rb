require "awesome_print"
require "csv"
require File.join( Dir.pwd , "vowel_syllabifications.rb")
require File.join( Dir.pwd , "probabilistic_random.rb")


$vowel_cluster_syllabification_freqs = CSV.read('vowel_cluster_syllabification_freqs.csv')
# example element of array above: [ "aa", "a-a", "10"]

$block_frequency_in_syllables = CSV.read('block_frequency_in_syllables.csv')
$block_frequency_in_syllables = Hash[*$block_frequency_in_syllables.flatten(1)]

$auto_updating_block_frequency_in_syllables = Hash.new

$hash_of_matrix = Hash.new(true)


$prefix_frequencies = CSV.read("prefix_scores_92000.csv")
$prefix_frequencies = $prefix_frequencies.select{|x| x.last.to_f > 0.60}
$prefix_frequencies_hash =  Hash[*$prefix_frequencies.flatten(1)]

$suffix_frequencies = CSV.read("suffix_scores_92000.csv")
$suffix_frequencies = $suffix_frequencies.select{|x| x.last.to_f >= 0.60}

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






def array_permutation(array)
  return array[0] if array.size == 1
  first = array.shift
  return first.product( array_permutation(array) )
end


def is_vowel(char)
 	not char.gsub(/[aeiou]/).to_a.empty?
end

def is_consonant(char)
 	not char.gsub(/[^aeiou]/).to_a.empty?
end

def hyphenate(word)
	return "" if word.nil? or word.strip.empty?
	parts = []
	# ap "Word is #{word}"
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



def possible_syllabifications(word)

	#######
	hyphenated_word = hyphenate(word)
	# ap hyphenated_word
	hyphenated_word.split("-").select{|split| not split[0].match(/[aeiou]/).to_a.empty?}
	
	clusters = hyphenated_word.split("-")
	vowel_clusters = hyphenated_word.split("-").select{|split| not split[0].match(/[aeiou]/).to_a.empty?}

	vowel_clusters_starting_indices = []
	traversed = 0
	clusters.each_with_index do |cluster , i|
		if not cluster.match(/[aeiou]/).to_a.empty?
			vowel_clusters_starting_indices << traversed
		end
		traversed += cluster.size
	end

	first_vowel_index = vowel_clusters_starting_indices.first
	last_vowel_index = vowel_clusters_starting_indices.last

	if vowel_clusters_starting_indices.size <= 1
		hyphenated_word = word
		$pre = ""
		$post = ""
	else
		$pre = word.slice(0 , first_vowel_index + 1)
		$post = word.slice( last_vowel_index , word.size - last_vowel_index)
		mid = (word.slice(first_vowel_index + 1 , last_vowel_index - first_vowel_index - 1))
		hyphenated_word = word
		mid = hyphenate(mid)
		hyphenated_word = [$pre , mid , $post ].join("-")
		hyphenated_word = [$pre , $post ].join("-") if mid.to_s.empty?
	end
	# ap hyphenated_word
	return [hyphenated_word] if hyphenated_word.split("-").size == 1
	#######

	sum = 0
	cumulative_sizes = hyphenated_word.split("-").map{|x| x.size }.map{|size| sum = sum + size  }
	cumulative_sizes.pop

	confusing_parts = []
	while cumulative_sizes.size >= 2 do
		confusing_parts << cumulative_sizes.take(2)
		cumulative_sizes.shift
	end
	# ap word
	# ap hyphenated_word
	# ap confusing_parts
	confusing_parts.each{|confusing_part| confusing_part[0] += -1}
	confusing_parts = confusing_parts.map{|confusing_part| ((confusing_part.first)..(confusing_part.last)).to_a.combination(2).to_a.select{|confusing_part| confusing_part.first == confusing_part.last - 1} }
	confusing_consonants = confusing_parts.select{|confusing_part| is_consonant(word[confusing_part[1][0]])}
	confusing_vowels = confusing_parts.select{|confusing_part| is_vowel(word[confusing_part[1][0]])}

	# ap confusing_consonants
	# ap confusing_consonants

	if confusing_consonants.size >= 2
		# ap confusing_consonants.inspect
		possible_split_combinations = array_permutation(confusing_consonants).map{|x| x.flatten}.map{|x| x.each_slice(2).to_a }
		# ap possible_split_combinations#.inspect
		original_word = word
		possible_syllabifications = []
		# ap possible_split_combinations
		for split_combination in possible_split_combinations
			# ap "Split combination #{split_combination}    : #{hyphenated_word}"
			word = original_word.dup
			added = 0
			split_combination.each do |split|
				word = word.dup
				word.insert(split.last + added , "-")
				added += 1
			end
			possible_syllabifications << word
			##
			# for possible_syllabification in possible_syllabifications
			# 	parts = possible_syllabification.split("-")
			# 	for part in parts
			# 		if part != parts.first and part != parts.last
			# 			regex = part.split("").join('-?')
			# 			possible_syllabification.gsub!(/#{regex}/) do |match|
			# 				hyphenated_word.gsub(/#{regex}/).to_a.first
			# 			end
			# 		end
			# 	end
			# end
			##
		end
		# ap possible_syllabifications
		return possible_syllabifications
	elsif confusing_consonants.size == 1
		possible_splits = confusing_consonants[0]
		original_word = word.dup
		possible_syllabifications = []
		for split in possible_splits
			word = original_word.dup
			word.insert(split.last , "-")
			possible_syllabifications << word
		end		
		# ap possible_syllabifications
		##
		# for possible_syllabification in possible_syllabifications
		# 	parts = possible_syllabification.split("-")
		# 	for part in parts
		# 		if part != parts.first and part != parts.last
		# 			regex = part.split("").join('-?')
		# 			possible_syllabification.gsub!(/#{regex}/) do |match|
		# 				hyphenated_word.gsub(/#{regex}/).to_a.first
		# 			end
		# 		end
		# 	end
		# end
		##
		return possible_syllabifications
	else
		# ap [word]
		return [word]
	end

end






syllables_frequencies = CSV.read("list_of_syllables_from_tagged-data.csv")
$syllables_frequencies = Hash[*syllables_frequencies.flatten(1)]
$syllables = $syllables_frequencies.keys

def most_probable_syllabification( possible_syllabifications )
	# ap "possible_syllabifications #{possible_syllabifications.inspect} #{possible_syllabifications.size}"
	return possible_syllabifications.first if possible_syllabifications.size == 1
	probability_hash = Hash.new(0)
	# ap "possible_syllabifications"
	# ap possible_syllabifications
	for possible_syllabification in possible_syllabifications
		# ap "IN possible_syllabification : #{possible_syllabification}"
		syllables = possible_syllabification.split("-")
		# ap "syllable size #{syllables.size}"
		# probability = 0
		probability = 1
		# ap "-----"
		for syllable in syllables
			to_be_matched = syllable.match(/[aeiou]+/).to_a.first
			if syllable == syllables.first
				# base_frequency = $auto_updating_block_frequency_in_syllables["^#{$pre}.*"]
				# if base_frequency.nil?
				# 	base_frequency = $syllables.count{|x| not x.match(/^#{$pre}.*/).to_a.empty? }
				# 	$auto_updating_block_frequency_in_syllables["^#{$pre}.*"] = base_frequency
				# end
				# ap "first pre: #{base_frequency}"
			elsif syllable == syllables.last				
				# base_frequency = $auto_updating_block_frequency_in_syllables[".*#{$post}$"]
				# if base_frequency.nil?
				# 	base_frequency = $syllables.count{|x| not x.match(/.*#{$post}$/).to_a.empty? }
				# 	$auto_updating_block_frequency_in_syllables[".*#{$post}$"] = base_frequency
				# end
				# ap "last  post: #{base_frequency}"
			else			
				# base_frequency = $auto_updating_block_frequency_in_syllables["#{to_be_matched}"]
				# if base_frequency.nil?
				# 	base_frequency = $syllables.select{|x| not x.match(/#{to_be_matched}/).to_a.empty? }.size
				# 	$auto_updating_block_frequency_in_syllables["#{to_be_matched}"] = base_frequency
				# end
				# probability_hash[possible_syllabification] += ($syllables_frequencies[syllable].to_i || 0)
				# ap "other MID : #{base_frequency}"
			end
			num_freq = ($syllables_frequencies[syllable].to_i || 0).to_f 
			# base_frequency += 1
			num_freq += 1
			# ap "Num fre #{num_freq}   : base_frequency  #{base_frequency}"
			# ap "BASE PROBLEM" if base_frequency == 1
			# ap "NUM  PROBLEM" if num_freq == 0
			# probability += num_freq 
			#IF NUM FREQUENCY IS 0 , then that syllable is illegal and so should never be used.
			probability += Math.log2( ( num_freq))
		end
		probability_hash[possible_syllabification] = probability
	end
	# ap probability_hash
	probability_hash.to_a.max_by(&:last).first
end

# (possible_syllabifications("beasansign"))
# ap most_probable_syllabification(possible_syllabifications("aboriginal"))

def tag(word)

	# Do no do this : it reduces the efficiency by 2 %age.
	# return word	if word.gsub(/[aeiou]+/).to_a.size <= 1

	prefix , word = split_prefix(word)
	word , suffix = split_suffix(word)

	# ap "prefix: #{prefix}    suffix : #{suffix}"

	return prefix if word.empty? and suffix.empty?
	return suffix if word.empty? and prefix.empty?
	return [prefix , suffix].join("-") if word.empty?
	
	syllabified = most_probable_syllabification(possible_syllabifications(word))
	
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
	# ap syllabified_word


end



ap tag("pudendum")


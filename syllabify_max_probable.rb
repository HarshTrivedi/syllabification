require "awesome_print"
require "csv"


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
	return hyphenated_word
end



def possible_syllabifications(word)

	#######
	hyphenated_word = hyphenate(word)
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
	end
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

	confusing_parts.each{|confusing_part| confusing_part[0] += -1}
	confusing_parts = confusing_parts.map{|confusing_part| ((confusing_part.first)..(confusing_part.last)).to_a.combination(2).to_a.select{|confusing_part| confusing_part.first == confusing_part.last - 1} }
	confusing_consonants = confusing_parts.select{|confusing_part| is_consonant(word[confusing_part[1][0]])}
	confusing_vowels = confusing_parts.select{|confusing_part| is_vowel(word[confusing_part[1][0]])}

	# ap confusing_consonants

	if confusing_consonants.size >= 2
		# ap confusing_consonants.inspect
		possible_split_combinations = array_permutation(confusing_consonants).map{|x| x.flatten}.map{|x| x.each_slice(2).to_a }
		# ap possible_split_combinations#.inspect
		original_word = word
		possible_syllabifications = []
		# ap possible_split_combinations
		for split_combination in possible_split_combinations
			word = original_word.dup
			added = 0
			split_combination.each do |split|
				word = word.dup
				word.insert(split.last + added , "-")
				added += 1
			end
			possible_syllabifications << word
		end
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
		return possible_syllabifications
	else
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
	# ap possible_syllabifications
	for possible_syllabification in possible_syllabifications
		syllables = possible_syllabification.split("-")
		probability = 0
		# ap "-----"
		for syllable in syllables
			# to_be_matched = syllable.match(/[aeiou]+/).to_a.first
			# if syllable == syllables.first
			# 	# ap "pre #{$pre}"
			# 	base_frequency = $syllables.select{|x| not x.match(/^#{$pre}.*/).to_a.empty? }.size
			# 	# ap "first : #{base_frequency}"
			# elsif syllable == syllables.last
			# 	base_frequency = $syllables.select{|x| not x.match(/.*#{$post}$/).to_a.empty? }.size				
			# 	# ap "last  : #{base_frequency}"
			# else			
			# 	base_frequency = $syllables.select{|x| not x.match(/#{to_be_matched}/).to_a.empty? }.size
			# 	# probability_hash[possible_syllabification] += ($syllables_frequencies[syllable].to_i || 0)
			# 	# ap "other #{base_frequency}"
			# end
			num_freq = ($syllables_frequencies[syllable].to_i || 0).to_f 
			# base_frequency += 1
			# num_freq += 1
			# ap "BASE PROBLEM" if base_frequency == 1
			# ap "NUM  PROBLEM" if num_freq == 0
			probability += num_freq 
			# probability += Math.log2( num_freq / (base_frequency.to_f))
		end
		probability_hash[possible_syllabification] = probability
	end
	# ap probability_hash
	probability_hash.to_a.max_by(&:last).first
end


# (possible_syllabifications("beasansign"))

# ap most_probable_syllabification(possible_syllabifications("aboriginal"))

def tag(word)
	most_probable_syllabification(possible_syllabifications(word))
end

# .select{|x| not x.match(/#{"h"}/).to_a.empty? }.size



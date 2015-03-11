require "awesome_print"
require "csv"
# require File.join( Dir.pwd , "vowel_syllabifications.rb")
# require File.join( Dir.pwd , "probabilistic_random.rb")


# $vowel_cluster_syllabification_freqs = CSV.read('vowel_cluster_syllabification_freqs.csv')
# # example element of array above: [ "aa", "a-a", "10"]

# $block_frequency_in_syllables = CSV.read('block_frequency_in_syllables.csv')
# $block_frequency_in_syllables = Hash[*$block_frequency_in_syllables.flatten(1)]

$auto_updating_block_frequency_in_syllables = Hash.new

$hash_of_matrix = Hash.new(true)


# $prefix_frequencies = CSV.read("prefix_scores_92000.csv")
# $prefix_frequencies = $prefix_frequencies.select{|x| x.last.to_f > 0.60}
# $prefix_frequencies_hash =  Hash[*$prefix_frequencies.flatten(1)]

# $suffix_frequencies = CSV.read("suffix_scores_92000.csv")
# $suffix_frequencies = $suffix_frequencies.select{|x| x.last.to_f >= 0.60}

# $suffix_frequencies_hash =  Hash[*$suffix_frequencies.flatten(1)]




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
		hyphenated_word = [$pre , $post ].join("-") if mid.to_s.empty?
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

	if confusing_consonants.size >= 2
		possible_split_combinations = array_permutation(confusing_consonants).map{|x| x.flatten}.map{|x| x.each_slice(2).to_a }
		original_word = word
		possible_syllabifications = []
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
	return possible_syllabifications.first if possible_syllabifications.size == 1
	probability_hash = Hash.new(0)
	for possible_syllabification in possible_syllabifications
		syllables = possible_syllabification.split("-")
		probability = 1
		for syllable in syllables
			num_freq = ($syllables_frequencies[syllable].to_i || 0).to_f 
			num_freq += 1
			probability += Math.log2( ( num_freq))
		end
		probability_hash[possible_syllabification] = probability
	end
	probability_hash.to_a.max_by(&:last).first
end


def tag(word)

	syllabified = most_probable_syllabification(possible_syllabifications(word))	
	syllabified_word = syllabified
	return syllabified_word
end



# ap tag("brinkmanship")


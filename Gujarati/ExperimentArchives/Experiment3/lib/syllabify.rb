# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__
require  File.join( directory , "calculate_syllabic_scores.rb" )

$experiment_root = File.join( directory , ".." )


####

correlation_quantities_array = CSV.read( File.join( $experiment_root , "model_files" , "correlation_quantities.csv")  )
$correlation_quantities_hash = {}
for correlation_quantity in correlation_quantities_array
	correlation = correlation_quantity.first
	correlation_quantity.shift
	$correlation_quantities_hash[correlation] = correlation_quantity
end


####

syllable_existence_frequencies_array = CSV.read( File.join( $experiment_root , "model_files" , "syllable_frequencies.csv")  )
$syllable_existence_frequencies_hash = Hash.new(0)
for syllable_frequency in syllable_existence_frequencies_array
	syllable = syllable_frequency.first
	frequency = syllable_frequency.last
	$syllable_existence_frequencies_hash[syllable] = frequency
end



#####

def get_linearly_decrease_substrings(string)
	results = []
	array = string.split("")
	results << array.join
	while not array.empty? do 
		array = array.dup
		array.shift
		results << array.join
	end
	results.pop
	results
end


def get_linearly_increase_substrings(string)
	string = string.dup.reverse
	results = get_linearly_decrease_substrings(string)
	results.map!(&:reverse).reverse
end



$prefix_frequencies = CSV.read(  File.join(directory , ".." , "model_files" , "prefix_scores.csv" )  )
# $prefix_frequencies = $prefix_frequencies.select{|x| x.last.to_f >= 0.95}
$prefix_frequencies_hash =  Hash[*$prefix_frequencies.flatten(1)]

$suffix_frequencies = CSV.read(  File.join(directory , ".." , "model_files" , "suffix_scores.csv" )  )
# $suffix_frequencies = $suffix_frequencies.select{|x| x.last.to_f >= 0.95}
$suffix_frequencies_hash =  Hash[*$suffix_frequencies.flatten(1)]


def split_prefix(word)

	possible_prefixes = get_linearly_increase_substrings(word)
	# ap possible_prefixes
	prefix = possible_prefixes.select{|prefix| $prefix_frequencies_hash[prefix].to_f >= 0.70 }.max_by{|prefix| $prefix_frequencies_hash[prefix].to_f } || ""

	possible_prefixes = get_linearly_decrease_substrings(word)
	possible_prefixes.max_by{|prefix|  $prefix_frequencies_hash[prefix].to_i } || ""

	word_dup = word.dup
	word_dup.gsub!(/^#{prefix}/ , "") if not prefix.empty?
	return prefix , word_dup
end


def split_suffix(word)
	possible_suffixes = get_linearly_decrease_substrings(word)
	suffix = possible_suffixes.select{|suffix| $suffix_frequencies_hash[suffix].to_f >= 0.70 }.max_by{|suffix|  $suffix_frequencies_hash[suffix].to_f } || ""
	# ap possible_suffixes
	possible_suffixes = get_linearly_decrease_substrings(word)
	possible_suffixes.max_by{|suffix|  $suffix_frequencies_hash[suffix].to_i } || ""

	word_dup = word.dup
	word_dup.gsub!(/#{suffix}$/ , "") if not suffix.empty?
	return word_dup , suffix
end


#####


def hyphenate(word)
	# ap "WORD IS #{word}"
	parts = []
	chars = word.chars.to_a.select{|x| not x.strip.ord == 8204 }
	types = ["non_matra" , "matra" ]
	part = [chars.shift]
	for char in chars
		if is_matra(char)
			part << char
		else
			parts << part
			part = [char]
		end
	end
	parts << part	
	hyphenated_word = parts.map(&:join).join("-")
	return hyphenated_word

end



def syllabify_wrapper(word)

	prefix , word = split_prefix(word)
	word , suffix = split_suffix(word)

	ap "prefix: #{prefix}    suffix : #{suffix}"

	return prefix if word.empty? and suffix.empty?
	return suffix if word.empty? and prefix.empty?
	return [prefix , suffix].join("-") if word.empty?

	syllabified = syllabify(word)

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


end



def syllabify(word)
	hyphenated_word = hyphenate(word)
	parts = hyphenated_word.split("-")
	max_possible_splits = parts.size - 1
	return word if max_possible_splits == 0
	combinations = []
	for i in 1..max_possible_splits
		combination = ( ( 1..(parts.size - 1) ).to_a.combination(i).to_a )
		combinations += combination
	end
	combinations << []
	combination_score_hash = Hash.new

	combinated_words = []
	combinations.each do |combination|
		dash_count = 0
		chars = hyphenated_word.chars.to_a.select{|x| not x.strip.ord == 8204 }
		new_chars = []
		for char in chars
			if char == "-"
				dash_count += 1
				new_chars << "-" if combination.include?(dash_count)				
			else
				new_chars << char
			end
		end
		combinated_word = new_chars.join("")
		combinated_words << combinated_word
		score = get_score( hyphenated_word , combinated_word , combination)	
		combination_score_hash[combinated_word] = score
	end
	combinated_words
	ap combination_score_hash
	return combination_score_hash.to_a.sort_by(&:last).last.first
end


def get_score( hyphenated_word , permutation , combination)	
	# ap permutation
	parts = permutation.split("-")
	parts.map{|part| $syllable_existence_frequencies_hash[part].to_f }.inject(:*)
end


ap syllabify("હાથકડી")

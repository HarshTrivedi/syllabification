require "awesome_print"
require "csv"


word_syllabifications = CSV.read("data/train_data.csv")
word_syllabifications.uniq!
word_syllabifications = word_syllabifications.select{|word_syllabification| not word_syllabification.empty?}



syllabes_hash = Hash.new(0)
word_syllabifications.each do |word_syllabification|
	word , syllabification = word_syllabification 
	syllabification.split("-").each{|syllable| syllabes_hash[syllable] += 1}

end


CSV.open('model_files/syllable_frequencies.csv', 'w') do |csv_object|
	syllables_array = syllabes_hash.to_a.sort_by(&:first)
	syllables_array.each do |row_array|
    	csv_object << row_array
	end
end

###########################################################################
###########################################################################

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



prefix_freqs = Hash.new(0)
suffix_freqs = Hash.new(0)

for word_syllabification in word_syllabifications
	syllabification = word_syllabification.last
	parts = syllabification.split("-")
	if parts.size > 0
		prefix_freqs[parts.first] += 1 if not parts.first.empty?
		suffix_freqs[parts.last] += 1 if not parts.last.empty?
	end
end


prefix_freqs_array = prefix_freqs.to_a.sort_by(&:last).reverse
suffix_freqs_array = suffix_freqs.to_a.sort_by(&:last).reverse



# ##PREFIX PROCESSING STARTS
# selected_prefixes = prefix_freqs.to_a.map(&:first)#.sort_by(&:last).reverse.take(1000).map(&:first)
# selected_prefix_freqs = {}
# selected_prefixes.each{|prefix| selected_prefix_freqs[prefix] = prefix_freqs[prefix]}
# prefix_scores_hash = Hash.new(0)
# $cash_frequency_hash = {}

# selected_prefixes.each do |key|
# 	word_syllabifications_starting_with_key = word_syllabifications.select{|word_syllabification| not word_syllabification[0].match(/^#{key}.*/).to_a.empty? }

# 	# Finding (ABC)
# 	num_count = word_syllabifications_starting_with_key.select{|word_syllabification|  word_syllabification[1].split("-").first == key}.size

# 	## Finding N(A) , N(AB) 
# 	substrings = get_linearly_increase_substrings(key)
# 	substrings.pop
# 	base_count_1 = 0
# 	for substring in substrings
# 		base_count = word_syllabifications_starting_with_key.count{|word_syllabification|  not word_syllabification[1].match(/^#{substring}-.+/).to_a.empty?}#.size		
# 		base_count_1 += base_count
# 	end

# 	## Finding N(ABC*)
# 	base_count_2 = word_syllabifications_starting_with_key.count{|word_syllabification| not word_syllabification[1].match(/^#{key}[^-]+/).to_a.empty? }#.size

# 	##  N(A) + N(AB) + N(ABC) + N(ABC*)
# 	base_count_final = base_count_1 + base_count_2 + num_count

# 	val = (num_count.to_f / base_count_final.to_f)
# 	prefix_scores_hash[key] = val
# 	puts "#{key}	#{base_count_1}	#{base_count_2}	#{num_count}	#{base_count_final}	#{val}"
# end

# selected_prefixes = prefix_scores_hash.to_a.sort_by(&:last).reverse
# CSV.open('model_files/prefix_scores.csv', 'w') do |csv_object|
#   selected_prefixes.each do |row_array|
#     csv_object << row_array
#   end
# end
# ##PREFIX PROCESSING ENDS



##SUFFIX PROCESSING STARTS
selected_suffixes = suffix_freqs.to_a.map(&:first)#.sort_by(&:last).reverse.take(1000).map(&:first)
selected_suffix_freqs = {}
selected_suffixes.each{|suffix| selected_suffix_freqs[suffix] = suffix_freqs[suffix]}
suffix_scores_hash = Hash.new(0)
$cash_frequency_hash = {}

selected_suffixes.each do |key|
	word_syllabifications_ending_with_key = word_syllabifications.select{|word_syllabification| not word_syllabification[0].match(/.*#{key}$/).to_a.empty? }

	# Finding N(ABC)
	num_count = word_syllabifications_ending_with_key.count{|word_syllabification|  word_syllabification[1].split("-").last == key}#.size

	# Finding N(A) , N(AB) 
	substrings = get_linearly_decrease_substrings(key)
	substrings.shift
	base_count_1 = 0

	for substring in substrings
		base_count = word_syllabifications_ending_with_key.count{|word_syllabification|  not word_syllabification[1].match(/[^-]+-#{substring}$/).to_a.empty?}#.size
		base_count_1 += base_count
	end

	## Finding N(*ABC)
	base_count_2 = word_syllabifications_ending_with_key.count{|word_syllabification| not word_syllabification[1].match(/[^-]+#{key}$/).to_a.empty? }#.size
	##


	##  N(A) + N(AB) + N(ABC) + N(ABC*)
	base_count_final = base_count_1 + base_count_2 + num_count

	val = (num_count.to_f / base_count_final.to_f)
	suffix_scores_hash[key] = val
	puts "#{key}	#{base_count_1}	#{base_count_2}	#{num_count}	#{base_count_final}	#{val}"
end

selected_suffixes = suffix_scores_hash.to_a.sort_by(&:last).reverse

CSV.open('model_files/suffix_scores.csv', 'w') do |csv_object|
  selected_suffixes.each do |row_array|
    csv_object << row_array
  end
end
##SUFFIX PROCESSING ENDS

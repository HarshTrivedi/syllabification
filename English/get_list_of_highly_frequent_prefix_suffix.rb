require 'csv'
require 'awesome_print'

word_syllabifications = CSV.read("normalized_tagged-data_92000.csv")


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
CSV.open('prefix_freqs_92000.csv', 'w') do |csv_object|
  prefix_freqs_array.each do |row_array|
    csv_object << row_array
  end
end
suffix_freqs_array = suffix_freqs.to_a.sort_by(&:last).reverse
CSV.open('suffix_freqs_92000.csv', 'w') do |csv_object|
  suffix_freqs_array.each do |row_array|
    csv_object << row_array
  end
end



##PREFIX PROCESSING STARTS
selected_prefixes = prefix_freqs.to_a.map(&:first)#.sort_by(&:last).reverse.take(1000).map(&:first)
selected_prefix_freqs = {}
selected_prefixes.each{|prefix| selected_prefix_freqs[prefix] = prefix_freqs[prefix]}

prefix_scores_hash = Hash.new(0)
$cash_frequency_hash = {}
selected_prefixes.each do |key|
	ap "In #{key}"
	substrings = get_linearly_increase_substrings(key)
	## A , AB , ABC
	base_count_1 = 0
	for substring in substrings
		base_count = selected_prefix_freqs[substring] || 0
		base_count_1 += base_count
	end
	# ap "base_count_1 #{base_count_1}"
	##

	## finding N(ABC*)
	if $cash_frequency_hash["^#{key}"].nil?
		base_prefixes = selected_prefixes.select{|prefix| not prefix.match(/^#{key}.+/).to_a.empty? }
		base_prefix_frequencies = base_prefixes.map{|prefix| selected_prefix_freqs[prefix]}
		base_count = 0
		base_prefix_frequencies.each{|x| base_count += x}
		base_count_2 = base_count
		$cash_frequency_hash["^#{key}"] = base_count_2
	end
	##
	##  N(A) + N(AB) + N(ABC) + N(ABC*)
	base_count_final = base_count_1 + base_count_2 
	## numcount => val => N(ABC)
	num_count = selected_prefix_freqs[key] #val
	denom_count = base_count_final - num_count + 1

	val = (num_count.to_f / denom_count.to_f)
	prefix_scores_hash[key] = val
	puts "#{key}	#{base_count_1}	#{base_count_2}	#{num_count}	#{denom_count}	#{val}"
end

selected_prefixes = prefix_scores_hash.to_a.sort_by(&:last).reverse
CSV.open('prefix_scores_92000.csv', 'w') do |csv_object|
  selected_prefixes.each do |row_array|
    csv_object << row_array
  end
end
##PREFIX PROCESSING ENDS



suffix_scores_hash = Hash.new(0)
$cash_frequency_hash = {}
##SUFFIX PROCESSING STARTS
selected_suffixes = suffix_freqs.to_a.map(&:first)#.select{|x| x.last >= 10}.map(&:first)#.sort_by(&:last).reverse.take(1000).map(&:first)
selected_suffix_freqs = {}
selected_suffixes.each{|suffix| selected_suffix_freqs[suffix] = suffix_freqs[suffix]}

selected_suffixes.each do |key|
	substrings = get_linearly_decrease_substrings(key)
	## ABC , BC , C
	base_count_1 = 0
	for substring in substrings
		base_count = selected_suffix_freqs[substring] || 0
		base_count_1 += base_count
	end
	##

	## finding N(*ABC)
	if $cash_frequency_hash["#{key}$"].nil?
		base_suffixes = selected_suffixes.select{|suffix| not suffix.match(/.+#{key}$/).to_a.empty? }
		base_suffix_frequencies = base_suffixes.map{|suffix| selected_suffix_freqs[suffix]}
		base_count = 0
		base_suffix_frequencies.each{|x| base_count += x}
		base_count_2 = base_count
		$cash_frequency_hash["#{key}$"] = base_count_2
	end
	##
	##  N(C) + N(BC) + N(ABC) + N(ABC*)
	base_count_final = base_count_1 + base_count_2 
	## numcount => val => N(ABC)
	num_count = selected_suffix_freqs[key] #val
	denom_count = base_count_final - num_count + 1

	val = (num_count.to_f / denom_count.to_f)
	suffix_scores_hash[key] = val
	puts "#{key}	#{base_count_1}	#{base_count_2}	#{num_count}	#{denom_count}	#{val}"
end

selected_suffixes = suffix_scores_hash.to_a.sort_by(&:last).reverse
CSV.open('suffix_scores_92000.csv', 'w') do |csv_object|
  selected_suffixes.each do |row_array|
    csv_object << row_array
  end
end
##SUFFIX PROCESSING ENDS


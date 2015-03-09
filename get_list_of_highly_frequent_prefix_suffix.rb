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






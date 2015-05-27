require 'csv'
require 'awesome_print'
word_syllabifications = CSV.read( File.join( Dir.pwd , "unique_gujarati_syllabification_corpus.csv" ) ) 

syllable_frequency_hash = Hash.new(1)

for word_syllabification in word_syllabifications
	syllables = word_syllabification.last.split("-") # syllabification
	for syllable in syllables
		syllable_frequency_hash[syllable] += 1
	end
end


array = syllable_frequency_hash.to_a.sort_by(&:first)
CSV.open('syllable_frequencies_sorted_aplha.csv', 'w') do |csv_object|
	array.each do |row_array|
		csv_object << row_array
	end
end

array = syllable_frequency_hash.to_a.sort_by(&:last).reverse
CSV.open('syllable_frequencies_sorted_freq.csv', 'w') do |csv_object|
	array.each do |row_array|
		csv_object << row_array
	end
end



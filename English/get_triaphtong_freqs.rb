require("awesome_print")
require("csv")

vowel_trigrams = %w[a e i o u].permutation(3).map(&:join)

words = []
File.open("dictionary_58000.txt" , "r") do |f|
	f.each_line do |line|
		words << line.strip
	end
end

vowel_trigram_frequencies = []

for vowel_trigram in vowel_trigrams
	vowel_trigram_frequency = []	
	triphtong_frequency = words.select{|word| not word.gsub(/#{vowel_trigram}/).to_a.empty? }.size
	vowel_trigram_frequency << vowel_trigram
	vowel_trigram_frequency << triphtong_frequency
	vowel_trigram_frequencies << vowel_trigram_frequency
end


CSV.open('triphtong_freqs.csv', 'w') do |csv_object|
  vowel_trigram_frequencies.to_a.each do |row_array|
    csv_object << row_array
  end
end
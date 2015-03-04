require("awesome_print")
require("csv")

vowel_digrams = %w[a e i o u].permutation(2).map(&:join)

words = []
File.open("dictionary_58000.txt" , "r") do |f|
	f.each_line do |line|
		words << line.strip
	end
end

vowel_digram_frequencies = []

for vowel_digram in vowel_digrams
	vowel_digram_frequency = []	
	diphtong_frequency = words.select{|word| not word.gsub(/#{vowel_digram}/).to_a.empty? }.size
	hiatus_frequency = words.select{|word| not word.gsub(/#{vowel_digram[0]}[^aeiou]#{vowel_digram[1]}/).to_a.empty? }.size
	vowel_digram_frequency << vowel_digram
	vowel_digram_frequency << diphtong_frequency
	vowel_digram_frequency << hiatus_frequency
	vowel_digram_frequencies << vowel_digram_frequency
end


CSV.open('diphtong_hiatus_freqs.csv', 'w') do |csv_object|
  vowel_digram_frequencies.to_a.each do |row_array|
    csv_object << row_array
  end
end
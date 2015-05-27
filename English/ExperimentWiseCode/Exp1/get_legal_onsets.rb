require("awesome_print")
require("csv")
onset_frequency = Hash.new(0)
File.open("dictionary_58000.txt" , "r") do |f|
f.each_line do |line|
onset = line.split(/[aeiou]/).first.strip
onset_frequency[onset] += 1
end
end

onset_frequency.delete("")

ap onset_frequency
sum_of_frequencies = onset_frequency.values.inject{|sum,x| sum + x } 
ap("Sum of frequencies is : #{sum_of_frequencies} " )
ap("Total number of terms : #{onset_frequency.keys.size} " )


CSV.open('legal_onsets.csv', 'w') do |csv_object|
  onset_frequency.to_a.each do |row_array|
    csv_object << row_array
  end
end



onset_frequency.each do |key , val|
	if key.size != 1
		onset_frequency[key] = onset_frequency[key].to_f / onset_frequency[key[0]].to_f
	end
end

onset_frequency.each do |key , val|
	onset_frequency[key] = onset_frequency[key].to_f / sum_of_frequencies if key.size == 1
end

CSV.open('normalised_legal_onsets.csv', 'w') do |csv_object|
  onset_frequency.to_a.each do |row_array|
    csv_object << row_array
  end
end
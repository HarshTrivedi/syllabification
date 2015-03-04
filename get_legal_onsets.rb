require("awesome_print")
require("csv")
onset_frequency = Hash.new(0)
File.open("dictionary_58000.txt" , "r") do |f|
	f.each_line do |line|
		onset = line.split(/[aeiou]/).first.strip
		onset_frequency[onset] += 1
	end
end
ap onset_frequency
ap("Sum of frequencies is : #{onset_frequency.values.inject{|sum,x| sum + x } } " )
ap("Total number of terms : #{onset_frequency.keys.size} " )



CSV.open('legal_onsets.csv', 'w') do |csv_object|
  onset_frequency.to_a.each do |row_array|
    csv_object << row_array
  end
end
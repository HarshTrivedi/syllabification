require("awesome_print")
require("csv")

syllabes_hash = Hash.new(0)

File.open("tagged-data.txt" , "r") do |f|
	f.each_line do |line|
		if not line.strip.empty?	
			word , syllabification = line.strip.split("=")
			syllabification.split("-").each{|syllable| syllabes_hash[syllable] += 1}		
		end
	end
end


CSV.open('list_of_syllables_from_tagged-data.csv', 'w') do |csv_object|
	syllables_array = syllabes_hash.to_a.sort_by(&:first)
	syllables_array.each do |row_array|
    	csv_object << row_array
	end
end


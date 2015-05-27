require("awesome_print")
require("csv")
require 'unidecoder'

normalized_data = []

File.open("tagged-data_92000.txt" , "r") do |f|
	f.each_line do |line|
		if not line.strip.empty?	
			word , syllabification = line.strip.split("=")
			word = word.downcase
			syllabification = syllabification.split(/[^\w]/).join("-").downcase.to_ascii
			if syllabification.match(/--+/).to_a.empty? and (syllabification.gsub(/\w/).to_a.size == word.gsub(/\w/).to_a.size)
				normalized_data << [word , syllabification] 
			end
		end
	end
end


CSV.open('normalized_tagged-data_92000.csv', 'w') do |csv_object|
  normalized_data.each do |row_array|
    csv_object << row_array
  end
end

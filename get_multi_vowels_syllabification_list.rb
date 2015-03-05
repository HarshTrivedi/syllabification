require("awesome_print")
require("csv")



vowel_diagrams = []
vowel_triagrams = []
vowel_quadgrams = []


File.open("tagged-data.txt" , "r") do |f|
	f.each_line do |line|
	if not line.strip.empty?	
		word , syllabification = line.strip.split("=")

		vowel_diagram = word.gsub(/[aeiou][aeiou]/).to_a.first
		if not vowel_diagram.nil?
			vowel_diagram_syllabification = syllabification.gsub(/[aeiou]-*[aeiou]/).to_a.first
			vowel_diagrams << [vowel_diagram , vowel_diagram_syllabification] 
		end

		vowel_triagram = word.gsub(/[aeiou][aeiou][aeiou]/).to_a.first		
		if not vowel_triagram.nil?
			vowel_triagram_syllabification = syllabification.gsub(/[aeiou]-*[aeiou]-*[aeiou]/).to_a.first if not vowel_triagram.nil?
			vowel_triagrams << [vowel_triagram , vowel_triagram_syllabification] 
		end
	
		vowel_quadgram = word.gsub(/[aeiou][aeiou][aeiou][aeiou]/).to_a.first		
		if not vowel_quadgram.nil?
			vowel_quadgram_syllabification = syllabification.gsub(/[aeiou]-*[aeiou]-*[aeiou]-*[aeiou]/).to_a.first if not vowel_quadgram.nil?
			vowel_quadgrams << [vowel_quadgram , vowel_quadgram_syllabification] 
		end
	end
	end
end


vowel_diagrams = vowel_diagrams.sort_by(&:first).uniq
vowel_triagrams = vowel_triagrams.sort_by(&:first).uniq
vowel_quadgrams = vowel_quadgrams.sort_by(&:first).uniq

CSV.open('vowel_diagram_syllabifications.csv', 'w') do |csv_object|
  vowel_diagrams.to_a.each do |row_array|
    csv_object << row_array
  end
end

CSV.open('vowel_triagram_syllabifications.csv', 'w') do |csv_object|
  vowel_triagrams.to_a.each do |row_array|
    csv_object << row_array
  end
end

CSV.open('vowel_quadgram_syllabifications.csv', 'w') do |csv_object|
  vowel_quadgrams.to_a.each do |row_array|
    csv_object << row_array
  end
end
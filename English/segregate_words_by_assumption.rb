require("awesome_print")
require("csv")


non_vowelic_clustered_words = []
vowelic_clustered_words = []
words_following_assumption = []
words_not_following_assumption = []

File.open("tagged-data.txt" , "r") do |f|
	f.each_line do |line|
	if not line.strip.empty?	
		word , syllabification = line.strip.split("=")
		if word.match(/[aeiou][aeiou]+/).to_a.empty?
			non_vowelic_clustered_words << [word , syllabification]
		else
			vowelic_clustered_words << [word , syllabification]
		end

		#words following/not_following assumption 1
		x = syllabification.split("-").map{|syllable| syllable.gsub(/[aeiou]+/).to_a.size == 1}.uniq
		if (word.gsub((/[aeiou]+/)).to_a.size == syllabification.split("-").size) and ((x.size == 1) and (x.first == true))
			words_following_assumption << [word , syllabification] 
		else
			words_not_following_assumption << [word , syllabification] 
		end
	end
	end
end


File.open("non_vowelic_clustered_tagged-data.txt", 'w') do |file| 
	for word in non_vowelic_clustered_words
		file.puts( word.join("=") ) 
	end
end


File.open("vowelic_clustered_tagged-data.txt", 'w') do |file| 
	for word in non_vowelic_clustered_words
		file.puts( word.join("=") ) 
	end
end

File.open("tagged-data_following_assumption.txt", 'w') do |file| 
	for word in words_following_assumption
		file.puts( word.join("=") ) 
	end
end

File.open("tagged-data_not_following_assumption.txt", 'w') do |file| 
	for word in words_not_following_assumption
		file.puts( word.join("=") ) 
	end
end








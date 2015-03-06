require "awesome_print"
require File.join( Dir.pwd , "syllabify.rb")

word_syllabification = {}
File.open("tagged-data.txt" , "r") do |f|
	f.each_line do |line|
		if not line.strip.empty?
			word , syllabification = line.strip.split("=")
			word_syllabification[word] = syllabification
		end
	end
end

correctly_tagged = 0
word_syllabification.each do |word , syllabification|
	if tag(hyphenate(word)) == syllabification
		ap word
		correctly_tagged += 1 
	else
	end
	# ap "#{tag(hyphenate(word))}    :   #{syllabification}"
end

ap "Correctly tagged are: #{correctly_tagged} of total #{word_syllabification.size}"
ap "Percentage : #{correctly_tagged.to_f / word_syllabification.size}"
# ap correctly_tagged.to_f / word_syllabification.size
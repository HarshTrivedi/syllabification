require "awesome_print"
require File.join( Dir.pwd , "syllabify.rb")
require File.join( Dir.pwd , "port_syllable_representation.rb")


word_syllabification = {}
File.open("tagged-data.txt" , "r") do |f|
	f.each_line do |line|
		if not line.strip.empty? #and (1..5) === rand(1..100)
			word , syllabification = line.strip.split("=")
			word_syllabification[word] = syllabification
		end
	end
end

correctly_tagged = 0

correctly_tagged_characters = 0
total_characters = 0
word_syllabification.each do |word , syllabification|
	if not word.strip.empty?
		tagged_word = tag( word )
		if tagged_word == syllabification
			ap word
			correctly_tagged += 1 
		else
			ap "Incorrect  #{tagged_word}  #{syllabification}"
		end
		correctly_tagged_characters += count_correct_characters_tagged(syllabification , tagged_word )
		total_characters += word.size
	end
	# ap "#{tag(hyphenate(word))}    :   #{syllabification}"
end

ap "Correctly tagged word are: #{correctly_tagged} from total of #{word_syllabification.size}"
ap "Percentage of correctly tagged words  : #{correctly_tagged.to_f / word_syllabification.size}"
ap "Correctly tagged characters are: #{correctly_tagged_characters} from total of #{total_characters}"
ap "Percentage of correctly tagged words  : #{correctly_tagged_characters.to_f / total_characters}"


# ap correctly_tagged.to_f / word_syllabification.size
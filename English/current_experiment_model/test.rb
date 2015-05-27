require "awesome_print"
require File.join( Dir.pwd , "syllabify.rb")


def port_syllable_representation(syllabified_word)
	chars = syllabified_word.split("")
	ported_code = []
	toggle = true
	for char in chars
		if char == "-"
			toggle = true 
		else
			if toggle == true
				toggle = false
				ported_code << "S"
			else
				ported_code << "F"
			end
		end
	end
	ported_code.join("")
end

def count_correct_characters_tagged(correct_syllabified_word , tagged_syllabified_word)
	correct = port_syllable_representation(correct_syllabified_word)
	tagged = port_syllable_representation(tagged_syllabified_word)
	correct.split("").zip(tagged.split("")).count{|x| x.first == x.last}
end	


word_syllabifications = CSV.read("test-data.csv")
word_syllabifications.uniq!
word_syllabifications = word_syllabifications.select{|word_syllabification| not word_syllabification.empty?}
word_syllabification = Hash[*word_syllabifications.flatten(1)]


correctly_tagged = 0
correctly_tagged_characters = 0
total_characters = 0


File.open("detailed-result.txt", 'w') do |file| 
	word_syllabification.each do |word , syllabification|
		if not word.strip.empty?
			tagged_word = tag( word )
			if tagged_word == syllabification
				ap word
				correctly_tagged += 1 
				ap "Correct 	#{tagged_word}"
				file.puts "Correct 	#{tagged_word}"
			else
				ap "Incorrect  	#{tagged_word}		#{syllabification}"
				file.puts "Incorrect  	#{tagged_word}		#{syllabification}"			
			end
			correctly_tagged_characters += count_correct_characters_tagged(syllabification , tagged_word )
			total_characters += word.size
		end
	end  
end



ap "Correctly tagged word are: #{correctly_tagged} from total of #{word_syllabification.size}"
ap "Percentage of correctly tagged words  : #{correctly_tagged.to_f / word_syllabification.size}"
ap "Correctly tagged characters are: #{correctly_tagged_characters} from total of #{total_characters}"
ap "Percentage of correctly tagged words  : #{correctly_tagged_characters.to_f / total_characters}"


File.open("result-analysis.txt", 'w') do |file| 
	file.puts "Correctly tagged word are: #{correctly_tagged} from total of #{word_syllabification.size}"
	file.puts "Percentage of correctly tagged words  : #{correctly_tagged.to_f / word_syllabification.size}"
	file.puts "Correctly tagged characters are: #{correctly_tagged_characters} from total of #{total_characters}"
	file.puts "Percentage of correctly tagged words  : #{correctly_tagged_characters.to_f / total_characters}"
end


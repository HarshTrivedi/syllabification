# encoding: UTF-8
require 'bundler/setup'
Bundler.require

$experiment_root = Dir.pwd 

require File.join( $experiment_root , "lib" , "syllabify.rb")
require File.join( $experiment_root , "lib" , "port_syllable_representation.rb")


word_syllabifications = CSV.read( File.join( Bundler.root , "data" , "test_data.csv") ) 
word_syllabification = Hash[*word_syllabifications.flatten(1)]

correctly_tagged_words = 0
correctly_tagged_characters = 0
traversed_words = 0
traversed_characters = 0


File.open( File.join( $experiment_root , "result" , "detailed-result.txt" )  , 'w') do |file| 

	word_syllabification.each do |word , syllabification|
		if not word.strip.empty?
			msg = []
			syllabified_word = syllabify( word )
			if syllabified_word == syllabification
				correctly_tagged_words += 1 
				msg << "Correct   : #{syllabified_word} → #{syllabification}"
			else
				msg << "Incorrect : #{syllabified_word} → #{syllabification}"
			end
			correctly_tagged_characters += count_correct_characters_tagged(syllabification , syllabified_word )
			traversed_characters += word.size
			traversed_words += 1

			msg << "Words Accuracy : (#{traversed_words} words)       :  #{correctly_tagged_words.to_f / traversed_words }"
			msg << "Char  Accuracy : (#{traversed_characters} chars)  :  #{correctly_tagged_characters.to_f / traversed_characters}"
			
			msg = msg.join("\n") ; ap msg ; file.puts msg ;
			puts "\n"
		end
	end

end



msg = []
msg << "-----------------"
msg << "-----Final-------"
msg << "Correctly tagged word are: #{correctly_tagged} from total of #{word_syllabification.size}"
msg << "Percentage of correctly tagged words  : #{correctly_tagged.to_f / word_syllabification.size}"
msg << "Correctly tagged characters are: #{correctly_tagged_characters} from total of #{traversed_characters}"
msg << "Percentage of correctly tagged words  : #{correctly_tagged_characters.to_f / traversed_characters}"

msg = msg.join("\n")

File.join( $experiment_root , "result" , "result-analysis.txt" ) { |file| file.puts  msg }

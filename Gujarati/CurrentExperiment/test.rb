require "awesome_print"
require File.join( Dir.pwd , "syllabify.rb")
require File.join( Dir.pwd , "port_syllable_representation.rb")

word_syllabifications = CSV.read( File.join( Dir.pwd , "unique_gujarati_syllabification_corpus.csv" ) ) 
word_syllabification = {}
word_syllabifications.each{|x| word_syllabification[x.first] = x.last }

correctly_tagged = 0

correctly_tagged_characters = 0
total_characters = 0

traversed_words = 0

# word_syllabification = word_syllabification.take(1000)
word_syllabification.each do |word , syllabification|
	if not word.strip.empty?
		syllabified_word = syllabify( word )
		if syllabified_word == syllabification
			ap word
			correctly_tagged += 1 
		else
			ap "Incorrect  #{syllabified_word}  #{syllabification}"
		end
		correctly_tagged_characters += count_correct_characters_tagged(syllabification , syllabified_word )
		total_characters += word.size
	end
	# ap "#{tag(hyphenate(word))}    :   #{syllabification}"
	traversed_words += 1
	ap "Words Accuracy (#{traversed_words} words): #{correctly_tagged.to_f / traversed_words }"
	ap "Char  Accuracy : #{correctly_tagged_characters.to_f / total_characters}"
	puts "\n"
end


ap "-----------------"
ap "Final"
ap "Correctly tagged word are: #{correctly_tagged} from total of #{word_syllabification.size}"
ap "Percentage of correctly tagged words  : #{correctly_tagged.to_f / word_syllabification.size}"
ap "Correctly tagged characters are: #{correctly_tagged_characters} from total of #{total_characters}"
ap "Percentage of correctly tagged words  : #{correctly_tagged_characters.to_f / total_characters}"


# ap correctly_tagged.to_f / word_syllabification.size
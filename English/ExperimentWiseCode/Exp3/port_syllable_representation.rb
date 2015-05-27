
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

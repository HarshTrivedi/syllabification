# encoding: UTF-8
require 'awesome_print'
require 'csv'
require  File.join( Dir.pwd , "character_details.rb" )

array = [ "અ" , "ણ"  ]

$word_syllabifications = CSV.read( File.join( Dir.pwd , "unique_gujarati_syllabification_corpus.csv" ) ) 


def get_pair_coexistence_probability(array , seperate = true)

	
	word_syllabifications_to_be_considered = []
	for word_syllabification in $word_syllabifications
		word = word_syllabification.first
		capture = Regexp.new(/#{array.first}#{array.last}/)
		extraneous_capture = Regexp.new(/#{array.first}#{array.last}[ાિીુૂૅૅૈોૉૌં્]+/)
		if not (capture =~ word).nil?
			if (extraneous_capture =~ word).nil?
				word_syllabifications_to_be_considered << word_syllabification
			end
		end
	end
	# ap word_syllabifications_to_be_considered
	denominator = word_syllabifications_to_be_considered.size


	if seperate
		capture = Regexp.new(/#{array.first}-#{array.last}/)
	else
		capture = Regexp.new(/#{array.first}#{array.last}/)
	end

	numerator = 0
	for word_syllabification in word_syllabifications_to_be_considered
		syllabification = word_syllabification.last
		if not (capture =~ syllabification).nil?
				numerator += 1
		end	
	end
	 
	return numerator.to_f / denominator.to_f

end



ap get_pair_coexistence_probability(array , false)
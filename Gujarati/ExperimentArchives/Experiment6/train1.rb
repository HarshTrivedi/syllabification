# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__
$experiment_root = directory

require  File.join( directory , "lib" , "syllabify.rb")

def get_pair_existence_probability(pair)

	#To Be Returned
	#words_together_in , syllables_together_in , syllables_seperate_in , coexistence_probability , non_coexistence_probability
	
	word_syllabifications_to_be_considered = []
	for word_syllabification in $word_syllabifications
		word = word_syllabification.first
		capture = Regexp.new(/#{pair.first}#{pair.last}/)
		extraneous_capture = Regexp.new(/#{pair.first}#{pair.last}[ાિીુૂૅૅૈોૉૌં્]+/)
		if (not (capture =~ word).nil?) and ((extraneous_capture =~ word).nil?)
			word_syllabifications_to_be_considered << word_syllabification
		end
	end

	###
	words_together_in = word_syllabifications_to_be_considered.size
	###

	capture = Regexp.new(/#{pair.first}#{pair.last}/)

	numerator = 0
	for word_syllabification in word_syllabifications_to_be_considered
		syllabification = word_syllabification.last
		if not (capture =~ syllabification).nil?
				numerator += 1
		end	
	end

	###
	syllables_together_in = numerator
	###

	capture = Regexp.new(/#{pair.first}-#{pair.last}/)
	numerator = 0
	for word_syllabification in word_syllabifications_to_be_considered
		syllabification = word_syllabification.last
		if not (capture =~ syllabification).nil?
				numerator += 1
		end	
	end	 

	###
	syllables_seperate_in = numerator
	###

	###
	coexistence_probability     = syllables_together_in.to_f / words_together_in.to_f
	non_coexistence_probability = syllables_seperate_in.to_f / words_together_in.to_f
	###

	return words_together_in , syllables_together_in , syllables_seperate_in , coexistence_probability , non_coexistence_probability

end



word_syllabifications = CSV.read( File.join( $experiment_root , "data" , "train_data.csv" ) ) 

pairs = []

for word_syllabification in word_syllabifications
	hyphenated_word = hyphenate(word_syllabification.first)
	parts = hyphenated_word.split("-")
	max_possible_splits = parts.size - 1

	for i in 1..max_possible_splits
		pairs << [ parts[i - 1]  , parts[i] ].join("<=>")
	end
end

ap pairs.size
rows = []

pairs.each_with_index do |pair , index|
	row = []
	row << pair
	pair = pair.split("<=>")
	row += get_pair_existence_probability(pair)
	rows << row
	ap index
	ap row
end



CSV.open( File.join( $experiment_root , "model_files" , "correlation_quantities.csv" ) , 'w') do |csv_object|
	rows.each do |row_array|
		csv_object << row_array
	end
end

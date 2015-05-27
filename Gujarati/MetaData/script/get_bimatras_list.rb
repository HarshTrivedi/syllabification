# encoding: UTF-8
require 'awesome_print'
require 'csv'
require  File.join( Dir.pwd , "character_details.rb" )

word_syllabifications = CSV.read( File.join( Dir.pwd , "unique_gujarati_syllabification_corpus.csv" ) ) 

bimatara_frequency_hash = Hash.new(1)

for word_syllabification in word_syllabifications
	word = word_syllabification.first
	capture = Regexp.new(/[ાિીુૂૅૅૈોૉૌં્][ાિીુૂૅૅૈોૉૌં્]/)
	# if not (capture =~ word).nil?
	word.gsub(capture) { |match|  
		bimatara_frequency_hash[match] += 1
	}
	# end
end


# puts bimatara_frequency_hash.inspect

CSV.open('bimatara_frequencies.csv', 'w') do |csv_object|
	bimatara_frequency_hash.each do |row_array|
		csv_object << row_array
	end
end

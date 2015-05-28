# encoding: UTF-8
require 'bundler/setup'
Bundler.require

## Using Syllabification from CurrentExperiment
## Using Version 1 of data for tagging purpose

require File.join(Bundler.root , "CurrentExperiment" , "lib" , "syllabify.rb")

words = CSV.read( File.join( Bundler.root , "TaggedData" , "version-1" , "to_be_suggested_data.csv" ) ) 
words = words.flatten(1)

word_syllabifications = []

words.each_with_index do |word , index |
	word_syllabification = [ word , syllabify(word) ]
	word_syllabifications << word_syllabification
	ap index
	ap word_syllabification
end

CSV.open(   File.join( Bundler.root , "TaggedData" , "version-1" , "suggested_data.csv" )   , 'w') do |csv_object|
  word_syllabifications.each do |row_array|
    csv_object << row_array
  end
end

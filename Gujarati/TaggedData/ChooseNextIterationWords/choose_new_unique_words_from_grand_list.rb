
require 'bundler/setup'
Bundler.require

## Using Version 1 of data for for getting new words

directory = __dir__

all_words = CSV.read( File.join( __dir__ , "grand_word_list.csv"  ) ).flatten(1).uniq

done_words_hash = {}
word_syllabifications = CSV.read( File.join( Bundler.root , "TaggedData" , "version-1" , "tagged_data.csv" ) ).each{|x| done_words_hash[x.first.strip] = true }

new_words = all_words.select{|word| not done_words_hash[word.strip] }

chosen_words = new_words.uniq.shuffle.sample( 6000 )

CSV.open(   File.join( __dir__ , "to_be_suggested_data.csv" )   , 'w') do |csv_object|
  chosen_words.map{|x| [x]}.each { |row_array| csv_object << row_array }
end

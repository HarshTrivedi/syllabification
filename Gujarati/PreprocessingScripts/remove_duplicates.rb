require 'csv'



rows = CSV.read( File.join( Dir.pwd , "gujarati_syllabification_corpus1.csv" ) ) 

unique_rows = rows.uniq{|x| x.first}

CSV.open('unique_gujarati_syllabification_corpus.csv', 'w') do |csv_object|
  unique_rows.each do |row_array|
    csv_object << row_array
  end
end



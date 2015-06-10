# encoding: UTF-8
 require 'bundler/setup'
 Bundler.require

 directory = __dir__

 require File.join( directory , "lib" , "crf.rb")
 require File.join( directory , "lib" , "configure_crf.rb")

 word_syllabifications = CSV.read( File.join( directory , "data" , "train_data.csv" ) )
 syllabifications = word_syllabifications.map(&:last)


 complete_data = CRFData.parse(syllabifications)

 CRF.ten_fold_cross_validate( complete_data , 
 	File.join( directory, "model_files" , "template_file") , 
 	File.join( directory, "result" , "cross_validation_result.txt" )  )
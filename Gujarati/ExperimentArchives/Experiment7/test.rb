# encoding: UTF-8
 
 require 'bundler/setup'
 Bundler.require
 
 directory = __dir__
 
 require File.join( directory , "lib" , "crf.rb")
 require File.join( directory , "lib" , "configure_crf.rb")

 model_file = File.join( directory , "model_files" , "model_file")
 template_file = File.join( directory , "model_files" , "template_file")
 train_data = CRF.load_training_data(  File.join( directory , "model_files" , "train_file" )  )

 model = Model.new(model_file , template_file , train_data ) 
 
 word_syllabifications = CSV.read( File.join( directory , "data" , "test_data.csv" ) )
 syllabifications = word_syllabifications.map(&:last)
 
 test_data = CRFData.parse( syllabifications )
 test_data.featurize
 
 result_data = model.test(test_data)

 ap result_data.correct_groups.size
 ap result_data.incorrect_groups.size   

 result_data.detailed_log(  File.join( directory , "result" , "detailed.log")  )
 result_data.analyse( File.join( directory , "result" , "result.txt") )
 
 
 
# encoding: UTF-8
 require 'bundler/setup'
 Bundler.require

 directory = __dir__

 require File.join( directory , "lib" , "crf.rb")
 require File.join( directory , "lib" , "configure_crf.rb")

 word_syllabifications = CSV.read( File.join( directory , "data" , "train_data.csv" ) )
 syllabifications = word_syllabifications.map(&:last)
 
 data = CRFData.parse(syllabifications)
 data.featurize

 template_file = File.join( directory , "model_files" , "template_file" )
 train_file = ".train_file"
 model_file = File.join( directory , "model_files" , "model_file" )
 CRF.train(data , template_file , train_file , model_file)


 data.save( File.join( directory , "model_files" , "train_file" ) )


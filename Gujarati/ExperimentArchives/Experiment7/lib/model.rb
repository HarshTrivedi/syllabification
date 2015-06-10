# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__

require File.join( directory , "crf_data.rb")
require File.join( directory , "crf.rb")

class Model

	attr_accessor :path , :template_file , :data

	def initialize( path = nil , template_file = nil , data = nil )
		self.path = path
		self.template_file = template_file
		self.data = data
	end


	## If CRFData is in input, it returns CRFData
	## If Group   is in input, it returns Group
	def test( to_be_tested , test_file = ".test_file" , output_file = ".output_file")

		if to_be_tested.is_a?(CRFData)
			to_be_tested.save(test_file)
			system( "crf_test -m #{self.path} #{test_file} > #{output_file}" )
			result = CRF.load_tested_data(output_file)
			FileUtils.rm(test_file)
			FileUtils.rm(output_file)
			return result
		elsif to_be_tested.is_a?(Group)
			data = CRFData.new([to_be_tested])
			data.save(test_file)
			system( "crf_test -m #{self.path} #{test_file} > #{output_file}" )
			result = CRF.load_tested_data(output_file)
			FileUtils.rm(test_file)
			FileUtils.rm(output_file)
			return result.groups.first
		else
			puts "argument to be tested must be CRFData or Group"
		end
	end

	def featurize
		data.featurize
	end


end
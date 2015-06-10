# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__

require File.join( directory , "model.rb")

class CRF

	def self.train( data , template_file = "template_file" , train_file = ".train_file" , model_file = ".model_file" )

		if data.is_a?(CRFData)
			model = Model.new(model_file , template_file , data)
			data.save(train_file)

			system( "crf_learn #{model.template_file} #{train_file} #{model.path}" )
			FileUtils.rm(train_file)
			return model
		else
			puts "Can only import data abstracted around Data class"
		end

	end

	def self.test( model , test_data )		
		model.test(test_data)
	end

	def self.load_training_data( train_file )
		data = CRFData.new
		group = Group.new
		lines = File.open( train_file , "r").readlines 
		column_consistency_count = nil

		lines.each do |line|
			if line.chomp.strip.empty?
				data << group
				group = Group.new
			else
				element = Element.new
				array = line.chomp.split("	")

				if ( column_consistency_count == array.size ) or ( column_consistency_count.nil? )

					column_consistency_count = array.size if column_consistency_count.nil?

					element.key = array.first
					element.features = array.slice(1 , array.size - 2)
					element.actual_tag = array.last
					group << element

				else
					puts "Data columns are not consistent. Cannot load data."
				end

			end
		end
		data
	end

	def self.load_tested_data( tested_file )

		result = CRFData.new
		group = Group.new

		lines = File.open( tested_file , "r").readlines 
		column_consistency_count = nil

		lines.each do |line|
			if line.chomp.strip.empty?
				result << group
				group = Group.new
			else
				element = Element.new
				array = line.chomp.split("	")

				if ( column_consistency_count == array.size ) or ( column_consistency_count.nil? )
					element.key = array.first
					element.features = array.slice(1 , array.size - 3)
					element.actual_tag = array[array.size - 2]
					element.crf_tag = array.last
					group << element
				else
					puts "Data columns are not consistent. Cannot load data."
				end

			end
		end
		result
	end


	def self.ten_fold_cross_validate( complete_data , template_file = "template_file" , file = nil )
		analysis_hashes = []
		10.times do
			test_data = CRFData.new( complete_data.sample( (complete_data.size / 10) + 1 ) )
			train_data  = CRFData.new( complete_data.to_a - test_data.to_a )
			train_data.featurize
			test_data.featurize

			model = CRF.train(train_data , template_file )
			result_data = model.test( test_data )

			analysis_hashes << result_data.analyse
		end

		evaulation_keys = analysis_hashes.first.keys

		sumall = Hash.new
		averages = Hash.new
		for evaulation_key in evaulation_keys
			sumall[evaulation_key] = [ 0 , 0 ]
			averages[evaulation_key] = []
			analysis_hashes.each do |analysis_hash|
				sumall[evaulation_key][0] += analysis_hash[evaulation_key][0]
				sumall[evaulation_key][1]  += analysis_hash[evaulation_key][1]				
				averages[evaulation_key] << (analysis_hash[evaulation_key][0].to_f / analysis_hash[evaulation_key][1].to_f)
			end
		end

		msg = []
		for evaulation_key in evaulation_keys
			macro_average = sumall[evaulation_key].first / sumall[evaulation_key].last
			msg << "On Macro evaulation: #{evaulation_key} => [ #{sumall[evaulation_key].first} / #{sumall[evaulation_key].last} ] correct (#{macro_average})"
			micro_average = averages[evaulation_key].inject(:+).to_f / 10
			msg << "On Micro evaulation: #{evaulation_key} => (#{micro_average})"			
		end

		puts msg.join("\n")

		if file
			File.open(file , "w") {|file| file.puts msg.join("\n") }
		end

		sumall
	end
 
end


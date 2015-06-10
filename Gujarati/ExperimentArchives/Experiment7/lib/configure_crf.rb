# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__




 require File.join( directory , "crf.rb")

 ## Implement features model method according to your need ##
 require File.join( Bundler.root , "character_details.rb")
 class Element
	def compute_features
		$character_hash[self.key] * 2
	end
 end
 #####

 ### Implement conversion of plain sentence to group class
 class Group
 	def self.parse( plain_expression , with_actual_tags = true )
 		# ap plain_expression
 		group = Group.new
 		parts = plain_expression.chomp.split("-")

 		for part in parts
 			chars = part.chars
 			for char in chars
	 			element = Element.new
	 			element.key = char
	 			if with_actual_tags
	 			# since we will not have
	 			# actual tags in case of test 
	 			# ie. when with_actual_tags = false
		 			if char == chars.first
		 				element.actual_tag = "S"
		 			else
		 				element.actual_tag = "F"
		 			end
		 		end
	 			group << element
 			end
 		end
 		group
 	end

 	def unparse_to_actual
 		unparsed = ""
 		elements_array = self.elements.dup
 		unparsed += elements_array.shift.key
 		elements_array.each do |element|
			unparsed += "-" if( element.actual_tag == "S" )
 			unparsed += element.key
	 	end
	 	unparsed
 	end

 	def unparse_to_tagged
 		unparsed = ""
 		elements_array = self.elements.dup
 		unparsed += elements_array.shift.key
 		elements_array.each do |element|
			unparsed += "-" if( element.crf_tag == "S" )
 			unparsed += element.key
	 	end
	 	unparsed
 	end

 end
###

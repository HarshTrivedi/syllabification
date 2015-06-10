# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__

require File.join( directory , "element.rb")

class Group < Array

	def initialize( group = [])
    	super 
	end 

  	def <<(element)
		if element.is_a?(Element)
    		super(element)
    	else
    		# Raise error
	    	puts "Cannot add non element object to Group"
	    end
  	end

  	# def reverse
  		# Group.new(@group.reverse)
  	# end

  	def elements
  		self
  	end

	def keys
		self.elements.map(&:key)
	end

	def correct?
		elements.each do |element|
			return false if (element.crf_tag != element.actual_tag)
		end
		return true
	end

	def correctly_tagged_elements
		elements.select{|element| element.correct? }
	end

    def featurize
        for element in self
          element.features = element.compute_features
        end
    end

end
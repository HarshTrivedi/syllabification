# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__


require File.join( directory , "group.rb")

class CRFData < Array

  	def initialize( load_data = [])
        super
  	end 

  	def <<(group)
      if group.is_a?(Group)
        super(group)
      else
        # Raise error
        puts "Cannot add non group object to Group"
      end  
  	end

  	# def reverse
  	# 	Group.new(@group.reverse)
  	# end



  	def groups
  		self
  	end

    def correct_groups
      groups.select(&:correct?)
    end

    def incorrect_groups
      groups.select{|group| not group.correct? }
    end

    def elements
      elements_array = []
      for group in groups
        elements_array += group.elements
      end
      elements_array
    end

    def correct_elements
      elements.select(&:correct?)
    end

    def incorrect_elements
      elements.select{|element| not element.correct? }
    end

    def save( file_name , disable_actual_tag = false )

      File.open( file_name , "w") do |file|
        for group in self
          for element in group
            array = [element.key]
            array += element.features
            array += [element.actual_tag] if (not disable_actual_tag)
            array += [element.crf_tag] if ( not element.crf_tag.nil? )
            file.puts array.join("\t")
          end
          file.puts
        end
      end

    end

    def number_of_groups
        self.size
    end

    def number_of_elements
        groups.map(&:size).inject(&:+)
    end

    def number_of_correct_groups
        correct_groups.size 
    end

    def number_of_correct_elements        
        correct_elements.size
    end


    def featurize
      for group in self
        for element in group
          element.features = element.compute_features
        end
      end
    end
    
    def self.parse(sentences = [] , with_actual_tags = true )
      data = CRFData.new
      for sentence in sentences
        data << Group.parse(sentence , with_actual_tags )
      end
      data
    end


    def analyse(file = nil )
      analysis = {}
      analysis["character"] = [ number_of_correct_elements.to_f , (number_of_elements.to_f ) ]
      analysis["word"] = [ number_of_correct_groups.to_f , ( number_of_groups.to_f)]
      
      
      syllables_correct = self.groups.map{|group| (group.unparse_to_actual.split("-") & group.unparse_to_tagged.split("-")).size }.inject(:+)
      syllables_total = self.groups.map{|group| group.unparse_to_actual.split("-").size }.inject(:+)
      
      analysis["syllable"] = [ syllables_correct.to_f , ( syllables_total.to_f)]


      if file
        msg = []
        evaulation_keys = analysis.keys
        for evaulation_key in evaulation_keys
          accuracy = analysis[evaulation_key].first / analysis[evaulation_key].last
          msg << "On evaulation: #{evaulation_key} => [ #{analysis[evaulation_key].first} / #{analysis[evaulation_key].last} ] correct (#{accuracy})"
        end
        puts msg.join("\n") ;
        File.open(file , "w") { |file| file.puts msg.join("\n") }
      end

      return analysis
    end


    def detailed_log(file_name = "detailed.log")
      File.open( file_name, "w") do |file|  

        file.puts "Correct groups"
        file.puts "--------------"
        file.puts

        for group in self.correct_groups
          file.puts "#{group.unparse_to_tagged} => #{group.unparse_to_actual}"
        end

        file.puts

        file.puts "InCorrect groups"
        file.puts "--------------"
        file.puts

        for group in self.incorrect_groups
          file.puts "#{group.unparse_to_tagged} => #{group.unparse_to_actual}"
        end

      end
    end

end

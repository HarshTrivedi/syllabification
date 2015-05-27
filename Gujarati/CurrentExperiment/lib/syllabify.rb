# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__
require  File.join( directory , "calculate_syllabic_scores.rb" )

$experiment_root = File.join( directory , ".." )

correlation_quantities_array = CSV.read( File.join( $experiment_root , "model_files" , "correlation_quantities.csv")  )
$correlation_quantities_hash = {}
for correlation_quantity in correlation_quantities_array
	correlation = correlation_quantity.first
	correlation_quantity.shift
	$correlation_quantities_hash[correlation] = correlation_quantity
end


def hyphenate(word)
	# ap "WORD IS #{word}"
	parts = []
	chars = word.chars.to_a.select{|x| not x.strip.ord == 8204 }
	types = ["non_matra" , "matra" ]
	part = [chars.shift]
	for char in chars
		if is_matra(char)
			part << char
		else
			parts << part
			part = [char]
		end
	end
	parts << part	
	hyphenated_word = parts.map(&:join).join("-")
	return hyphenated_word

end


def syllabify(word)
	hyphenated_word = hyphenate(word)
	parts = hyphenated_word.split("-")
	max_possible_splits = parts.size - 1
	return word if max_possible_splits == 0
	combinations = []
	for i in 1..max_possible_splits
		combination = ( ( 1..(parts.size - 1) ).to_a.combination(i).to_a )
		combinations += combination
	end
	combinations << []
	combination_score_hash = Hash.new

	combinated_words = []
	combinations.each do |combination|
		dash_count = 0
		chars = hyphenated_word.chars.to_a.select{|x| not x.strip.ord == 8204 }
		new_chars = []
		for char in chars
			if char == "-"
				dash_count += 1
				new_chars << "-" if combination.include?(dash_count)				
			else
				new_chars << char
			end
		end
		combinated_word = new_chars.join("")
		combinated_words << combinated_word
		score = get_precomputed_score( hyphenated_word , combinated_word , combination)	
		combination_score_hash[combinated_word] = score
	end
	combinated_words

	return combination_score_hash.to_a.sort_by(&:last).last.first
end


def get_score( hyphenated_word , permutation , combination)	
	parts = hyphenated_word.split("-")
	max_possible_splits = parts.size - 1
	probabilities = []
	for i in 1..max_possible_splits
		pair = parts.slice( i - 1 , 2 )
		if combination.include?(i)
			probabilities << get_pair_coexistence_probability( pair , true)
		else
			probabilities << get_pair_coexistence_probability( pair , false)
		end
	end
	score = probabilities.inject(:*)
	score
end


def get_precomputed_score( hyphenated_word , permutation , combination)
	parts = hyphenated_word.split("-")
	max_possible_splits = parts.size - 1
	probabilities = []
	for i in 1..max_possible_splits
		pair = parts.slice( i - 1 , 2 )
		if combination.include?(i)
			probabilities << $correlation_quantities_hash[pair.join("<=>")][3].to_f rescue 0.0
		else
			probabilities <<  $correlation_quantities_hash[pair.join("<=>")][4].to_f rescue 0
		end
	end
	score = probabilities.inject(:*)
	return score
end

ap syllabify("તકરાર")

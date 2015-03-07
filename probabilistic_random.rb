
require 'awesome_print'



def probabilistic_random(probabilities)
	# probabilistic should be like : [0.30 , 0.40 ,0.20 , 0.10]
	# with 0.30 probability it will generate -> 1
	# with 0.40 probability it will generate -> 2
	# with 0.20 probability it will generate -> 3
	# with 0.10 probability it will generate -> 4
	sum = 0.0
	cumulative_probabilities = probabilities.map{|probability| sum = (sum + probability).round(3) ;sum  }
	rand_value = rand()
	current = 0.0
	index = 0
	cumulative_probabilities[cumulative_probabilities.size - 1] = 1.1
	cumulative_probabilities.each do |x| 
		ans = (((current)..(x)) === (rand_value) )
		current = x 
		return index if ans 
		index += 1
	end
	ap "WARNING : Not chosen according to probability:  #{rand_value} :  #{cumulative_probabilities}"
	return index
end


# ap probabilistic_random([0.30 , 0.40 ,0.20 , 0.10])
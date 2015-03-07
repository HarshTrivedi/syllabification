require 'awesome_print'

# example input : "aeio"
# output:
# [
#     [0] "a-e-i-o",
#     [1] "a-e-io",
#     [2] "a-ei-o",
#     [3] "a-eio",
#     [4] "ae-i-o",
#     [5] "ae-io",
#     [6] "aei-o",
#     [7] "aeio"
# ]



def get_possible_vowel_syllabifications(vowel_cluster)
	vowels = vowel_cluster.split("")
	perms = [vowels.shift]
	for vowel in vowels
		temp_perms = perms.dup
		perms = []
		for perm in temp_perms
			temp = perm.dup;temp += "-#{vowel}" ;perms << temp
			temp = perm.dup ; temp += " #{vowel}" ;perms << temp
		end
		perms.map!{|perm| perm.gsub(/ / , "")}
	end
	return perms
end


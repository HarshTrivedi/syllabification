
def is_vowel(char)
 	not char.gsub(/[aeiou]/).to_a.empty?
end

def is_consonant(char)
 	not char.gsub(/[^aeiou]/).to_a.empty?
end


def hyphenate(word)
	parts = []
	chars = word.split("")
	types = ["vowel" , "consonant"]
	types.reverse! if not eval("is_#{types.first}(chars.first)")
	part = []
	for char in chars
		if not eval("is_#{types.first}(char) ")
			types.reverse!	
			parts << part
			part = [char]
		else
			part << char
		end
	end
	parts << part
	
	hyphenated_word = parts.map(&:join).join("-")
	return hyphenated_word
end


word = "cry"
hyphenated_word = hyphenate(word)
hyphenated_word.split("-").select{|split| not split[0].match(/[aeiou]/).to_a.empty?}
clusters = hyphenated_word.split("-")
vowel_clusters = hyphenated_word.split("-").select{|split| not split[0].match(/[aeiou]/).to_a.empty?}

vowel_clusters_starting_indices = []
traversed = 0
clusters.each_with_index do |cluster , i|
	if not cluster.match(/[aeiou]/).to_a.empty?
		vowel_clusters_starting_indices << traversed
	end
	traversed += cluster.size
end

first_vowel_index = vowel_clusters_starting_indices.first
last_vowel_index = vowel_clusters_starting_indices.last


if vowel_clusters_starting_indices.size <= 1
	hyphenated_word = word
else
	pre = word.slice(0 , first_vowel_index + 1)
	post = word.slice( last_vowel_index , word.size - last_vowel_index)
	mid = (word.slice(first_vowel_index + 1 , last_vowel_index - first_vowel_index - 1))
	hyphenated_word = word
	mid = hyphenate(mid)
	hyphenated_word = [pre , mid , post ].join("-")
end
	


puts hyphenated_word




require 'csv'
require 'awesome_print'

word_syllabifications = CSV.read("normalized_tagged-data_92000.csv")

vowel_cluster_syllabification_freqs = Hash.new(0)

for word_syllabification in word_syllabifications
	word , syllabification = word_syllabification
	syllables = syllabification.split("-")

end


def has_vowel_digram_cluster?(word)
	not word.match(/[^aeiou\b][aeiou][aeiou][^aeiou\b]/).to_a.empty?
end

def has_vowel_trigram_cluster?(word)
	not word.match(/[^aeiou\b][aeiou][aeiou][aeiou][^aeiou\b]/).to_a.empty?
end

def has_vowel_quadgram_cluster?(word)
	not word.match(/[^aeiou\b][aeiou][aeiou][aeiou][aeiou][^aeiou\b]/).to_a.empty?
end

word_syllabifications_with_vowel_digram_clusters = word_syllabifications.select{|word_syllabification|  has_vowel_digram_cluster?(word_syllabification[0]) }
word_syllabifications_with_vowel_trigram_clusters = word_syllabifications.select{|word_syllabification|  has_vowel_trigram_cluster?(word_syllabification[0]) }
word_syllabifications_with_vowel_quadgram_clusters = word_syllabifications.select{|word_syllabification|  has_vowel_quadgram_cluster?(word_syllabification[0]) }


for word_syllabification in word_syllabifications_with_vowel_digram_clusters
	word , syllabification = word_syllabification
	vowel_digram = word.gsub(/[aeiou][aeiou]/).to_a.first
	vowel_diagram_syllabification = syllabification.gsub(/[aeiou]-?[aeiou]/).to_a.first
	ap "#{word}  #{syllabification}  #{vowel_digram} #{vowel_diagram_syllabification}" if vowel_diagram_syllabification.nil?
	vowel_cluster_syllabification_freqs["#{vowel_digram}:#{vowel_diagram_syllabification}"] +=  1

end

for word_syllabification in word_syllabifications_with_vowel_trigram_clusters
	word , syllabification = word_syllabification
	vowel_trigram = word.gsub(/[aeiou][aeiou][aeiou]/).to_a.first
	vowel_trigram_syllabification = syllabification.gsub(/[aeiou]-?[aeiou]-?[aeiou]/).to_a.first
	vowel_cluster_syllabification_freqs["#{vowel_trigram}:#{vowel_trigram_syllabification}"] +=  1
end

for word_syllabification in word_syllabifications_with_vowel_quadgram_clusters
	word , syllabification = word_syllabification
	vowel_quadgram = word.gsub(/[aeiou][aeiou][aeiou][aeiou]/).to_a.first
	vowel_quadgram_syllabification = syllabification.gsub(/[aeiou]-?[aeiou]-?[aeiou]-?[aeiou]/).to_a.first
	vowel_cluster_syllabification_freqs["#{vowel_quadgram}:#{vowel_quadgram_syllabification}"] +=  1
end


vowel_cluster_syllabifications = []
vowel_cluster_syllabification_freqs.each do |key , val|
	vowel_cluster , vowel_cluster_syllabification =  key.split(":")
	freq = val
	vowel_cluster_syllabifications << [vowel_cluster , vowel_cluster_syllabification , freq]
end


vowel_cluster_syllabifications.sort_by!(&:first)
CSV.open('vowel_cluster_syllabification_freqs.csv', 'w') do |csv_object|
  vowel_cluster_syllabifications.to_a.each do |row_array|
    csv_object << row_array
  end
end

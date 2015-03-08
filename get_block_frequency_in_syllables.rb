require 'csv'
require 'awesome_print'

syllables_frequencies = CSV.read("list_of_syllables_from_tagged-data.csv")
syllables = syllables_frequencies.map(&:first)

# ap syllables

alphabets = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
alphabet_clusters = alphabets.repeated_combination(1).to_a.map(&:join) + alphabets.repeated_combination(2).to_a.map(&:join) + alphabets.repeated_combination(3).to_a.map(&:join) + alphabets.repeated_combination(4).to_a.map(&:join)
alphabet_cluster_frequency_hash = Hash.new(0)

for alphabet_cluster in alphabet_clusters
	# ap alphabet_cluster
	count = syllables.count{ |syllable| not syllable[alphabet_cluster].nil? }
	alphabet_cluster_frequency_hash[alphabet_cluster] += count
end

# ap alphabet_cluster_frequency_hash

CSV.open('block_frequency_in_syllables.csv', 'w') do |csv_object|
  alphabet_cluster_frequency_hash.to_a.each do |row_array|
    csv_object << row_array
  end
end







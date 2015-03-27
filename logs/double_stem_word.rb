require 'csv'
require 'awesome_print'

$prefix_frequencies = CSV.read("prefix_freqs_92000.csv")
$prefix_frequencies = $prefix_frequencies.select{|x| x.last.to_i > 100}
$prefix_frequencies_hash =  Hash[*$prefix_frequencies.flatten(1)]

$suffix_frequencies = CSV.read("suffix_freqs_92000.csv")
$suffix_frequencies = $suffix_frequencies.select{|x| x.last.to_i > 100}

$suffix_frequencies_hash =  Hash[*$suffix_frequencies.flatten(1)]


word = "incarnation"


def split_suffix(word)
	suffix = $suffix_frequencies.select{|suffix|  not word.match(/#{suffix[0]}$/).to_a.empty? }.sort_by{|x| x[0]}.last.first rescue ""
	word.gsub!(/#{suffix}$/ , "") if not suffix.empty?
	return suffix
end


def split_prefix(word)
	prefix = $prefix_frequencies.select{|prefix|  not word.match(/^#{prefix[0]}/).to_a.empty? }.sort_by{|x| x[0]}.last.first rescue ""
	word.gsub!(/^#{prefix}/ , "") if not prefix.empty?
	return prefix
end

# suffix = split_suffix(word)
# prefix = split_prefix(word)


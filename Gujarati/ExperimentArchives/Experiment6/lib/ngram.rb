# encoding: UTF-8
require 'bundler/setup'
Bundler.require

words = CSV.read(File.join( Bundler.root , "TaggedData" , "ChooseNextIterationWords" , "grand_word_list.csv")).flatten(1)

def ngram(word , n); word.chars.each_cons(n).to_a.map(&:join); end
def compare_upto_ngrams(word1 , word2 , n)
	answer = 0
	(2..n).each{|i| answer += ( i * (( ngram(word1 , i) & ngram(word2 , i) ).size)) }
	answer
end

def get_top_similars(words , test_word , n)
	word_scores = words.map{|word| [ word , compare_upto_ngrams( word , test_word , 4)]  }.sort_by{|x| - x.last}.take(n)
	word_scores.map(&:first)
end

get_top_similars( words.take(10000) , "કાર" , 10)


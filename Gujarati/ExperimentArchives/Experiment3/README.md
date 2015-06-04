# Experiment 2 (notes)
---

* Maximum Probabilistic model 
* Probability = product of probabilities of each each constituent syllable
* And probability of constituent syllable is its number of existence in corpus
* These probabilities are pre-computed and stored in directory for model_files/

###Results
---

##### Without Prefix - Suffix 

* Correct Words: 1729  / 6491  (26.63 %)
* Correct Chars: 29417 / 35444 (82.99 %)

##### With Prefix - Suffix 

* Correct Words: 4444  / 6491  (68.46 %)
* Correct Chars: 32928 / 35444 (92.90 %)

###Observations

* This approach fails heavily since: In contranst to English, where number of syllables were predefined, here its is not predeterminable. Hence Number of multiplicative factors (eg: x * y * z ... etc) would not be known in advance and hence permutation having maximum number of splits would always have maximum calculated probability ( completely wrong! )
* However previous way of calculating probabilites (product of probabilities of keeping / not keeping dashes) is more appropriate for Gujarati. But in this approach, some times a permutation is selected which has an illegal syllable present in it. So before assigning score to a permutation, it should be checked if it contains illegal syllable. And if yes, then assign 0. 
* This should be the next experiment!


# Experiment 5 (notes)
---

* Maximum Probabilistic model 
* Probability = same as experiment 1
* These probabilities are pre-computed and stored in directory for model_files/
* Everything is same as experiment 4
* Difference is training and test data set :
	* Training is original 6 K dataset (of 1st iteration)
    * Test is new 4 K dataset tagged manually (of 2nd iteration)

###Results
---

##### Without Prefix - Suffix 

* Correct Words: 2104  / 3795  (55.44 %)
* Correct Chars: 18945 / 21214 (89.34 %)


##### With Prefix - Suffix 

* Correct Words: 2523  / 3795  (66.48 %)
* Correct Chars: 19462 / 21214 (91.74 %)


###Observations

* The word level performance (with prefix-suffix) has dropped from about 92 % to 66 % when test data is completely different from training data.
* But good things is difference of performance in with / without prefix-suffix algorithm implying its usefullness.

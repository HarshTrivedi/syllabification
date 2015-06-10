# Experiment 7 (notes)
---

* CRF based
* Based on ruby-crf project
* Training data is i2 (10 K)

###Results
---
#### (1) [2 featured] Train ( all 10 K) ; Test  ( all 10  K)

* Correct Words: 10249  / 10305  (99.45 %)
* Correct Chars: 56623 / 56683   (99.89 %)


#### (2) [1 featured] 10 fold Cross Validate 

* Correct Words: 54983 / 56597 (97.14 %)
* Correct Chars: 9058 / 10310  (87.85 %)


#### (2) [2 featured] 10 fold Cross Validate 

* Correct Words: 55214 / 56704 (97.14 %)
* Correct Chars: 9162 / 10310  (88.86 %)

###Observations

* CRF happens to performs best. 
* Difficult to find loopholes. 
* Not sure if combining it with prefix-suffix will improves its already so good performance or not. 
* Need to check failure cases for the same.

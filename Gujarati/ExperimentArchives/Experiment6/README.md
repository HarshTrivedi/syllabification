# Experiment 6 (notes)
---

* Experiment same as (Exp 4) 
* But training and testing are altered

###Results
---
#### (1) Train ( all 10 K) ; Test  ( new 4  K)

* Correct Words: 3466  / 3795  (91.33 %)
* Correct Chars: 20825 / 21214 (98.16 %)

#### (2) Train ( all 10 K) ; Test  ( all 10  K)

* Correct Words: 9155  / 10296  (88.91 %)
* Correct Chars: 55080 / 56633 (97.25 %)

#### (3) Train ( all 10 K) ; Test  ( old 6  K)

* Correct Words: 5650  / 6510  (86.78 %)
* Correct Chars: 34304 / 35544 (96.51 %)

###Observations

* Even though we have added 4 K more of data, no difference is observed on performance.
* This also means that since Full Train-Test is giving same results so the new 4 K data set that has been created is in sink with our old 6 K dataset.

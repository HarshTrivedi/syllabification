# Experiment 2 (notes)
---

* Prefix-Suffix stripping + Maximum Probabilistic model 
* Probability = product of probabilities of each "-" being present / absent
* These probabilities are pre-computed and stored in directory for model_files/
* Similarly matrices for prefix/suffix probabilites are also pre-computed and stored in model_files/ directory


###Results
---

* Correct Words: 5738  / 6491  (88.39 %)
* Correct Chars: 34418 / 35444 (97.10 %)


###Observations

* Probability calculation is not as we used to do in English context
* Iterative Prefix-Suffix can be used to improved performance.



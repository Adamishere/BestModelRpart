# BestModelRpart
Function to select the best decision tree model based on the 1-SE decision rule.

# Problem
We wanted to explore the predictive and descriptive power of CART decisions trees as a way to inform a larger data process. As an Apriori assumption, based on our data process, there are +20 unique segments of the data that would need their own individual model. We need a quicker way to produce and reviewing decision tree models.

# Solution
This wrapper function utilized the R package "rpart" to build the decision tree and automatically pare it down to its optimal size (based on the 1-SE rule). In the process, it also produces addition fit diagnostics and image of the trimmed tree as saved output. 

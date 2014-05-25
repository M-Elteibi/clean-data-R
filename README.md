Getting and Cleaning Data Course Project

The code attached called run_analysis.R download clean and summarise 
data from http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The code selects variables as decribed in the project. i.e. only variables that are means or standard deviations.

The combined dataset of train and test that contains these select variables is called 
req_data

This dataset in then summarised by computing the average of each variable by subject and activity. these results are saved in the dataset summ_set

A note: this code does not require any manual intervention.
it saves the zip file, extracts it and does the cleaning.

This code was written on a linux machine (no issues because of this should arrise)
 



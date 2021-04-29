# ESC403 Project

## Project Members
- Alessandro De Luca
- Jessy J. Duran Ramirez
- Michael Suter 

# Analysing the Covid-19 measurement's a government takes based on tweets and their sentiment

## Introduction
The goal of this work is to analyse the possible impact of different factors to the decision making of a governments  
related to COVID-19 mitigation measures.  
The two factors we are analysing are:  
- Daily/Weekly COVID-19 cases
- General public's opinion on the matter (Tweets)

## Datasets Used
- Tweets:
    - https://www.kaggle.com/gpreda/covid19-tweets
    - https://www.kaggle.com/smid80/coronavirus-covid19-tweets-late-april
    - https://www.kaggle.com/smid80/coronavirus-covid19-tweets-early-april

- COVID-19 Cases: https://www.kaggle.com/gpreda/coronavirus-2019ncov
- Mitigation Measures:
    - https://www.kaggle.com/davidoj/covid19-national-responses-dataset
    - https://www.kaggle.com/barun2104/government-measures-to-combat-covid19
    - https://www.kaggle.com/paultimothymooney/covid19-containment-and-mitigation-measures
    - https://www.kaggle.com/gustavomodelli/covid-community-measures

## Questions
- Is there any relationship between the pandemic course and the sentiments from the tweets? 
- Is there any forecast possible based on tweet sentiments for the pandemic development:  
    neutral tweets no change in trend of pandemic course, negative tweets worse pandemic course  
    and positive tweets better pandemic course?
- Or is the sentiment of the people influenced based on the pandemic course? 
- Does the relationship of sentiments and pandemic course differ in the 3 countries (or regions)? 
- Are the two months April and August comparable ?
 
## Analysis
Analysed countries (as of now):
- Switzerland (CH)
- Germany (DE)
- Italy (IT)
  
Data Analysis & Processing:
1.	Clean the dataset and filter for the three countries 
2.	Exploratory data analysis (EDA) to conduct summary statistics and check for correlation
3.	Sentiment analysis & modification of sentiment analysis for other languages (Italian and German): 
    - Tokenization (segregation into words)
    - Cleaning (removing the special characters)
    - Removing Stop words (preposition, auxiliary verbs, etc.) 
    - Classification of words (+1: positive, -1 negative, 0: neutral)
    - Apply supervised algorithm for classification (train model with word or lexicons, and test on the analysis statement)
    - Calculate sentiment of statement (look at polarity) 
4.	Categorization of mitigation measures (response variable) into strict, medium, and light
5.	Predictive modelling of mitigation measure based on sentiment and pandemic course
    - Importantly the response and predictors are polytomous variables (>2 possible categories)
    - Possible machine learning models: 
        - Logistic regression
        - Artificial neural network
6.	If time: temporal analysis of response changes (i.e., first wave, second wave) using the same predictors


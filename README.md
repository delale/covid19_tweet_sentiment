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
    ⇒ combined into `covid19_tweets.csv`.  
  
- COVID-19 Cases: https://www.kaggle.com/gpreda/coronavirus-2019ncov  ⇒ `covid-19-all.csv`    

- Mitigation Measures: https://www.kaggle.com/barun2104/government-measures-to-combat-covid19

## Questions
- Is there any relationship between the pandemic course and the sentiments from the tweets? 
- Does the sentiment of the general public influence governmental decisions on mitigation measures?
- Does the relationship of sentiments and pandemic course differ in the 4 countries (or regions)? 
- Are the two months April and August comparable?
 
## Analysis
*Analysed countries*:
- United Kingdom (UK)
- Germany (DE)
- Switzerland (CH)
- Italy (IT)
  
*Analysed Timeframes*:
- April
- August  
This is due to the limiting dates on the tweets dataset.

*Data Analysis & Processing*:
1.	Clean the dataset and filter for the three countries 
2.	Sentiment analysis (there is no need for modifications for non-English countries as most tweets are in English): 
    - Tokenization (segregation into words)
    - Cleaning (removing the special characters)
    - Removing Stop words (preposition, auxiliary verbs, etc.) 
    - Classification of words (+1: positive, -1 negative, 0: neutral)
    - Apply supervised algorithm for classification (train model with word or lexicons, and test on the analysis statement)
    - Calculate sentiment of statement (look at polarity)
3.  - Timeseries analysis of daily COVID-19 cases ⇒ moving average used as predictor in the model 
4.	Inferential modelling of mitigation measure based on sentiment and pandemic course
    - Importantly the response and predictors are polytomous variables (>2 possible categories)
    - Possible machine learning models: 
        - Logistic regression ✔
        - Artificial neural network ❌
5.	If time: temporal analysis of response changes (i.e., first wave, second wave) using the same predictors.

*Packages used*: (?)

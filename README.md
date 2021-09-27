# ESC403 Project University of Zurich

## Project Members
- Alessandro De Luca
- Jessy J. Duran Ramirez
- Michael Suter 

# Analysing the Covid-19 measurement's a government takes based on tweets and their sentiment

## Introduction
The goal of this work is to analyse the possible impact of different factors to the decision making of a governments  
related to COVID-19 mitigation measures.  
The two factors we are analysing are:  
- Daily/Weekly COVID-19 measures (confirmed cases, deaths, recovered)
- General public's opinion on the matter (Tweets)

## Datasets Used
- Tweets:
    - https://www.kaggle.com/gpreda/covid19-tweets
    - https://www.kaggle.com/smid80/coronavirus-covid19-tweets-late-april
    - https://www.kaggle.com/smid80/coronavirus-covid19-tweets-early-april  
  
- COVID-19 Cases: https://www.kaggle.com/gpreda/coronavirus-2019ncov

- Mitigation Measures: https://www.kaggle.com/barun2104/government-measures-to-combat-covid19

## Questions & Predictions
- Q1: Is there any relationship between the mitigation measures and the sentiments from the tweets? 
- Q2: Does the relationship of sentiments and mitigation category differ between the 4 countries?
- Q3: Are the two months April and August comparable?   
   
-----------------------------------------------------------------------------------------------------------------------------  
  
- P1: We think that there should be no influence of the general public's sentiment on the governmental mitigation measures
- P2: We don't think that there should be a difference between the 4 analysed countries
- P3: We don't think there would be differences between the two months
 
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
    - Cleaning (removing the special characters)
    - Removing Stop words (preposition, auxiliary verbs, etc.) 
    - Tokenization (segregation into words)
    - Apply lexicon-based classification of words (+1: positive, -1 negative, 0: neutral)
    - Calculate sentiment of statement (look at polarity)
3.  - Timeseries analysis of daily COVID-19 cases ⇒ moving average used as predictor in the model 
4.	Inferential modelling of mitigation measure based on sentiment and pandemic course
    - Importantly the response and predictors are polytomous variables (>2 possible categories)
    - Possible machine learning models: 
        - Multinomial regression ✔
        - Artificial neural network ❌
5.	If time: temporal analysis of response changes (i.e., first wave, second wave) using the same predictors.  
  
*Coded in R:*
R versions 4.0.4 (2021-02-15) & 4.0.5 (2021-03-31) -- "Shake and Throw"  
Copyright (C) 2021 The R Foundation for Statistical Computing  
Platform: x86_64-apple-darwin17.0  & x86_64-w64-mingw32/x64 (64-bit)  
  
*R Packages used*:
- VIM
- tidyverse
- nnet
- ggfortify
- gridExtra
- stargazer
- knitr
- GGally
- corrplot
- textcat
- ggplot2
- ggcharts
- scales
- reshape2
- lubridate
- tm
- syuzhet
- tidytext
- dplyr
- tidyr
- wordcloud
- wordcloud2

rm(list = ls())

library(tidyverse)

## load data ####
covid19_tweets <- read.csv("covid19_tweets.csv", comment.char = "#")
glimpse(covid19_tweets)
covid19_tweets$date <- as.Date(covid19_tweets$date)
covid19_tweets$is_retweet <- as.logical(covid19_tweets$is_retweet)
covid19_tweets$user_friends <- as.numeric(covid19_tweets$user_friends)
covid19_tweets$user_followers <- as.numeric(covid19_tweets$user_followers)
covid19_tweets$user_favourites <- as.numeric(covid19_tweets$user_favourites)
covid19_tweets$user_verified <- as.logical(covid19_tweets$user_verified)

head(covid19_tweets)
summary(covid19_tweets)

## select only Switzerland, Germany, Italy ####
# using regex and str_detect from stringr

tweetsCH <- filter(
    covid19_tweets,
    str_detect(user_location, regex("Switzerland", ignore_case = TRUE)) |
        str_detect(user_location, regex("Schweiz", ignore_case = TRUE))
)

tweetsDE <- filter(
    covid19_tweets,
    str_detect(user_location, regex("Germany", ignore_case = TRUE)) |
        str_detect(user_location, regex("Deutschland", ignore_case = TRUE))
)

tweetsIT <- filter(
    covid19_tweets,
    str_detect(user_location, regex("Italy", ignore_case = TRUE)) |
        str_detect(user_location, regex("Italia", ignore_case = TRUE))
)

## clean the tweet location ####
tweetsCH$user_location <- rep("CH", nrow(tweetsCH))
tweetsIT$user_location <- rep("IT", nrow(tweetsIT))
tweetsDE$user_location <- rep("DE", nrow(tweetsDE))

## filtered set ####
filtered_tweets <- rbind(tweetsCH, tweetsDE, tweetsIT)
filtered_tweets$user_location <- as.factor(filtered_tweets$user_location)
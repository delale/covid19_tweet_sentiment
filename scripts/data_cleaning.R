rm(list = ls())

library(tidyverse)

## covid cases data cleaning ####
## TODO: subset data for the countries needed (UK, DE)

covid_all <- read.csv("datasets/original/covid-19-all.csv")
glimpse(covid_all)

# column cleaning
covid_all <- select(covid_all, -c(Latitude, Longitude))

# select countries (UK, Germany) #
covid_all_filtered <- filter(
    covid_all,
    Country.Region %in% c("United Kingdom", "Germany")
)
glimpse(covid_all_filtered)
covid_all_filtered$Date <- as.Date(covid_all_filtered$Date)

# write.csv(covid_all_filtered, "datasets/covid_cases_filtered.csv")


## tweets ####

covid_tweets <- read.csv("datasets/original/covid19_tweets.csv")
glimpse(covid_tweets)

# some refactoring
covid_tweets$date <- as.Date(covid_tweets$date)
covid_tweets$is_retweet <- as.logical(covid_tweets$is_retweet)
covid_tweets$user_friends <- as.numeric(covid_tweets$user_friends)
covid_tweets$user_followers <- as.numeric(covid_tweets$user_followers)
covid_tweets$user_favourites <- as.numeric(covid_tweets$user_favourites)
covid_tweets$user_verified <- as.logical(covid_tweets$user_verified)

glimpse(covid_tweets)

# select only UK and DE #
# using regex and str_detect from stringr

# cleaning for regex: space padding for exact match
covid_tweets$user_location <- paste(" ", covid_tweets$user_location, " ")

countries_uk <- c(
    " United Kingdom ",
    " Britain ",
    " Wales ",
    " Northern Ireland ",
    " Scotland ",
    " England ",
    " UK ",
    " GB "
)
countries_de <- c(" Germany ", " Deutschland ")

# filtering
tweets_uk <- data.frame()

for (country in countries_uk) {
    tweets_uk <- rbind(
        tweets_uk,
        filter(
            covid_tweets,
            str_detect(user_location, regex(country, ignore_case = TRUE))
        )
    )
}

tweets_de <- data.frame()

for (country in countries_de) {
    tweets_de <- rbind(
        tweets_de,
        filter(
            covid_tweets,
            str_detect(user_location, regex(country, ignore_case = TRUE))
        )
    )
}

# refactor tweets location in new var
tweets_uk <- cbind(
    tweets_uk,
    data.frame(loc_short = as.factor(rep("UK", nrow(tweets_uk))))
)
tweets_de <- cbind(
    tweets_de,
    data.frame(loc_short = as.factor(rep("DE", nrow(tweets_de))))
)

# complete df
filtered_tweets <- rbind(tweets_uk, tweets_de)
# write.csv(filtered_tweets, "datasets/filtered_tweets.csv")
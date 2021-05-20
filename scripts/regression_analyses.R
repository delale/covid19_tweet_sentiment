################################################################################
## Author: Alessandro De Luca
## Description: Multinomial regression analysis using sentiment polarity of tweets
## and average of daily covid measures as explanatory variables of tmitigation
################################################################################

## Q1: Is there any relationship between the mitigation measures
##      and the sentiments from the tweets? 
## Q2: Does the relationship of sentiments and covid measures
##      (confirmed cases, deaths, recovered)
##      differ in the 4 countries? 
## Q3: Are the two months April and August comparable?

## prelims ####
rm(list = ls())

library(tidyverse)
library(nnet)
library(ggfortify)
library(gridExtra)

## load the data ####
cases <- read.csv("datasets/measurementrs_Covid_all_Countries&dates.csv")
sentiment <- read.csv("datasets/tweets_sentiment_scores_method.csv")
mitigation <- read.csv("datasets/filtered_Mitigation_gov1.csv")


## cleaning of the data ####

# cases #
glimpse(cases)
cases$Date <- as.Date(cases$Date, format = "%Y-%m-%d")

anyNA(cases)
which(is.na(cases$Recovered) | is.na(cases$Deaths) | is.na(cases$Confirmed))
cases[which(is.na(cases$Recovered) | is.na(cases$Deaths)), ]
## results from beginning of the pandemic measuring
## -> not important for the time period we are analysing

# change the var names
names(cases) <- c(
    "ID", "country", "province", "confirmed",
    "recovered", "deaths", "date"
)

# coding locations
cases$location_code <- with(
    cases,
    ifelse(country == "United Kingdom", "UK",
        ifelse(country == "Germany", "DE",
            ifelse(country == "Italy", "IT",
                "CH"
            )
        )
    )
)
cases$location_code <- as.factor(cases$location_code)

# sum together the province cases
cases <- cases %>%
    select(-province) %>%
    group_by(location_code, date) %>%
    summarise(
        confirmed = sum(confirmed),
        recovered = sum(recovered),
        deaths = sum(deaths)
    ) %>%
    ungroup()


# sentiment #
glimpse(sentiment)
sentiment$date <- as.Date(sentiment$date, format = "%Y-%m-%d")
sentiment$user_location <- as.factor(sentiment$user_location)
names(sentiment)[1] <- "ID"
anyNA(sentiment)
# filter for only NRC method
sentiment <- filter(sentiment, method == "NRC")

# mitigation #
glimpse(mitigation)
names(mitigation) <- tolower(names(mitigation))
names(mitigation)[1] <- "ID"
mitigation$date_implemented <- as.Date(mitigation$date_implemented,
    format = "%d-%m-%Y"
)
mitigation$entry_date <- as.Date(mitigation$entry_date,
    format = "%d-%m-%Y"
)

# coding locations
mitigation$location_code <- with(
    mitigation,
    ifelse(country == "United Kingdom", "UK",
        ifelse(country == "Germany", "DE",
            ifelse(country == "Italy", "IT",
                "CH"
            )
        )
    )
)
mitigation$location_code <- as.factor(mitigation$location_code)

anyNA(mitigation)
colnames(mitigation)[apply(mitigation, 2, anyNA)]

any(mitigation$date_implemented > mitigation$entry_date)
mitigation[
    which(mitigation$date_implemented > mitigation$entry_date),
    c("date_implemented", "entry_date")
] # I think this is due to errors in the entry_date insertion or
# inaccuracies from the source for the date_implemented

# substitute NA date_implemented w/ entry_date
mitigation <- mitigation %>%
    mutate(date_implemented = as.Date(
        ifelse(is.na(date_implemented), entry_date, date_implemented),
        origin = "1970-01-01"
    ))

# create categories based on category and introduction/phase-out
mitigation <- mitigation %>%
    mutate(category_log = ifelse(
        log_type == "Introduction / extension of measures",
        paste("INTRO -", category),
        paste("END -", category)
    ))
mitigation$category_log <- as.factor(mitigation$category_log)
mitigation$category_log <- relevel(mitigation$category_log,
    ref = "INTRO - Social distancing"
) # reference level

# filter for April and August
max(mitigation$date_implemented) # unfortunately no data for August
mitigation <- filter(
    mitigation,
    between(mitigation$date, as.Date("2020-03-29"), as.Date("2020-05-01"))
)

## quick preliminary EDA ####
ggplot(data = cases, aes(x = date, y = confirmed)) +
    geom_point() +
    facet_wrap(~location_code)


ggplot(data = sentiment, aes(x = date, y = net_sentiment, colour = date)) +
    geom_point() +
    facet_wrap(~user_location)

table(mitigation$category_log, mitigation$location_code)


## preparing for analysis ####
# get a weekly mean before each measure for Q1 & Q2
df_ana_1 <- data.frame()
for (i in seq_len(nrow(mitigation))) {
    mit_row <- mitigation[i, ]

    start_date <- mit_row$date_implemented - 7
    end_date <- mit_row$date_implemented
    temp_cases <- cases %>%
        filter(
            location_code == mit_row$location_code,
            between(date, start_date, end_date)
        ) %>%
        summarise(
            confirmed_mean = mean(confirmed),
            deaths_mean = mean(deaths),
            recovered_mean = mean(recovered)
        )

    temp_sentiment <- sentiment %>%
        filter(
            user_location == mit_row$location_code,
            between(date, start_date, end_date)
        ) %>%
        summarise(sentiment_mean = mean(net_sentiment))

    temp_df <- cbind(mit_row, temp_cases, temp_sentiment)
    temp_df <- temp_df %>%
        select(
            location_code, date_implemented, category_log,
            confirmed_mean, deaths_mean, recovered_mean, sentiment_mean
        )

    df_ana_1 <- rbind(df_ana_1, temp_df)
}
glimpse(df_ana_1)

# gather the data for Q3
temp_sentiment <- sentiment %>%
    group_by(user_location, date) %>%
    summarise(sentiment_mean = mean(net_sentiment)) %>%
    ungroup()
head(temp_sentiment)

df_ana_2 <- inner_join(
    x = cases, y = temp_sentiment,
    by = c("date" = "date", "location_code" = "user_location")
)

# month category
df_ana_2 <- df_ana_2 %>%
    mutate(month = ifelse(
        between(date, as.Date("2020-03-20"), as.Date("2020-05-10")),
        "April", "August"
    ))
df_ana_2$month <- as.factor(df_ana_2$month)

# polarity category
summary(df_ana_2$sentiment_mean)
hist(df_ana_2$sentiment_mean)

df_ana_2 <- df_ana_2 %>%
    mutate(sentiment_polarity = ifelse(
        sentiment_mean < -0.33, "NEG",
        ifelse(sentiment_mean > 0.33, "POS", "NEU")
    ))
df_ana_2$sentiment_polarity <- as.factor(df_ana_2$sentiment_polarity)
glimpse(df_ana_2)


## analysis Q1 ####
# look for correlation between covariates
cor(df_ana_1[, 4:7]) # normal correlation only between covid measures

# visualization of the relationship
ggplot(data = df_ana_1, aes(x = sentiment_mean, y = category_log)) +
    geom_boxplot() +
    geom_point()

# model
multi_mod <- multinom(
    category_log ~ confirmed_mean + deaths_mean
        + recovered_mean + sentiment_mean,
    data = df_ana_1
)
(s1 <- summary(multi_mod))
coefs1 <- coef(multi_mod)
# coefficients on the odds-scale
exp(coefs1)

# statistical test (Z-test)
z <- s1$coefficients / s1$standard.error
p <- pnorm(abs(z), lower.tail = FALSE) * 2
p ## some extreme z scores => p-values = 0
# compute p-values on log-scale
p_extr <- log(2) + pnorm(abs(z), lower.tail = FALSE, log.p = TRUE)
p_extr


## analysis Q2 ####
# visualization of the relationships
plt1 <- ggplot(data = df_ana_1, aes(
    x = sentiment_mean, y = category_log, color = location_code
)) +
    geom_boxplot() +
    geom_point() +
    theme(legend.position = "none")
plt2 <- ggplot(data = df_ana_1, aes(
    x = confirmed_mean, y = category_log, color = location_code
)) +
    geom_boxplot() +
    geom_point() + # there is some sort of interaction
    ylab("") +
    theme(axis.text.y = element_blank())
grid.arrange(plt1, plt2, ncol = 2)

# model
multi_mod_2 <- multinom(category_log ~ (confirmed_mean + deaths_mean
    + recovered_mean + sentiment_mean) * location_code,
data = df_ana_1
)
(s2 <- summary(multi_mod_2))
coefs2 <- coef(multi_mod_2)
# only concerned w/ location_code and interaction terms
coefs2 <- coefs2[, c(1, 6:20)]
# on the odds-scale
exp(coefs2)

# statistical test (Z-test)
z2 <- coefs2 / s2$standard.error[, c(1, 6:20)]
p2 <- pnorm(abs(z2), lower.tail = FALSE) * 2
p2 ## again some very extreme p-values


## analysis Q3 ####
## this analysis will only be looking at the relationship between
## sentiment and covid measures because of lack of data for August mitigations

# variable exploration
ggplot(
    data = gather(df_ana_2[, 3:6], key = "variable", value = "value"),
    aes(x = value)
) +
    geom_histogram(bins = 15) +
    facet_wrap(~variable, scales = "free") ## slightly bimodal?

# log transform
df_ana_2 <- df_ana_2 %>%
    group_by(month) %>%
    mutate(
        log_confirmed = log(confirmed),
        log_deaths = log(deaths),
        log_recovered = log(recovered)
    )
ggplot(
    data = gather(df_ana_2[, c(6, 9:11)], key = "variable", value = "value"),
    aes(x = value)
) +
    geom_histogram(bins = 15) +
    facet_wrap(~variable, scales = "free") ## better

# visualization of the relationship
# linear
plt1 <- ggplot(data = df_ana_2, aes(
    x = log_confirmed, y = sentiment_mean, color = month
)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) + # maybe slight interaction
    theme(legend.position = "none")
# multinomial
plt2 <- ggplot(data = df_ana_2, aes(
    x = confirmed, y = sentiment_polarity, color = month
)) +
    geom_boxplot() +
    geom_point() # maybe some interaction
grid.arrange(plt1, plt2, ncol = 2)

# linear model
lm_mod <- lm(sentiment_mean ~ (log_confirmed + log_recovered
    + log_deaths) * month,
data = df_ana_2
)
autoplot(lm_mod) # model diagnostics -> normality assumption?

# model summary
summary(lm_mod)

# multinomial model
multi_mod_3 <- multinom(sentiment_polarity ~
(confirmed + recovered + deaths) * month,
data = df_ana_2
)
(s3 <- summary(multi_mod_3))
coefs3 <- coef(multi_mod_3)
exp(coefs3)

# statistical test (Z-test)
z3 <- coefs3 / s3$standard.error
p3 <- pnorm(abs(z3), lower.tail = FALSE) * 2
p3 ## again some very extreme p-values


## figures ####
# figure 1 #
newdf_1 <- data.frame(
    sentiment_mean = seq(
        from = min(df_ana_1$sentiment_mean),
        to = max(df_ana_1$sentiment_mean),
        length.out = 500
    ),
    confirmed_mean = rep(mean(df_ana_1$confirmed_mean), 500),
    deaths_mean = rep(mean(df_ana_1$deaths_mean), 500),
    recovered_mean = rep(mean(df_ana_1$recovered_mean), 500)
)
prob_1 <- predict(multi_mod, newdata = newdf_1, type = "probs", se = TRUE)
predicted_probs_1 <- cbind(newdf_1, prob_1)

# to long format
long_predicted_probs_1 <- gather(predicted_probs_1,
    key = "Mitigation",
    value = "probability",
    -sentiment_mean, -confirmed_mean, -deaths_mean, -recovered_mean,
    factor_key = TRUE
)

ggplot(
    data = long_predicted_probs_1,
    aes(x = sentiment_mean, y = probability, color = Mitigation)
) +
    geom_line(size = 1.3) +
    scale_color_brewer(type = "div") +
    xlab("Sentiment (mean over 1 week period before measure)") +
    ylab("P(category_log = Y)") +
    theme_bw()


# figure 2 #
newdf_2 <- data.frame(
    sentiment_mean = seq(
        from = min(df_ana_1$sentiment_mean),
        to = max(df_ana_1$sentiment_mean),
        length.out = 500
    ),
    location_code = as.factor(rep(levels(df_ana_1$location_code), 500)),
    confirmed_mean = seq(
        from = min(df_ana_1$confirmed_mean),
        to = max(df_ana_1$confirmed_mean),
        length.out = 500
    ),
    deaths_mean = rep(mean(df_ana_1$deaths_mean), 500),
    recovered_mean = rep(mean(df_ana_1$recovered_mean), 500)
)
prob_2 <- predict(multi_mod_2, newdata = newdf_2, type = "probs", se = TRUE)
predicted_probs_2 <- cbind(newdf_2, prob_2)

# to long format
long_predicted_probs_2 <- gather(predicted_probs_2,
    key = "Mitigation",
    value = "probability",
    -sentiment_mean, -confirmed_mean, -deaths_mean, -recovered_mean,
    -location_code,
    factor_key = TRUE
)

ggplot(
    data = long_predicted_probs_2,
    aes(x = sentiment_mean, y = probability, color = Mitigation)
) +
    geom_line(size = 1.3) +
    scale_color_brewer(type = "div") +
    xlab("Sentiment (mean over 1 week periob before measure)") +
    theme_bw() +
    facet_wrap(~location_code, scales = "free")


# figure 3 & 4 #
newdf_3_lm <- data.frame(
    log_confirmed = seq(
        from = min(df_ana_2$log_confirmed),
        to = max(df_ana_2$log_confirmed), length.out = 100
    ),
    log_deaths = rep(mean(df_ana_2$log_deaths), 100),
    log_recovered = rep(mean(df_ana_2$log_recovered), 100),
    month = as.factor(rep(levels(df_ana_2$month), 100))
)
pred_sentiment <- predict(lm_mod, newdata = newdf_3_lm, interval = "confidence")
predicted_3_lm <- cbind(newdf_3_lm, pred_sentiment)
predicted_3_lm <- rename(predicted_3_lm, sentiment = fit)

ggplot(
    predicted_3_lm,
    aes(x = log_confirmed, y = sentiment, color = month)
) +
    geom_point(alpha = .5) +
    geom_smooth(mapping = aes(ymin = lwr, ymax = upr), stat = "identity") +
    theme_bw()

newdf_3_multinom <- data.frame(
    confirmed = seq(
        from = min(df_ana_2$confirmed),
        to = max(df_ana_2$confirmed), length.out = 100
    ),
    deaths = rep(mean(df_ana_2$deaths), 100),
    recovered = rep(mean(df_ana_2$recovered), 100),
    month = as.factor(rep(levels(df_ana_2$month), 100))
)
prob_sentiment <- predict(multi_mod_3,
    newdata = newdf_3_multinom,
    type = "probs", se = TRUE
)
predicted_probs_3 <- cbind(newdf_3_multinom, prob_sentiment)

# to long format
long_predicted_probs_3 <- gather(predicted_probs_3,
    key = "Sentiment_Polarity",
    value = "probability",
    -confirmed, -deaths, -recovered, -month,
    factor_key = TRUE
)
ggplot(
    data = long_predicted_probs_3,
    aes(x = confirmed, y = probability, color = month)
) +
    geom_line(size = 1.3) +
    xlab("") +
    ylab("P(sentiment_polarity = Y)") +
    theme_bw() +
    facet_wrap(~Sentiment_Polarity, scales = "free")
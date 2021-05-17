################################################################################
## Author: Alessandro De Luca
## Description: Timeseries of covid-19 cases EDA
################################################################################

rm(list = ls())

## libraries ####
library(tidyverse)
library(forecast)
library(tseries)


# cases <- read.csv("datasets/measurementrs_Covid_all")
#  cases <- read.csv("datasets/new_filtered_cases.csv")
cases <- read.csv("datasets/measurementrs_Covid_all_Countries&dates.csv")
glimpse(cases)

## clean the data ####
cases <- select(cases, -X) # remove X column (index from cleaning)

# coding locations
cases$location_code <- with(
    cases,
    ifelse(Country.Region == "United Kingdom", "UK",
        ifelse(Country.Region == "Germany", "DE",
            ifelse(Country.Region == "Italy", "IT",
                "CH"
            )
        )
    )
)
cases$location_code <- as.factor(cases$location_code)
cases$Date <- as.Date(cases$Date) # Date as dates

# sum together the province cases
cases <- cases %>%
    group_by(location_code, Date) %>%
    select(-Province.State) %>%
    summarise(
        Confirmed = sum(Confirmed),
        Recovered = sum(Recovered),
        Deaths = sum(Deaths)
    ) %>%
    ungroup()

## for analysis ####
# different countries
confirmed_uk <- cases %>%
    filter(location_code == "UK") %>%
    select(Date, Confirmed)
confirmed_ch <- cases %>%
    filter(location_code == "CH") %>%
    select(Date, Confirmed)
confirmed_it <- cases %>%
    filter(location_code == "IT") %>%
    select(Date, Confirmed)
confirmed_de <- cases %>%
    filter(location_code == "DE") %>%
    select(Date, Confirmed)

## time-series obj ####
# freq. = 7 (daily samples, nat. period 1 week)
ts_confirmed_uk <- ts(data = confirmed_uk, frequency = 7)
ts_confirmed_ch <- ts(data = confirmed_ch, frequency = 7)
ts_confirmed_de <- ts(data = confirmed_de, frequency = 7)
ts_confirmed_it <- ts(data = confirmed_it, frequency = 7)

{
    par(mfrow = c(2, 2))
    plot(ts_confirmed_uk[, 2], main = "UK", ylab = "Confirmed")
    plot(ts_confirmed_ch[, 2], ylab = "Confirmed", main = "CH")
    plot(ts_confirmed_it[, 2], ylab = "Confirmed", main = "IT")
    plot(ts_confirmed_de[, 2], ylab = "Confirmed", main = "DE")
}

# check seasonality ####
fit_uk <- stl(ts_confirmed_uk[, 2], s.window = "periodic")
fit_ch <- stl(ts_confirmed_ch[, 2], s.window = "periodic")
fit_de <- stl(ts_confirmed_de[, 2], s.window = "periodic")
fit_it <- stl(ts_confirmed_it[, 2], s.window = "periodic")


# ggseasonplot(ts_confirmed_uk[, 2], year.labels = TRUE)
plot(fit_uk)
plot(fit_de)
plot(fit_it)
plot(fit_ch)

## stationarity test ####
adf.test(ts_confirmed_uk[, 2])
adf.test(ts_confirmed_ch[, 2])
adf.test(ts_confirmed_de[, 2])
adf.test(ts_confirmed_it[, 2])

## get stationary ts ####
uk_stat_ts <- diff(
    ts_confirmed_uk[, 2],
    lag = frequency(ts_confirmed_uk[, 2]),
    differences = 3
)
it_stat_ts <- diff(
    ts_confirmed_it[, 2],
    lag = frequency(ts_confirmed_it[, 2]),
    differences = 3
)
de_stat_ts <- diff(
    ts_confirmed_de[, 2],
    lag = frequency(ts_confirmed_de[, 2]),
    differences = 3
)
ch_stat_ts <- diff(
    ts_confirmed_ch[, 2],
    lag = frequency(ts_confirmed_ch[, 2]),
    differences = 3
)

{
    par(mfrow = c(2, 2))
    plot(uk_stat_ts, main = "UK")
    plot(de_stat_ts, main = "DE")
    plot(it_stat_ts, main = "IT")
    plot(ch_stat_ts, main = "CH")
}

## stationarity test ####
adf.test(uk_stat_ts)
adf.test(de_stat_ts)
adf.test(it_stat_ts)
adf.test(ch_stat_ts)

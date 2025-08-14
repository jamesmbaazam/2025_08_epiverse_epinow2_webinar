library(EpiNow2)
library(data.table)
library(ggplot2)

options(mc.cores = min(parallel::detectCores(), 4))

cases <- data.table::copy(example_confirmed)
## calculate weekly sum
cases[, confirm := data.table::frollsum(confirm, 7)]
## limit to dates once a week
cases_weekly <- cases[seq(7, nrow(cases), 7)]

saveRDS(cases_weekly, "data/example_weekly_data.rds")

# Visualise the data
weekly_cases_plot <- ggplot(cases_weekly, aes(x = date, y = confirm)) +
    geom_col() +
    scale_y_continuous(labels = scales::comma) +
    scale_x_date(date_labels = "%b-%d", date_breaks = "2 weeks") +
    labs(title = "Weekly case counts", x = "Date", y = "Cases") +
    theme_minimal()

if (interactive()) print(weekly_cases_plot)

# Create compatible data for EpiNow2
cases_weekly_complete <- fill_missing(
    cases_weekly,
    missing_dates = "accumulate",
    missing_obs = "accumulate"
)

head(cases_weekly_complete)

# set an example generation time. In practice this should use an estimate
# from the literature or be estimated from data
generation_time <- Gamma(
    shape = Normal(1.3, 0.3),
    rate = Normal(0.37, 0.09),
    max = 14
)
# set an example incubation period. In practice this should use an estimate
# from the literature or be estimated from data
incubation_period <- LogNormal(
    meanlog = Normal(1.6, 0.06),
    sdlog = Normal(0.4, 0.07),
    max = 14
)
# set an example reporting delay. In practice this should use an estimate
# from the literature or be estimated from data
reporting_delay <- LogNormal(mean = 2, sd = 1, max = 10)

# set an example prior for the reproduction number
rt_prior <- LogNormal(mean = 2, sd = 0.1)

# for more examples, see the "estimate_infections examples" vignette
weekly_est <- estimate_infections(
    cases_weekly_complete,
    generation_time = gt_opts(generation_time),
    delays = delay_opts(incubation_period + reporting_delay),
    rt = rt_opts(prior = rt_prior)
)

saveRDS(weekly_est, "data/example_estimate_infections_weekly.rds")

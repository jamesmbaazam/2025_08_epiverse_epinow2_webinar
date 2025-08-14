# load packages
library(data.table)
library(EpiNow2)

# Setup cores for parallel processing
options(mc.cores = min(parallel::detectCores(), 4))

# make some example prevalence data
cases <- example_confirmed
cases <- as.data.table(cases)[, primary := confirm]
# Assume that only 30 percent of cases are reported
cases[, scaling := 0.3]
# Parameters of the assumed log normal delay distribution
cases[, meanlog := 1.6][, sdlog := 0.8]

# Simulate secondary cases
es_cases_prevalence <- convolve_and_scale(cases, type = "prevalence")

# Remove the confirm column as not needed
es_cases_prevalence[, confirm := NULL]

# Rearrange column names
setcolorder(
    es_cases_prevalence,
    c("date", "primary", "secondary",
      setdiff(names(es_cases_prevalence), c("date", "primary", "secondary")))
)

saveRDS(es_cases_prevalence, "data/example_secondary_prevalence_data.rds")

# fit model to example prevalence data
es_prev <- estimate_secondary(
    es_cases_prevalence[1:100],
    secondary = secondary_opts(type = "prevalence"),
    obs = obs_opts(
        week_effect = FALSE,
        scale = Normal(mean = 0.4, sd = 0.1)
    )
)

saveRDS(es_prev, "data/example_estimate_secondary_prevalence.rds")

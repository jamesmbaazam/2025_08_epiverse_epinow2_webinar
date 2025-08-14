# load packages
library(data.table)
library(EpiNow2)

# Setup cores for parallel processing
options(mc.cores = min(parallel::detectCores(), 4))

#### Incidence data example ####

# make some example secondary incidence data
cases <- example_confirmed
cases <- as.data.table(cases)[, primary := confirm]
# Assume that only 40 percent of cases are reported
cases[, scaling := 0.4]
# Parameters of the assumed log normal delay distribution
cases[, meanlog := 1.8][, sdlog := 0.5]

# Simulate secondary cases
es_cases_incidence <- convolve_and_scale(cases, type = "incidence")

# Remove the confirm column as not needed
es_cases_incidence[, confirm := NULL]

# Rearrange column names
setcolorder(
    es_cases_incidence,
    c("date", "primary", "secondary",
      setdiff(names(es_cases_incidence), c("date", "primary", "secondary")))
)

saveRDS(es_cases_incidence, "data/example_secondary_incidence_data.rds")
#
# fit model to example data specifying a weak prior for fraction reported
# with a secondary case
es_inc <- estimate_secondary(
    data = es_cases_incidence[1:60],
    secondary = secondary_opts(type = "incidence"),
    obs = obs_opts(
        scale = Normal(mean = 0.2, sd = 0.2),
        week_effect = FALSE
    )
)
saveRDS(es_inc, "data/example_estimate_secondary_incidence_res.rds")

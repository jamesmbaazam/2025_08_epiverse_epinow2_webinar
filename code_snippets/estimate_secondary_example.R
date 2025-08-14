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
cases <- convolve_and_scale(cases, type = "incidence")
#
# fit model to example data specifying a weak prior for fraction reported
# with a secondary case
inc <- estimate_secondary(
    cases[1:60],
    obs = obs_opts(
        scale = Normal(mean = 0.2, sd = 0.2),
        week_effect = FALSE
    )
)

saveRDS(prev, "data/example_estimate_secondary_incidence.rds")

# load the EpiNow2 package
library(EpiNow2)

# Setup cores for parallel processing
options(mc.cores = min(parallel::detectCores(), 4))

# get example case counts
reported_cases <- example_confirmed[1:60]

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
def <- estimate_infections(
    data = reported_cases,
    generation_time = gt_opts(generation_time),
    delays = delay_opts(incubation_period + reporting_delay),
    rt = rt_opts(prior = rt_prior)
)

# save the output
saveRDS(def, "data/example_estimate_infections.rds")

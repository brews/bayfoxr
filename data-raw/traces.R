# Read clean and write MCMC trace draw files for internal package use.

require("devtools")

traces <- list()
trace_files <- Sys.glob("*_trace.csv")
for (fl in trace_files) {
    basename <- unlist(strsplit(fl, '_trace'))[1]
    df <- read.csv(fl, check.names = FALSE)
    traces[[basename]] <- df
}
devtools::use_data(traces, compress = "bzip2", internal = TRUE, overwrite = TRUE)

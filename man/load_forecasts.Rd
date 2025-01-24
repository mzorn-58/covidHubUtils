% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_forecasts.R
\name{load_forecasts}
\alias{load_forecasts}
\title{Load all available forecasts submitted around forecast dates from Zoltar,
local Zoltar module or local hub repo.}
\usage{
load_forecasts(
  models = NULL,
  dates = NULL,
  date_window_size = 0,
  locations = NULL,
  types = NULL,
  targets = NULL,
  source = "zoltar",
  hub_repo_path,
  local_zoltpy_path,
  zoltar_sqlite_file,
  data_processed_subpath = "data-processed/",
  as_of = NULL,
  hub = c("US", "ECDC", "FluSight"),
  verbose = TRUE
)
}
\arguments{
\item{models}{Character vector of model abbreviations.
Default all models that submitted forecasts meeting the other criteria.}

\item{dates}{The forecast date of forecasts to retrieve.
A vector of one or more Date objects or character strings in format “YYYY-MM-DD”
Default to all valid forecast dates.}

\item{date_window_size}{The number of days across each date in \code{dates} parameter to
look for the most recent forecasts.
Default to 0, which means to only look at the \code{dates} parameter only.}

\item{locations}{a vector of strings of fips code or CBSA codes or location names,
such as "Hampshire County, MA", "Alabama", "United Kingdom".
A US county location names must include state abbreviation.
Default to \code{NULL} which would include all locations with available forecasts.}

\item{types}{Character vector specifying type of forecasts to load: \code{"quantile"}
and/or \code{"point"}. Default to all valid forecast types.}

\item{targets}{character vector of targets to retrieve, for example
\code{c('1 wk ahead cum death', '2 wk ahead cum death')}.
Default to \code{NULL} which stands for all valid targets.}

\item{source}{string specifying where forecasts will be loaded from: one of
\code{"local_hub_repo"}, \code{"zoltar"} and \code{"local_zoltar"}. Default to \code{"zoltar"}.}

\item{hub_repo_path}{path to local clone of the forecast hub
repository}

\item{local_zoltpy_path}{path to local clone of zolpy repository.
Only needed when \code{source} is \verb{"local_zoltar}.}

\item{zoltar_sqlite_file}{path to local sqlite file,
either a relative path w.r.t. \code{local_zoltpy_path} or an absolute path.
Only needed when \code{source} is \verb{"local_zoltar}.}

\item{data_processed_subpath}{folder within the hub_repo_path that contains
forecast submission files.  Default to \code{"data-processed/"}, which is
appropriate for the covid19-forecast-hub repository.}

\item{as_of}{character for date time to load forecasts submitted as of this time from Zoltar.
Ignored if \code{source = "local_hub_repo"}.
It could use the format of one of the three examples:
\verb{"2021-01-01", "2020-01-01 01:01:01" and "2020-01-01 01:01:01 UTC"}.
If you would like to set a timezone, it has to be UTC now.
If not, helper function will append the default timezone to your input based on \code{hub} parameter.
Default to NULL to load the latest version.}

\item{hub}{character vector, where the first element indicates the hub
from which to load forecasts. Possible options are \code{"US"}, \code{"ECDC"} and \code{"FluSight"}.}

\item{verbose}{logical to print out diagnostic messages. Default is \code{TRUE}.}
}
\value{
data.frame with columns \code{model}, \code{forecast_date}, \code{location}, \code{horizon},
\code{temporal_resolution}, \code{target_variable}, \code{target_end_date}, \code{type}, \code{quantile}, \code{value},
\code{location_name}, \code{population}, \code{geo_type}, \code{geo_value}, \code{abbreviation}
}
\description{
\itemize{
\item If \code{date_window_size} is 0, this function returns all available forecasts
submitted on every day in \code{dates}.

\item If\code{date_window_size}  is not 0, this function will look for the latest
forecasts that are submitted within window size for each day in  \code{dates}.

\item If \code{source} is \code{local_zoltar}, a valid sqlite3 object is required.
Please follow the instruction in \code{\link[=load_forecasts_local_zoltar]{load_forecasts_local_zoltar()}} to set up
required environment.

}
}
\examples{
# Load forecasts from US forecast hub
# This call only loads the latest forecast submitted on "2021-07-26" in
# a 12-day window w.r.t "2021-7-30".
load_forecasts(
  models = "COVIDhub-ensemble",
  dates = "2021-07-30",
  date_window_size = 11,
  locations = "US",
  types = c("point", "quantile"),
  targets = paste(1:4, "wk ahead inc case"),
  source = "zoltar",
  verbose = FALSE,
  as_of = NULL
)

# Load forecasts from ECDC forecast hub
# This function call loads the latest forecasts in each 2-day window
# w.r.t "2021-03-08" and "2021-07-27".
load_forecasts(
  models = "ILM-EKF",
  hub = c("ECDC", "US"),
  dates = c("2021-03-08", "2021-07-27"),
  date_window_size = 1,
  locations = "GB",
  targets = paste(1:4, "wk ahead inc death"),
  source = "zoltar"
)
}

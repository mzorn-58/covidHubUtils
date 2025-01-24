% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_latest_forecasts_repo.R
\name{load_latest_forecasts_repo}
\alias{load_latest_forecasts_repo}
\title{Load the most recent forecasts of all that were submitted
on \code{forecast_dates} from a local clone of \code{reichlab/covid19-forecast-hub} repo.}
\usage{
load_latest_forecasts_repo(
  file_path,
  models = NULL,
  forecast_dates,
  locations = NULL,
  types = NULL,
  targets = NULL,
  hub = c("US", "ECDC"),
  verbose = TRUE
)
}
\arguments{
\item{file_path}{path to the data-processed folder within a local clone of the hub repo}

\item{models}{Character vector of model abbreviations.
Default all models that submitted forecasts meeting the other criteria.}

\item{forecast_dates}{A 2 dimensional list of forecast dates to retrieve forecasts.
This function will return the latest forecasts
for each sub-list of dates.
Default to  \code{NULL} which would include all valid forecast dates.
The function will throw an error if all dates in this parameter are invalid forecast dates.}

\item{locations}{a vector of strings of fips code or CBSA codes or location names,
such as "Hampshire County, MA", "Alabama", "United Kingdom".
A US county location names must include state abbreviation.
Default to \code{NULL} which would include all locations with available forecasts.}

\item{types}{Character vector specifying type of forecasts to load: \code{"quantile"}
and/or \code{"point"}. Default to all valid forecast types.}

\item{targets}{character vector of targets to retrieve, for example
\code{c('1 wk ahead cum death', '2 wk ahead cum death')}.
Default to \code{NULL} which stands for all valid targets.}

\item{hub}{character vector indicating the hub from which to load forecasts.
Possible options are \code{"US"}, \code{"ECDC"} and \code{"FluSight"}.}

\item{verbose}{logical to print out diagnostic messages. Default is \code{TRUE}}
}
\description{
This function will drop rows with NULLs in value column.
}
\details{
\Sexpr[results=rd, stage=render]{lifecycle::badge("deprecated")}
Please use \code{\link[=load_forecasts_repo]{load_forecasts_repo()}} instead.
}

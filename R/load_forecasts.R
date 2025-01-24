#' Load all available forecasts submitted around forecast dates from Zoltar,
#' local Zoltar module or local hub repo.
#'
#' @description
#' \itemize{
#'   \item If `date_window_size` is 0, this function returns all available forecasts
#' submitted on every day in `dates`.
#'
#'   \item If`date_window_size`  is not 0, this function will look for the latest
#' forecasts that are submitted within window size for each day in  `dates`.
#'
#'   \item If `source` is `local_zoltar`, a valid sqlite3 object is required. 
#' Please follow the instruction in [load_forecasts_local_zoltar()] to set up 
#' required environment.
#' 
#' }
#' 
#' @param models Character vector of model abbreviations.
#' Default all models that submitted forecasts meeting the other criteria.
#' @param dates The forecast date of forecasts to retrieve.
#' A vector of one or more Date objects or character strings in format “YYYY-MM-DD”
#' Default to all valid forecast dates.
#' @param date_window_size The number of days across each date in `dates` parameter to
#' look for the most recent forecasts.
#' Default to 0, which means to only look at the `dates` parameter only.
#' @param locations a vector of strings of fips code or CBSA codes or location names,
#' such as "Hampshire County, MA", "Alabama", "United Kingdom".
#' A US county location names must include state abbreviation. 
#' Default to `NULL` which would include all locations with available forecasts.
#' @param types Character vector specifying type of forecasts to load: `"quantile"`
#' and/or `"point"`. Default to all valid forecast types.
#' @param targets character vector of targets to retrieve, for example
#' `c('1 wk ahead cum death', '2 wk ahead cum death')`.
#' Default to `NULL` which stands for all valid targets.
#' @param source string specifying where forecasts will be loaded from: one of
#' `"local_hub_repo"`, `"zoltar"` and `"local_zoltar"`. Default to `"zoltar"`.
#' @param hub_repo_path path to local clone of the forecast hub
#' repository
#' @param local_zoltpy_path path to local clone of zolpy repository.
#' Only needed when `source` is `"local_zoltar`.
#' @param zoltar_sqlite_file path to local sqlite file, 
#' either a relative path w.r.t. `local_zoltpy_path` or an absolute path.
#' Only needed when `source` is `"local_zoltar`.
#' @param data_processed_subpath folder within the hub_repo_path that contains
#' forecast submission files.  Default to `"data-processed/"`, which is
#' appropriate for the covid19-forecast-hub repository.
#' @param as_of character for date time to load forecasts submitted as of this time from Zoltar.
#' Ignored if `source = "local_hub_repo"`.
#' It could use the format of one of the three examples:
#' `"2021-01-01", "2020-01-01 01:01:01" and "2020-01-01 01:01:01 UTC"`.
#' If you would like to set a timezone, it has to be UTC now.
#' If not, helper function will append the default timezone to your input based on `hub` parameter.
#' Default to NULL to load the latest version.
#' @param hub character vector, where the first element indicates the hub
#' from which to load forecasts. Possible options are `"US"`, `"ECDC"` and `"FluSight"`.
#' @param verbose logical to print out diagnostic messages. Default is `TRUE`.
#'
#' @return data.frame with columns `model`, `forecast_date`, `location`, `horizon`,
#' `temporal_resolution`, `target_variable`, `target_end_date`, `type`, `quantile`, `value`,
#' `location_name`, `population`, `geo_type`, `geo_value`, `abbreviation`
#'
#' @examples
#' # Load forecasts from US forecast hub
#' # This call only loads the latest forecast submitted on "2021-07-26" in
#' # a 12-day window w.r.t "2021-7-30".
#' load_forecasts(
#'   models = "COVIDhub-ensemble",
#'   dates = "2021-07-30",
#'   date_window_size = 11,
#'   locations = "US",
#'   types = c("point", "quantile"),
#'   targets = paste(1:4, "wk ahead inc case"),
#'   source = "zoltar",
#'   verbose = FALSE,
#'   as_of = NULL
#' )
#'
#' # Load forecasts from ECDC forecast hub
#' # This function call loads the latest forecasts in each 2-day window
#' # w.r.t "2021-03-08" and "2021-07-27".
#' load_forecasts(
#'   models = "ILM-EKF",
#'   hub = c("ECDC", "US"),
#'   dates = c("2021-03-08", "2021-07-27"),
#'   date_window_size = 1,
#'   locations = "GB",
#'   targets = paste(1:4, "wk ahead inc death"),
#'   source = "zoltar"
#' )
#' @export
load_forecasts <- function(models = NULL,
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
                           verbose = TRUE) {

  # validate source
  source <- match.arg(source, choices = c("local_hub_repo", "zoltar", "local_zoltar"))
  
  hub <- match.arg(hub,
                   choices = c("US", "ECDC", "FluSight"),
                   several.ok = TRUE
  )
  
  if (!is.null(dates) & date_window_size > 0) {
    # 2d array
    all_forecast_dates <- purrr::map(
      dates, function(date) {
        return(as.Date(date) + seq(from = -date_window_size, to = 0))
      }
    )
  } else {
    all_forecast_dates <- dates
  }

  if (source == "local_hub_repo") {
    # validate hub repo path
    if (missing(hub_repo_path) | !dir.exists(hub_repo_path)) {
      stop("Error in load_forecasts: Please provide a valid path to hub repo.")
    }

    if (!is.null(as_of)) {
      if (as_of != Sys.Date()) {
        stop("Error in load_forecasts: as_of parameter is not available for `local_hub_repo` source now.")
      }
    }

    # path to data-processed folder in hub repo
    data_processed <- file.path(hub_repo_path, data_processed_subpath)

    forecasts <- load_forecasts_repo(
      file_path = data_processed,
      models = models,
      forecast_dates = all_forecast_dates,
      locations = locations,
      types = types,
      targets = targets,
      verbose = verbose,
      hub = hub
    )
  } else if (source == "zoltar") {
    if (hub[1] == "FluSight") {
      stop("Error in load_forecasts: FluSight data is not available on zoltar.")
    }
    forecasts <- load_forecasts_zoltar(
      models = models,
      forecast_dates = all_forecast_dates,
      locations = locations,
      types = types,
      targets = targets,
      as_of = as_of,
      verbose = verbose,
      hub = hub
    )
  } else if (source == "local_zoltar") {
    if (hub[1] == "FluSight") {
      stop("Error in load_forecasts: FluSight data is not available in local zoltar.")
    }
    
    if (missing(local_zoltpy_path) | missing(zoltar_sqlite_file)) {
      stop("Error in load_forecasts: Please provide local_zoltpy_path and zoltar_sqlite_file.")
    }

    forecasts <- load_forecasts_local_zoltar(
      models = models,
      forecast_dates = all_forecast_dates,
      locations = locations,
      types = types,
      targets = targets,
      as_of = as_of,
      verbose = verbose,
      hub = hub,
      local_zoltpy_path = local_zoltpy_path,
      zoltar_sqlite_file = zoltar_sqlite_file
    )
  }

  return(forecasts)
}

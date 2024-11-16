#' @title initialize_forecast_environment
#' @description Creates necessary directory structure and copies configuration files for FLARE setup, overwriting existing files
#' @param lake_directory Path where the forecast environment should be set up. If NULL, uses a temp directory
#' @param local_fork_directory Path to your local FLAREr fork/repository
#' @return list containing paths to created directories
#' @importFrom utils read.csv
#' @export
initialize_forecast_environment <- function(lake_directory = NULL, local_fork_directory = NULL) {
  
  # Input validation
  if(is.null(local_fork_directory)) {
    stop("Please provide the path to your local FLAREr repository")
  }
  
  if(!dir.exists(local_fork_directory)) {
    stop("The provided FLAREr repository path does not exist")
  }
  
  # If lake_directory not provided, use temp directory
  if(is.null(lake_directory)) {
    lake_directory <- normalizePath(tempdir(), winslash = "/")
  }
  
  # If lake_directory exists, remove it entirely
  if(dir.exists(lake_directory)) {
    unlink(lake_directory, recursive = TRUE)
    message(paste("Existing directory removed:", lake_directory))
  }
  
  # Create necessary directories
  dirs_to_create <- c(
    file.path(lake_directory, "configuration/default"),
    file.path(lake_directory, "targets"),
    file.path(lake_directory, "drivers")
  )
  
  lapply(dirs_to_create, dir.create, recursive = TRUE, showWarnings = FALSE)
  
  # Define files to copy with their source and destination paths
  files_to_copy <- list(
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/configure_flare.yml"),
      to = file.path(lake_directory, "configuration/default/configure_flare.yml")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/configure_run.yml"),
      to = file.path(lake_directory, "configuration/default/configure_run.yml")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/parameter_calibration_config.csv"),
      to = file.path(lake_directory, "configuration/default/parameter_calibration_config.csv")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/states_config.csv"),
      to = file.path(lake_directory, "configuration/default/states_config.csv")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/depth_model_sd.csv"),
      to = file.path(lake_directory, "configuration/default/depth_model_sd.csv")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/observations_config.csv"),
      to = file.path(lake_directory, "configuration/default/observations_config.csv")
    ),
    list(
      from = file.path(local_fork_directory, "inst/extdata/configuration/default/glm3.nml"),
      to = file.path(lake_directory, "configuration/default/glm3.nml")
    )
  )
  
  # Copy individual files
  for(file in files_to_copy) {
    if(!file.exists(file$from)) {
      warning(paste("Source file not found:", file$from))
      next
    }
    file.copy(from = file$from, to = file$to, overwrite = TRUE)
  }
  
  # Copy directories
  dirs_to_copy <- c("targets", "drivers")
  for(dir in dirs_to_copy) {
    from_path <- file.path(local_fork_directory, "inst/extdata", dir)
    if(!dir.exists(from_path)) {
      warning(paste("Source directory not found:", from_path))
      next
    }
    file.copy(from = from_path,
              to = lake_directory,
              recursive = TRUE,
              overwrite = TRUE)
  }
  
  # Verify setup by checking a sample file
  target_file <- file.path(lake_directory, "targets/fcre/fcre-targets-insitu.csv")
  if(file.exists(target_file)) {
    message("Setup completed successfully. Sample data preview:")
    if(requireNamespace("readr", quietly = TRUE)) {
      print(head(readr::read_csv(target_file, show_col_types = FALSE)))
    } else {
      print(head(read.csv(target_file)))
    }
  } else {
    warning("Setup completed but sample target file not found. Please verify your setup manually.")
  }
  
  message(paste("Forecast environment initialized at:", lake_directory))
  
  # Return paths
  return(list(
    lake_directory = lake_directory,
    config_directory = file.path(lake_directory, "configuration/default"),
    targets_directory = file.path(lake_directory, "targets"),
    drivers_directory = file.path(lake_directory, "drivers")
  ))
}
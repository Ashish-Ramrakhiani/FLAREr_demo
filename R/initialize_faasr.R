initialize_faasr <- function(config) {
  
  .faasr <- list(
    DefaultDataStore = "restart",
    DataStores = list()
  )

  if (!is.null(config$s3)) {
    for (datastore_name in names(config$s3)) {

      endpoint_url <- paste0("https://", sub("^[^\\.]+\\.", "", config$s3[[datastore_name]]$endpoint))
      .faasr$DataStores[[datastore_name]] <- list(
        Endpoint = endpoint_url,
        AccessKey = Sys.getenv("AWS_ACCESS_KEY_ID"),
        SecretKey = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
        Bucket = stringr::str_split_fixed(config$s3[[datastore_name]]$bucket, "/", n = 2)[1],
        Region = stringr::str_split_fixed(config$s3[[datastore_name]]$endpoint, pattern = "\\.", n = 2)[1],
        Anonymous = "FALSE"
      )
    }
  }
  
  # Warnings for AWS credentials
  if (Sys.getenv(x = "AWS_ACCESS_KEY_ID") == "" && config$run_config$use_s3 == TRUE) {
    warning(paste0("Use s3 is set to TRUE in the configuration file. ",
                   "AWS_ACCESS_KEY_ID environment variable is not set. S3 can still be used for downloading weather forecasts."))
  }
  
  if (Sys.getenv(x = "AWS_SECRET_ACCESS_KEY") == "" && config$run_config$use_s3 == TRUE) {
    warning(paste0("Use s3 is set to TRUE in the configuration file. ",
                   "AWS_SECRET_ACCESS_KEY environment variable is not set. S3 can still be used for downloading."))
  }
  
  return(invisible(.faasr))
}

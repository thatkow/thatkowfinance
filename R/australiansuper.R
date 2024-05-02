#' @export
download_australiansuper <- function() {
  url = paste0(
    "https://www.australiansuper.com//api/graphs/dailyrates/download/?start=01/07/2008&end=",
    format(Sys.time(), "%d/%m/%Y"),
    "&cumulative=False&superType=super&truncateDecimalPlaces=True&outputFilename=Daily%20Rates%2001%20Jul%202008%20-",
    # "%2001%20May%202024",
    "%20",format(Sys.time(), "%d"),format(Sys.time(), "%b"),"%20",format(Sys.time(), "%Y"),
    ".csv")
  tempfile <- tempfile(fileext = ".csv")
  system(paste0("curl \'",url, "\' > ",tempfile))
  data <- read.csv(tempfile,row.names = 1)
  file.remove(tempfile)
  data
}


#' @export
getDfForField <- function(data,field){
  data.frame(
    date = as.Date(rownames(data)),
    close = dailyRateToSharePrice(data[,field]),
    change = data[,field]
  )
}

#' @export
ema <- function(x,days=9,smoothing=2){
  stopifnot(is.numeric(x), is.numeric(days), is.numeric(smoothing))
  if (length(days) != 1 || ceiling(days != floor(days)) || days <= 1)
    stop("Window length 'n' must be a single integer greater 1.")
  nx <- length(x)
  if (days >= nx)
    stop("Window length 'n' must be greater then length of time series.")
  y <- numeric(nx)

  a <- smoothing/(days + 1)
  y[1] <- x[1]
  for (k in 2:nx) y[k] <- a * x[k] + (1 - a) * y[k - 1]

  return(y)
}

#' @export
dailyRateToSharePrice <- function(daily_change, starting_price = 100){
  price = rep(NA,length(daily_change))
  price[1] = (1+daily_change[1]/100) * starting_price
  daily_change[is.na(daily_change)] = 0.0
  for(i in 2:length(daily_change))
    price[i] = (1+daily_change[i]/100) * price[i-1]
  price
}


#' @export
getMacdDf <- function(data, filt_func = function(dates)dates>="2022-01-01", days = 9, first_ema_n = 12, second_ema_n = 26, smoothing = 2){
  ma_first = ema(x = data$close, days = first_ema_n, smoothing = smoothing)
  ma_second = ema(x = data$close, days = second_ema_n, smoothing = smoothing)
  macd = ma_first - ma_second

  df = data.frame(
    macd = macd,
    signal = ema(x = macd, days = days, smoothing = smoothing),
    price = data$close,
    change = data$change,
    date = data$date
  )[filt_func(data$date),]
  df
}

#' @export
getSignSwitch <- function(arr){
  sign_change_idx = which(diff(sign(arr))!=0)
  action = rep(NA,length(arr))
  action[which(diff(sign(arr))>0)+1] = 1
  action[which(diff(sign(arr))<0)+1] = -1
  action
}


#' @export
getModeChoiceBasedOnMacd <- function(macd_first, macd_second, differential_trigger = 2){
  stopifnot(length(macd_first) == length(macd_second))
  option_setting = rep(NA,length(macd_first))
  option_setting[1] = F
  macd_diff = abs(macd_first - macd_second)
  idx_match = which(macd_diff>differential_trigger)
  if(length(idx_match)>0){
    option_setting[macd_diff>differential_trigger] = sapply(idx_match,function(i){
      if(macd_first[i] > macd_second[i]) F else T
    })
  }
  for(i in which(is.na(option_setting))){
    option_setting[i] = option_setting[i-1]
  }
  option_setting
}

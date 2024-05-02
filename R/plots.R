#' @export
#' @import ggplot2 reshape2
renderInvementSwitchPlot <- function(daily_change_df, first_shares_name, second_shares_name,
                                     test_filt_func = function(dates)dates>"2022-01-01",
                                     macd_factor = 4, differential_trigger = 0.73,
                                     days = 9, first_ema_n = 12, second_ema_n = 26, smoothing = 2
                                     ){
  library(ggplot2)
  library(reshape2)

  test.first = getMacdDf(getDfForField(daily_change_df,first_shares_name),
                         filt_func = test_filt_func,
                         days = days, first_ema_n = first_ema_n, second_ema_n = second_ema_n, smoothing = smoothing
                         )
  test.second = getMacdDf(getDfForField(daily_change_df,second_shares_name),
                          filt_func = test_filt_func,
                          days = days, first_ema_n = first_ema_n, second_ema_n = second_ema_n, smoothing = smoothing
                          )


  is_other = getModeChoiceBasedOnMacd(test.second$macd,test.first$macd,differential_trigger = differential_trigger)
  change = test.first$change
  change[is_other] = test.second$change[is_other]


  df = data.frame(
    date = test.second$date,
    second.macd = test.second$macd,
    first.macd = test.first$macd,
    # first.signal = test.first$signal,
    # second.signal = test.second$signal,
    option = rep(first_shares_name,length(is_other))
  )
  colnames(df) = c("date",
                   paste0(second_shares_name,".macd"),
                   paste0(first_shares_name,".macd"),
                   # paste0(first_shares_name,".signal"),
                   # paste0(second_shares_name,".signal"),
                   "option")
  df$option[is_other] = second_shares_name
  p = ggplot() +
    geom_line(data = melt(df[,!colnames(df)%in%"option"],id.vars = "date"), mapping = aes(x=date, color=variable, y=value)) +
    geom_hline(yintercept = 0)  +
    geom_point(data = df, mapping = aes(x = date, y = 0, color = factor(option)))

  first = tail(dailyRateToSharePrice(daily_change_df[,first_shares_name][test_filt_func(as.Date(rownames(daily_change_df)))]),n=1)
  second = tail(dailyRateToSharePrice(daily_change_df[,second_shares_name][test_filt_func(as.Date(rownames(daily_change_df)))]),n=1)
  change = tail(dailyRateToSharePrice(change),n=1)

  return(list(
    plot = p,
    first_return = first,
    second_return = second,
    change_return = change
  ))


}

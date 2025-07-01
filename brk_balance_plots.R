library(ggplot2)
library(tidyr)
library(quantmod)
library(zoo)

# --- Read & reshape the balance‐sheet CSV ---
raw <- read.csv("brk_balance.csv", check.names = FALSE)
raw$Date <- as.Date(raw$Date, format = "%Y.%m.%d")

# Function to get the most recent available BRK-B price for a given date
get_closest_price <- function(date) {
  # Fetch a 5-day window ending on the given date
  tryCatch({
    prices <- getSymbols("BRK-B", src = "yahoo",
                         from = date - days(5), to = date,
                         auto.assign = FALSE)
    close_price <- Cl(prices)
    # Find latest available closing price on or before the date
    last_price <- last(close_price[index(close_price) <= date])
    as.numeric(last_price)
  }, error = function(e) NA_real_)
}

# Apply the function for each date
raw$StockPrice <- sapply(raw$Date, get_closest_price)
# 1. Compute total shares
raw$total_shares <- raw[["Average equivalent Class A shares outstanding"]] * 1500 +
  raw[["Average equivalent Class B shares outstanding"]]

exclude  <- c(
  "Total liabilities, redeemable noncontrolling interests and shareholders’ equity",
  "Total Insurance and Other",
  "Total Railroad, Utilities and Energy",
  "Total liabilities",
  "Berkshire shareholders’ equity",
  "Total shareholders’ equity",
  "Average equivalent Class A shares outstanding",
  "Average equivalent Class B shares outstanding",
  "total_shares", "ValuePerShare",
  "Berkshire shareholders' equity",
  "Total shareholders' equity",
  "Total liabilities, redeemable noncontrolling interests and shareholders' equity"
)


# Filter out excluded columns
plot_cols <- setdiff(colnames(raw), c("Date", "Item", "StockPrice", exclude))

# 2. Compute the sum of all balance sheet components per row (excluding non-component columns)
component_sum <- rowSums(raw[, plot_cols], na.rm = TRUE)

# 3. Compute intrinsic value per share (millions to units)
raw$ValuePerShare <- round((component_sum * 1e6) / raw$total_shares, 2)

library(ggplot2)
library(tidyr)

long <- pivot_longer(
  raw[, c("Date", plot_cols)],
  cols = all_of(plot_cols),
  names_to = "Component",
  values_to = "Value"
)
raw$PctOver <- round((raw$StockPrice - raw$ValuePerShare) / raw$ValuePerShare * 100, 1)
raw$Label <- paste0(raw$ValuePerShare, " (", raw$PctOver, "%)")
raw$component_sum <- rowSums(raw[, plot_cols], na.rm = TRUE)
raw$offset <- max(raw$component_sum, na.rm = TRUE) * 0.2
raw$Ratio <- raw$StockPrice / raw$ValuePerShare
model <- lm(Ratio ~ Date, data = raw)
fitted_values <- predict(model)
mean_fitted <- mean(fitted_values, na.rm = TRUE)
raw$AdjustedPrice <- round(mean_fitted * raw$ValuePerShare, 2)



# Plot stacked histogram by Date
ggplot(long, aes(x = Date, y = Value, fill = Component)) +
  geom_col(color = "black") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Berkshire Hathaway Balance Sheet Breakdown",
    x = "Date",
    y = "Value (millions USD)",
    fill = NULL
  ) + geom_line(
    data = raw,
    aes(x = Date, y = component_sum),
    color = "black",
    linewidth = 0.8,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = raw,
    aes(x = Date, y = component_sum),
    shape = 21, fill = "white", color = "black", size = 3,
    inherit.aes = FALSE
  ) +
  geom_text(
    data = raw,
    aes(x = Date, y = component_sum + offset, label = Label),
    angle = 90,
    size = 3,
    inherit.aes = FALSE
  ) +
  geom_text(
    data = raw,
    aes(x = Date, y = - offset, label = AdjustedPrice),
    angle = 90,
    size = 3,
    inherit.aes = FALSE
  )+
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5)
  )



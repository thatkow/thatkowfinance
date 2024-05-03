# Australian Super Investment Switch Test

This R package provides functionality for analyzing and visualizing Australian superannuation investment switch data.

## Installation

You can install the package from GitHub using the `devtools` package:

```R
devtools::install_github("thatkow/thatkowfinance")
```


## Usage

```R
library(thatkowfinance)
```

### Example usage

Once installed, you can load the package and start using its functions:

```R
library(thatkowfinance)
australiansuper_df = download_australiansuper()
first_shares_name = "Australian.Shares"
second_shares_name = "International.Shares"
investment_switch_results = renderInvementSwitchPlot(australiansuper_df, first_shares_name, second_shares_name)
plot(investment_switch_results$plot)
message("Returns ",first_shares_name, " ", investment_switch_results$first_return)
message("Returns ",second_shares_name, " ", investment_switch_results$second_return)
message("Returns of switch strategy ", investment_switch_results$change_return)
```

## Docker Image

To quickly try out a Shiny app using this package, you can use the Docker image available on Docker Hub.

```bash
docker run --rm -p 3838:3838 thatkow/australiansuperinvestmentswitchtest
```

This will start a Shiny app that uses the `thatkowfinance` package to analyze and visualize Australian superannuation investment switch data. To open the app, navigate to `http://localhost:3838` in your web browser.





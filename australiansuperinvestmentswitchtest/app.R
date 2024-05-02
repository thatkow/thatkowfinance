library(shiny)
library(thatkowfinance)

australiansuper_df = download_australiansuper()

investment_options = colnames(australiansuper_df)

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Australian Super Investment Strategy Test"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(

      selectInput("first_shares_name",
                  "First Option:",
                  choices = investment_options,
                  selected = "Australian.Shares"),
      selectInput("second_shares_name",
                  "Second Option:",
                  choices = investment_options,
                  selected = "International.Shares"),
      numericInput("first_ema_n",
                   "MACD First Period Days:",
                   min = 1,
                   max = 50,
                   value = 12),
      numericInput("second_ema_n",
                   "MACD Second Period Days:",
                   min = 2,
                   max = 100,
                   value = 26),
      numericInput("days",
                   "MACD Signal Days:",
                   min = 1,
                   max = 50,
                   value = 9),
      numericInput("smoothing",
                   "MACD Smoothing:",
                   min = 1,
                   max = 50,
                   value = 2),
      numericInput("differential_trigger",
                   "Value Difference Trigger:",
                   min = 0,
                   max = 50,
                   value = 0.73),
      dateInput("start_date",
                "Start Date:",
                value = format(Sys.time() - 60*60*24*365*5, "%Y-%m-%d")), # Take last 5 years as default
      dateInput("end_date",
                "End Date:",
                value = format(Sys.time(), "%Y-%m-%d"))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      textOutput("first_summary"),
      textOutput("second_summary"),
      textOutput("change_summary"),
      plotOutput("distPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  first_return = reactiveVal(0)
  second_return = reactiveVal(0)
  change_return = reactiveVal(0)
  first_summary = reactiveVal("")
  second_summary = reactiveVal("")
  change_summary = reactiveVal("")

  output$distPlot <- renderPlot({

    start_date = input$start_date
    end_date = input$end_date
    date_filt_func = function(dates)dates>=start_date & dates<=end_date

    macd_factor = input$macd_factor
    differential_trigger = input$differential_trigger

    investment_switch_results = renderInvementSwitchPlot(daily_change_df = australiansuper_df,
                                                         first_shares_name = input$first_shares_name,
                                                         second_shares_name = input$second_shares_name,
                                                         test_filt_func = date_filt_func,
                                                         macd_factor = macd_factor,
                                                         differential_trigger = differential_trigger,
                                                         first_ema_n = input$first_ema_n,
                                                         second_ema_n = input$second_ema_n,
                                                         smoothing = input$smoothing,
                                                         days = input$days
    )


    first_summary(paste0(input$first_shares_name, " return: ", round(investment_switch_results$first_return,digits = 1)))
    second_summary(paste0(input$second_shares_name, " return: ", round(investment_switch_results$second_return,digits = 1)))
    change_summary(paste0("Strategy return: ", round(investment_switch_results$change_return,digits = 1)))
    investment_switch_results$plot
  })

  output$first_summary = renderText({
    first_summary()
  })

  output$second_summary = renderText({
    second_summary()
  })

  output$change_summary = renderText({
    change_summary()
  })
}

# Run the application
shinyApp(ui = ui, server = server)

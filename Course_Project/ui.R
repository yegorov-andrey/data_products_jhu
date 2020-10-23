library(shiny)
library(plotly)

shinyUI(fluidPage(
        titlePanel("Carbon Dioxide Uptake in Grass Plants"),
        p("Random forest trained on `CO2` data from `datasets` package to recognize plant origin based on the set of predictors."),
        sidebarLayout(
                sidebarPanel(
                        p("This panel allows to specify training settings for the random forest."),
                        sliderInput("train.p", "Training set, %", min=10, max=90, value=60),
                        numericInput("num.trees", "Number of trees", min=1, max=1000, value=10),
                        checkboxGroupInput("predictors", "Predictors:",
                                           c("Treatment - a factor with levels nonchilled chilled"="Treatment",
                                             "conc - ambient carbon dioxide concentrations (mL/L)"="conc",
                                             "uptake - carbon dioxide uptake rates (umol/m^2 sec)"="uptake"),
                                           selected=c("Treatment", "conc", "uptake"))
                ),
                mainPanel(
                        p("Panel below shows predictions on the test set (all the data not used in training): accuracy, sensitivity, specificity and 3d plot."),
                        p("Sensitivity:", style="display: inline"),
                        textOutput('forest.sens', inline=TRUE),
                        br(),
                        p("Specificity:", style="display: inline"),
                        textOutput('forest.spec', inline=TRUE),
                        br(),
                        p("Accuracy:", style="display: inline"),
                        textOutput('forest.auc', inline=TRUE),
                        plotlyOutput('forest.pred'),
                        p("Legend explanation:"),
                        tags$ul(
                                tags$li("Wrong/Correct - prediction match the actual plant origin"), 
                                tags$li("Mississippi/Quebec - the actual plant origin")
                        )
                )
        )
))
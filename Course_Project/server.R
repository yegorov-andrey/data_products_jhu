library(datasets)
library(randomForest)
library(shiny)
library(caret)
library(plotly)

data("CO2")

shinyServer(function(input, output) {
        
        xlim <- range(CO2$conc)
        ylim <- range(CO2$uptake)
        
        train_and_predict <- reactive({
                validate(need(length(input$predictors) > 0,
                              'Select at least one predictor!'))
                
                set.seed(20201023)
                pTraining <- input$train.p / 100
                inTrain <- createDataPartition(CO2$Type, p=pTraining, list=FALSE)
                training <- CO2[inTrain, ]
                testing <- CO2[-inTrain, ]
                
                nt <- input$num.trees
                form <- as.formula(paste0('Type', '~', paste(input$predictors, collapse='+')))
                rf <- randomForest(form, data=training, ntree=nt)
                
                prediction <- predict(rf, testing)
                cm <- confusionMatrix(prediction, factor(testing$Type))
                predright <- testing$Type==prediction
                
                list(testing=testing, prediction=prediction, predright=predright,
                  accuracy=round(cm$overall['Accuracy'], 2),
                  sensitivity=round(cm$byClass['Sensitivity'], 2),
                  specificity=round(cm$byClass['Specificity'], 2))
        })
        
        output$forest.sens <- renderText({train_and_predict()$sensitivity})
        output$forest.spec <- renderText({train_and_predict()$specificity})
        output$forest.auc <- renderText({train_and_predict()$accuracy})

        output$forest.pred <- renderPlotly({
                data <- train_and_predict()$testing
                data$prediction <- train_and_predict()$prediction
                data$predright <- factor(train_and_predict()$predright,
                                         levels=c(FALSE, TRUE),
                                         labels=c('Wrong', 'Correct'))
                plot_ly(data, x=~conc, y=~uptake, z=~Treatment,
                        color=~predright, colors=c('#FF0000', '#00AA00'),
                        type="scatter3d", mode="markers",
                        symbol=~prediction,
                        symbols = c("circle", "square"),
                        marker = list(size = 10,
                                line = list(color = "black", width = 1)
                        )) %>% layout(legend=list(title=list(text='Prediction')))
        })
})
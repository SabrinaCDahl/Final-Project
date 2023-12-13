#ST558 final project Sabrina Dahl
library(shiny)
library(tidyverse)
library(dplyr)
library(caret)

shinyServer(function(input, output, session) {
  #dataset
  hypertension <- read_csv("Hipertension_Arterial_Mexico.csv")
  
  #clean the datasets that will be used in plots on data exploration tab
  hyp <- reactive({
    hypertension %>% 
    group_by(!!sym(input$plot)) %>%
    dplyr::summarise(proportion.hyp = mean(riesgo_hipertension), n = n())
  })
  #create plots for data exploration tab based on variable chosen from "plot" radioButton
  output$barPlot <- renderPlot({
    
    if(input$question == TRUE){
      ggplot(data=hyp, aes(x= !!sym(input$plot), y = proportion.hyp, size=n)) + geom_point() + facet_wrap(~!!sym(input$facet))
    } 
    else if(input$question == FALSE) {
      ggplot(data=hyp, aes(x= !!sym(input$plot), y = proportion.hyp, size=n)) + geom_point() 
    }
  })
  
  output$sumTable <- DT::renderDataTable({
    var <- !!sym(input$plot)
    tab <- hypertension %>% 
      select("riesgo_hipertension", var) %>%
      group_by(riesgo_hipertension) %>%
      summarize(mean = mean(get(var)))
    tab
  })
  
  #develop binary variable of riesgo_hipertension
  hypertension$hyp_binary <- as_factor(ifelse(hypertension$riesgo_hipertension==0, "not_at_risk", "at_risk"))
  
  #develop models
  output$models <- renderUI({
    #split dataset based on percentage chosen by user
    train.index <- createDataPartition(hypertension$hyp_binary, p = input$split, list = FALSE)
    #create training/test set based on percentage split chosen by user
    hypertension.train <- hypertension[train.index,]
    hypertension.test <- hypertension[-train.index,]
    
    #random forest model
    rf.fit <- train(hyp_binary ~ !!sym(input$rfPred), data = hypertension.train,
          #select rf method
          method = "rf",
          #do cross validation
          trControl = trainControl(method = "cv", number = input$cvNum),
          #add tuning parameter
          tuneGrid = data.frame(mtry = !!sym(input$mtry))
    )
    
    #generalized linear model
    glm.fit <- train(hyp_binary ~ !!sym(input$glmPred), data = hypertension.train,
            #select glm
            method = "glm",
            #do cross validation
            trControl = trainControl(method = "cv", number = !!sym(input$cvNum))
      )
    })
  
  #RMSE of models and best of each model when action button clicked
  rmse <- eventReactive(input$action,{
    rf.fit$results
    rf.fit$bestTune
    
    glm.fit$results
    glm.fit$bestTune
  })
  
  output$rmsePrint <- renderPrint({
    rmse
  })
  
  #create predictions based off models when action button clicked
  preds <- eventReactive(input$action,{
    pred.rf <- predict(rf.fit, newdata=hypertension.test)
    postResample(pred.rf, hypertension.test$hyp_binary)
    pred.glm <- predict(glm.fit, newdata=hypertension.test)
    postResample(pred.glm, hypertension.test$hyp_binary)
  })
  
  output$predPrint <- renderPrint({
    preds
  })
}
)
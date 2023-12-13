#ST558 final project Sabrina Dahl
library(shiny)
library(tidyverse)
library(dplyr)
library(caret)

shinyServer(function(input, output, session) {
  #dataset
  hypertension <- read_csv("Hipertension_Arterial_Mexico.csv")
  
  #clean the datasets that will be used in plots on data exploration tab
  hyp <- hypertension %>% 
    subset(select= -FOLIO_I) 
  
  #create plots for data exploration tab based on variable chosen from "plot" radioButton
  output$barPlot <- renderPlot({
    
    if(input$question == TRUE){
      ggplot(hyp, aes(x= input$plot, y = riesgo_hipertension)) + geom_point() + facet_wrap(~input$facet)
    } 
    else if(input$question == FALSE) {
      ggplot(hyp, aes(x= input$plot, y = riesgo_hipertension)) + geom_point() 
    }
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
    rf.fit <- train(hyp_binary ~ ., data = hypertension.train,
          #select rf method
          method = "rf",
          #do cross validation
          trControl = trainControl(method = "cv", number = input$cvNum),
          #add tuning parameter
          tuneGrid = data.frame(mtry = input$mtry)
    )
    
    #generalized linear model
    glm.fit <- train(hyp_binary ~ ., data = hypertension.train,
            #select glm
            method = "glm",
            #do cross validation
            trControl = trainControl(method = "cv", number = input$cvNum)
      )
    #calculate RMSE
    RMSE <- renderPrint({
      rf.fit$results
      rf.fit$bestTune
    
      glm.fit$results
      glm.fit$bestTune
    })
    return(RMSE)
    })
  
  #develop predictions based on models developed on Model Fitting subtab
  output$predictions <- renderUI({
    #split dataset based on percentage chosen by user
    train.index <- createDataPartition(hypertension$hyp_binary, p = input$split, list = FALSE)
    #create training/test set based on percentage split chosen by user
    hypertension.train <- hypertension[train.index,]
    hypertension.test <- hypertension[-train.index,]
    #random forest model
    rf.fit <- train(hyp_binary ~ ., data = hypertension.train,
                    #select rf method
                    method = "rf",
                    #do cross validation
                    trControl = trainControl(method = "cv", number = input$cvNum),
                    #add tuning parameter
                    tuneGrid = data.frame(mtry = input$mtry)
    )
    
    #generalized linear model
    glm.fit <- train(hyp_binary ~ ., data = hypertension.train,
                     #select glm
                     method = "glm",
                     #do cross validation
                     trControl = trainControl(method = "cv", number = input$cvNum)
    )

    #create predictions based off models
    preds <- renderPrint({
    pred.rf <- predict(rf.fit, newdata=hypertension.test)
    postResample(pred.rf, hypertension.test$hyp_binary)
    pred.glm <- predict(glm.fit, newdata=hypertension.test)
    postResample(pred.glm, hypertension.test$hyp_binary)
    })
    return(preds)
  })
}
)
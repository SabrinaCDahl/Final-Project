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
  
  #creating subtabs within the Modeling tab
  output$Modeling <- renderUI({
    tabsetPanel(id="subTabPanel",
                #subtab describing the two model approaches
                tabPanel("Modeling Info", 
                         h3("model one and drawback"),
                         h3("random forest model and drawback"),
                         h3("On the following tab there will be a section for inputing the wanted predictors and their interactions for each model. The user will be able to choose from
                            sexo (Gender), edad (Age), concentracion_hemoglobina(Hemoglobin concentration), temperatura_ambiente (Ambient Temperature), valor_acido_urico (Uric Acid Value), valor_albumina(Albumina Value), valor_colesterol_hdl(HDL Cholesterol Value), valor_colesterol_ldl(LDL CHolesterol Level), valor_colesterol_total(Total Cholesterol Level), valor_creatina(Creatinine level), valor_insulina(Insulin level), valor_trigliceridos(Trigliceride Level), resultado_glucosa (Glucose Result), valor_proteinac_reactiva (C-Reactive Protein Value), resultado_glucosa_promedio (Average Glucose Result), valor_ferritina (Ferritin Value), valor_folato (Folate Value), valor_homocisteina (Homocysteine Value), valor_transferrina (Transferrin Value), valor_vitamina_bdoce (Vitamin B12 Value), valor_vitamina_d (Vitamin D Value), peso (Weight), estatura (Height), tension_arterial (Blood Pressure), sueno_horas (Sleep in Hours), masa_corporal (Body Mass), and actividad_total (Total Activity).")),
                #subtab where user can change pieces of the model
                tabPanel("Model Fitting", 
                         fluidRow(column(4,
                                         textInput("rfPred", label= "Insert Random Forest Predictors", value = "peso+edad"),
                                         textInput("glmPred", label= "Insert GLM Predictors", value = "peso+edad"),
                                         sliderInput("split", label = "Percentage split for train/test sets", value=.7, min=0, max=1),
                                         sliderInput("cvNum", label = "Number of Cross Validation", value=5, min=2, max=10),
                                         sliderInput("mtry", label = "Number of input features for random forest model", value = 3, min = 1, max=25),
                                         actionButton("action", label="Fit Models to training data")
                                         ),
                                  column(8,
                                         uiOutput("models")
                                         )
                                  )),
                #subtab where user can choose values of the predictors
                tabPanel("Prediction", 
                         h3("Below is the summary of the each models predictions made using the test set:"),
                         uiOutput("predictions"))
    )
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
    print(rf.fit$results)
    print(rf.fit$bestTune)
    
    print(glm.fit$results)
    print(glm.fit$bestTune)
    #create predictions based off models
    pred.rf <- predict(rf.fit, newdata=hypertension.test)
    postResample(pred.rf, hypertension.test$hyp_binary)
    pred.glm <- predict(glm.fit, newdata=hypertension.test)
    postResample(pred.glm, hypertension.test$hyp_binary)
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
    pred.rf <- predict(rf.fit, newdata=hypertension.test)
    postResample(pred.rf, hypertension.test$hyp_binary)
    pred.glm <- predict(glm.fit, newdata=hypertension.test)
    postResample(pred.glm, hypertension.test$hyp_binary)
  })
}
)
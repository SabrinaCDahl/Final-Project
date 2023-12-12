#ST558 final project Sabrina Dahl
library(shiny)
library(tidyverse)
library(dplyr)
library(caret)

shinyServer(function(input, output, session) {
  #dataset
  hypertension <- read_csv("Hipertension_Arterial_Mexico.csv")
  
  #create the datasets that will be used in plots on data exploration tab
  bloodPressure.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(tension_arterial) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  activity.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(actividad_total) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  age.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(edad) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  #create plots for data exploration tab based on variable chosen from "plot" radioButton
  output$barPlot <- renderPlot({
    
    if(input$plot == "point"){
      ggplot(bloodPressure.sum, aes(x= tension_arterial, y = proportion.hypertension, size = n)) + geom_point()
    } 
    else if(input$plot == "point2") {
      ggplot(activity.sum, aes(x= actividad_total, y = proportion.hypertension, size = n)) + geom_point()
    }
    else if(input$plot == "point3") {
      ggplot(age.sum, aes(x= edad, y = proportion.hypertension, size = n)) + geom_point()
    }
  })
  
  #creating subtabs within the Modeling tab
  output$Modeling <- renderUI({
    tabsetPanel(id="subTabPanel",
                #subtab describing the two model approaches
                tabPanel("Modeling Info", 
                         h3("model one and drawback"),
                         h3("random forest model and drawback")),
                #subtab where user can change pieces of the model
                tabPanel("Model Fitting", 
                         fluidRow(column(4,
                                         checkboxGroupInput("rfPred", label= "Random Forest Predictors",choices =  list("Blood Pressure", "Hours of sleep", "Weight", "Cholesterol level in blood", "Hemoglobin concentration in blood", "Gender", "Age"), 
                                                            choiceValues= list(hypertension.train$tension_arterial, hypertension.train$sueno_horas, hypertension.train$peso, hypertension.train$valor_colesterol_total, hypertension.train$concentracion_hemoglobina, hypertension.train$sexo, hypertension.train$edad)),
                                         checkboxGroupInput("glmPred", label= "GLM Predictors", 
                                                            choiceNames = list("Blood Pressure", "Hours of sleep", "Weight", "Cholesterol level in blood", "Hemoglobin concentration in blood", "Gender", "Age"), 
                                                            choiceValues= list(hypertension.train$tension_arterial, hypertension.train$sueno_horas, hypertension.train$peso, hypertension.train$valor_colesterol_total, hypertension.train$concentracion_hemoglobina, hypertension.train$sexo, hypertension.train$edad)),
                                         sliderInput("split", label = "Percentage split for train/test sets", value=.7, min=0, max=1),
                                         sliderInput("cvNum", label = "Number of Cross Validation", value=5, min=2, max=10),
                                         sliderInput("mtry", label = "Number of input features for random forest model", value = 3, min = 1, max=7),
                                         actionButton("action", label="Fit Models to training data")
                                         ),
                                  column(8,
                                         uiOutput("models")
                                         )
                                  )),
                #subtab where user can choose values of the predictors
                tabPanel("Prediction")
    )
  })
  
  #develop binary variable of riesgo_hipertension
  hypertension$hyp_binary <- as_factor(ifelse(hypertension$riesgo_hipertension==0, "not_at_risk", "at_risk"))
  #create training set based on percentage split chosen by user
  hypertension.train <- reactive({
    hypertension[(createDataPartition(hypertension$hyp_binary, p = input$split, list = FALSE)),]
  })
  #create test set based on percentage split chosen by user
  hypertension.test <- reactive({
    hypertension[-(createDataPartition(hypertension$hyp_binary, p = input$split, list = FALSE)),]
  })
  #develop models
  output$models <- renderUI({
    #random forest model
    rf.fit <- train(hyp_binary ~ input$rfPred, data = hypertension.train,
          #select rf method
          method = "rf",
          #do cross validation
          trControl = trainControl(method = "cv", number = input$cvNum),
          #add tuning parameter
          tuneGrid = data.frame(mtry = input$mtry)
    )
    
    #generalized linear model
    glm.fit <- train(hyp_binary ~ input$glmPred, data = hypertension.train,
            #select glm
            method = "glm",
            #do cross validation
            trControl = trainControl(method = "cv", number = input$cvNum)
      )
    })
}
)
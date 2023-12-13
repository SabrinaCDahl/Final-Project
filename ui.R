#ST558 final project Sabrina Dahl
library(ggplot2)
library(shinyWidgets)
library(shinydashboard)

shinyUI(fluidPage(
mainPanel(
  tabsetPanel(id="tabs",
    #tab for describing the app
    tabPanel(title="About", h4("The purpose of this app is to create two models and then compare how well each of those models were able to predict whether an indiviudal will be at risk or not at risk of hypertension."),
             h4("We will be using the data from ", a("kaggle", href="https://www.kaggle.com/datasets/frederickfelix/hipertensin-arterial-mxico"), ". This dataset was collected from the National Health and Nutrition Survey. The dataset includes biometric information about the health of patients in Mexico including Sex, Age, Hemoglobin Concentration, Cholesterol, weight, height, and whether they're risk of developing arterial hypertension."),
             h4("The app has 3 main tabs- About, Data Exploration, and Modeling. You are currently on the About tab describing the purpose of this app. The Data Exploration tab will allow the user to create multiple plots from the dataset to explore any trends and get comfortable with the data. The Modeling tab will develop two different models that will predict an individuals risk factor for developing arterial hypertension."),
             h5("On the Data Exploration tab and the Model Fitting subtab there will be a section for inputing the wanted variables for plotting/predictors and their interactions for each model. The user will be able to choose from
                            sexo (Gender), edad (Age), concentracion_hemoglobina(Hemoglobin concentration), temperatura_ambiente (Ambient Temperature), valor_acido_urico (Uric Acid Value), valor_albumina(Albumina Value), valor_colesterol_hdl(HDL Cholesterol Value), valor_colesterol_ldl(LDL CHolesterol Level), valor_colesterol_total(Total Cholesterol Level), valor_creatina(Creatinine level), valor_insulina(Insulin level), valor_trigliceridos(Trigliceride Level), resultado_glucosa (Glucose Result), valor_proteinac_reactiva (C-Reactive Protein Value), resultado_glucosa_promedio (Average Glucose Result), valor_ferritina (Ferritin Value), valor_folato (Folate Value), valor_homocisteina (Homocysteine Value), valor_transferrina (Transferrin Value), valor_vitamina_bdoce (Vitamin B12 Value), valor_vitamina_d (Vitamin D Value), peso (Weight), estatura (Height), tension_arterial (Blood Pressure), sueno_horas (Sleep in Hours), masa_corporal (Body Mass), and actividad_total (Total Activity)."),
             #insert image
             tags$figure(
               class="centerFigure",
               tags$image(
                 src="PAH.png",
                 alt="Pulmonary Arterial Hypertension"
               )
             )),
    #tab for developing graphs and summaries from the dataset
    tabPanel(title="Data Exploration",
                #user chooses variable for x axis
                selectInput("plot", "Select the variable to plot vs proportion of hypertension", choices = list("sexo", "edad", "concentracion_hemoglobina", "temperatura_ambiente", "valor_acido_urico", "valor_albumina", "valor_colesterol_hdl", "valor_colesterol_ldl", "valor_colesterol_total", "valor_creatina", "valor_insulina", "valor_trigliceridos", "resultado_glucosa", "valor_proteinac_reactiva", "resultado_glucosa_promedio", "valor_ferritina", "valor_folato", "valor_homocisteina", "valor_transferrina", "valor_vitamina_bdoce", "valor_vitamina_d", "peso", "estatura", "tension_arterial", "sueno_horas", "masa_corporal", "actividad_total"), selected = "actividad_total"),
                #user chooses variable to facet graphs
                checkboxInput("question", label = "Facet?", value = FALSE),
                selectInput("facet", "Select the variable to facet the plot", choices = list("sexo", "edad", "concentracion_hemoglobina", "temperatura_ambiente", "valor_acido_urico", "valor_albumina", "valor_colesterol_hdl", "valor_colesterol_ldl", "valor_colesterol_total", "valor_creatina", "valor_insulina", "valor_trigliceridos", "resultado_glucosa", "valor_proteinac_reactiva", "resultado_glucosa_promedio", "valor_ferritina", "valor_folato", "valor_homocisteina", "valor_transferrina", "valor_vitamina_bdoce", "valor_vitamina_d", "peso", "estatura", "tension_arterial", "sueno_horas", "masa_corporal", "actividad_total"), selected = "edad"),
                #numerical summaries
                dataTableOutput("sumTable"),
                #create plot
                plotOutput("barPlot")
             ),
    #tab for developing models from the dataset
    tabPanel(title="Modeling", tabsetPanel(
      #creating subtabs within the Modeling tab
      tabPanel("Modeling Info",
               h4("Random Forest Model"),
               h5("The Random Forest model uses the same bagging method as the bagged tree classification model and creates multiple trees from the bootstrap samples and averages the results. The difference is that the random forest method does not use all of the predictors, instead it uses a random subset of predictors for each sample and tree fit. 
                  This is useful in the case where extra strong predictors exist since that predictor will not be the first split, and the trees will be less correlated than if the predictor was included. Forcing the model to choose from a subset of predictors, causes the resulting trees to be less correlated and therefore the random forest method leads to a reduction in variance and more reliable prediction. Bagging and random forest models aggregate many decision trees to increase the predictive performance of these models. With more models, we get more accurate predictions. The multiple trees created in a random forest model reduces the chances of overfitting our model making them superior when it comes to prediction. However, we do lose the interpretability of a singular classification tree when we use random forest models."),
               h4("Generalized Linear Model"),
               h5("A generalized linear model(GLM) can be used to model the interaction between the response variable and one or more predictors. A GLM can have both continuous and categorical predictors, like the General Linear Model. However, the response variable can be from a non-normal distribution. GLM are generally easy to interpret, but the precitor variables need to be uncorrelated."),
               ),
      #subtab where user can change pieces of the model
      tabPanel("Model Fitting", 
               fluidRow(column(4,
                               #user chooses predictor variables for random forest model
                               textInput("rfPred", label= "Insert Random Forest Predictors", value = "peso+edad"),
                               #user chooses predictor variables for generalized linear model
                               textInput("glmPred", label= "Insert GLM Predictors", value = "peso+edad"),
                               #user chooses split
                               sliderInput("split", label = "Percentage split for train/test sets", value=.7, min=0, max=1),
                               #user chooses number of cross validations
                               sliderInput("cvNum", label = "Number of Cross Validation", value=5, min=2, max=10),
                               #user chooses number for mtry
                               sliderInput("mtry", label = "Number of input features for random forest model", value = 3, min = 1, max=25),
                               #user can develop models
                               actionButton("action", label="Fit Models to training data")
               ),
               column(8,
                      verbatimTextOutput("rmsePrint")
               )
               )),
      #subtab where user can choose values of the predictors
      tabPanel("Prediction", 
               h3("Below is the summary of the each models predictions made using the test set:"),
               verbatimTextOutput("predPrint"))
    ))
  )
)))
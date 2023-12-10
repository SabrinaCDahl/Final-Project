library(shiny)

shinyServer(function(input, output, session) {
  output$Modeling <- renderUI({
    tabsetPanel(id="subTabPanel",
                tabPanel("Modeling Info"),
                tabPanel("Model Fitting"),
                tabPanel("Prediction")
                )
  })
}
)
library()

shinyUI(fluidPage(
mainPanel(
  tabsetPanel(id="tabSelected",
    tabPanel("About"),
    tabPanel("Data"),
    tabPanel("Modeling", uiOutput("Modeling"))
  )
)))
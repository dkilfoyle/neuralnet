library(shiny)
library(visNetwork)
library(shinyjs)
library(jsonlite)
library(plotly)

buildTrainingPlot = function() {
  plot_ly(
    y=c(0),
    x=c(0),
    type="scatter",
    mode="lines",
    line=list(color='#25FEFD', width=3)
  ) %>% 
    layout(
      xaxis=list(rangemode = "tozero"),
      yaxis=list(rangemode = "tozero")
    )
}

values = reactiveValues(
  net=NULL,
  p=buildTrainingPlot(),
  traces=0
)

shinyServer(function(input, output, session) {
   
  observe({
    values$net = NeuralNetwork$new(Species ~ ., data = iris, hidden = input$nHidden1)
    runjs("clearNetwork()")
    runjs(sprintf("buildNetwork(%s, %s, %s, %s)", 
      toJSON(values$net$W1),
      toJSON(values$net$W2),
      toJSON(colnames(values$net$X)[-1]),
      toJSON(levels(values$net$Y))))
    # runjs(sprintf("buildGraph()"))
  })
  
  output$trainPlot = renderPlotly(values$p)
  
  observeEvent(input$clearTrainingPlots, {
    values$p=buildTrainingPlot()
    values$traces = 0
  })

  observeEvent(input$go, {

    progress = shiny::Progress$new(style="notification")
    progress$set(message="Training", value=0)
    on.exit(progress$close())
    
    plotlyProxy("trainPlot", session) %>% 
      plotlyProxyInvoke("addTraces", list(y=list(0), x=list(0)))
    values$traces = values$traces + 1
    
    withCallingHandlers({
      values$net$train(
        iterations = input$nIterations,
        trace = input$nTrace,
        learn_rate = input$nLearn,
        tolerance = input$nTolerance,
        progress = function(iteration, neterror) {
          progress$set(iteration / input$nIterations)
          runjs(sprintf("updateNetwork(%s, %s, 2, 10)", 
            toJSON(values$net$W1),
            toJSON(values$net$W2)))
          # runjs(sprintf("updateGraph(%.4f, %.2f)", neterror, x))
          plotlyProxy("trainPlot", session) %>% 
            plotlyProxyInvoke("extendTraces", list(x=list(list(iteration)), y=list(list(neterror))), list(values$traces))
        })},
      message = function(m) {
        shinyjs::html(id="messages", html=m$message, add=T)
      }
    )
  })
  
})

library(shiny)
library(visNetwork)
library(shinyjs)
library(jsonlite)

values = reactiveValues(net=NULL)

shinyServer(function(input, output) {
   
  observe({
    values$net = NeuralNetwork$new(Species ~ ., data = iris, hidden = input$nHidden1)
    runjs("clearNetwork()")
    runjs(sprintf("buildNetwork(%s, %s, %s, %s)", 
      toJSON(values$net$W1),
      toJSON(values$net$W2),
      toJSON(colnames(values$net$X)[-1]),
      toJSON(levels(values$net$Y))))
    runjs(sprintf("buildGraph()"))
  })
  
  observeEvent(input$go, {
    
    progress = shiny::Progress$new(style="notification")
    progress$set(message="Training", value=0)
    on.exit(progress$close())
    
    withCallingHandlers({
      values$net$train(
        iterations = input$nIterations,
        trace = input$nTrace,
        learn_rate = input$nLearn,
        tolerance = input$nTolerance,
        progress = function(x, neterror) {
          progress$set(x)
          runjs(sprintf("updateNetwork(%s, %s, 2, 10)", 
            toJSON(values$net$W1),
            toJSON(values$net$W2)))
          runjs(sprintf("updateGraph(%.4f)", neterror))
        })},
      message = function(m) {
        shinyjs::html(id="messages", html=m$message, add=T)
      }
    )
  })
  
})

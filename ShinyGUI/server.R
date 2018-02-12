library(shiny)
library(visNetwork)
library(shinyjs)
library(jsonlite)

source("../NeuralNetwork.R")
source("../drawNetwork.R")

values = reactiveValues(net=NULL)

shinyServer(function(input, output) {
   
  observe({
    values$net = NeuralNetwork$new(Species ~ ., data = iris, hidden = input$nHidden1)
    runjs("clearNetwork()")
    runjs(paste0("buildNetwork(", toJSON(values$net$W1), ",", toJSON(values$net$W2), ");"))
  })
  
  observeEvent(input$go, {
    
    progress = shiny::Progress$new(style="notification")
    progress$set(message="Training", value=0)
    on.exit(progress$close())
    
    # net <<- initNetwork()
    # runjs("clearNetwork()")
    # runjs(paste0("buildNetwork(", toJSON(net$W1), ",", toJSON(net$W2), ");"))
    
    values$net$train(
      iterations = input$nIterations,
      trace = input$nTrace,
      learn_rate = input$nLearn,
      tolerance = input$nTolerance,
      progress = function(x) {
        progress$set(x)
        runjs(paste0("updateNetwork(", toJSON(values$net$W1), ",", toJSON(values$net$W2), ",2,10);"))
        # visNetworkProxy("network") %>%
        #   visUpdateEdges(getVisEdges(net))

      })
  })
  
  output$network = renderVisNetwork({
    if (is.null(net)) 
      draw(NeuralNetwork$new(Species ~ ., data = iris, hidden = input$nHidden1))
    else
      draw(net)
  })
  
})

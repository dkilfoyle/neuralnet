library(shiny)
library(visNetwork)
library(shinyjs)


shinyUI(fluidPage(
  useShinyjs(),
  
  tags$head(tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.4/svg.js")),
  
  includeScript("www/svg.js"),
  
  shiny::tags$head(shiny::tags$style(shiny::HTML(
    "#consoleOutput { font-size: 11pt; height: 400px; overflow: auto; }"
  ))),
  
  
  # Application title
  titlePanel("NeuralNet"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    
    sidebarPanel(
      selectInput("rbDataset", "Dataset:", c("Iris","Titanic","XOR")),
      numericInput("nIterations", "Iterations:", 10000, min=1, max=10000, step=100),
      numericInput("nTrace", "Trace Iterations:", 500, min=1, max=5000, step=100),
      numericInput("nTolerance","Error Tolerance:", 0.01, min=0.0, step=0.01),
      
      # radioButtons("rbBatchMethod", "Batch Method:", c("Online","Batch")),
      # conditionalPanel(condition="input.rbBatchMethod=='Batch'",
        # checkboxInput("bRandomEpoch","Randomize order each epoch: ", value=F),
        # numericInput("nBatchSize", "Batch Size %:", 100, min=1, max=100)),
      
      numericInput("nHidden1","Layer2 Hidden Neurons:", 5, min=0, max=100),
      numericInput("nHidden2","Layer3 Hidden Neurons:", 0, min=0, max=100),       
      selectInput("rbWeightSD", "Weight Initiation SD:", c("sd=1.0","sd=1/sqrt(n)","nguyen.widrow"),selected="sd=1.0"),
      
      # selectInput("sMethod","Back Propogation Method:",c("Standard","RPROP"), selected="Standard"),
      
      numericInput("nLearn","Learning Rate:", 0.0001, min=0, max=1, step=0.01),
      # sliderInput("nMomentum","Momentum:", 0.3, min=0, max=1, step=0.1),
      # textInput("txtRun","Run Name:", "Run_1"),
      # actionButton("btnClearRuns","Clear Runs"),
      # actionButton("go1","Step 1"),
      actionButton("go","Train")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Info",
          # withMathJax(includeHTML("math.html"))
          div(id="network-svg")),
        tabPanel("Console", 
          pre(id = "messages", class="shiny-text-output", style="height:800px; margin-top:20px")), 
        tabPanel("Plot", 
          plotOutput("distPlot"), style="margin-top:20px")),
        id="maintabs")
    )
  )
)

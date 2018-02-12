source("NeuralNetwork.R")

irisnet <- NeuralNetwork$new(Species ~ ., data = iris, hidden = 5)
irisnet$train(9999, trace = 1e3, learn_rate = .0001)
# draw(irisnet)

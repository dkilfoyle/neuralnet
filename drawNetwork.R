library(visNetwork)
library(dplyr)
library(scales)
library(RColorBrewer)

getVisEdges = function(neuralnet) {
  edges = data.frame()
  
  W1s = rescale(neuralnet$W1, to=c(0,1))
  W2s = rescale(neuralnet$W2, to=c(0,1))
  pal = rev(colorRampPalette(brewer.pal(9,"RdYlBu"))(100))
  
  # connect input to hidden
  for (i in 1:nrow(neuralnet$W1)) {
    for (h in 1:ncol(neuralnet$W1)) {
      wvalue = round(neuralnet$W1[i,h],2)
      wscale = W1s[i,h]
      edges = rbind(edges, data.frame(
        from = paste0("I",i-1),
        to = paste0("H",h),
        # label = wvalue,
        value = wvalue,
        color = pal[wscale*99+1]
      ))
    }
  }
  
  # connect hidden to output
  for (h in 1:nrow(neuralnet$W2)) {
    for (o in 1:ncol(neuralnet$W2)) {
      wvalue = round(neuralnet$W2[h,o],2)
      wscale = W2s[h,o]
      edges = rbind(edges, data.frame(
        from = paste0("H",h-1),
        to = paste0("O",o),
        # label = wvalue,
        value = wvalue,
        color = pal[wscale*99+1]
      ))
    }
  }
  
  return (edges)
}

draw = function(neuralnet) {
  
  nodes = data.frame() 
  
  # input nodes
  for (i in 1:nrow(neuralnet$W1)) {
    nodes = rbind(nodes, data.frame(
      id = paste0("I", i-1),
      label = paste0("I", i-1),
      level = 1,
      group = "input",
      value = 0,
      title = 0
    ))
  }
  
  # hidden nodes
  for (h in 1:nrow(neuralnet$W2)) {
    nodes = rbind(nodes, data.frame(
      id = paste0("H", h-1),
      label = paste0("H", h-1),
      level = 2,
      group = "hidden",
      value = 0,
      title = 0
    ))
  }
  
  # output nodes
  for (o in 1:ncol(neuralnet$W2)) {
    nodes = rbind(nodes, data.frame(
      id = paste0("O", o),
      label = paste0("O", o),
      level = 3,
      group = "output",
      value = 0,
      title = 0
    ))
  }
  
  edges = getVisEdges(neuralnet)
  
  scaleEdge = 'function (min,max,total,value) {
    if (max === min) {
      return 0.5;
    }
    else {
      var scale = 1 / (max - min);
      return Math.abs(value*scale);
    }
  }'
  
  visNetwork(nodes, edges) %>% 
    visHierarchicalLayout(direction = "LR", levelSeparation = 300, blockShifting = F, edgeMinimization = F) %>%
    visEdges(scaling=list(max=10, label=list(enabled=F), customScalingFunction=scaleEdge)) %>% 
    visNodes(scaling=list(max=5)) %>% 
    visGroups(groupname="input", shape="circle", color=list(background="lightgreen", border="green")) %>% 
    visGroups(groupname="hidden", shape="circle", color=list(background="lightgreen", border="green")) %>% 
    visGroups(groupname="output", shape="circle", color=list(background="lightgreen", border="green")) %>% 
    visInteraction(hover = F) %>% 
    visPhysics(enabled=F)
}
  
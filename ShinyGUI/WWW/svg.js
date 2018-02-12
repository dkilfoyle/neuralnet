$(document).on('shiny:connected', function(event) {
  SVG.extend(SVG.Gradient, {
    // Get color at given offset
    colorAt: function(offset) {
      var first, last;
  
      // find stops
      this.each(function() {
        if (this.attr('offset') <= offset) first = this;
      });
  		
      last = first.next();
      
      // if first is the last stop
      if ( ! last ) return first.attr('stop-color');
       
      var blend, relative, fo, lo;
  		
      // create morph
      blend = new SVG.Color(first.attr('stop-color'));
      blend.morph(last.attr('stop-color'));
      
      // calculate relative offset
      fo = first.attr('offset');
      lo = last.attr('offset');
      relative = (offset - fo) / (lo - fo);
  
      return blend.at( relative );
    }
  });
  netsvg = SVG('network-svg').size('100%', '100%').viewbox(0, 0, 800, 600);
});

clearNetwork = function() {
  netsvg.clear();
};

buildNetwork = function(W1, W2) {
  
  var input_nodes = [];
  var hidden_nodes = [];
  var output_nodes = [];
  
  var level_spacing = 200;
  var node_spacing = 80;
  
  var max_nodes_per_level = Math.max(W1.length, W1[0].length, W2[0].length);
  
  var W1_g = netsvg.group();
  var W2_g = netsvg.group();
  var in_g = netsvg.group();
  
  for (var i = 0; i < W1.length; i++) {
    var offset = (max_nodes_per_level - W1.length) / 2;
    input_nodes.push(in_g.circle(30).move(10 + (level_spacing * 0), node_spacing * (i + offset)));
  }
  
  for (var i = 0; i < W2.length; i++) {
    var offset = (max_nodes_per_level - W1[0].length) / 2;
    hidden_nodes.push(netsvg.circle(30).move(10 + (level_spacing * 1), node_spacing * (i + offset)));
  }
  
  for (var i = 0; i < W2[0].length; i++) {
    var offset = (max_nodes_per_level - W2[0].length) / 2;
    output_nodes.push(netsvg.circle(30).move(10 + (level_spacing * 2), node_spacing * (i + offset)));
  }
  
  W1_lines = [];
  W2_lines = [];
  
  for (var i = 0; i < W1.length; i++) {
    W1_lines[i] = [];
    for (var h = 0; h < W1[0].length; h++) {
      W1_lines[i][h] = W1_g.line(input_nodes[i].cx(), input_nodes[i].cy(), hidden_nodes[h+1].cx(), hidden_nodes[h+1].cy()).stroke({
          width: 2, //Math.abs(w_scaled) * max_edge_width,
          color: 'black' //edge_gradient.colorAt(w_scaled)
        });
    }
  }
  
  for (var h = 0; h < W2.length; h++) {
    W2_lines[h] = [];
    for (var o = 0; o < W2[0].length; o++) {
      W2_lines[h][o] = W2_g.line(hidden_nodes[h].cx(), hidden_nodes[h].cy(), output_nodes[o].cx(), output_nodes[o].cy()).stroke({
        width: 2, //Math.abs(w_scaled) * max_edge_width,
        color: 'black' //edge_gradient.colorAt(w_scaled)
      });
    }
  }
};

updateNetwork = function(W1, W2, max_weight, max_edge_width) {
  var edge_gradient = netsvg.gradient('linear', function(stop) {
    stop.at(-2, '#e50600');
    stop.at(0, '#ccc');
    stop.at(2, '#0020bf');
  });
  
  for (var i = 0; i < W1.length; i++) {
    for (var h = 0; h < W1[0].length; h++) {
    	var w_scaled = Math.max(Math.min(W1[i][h] / max_weight, max_weight), -max_weight);
      W1_lines[i][h].stroke({
        width: Math.abs(w_scaled) * max_edge_width,
        color: edge_gradient.colorAt(w_scaled)
      });
    }
  }

  for (var h = 0; h < W2.length; h++) {
    for (var o = 0; o < W2[0].length; o++) {
    	var w_scaled = Math.max(Math.min(W2[h][o] / max_weight, max_weight), -max_weight);
      W2_lines[h][o].stroke({
        width: Math.abs(w_scaled) * max_edge_width,
        color: edge_gradient.colorAt(w_scaled)
      });
    }
  }
  
};




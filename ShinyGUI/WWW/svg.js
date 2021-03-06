var netsvg = null;
var W1_lines = [];
var W2_lines = [];

var net_nest = null;

var graph_lines = null;
var graph_Scale = 0;
var graph_nest = null;

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

drawBB = function(bb) {
  netsvg.rect(bb.x, bb.y, bb.x2, bb.y2).stroke({width:1});
}

buildNetwork = function(W1, W2, xlabels, ylabels) {
  
  var input_nodes = [];
  var hidden_nodes = [];
  var output_nodes = [];
  
  var level_spacing = 200;
  var node_spacing = 80;
  
  var max_nodes_per_level = Math.max(W1.length, W2.length, W2[0].length);
  
  net_nest = netsvg.group();
  var W1_g = net_nest.group();
  var W2_g = net_nest.group();
  var in_g = net_nest.group();
  var h_g = net_nest.group();
  var o_g = net_nest.group();
  
  var node_x = 100;
  
  // build nodes
  for (var i = 0; i < W1.length; i++) {
    var offset = (max_nodes_per_level - W1.length) / 2.0;
    if (i===0)
      input_nodes.push(in_g.rect(30,30));
    else
      input_nodes.push(in_g.circle(30));
    input_nodes[i].move(node_x + (level_spacing * 0), node_spacing * (i + offset));
  }
  
  for (var i = 0; i < W2.length; i++) {
    var offset = (max_nodes_per_level - W2.length) / 2;
    if (i===0)
      hidden_nodes.push(h_g.rect(30,30));
    else
      hidden_nodes.push(h_g.circle(30));
    hidden_nodes[i].move(node_x + (level_spacing * 1), node_spacing * (i + offset));
  }
  
  for (var i = 0; i < W2[0].length; i++) {
    var offset = (max_nodes_per_level - W2[0].length) / 2;
    output_nodes.push(o_g.circle(30).move(node_x + (level_spacing * 2), node_spacing * (i + offset)));
  }
  
  // build text
  var labels_g = net_nest.group();
  for (var i=1; i< input_nodes.length; i++) {
    label = labels_g.text(xlabels[i-1]);
    lbb = label.bbox();
    nbb = input_nodes[i].bbox();
    // align label bbox center with node bbox center
    // right align text with node
    label.move(nbb.x - 5 - lbb.width, nbb.cy - (lbb.height/2));
  }
  
  for (var i=0; i<output_nodes.length; i++) {
    label = labels_g.text(ylabels[i]);
    lbb = label.bbox();
    nbb = output_nodes[i].bbox();
    // align label bbox center with node bbox center
    // right align text with node
    label.move(nbb.x2 + 5, nbb.cy - (lbb.height/2));
  }
  
  // center the whole network diagram within the viewbox (width 800)
  net_nest.cx(400);
  
  // style nodes
  in_g.fill({color:'lightgreen'});
  in_g.stroke({color:'black'});
  h_g.fill({color:'mediumseagreen'});
  h_g.stroke({color:'black'});
  o_g.fill({color:'lightgreen'});
  o_g.stroke({color:'black'});
  
  
  // build lines and save to global variables
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
        color: edge_gradient.colorAt(w_scaled),
        opacity: 0.6
      });
    }
  }

  for (var h = 0; h < W2.length; h++) {
    for (var o = 0; o < W2[0].length; o++) {
    	var w_scaled = Math.max(Math.min(W2[h][o] / max_weight, max_weight), -max_weight);
      W2_lines[h][o].stroke({
        width: Math.abs(w_scaled) * max_edge_width,
        color: edge_gradient.colorAt(w_scaled),
        opacity: 0.6
      });
    }
  }
  
};


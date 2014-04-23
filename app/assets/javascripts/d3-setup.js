// alert ($('#trends-data').val())
var layers_from_data = jQuery.parseJSON($('#trends-data').val())

var date_list = jQuery.parseJSON($('#date-list').val())
// var date_list = ["4.1", "4.2", "4.3","4.4", "5.14", 
//                  "5.15", "5.16", "5.17", "5.18","5.19", 
//                  "5.20", "5.21", "5.22", "5.23","5.24",
//                  "5.25", "5.26", "5.27", "5.28", "5.29", 
//                  "5.30", "5.31", "6.1", "6.2", "6.3", 
//                  "6.4", "6.5", "6.6", "6.7", "6.8"]
var layer1 = []
for(var li=0;li<date_list.length;li++)
{
  layer1.push({"x":date_list[li], "y":layers_from_data[0][li]})
}
var layer2 = []
for(var li=0;li<date_list.length;li++)
{
  layer2.push({"x":date_list[li], "y":1})
}
var layer3 = []
for(var li=0;li<date_list.length;li++)
{
  layer3.push({"x":date_list[li], "y":1})
}
var layer4 = []
for(var li=0;li<date_list.length;li++)
{
  layer4.push({"x":date_list[li], "y":1})
}

var n = 4 // number of layers
var m = 30 // number of samples per layer
var stack = d3.layout.stack()
var layers //= stack(layers_from_data)
// var values = d3.range(n).map(function() { return bumpLayer(m, .1); })
layers = stack([layer1,
                layer2,
                layer3,
                layer4]);
//alert(values)
//layers = stack(values)
var yGroupMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y; }); })
var yStackMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y0 + d.y; }); });

// alert(layers[0])
// alert(layers[0][0].x+" "+layers[0][0].y)
// layers = stack([{"x":0,"y": 0.3},{"x":1,"y":0.2}]);

var margin = {top: 40, right: 10, bottom: 20, left: 0},
    width = 700 - margin.left - margin.right,
    height = 300 - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .domain(date_list)
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .domain([0, yStackMax])
    .range([height, 0]);

 var color = d3.scale.linear()
     .domain([0, 1, 2, 3])
     .range(["#FFA93C", "#F57943", "#EA494A", "#CC0000"]);

var xAxis = d3.svg.axis()
    .scale(x)
    .tickSize(0)
    .tickPadding(6)
    .orient("bottom");

var svg = d3.select("#d3").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .attr("viewBox", "0 0 700 300")
    .attr("preserveAspectRatio", "xMidYMid")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var layer = svg.selectAll(".layer")
    .data(layers)
  .enter().append("g")
    .attr("class", "layer")
    .style("fill", function(d, i) { return color(i); });

var rect = layer.selectAll("rect")
    .data(function(d) { return d; })
  .enter().append("rect")
    .attr("x", function(d) { return x(d.x); })
    .attr("y", height)
    .attr("width", x.rangeBand())
    .attr("height", 0);

rect.transition()
    .delay(function(d, i) { return i * 10; })
    .attr("y", function(d) { return y(d.y0 + d.y); })
    .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); });

svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
  .selectAll("text")
    .attr("y", 3)
    .attr("x", 0)
    .attr("transform", "rotate(-35)")
    .style("text-anchor", "end");
    // .style("writing-mode", "tb-rl");

d3.selectAll("input").on("change", function change() {
  if (this.value === "grouped") transitionGrouped();
  else transitionStacked();
});

function transitionGrouped() {
  y.domain([0, yGroupMax]);

  rect.transition()
      .duration(500)
      .delay(function(d, i) { return i * 10; })
      .attr("x", function(d, i, j) { return x(d.x) + x.rangeBand() / n * j; })
      .attr("width", x.rangeBand() / n)
    .transition()
      .attr("y", function(d) { return y(d.y); })
      .attr("height", function(d) { return height - y(d.y); });
}

function transitionStacked() {
  y.domain([0, yStackMax]);

  rect.transition()
      .duration(500)
      .delay(function(d, i) { return i * 10; })
      .attr("y", function(d) { return y(d.y0 + d.y); })
      .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
    .transition()
      .attr("x", function(d) { return x(d.x); })
      .attr("width", x.rangeBand());
}

// Inspired by Lee Byron's test data generator.
// function bumpLayer(n, o) {

//   function bump(a) {
//     var x = 1 / (.1 + Math.random()),
//         y = 2 * Math.random() - .5,
//         z = 10 / (.1 + Math.random());
//     for (var i = 0; i < n; i++) {
//       var w = (i / n - y) * z;
//       a[i] += x * Math.exp(-w * w);
//     }
//   }

//   var a = [], i;
//   for (i = 0; i < n; ++i) a[i] = o + o * Math.random();
//   for (i = 0; i < 5; ++i) bump(a);
//   reval = a.map(function(d, i) { return {x: i, y: Math.max(0, d)}; });
  
//   return reval
// }

$(function(){
  var aspect = 700/300,
       chart = $("#d3").find("svg");
  var targetWidth = $("#d3").parent().width();
  chart.attr("width", targetWidth);
  chart.attr("height", targetWidth / aspect); 

  $(window).on("resize", function(){
    var targetWidth = $("#d3").parent().width();
    chart.attr("width", targetWidth);
    chart.attr("height", targetWidth / aspect); 
    $("svg").width(targetWidth);
    $("svg").height(targetWidth / aspect);
  });
});


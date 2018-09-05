(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
(function (global){
// title      : Anniversary Gift
// author     : Juan F. Mosquera
// license    : GNU GENERAL PUBLIC LICENSE v3
// tags       : anniversary, Anna Kuroshchenkova, Juan Felipe Mosquera Morales
// file       : anniversary_box.coffee
var get_bottom_box, get_extruded_dove_tail_rails, get_heart_polygon, get_top_box;

get_heart_polygon = function(heart_radius) {
  var half_heart;
  half_heart = new CSG.Path2D([[0, 0], [0, 3 * heart_radius]], false);
  half_heart = half_heart.appendBezier([[0, 4 * heart_radius], [heart_radius, 4 * heart_radius], [heart_radius, 4 * heart_radius]]);
  half_heart = half_heart.appendBezier([[2 * heart_radius, 4 * heart_radius], [2 * heart_radius, 3 * heart_radius], [2 * heart_radius, 3 * heart_radius]]);
  half_heart = half_heart.appendBezier([[2 * heart_radius, 2 * heart_radius], [0.5 * heart_radius, 2 * heart_radius], [0, 0]]);
  half_heart = half_heart.close();
  half_heart = polygon(half_heart);
  return union(half_heart, half_heart.mirroredX());
};

get_extruded_dove_tail_rails = function(front_polygon, box_width) {
  var extruded_p;
  extruded_p = rotateExtrude(translate([box_width * 3 / 8, 0, 0], front_polygon), {
    'resolution': 1,
    'angle': 90
  }).rotateZ(-90);
  return [extruded_p, translate([box_width, box_width, 0], extruded_p.rotateZ(180))];
};

get_top_box = function(box_width, top_height, heart_radius, clearance, heart_offset) {
  var dovetail_rails, heart, heart_box;
  heart = get_heart_polygon(heart_radius + clearance / 2);
  heart_box = cube({
    size: [box_width, box_width, top_height - clearance / 2],
    round: true
  }).translate([0, 0, clearance / 2]);
  dovetail_rails = get_extruded_dove_tail_rails(heart, box_width);
  return color('yellow', difference(heart_box, dovetail_rails[0].translate([0, 0, -heart_offset]), dovetail_rails[1].translate([0, 0, -heart_offset])));
};

get_bottom_box = function(box_width, bottom_height, heart_radius, clearance, heart_offset) {
  var dovetail_rails, heart, heart_box;
  heart = get_heart_polygon(heart_radius);
  heart_box = cube({
    size: [box_width, box_width, bottom_height - clearance / 2],
    round: true,
    resolution: 10
  });
  dovetail_rails = get_extruded_dove_tail_rails(heart, box_width);
  return color('blue', union(heart_box, dovetail_rails[0].translate([0, 0, bottom_height - heart_offset + clearance / 2]), dovetail_rails[1].translate([0, 0, bottom_height - heart_offset + clearance / 2])));
};

global.getParameterDefinitions = function() {
  var params_definition;
  params_definition = [
    {
      name: 'draw_selection',
      type: 'choice',
      caption: 'What to draw?',
      values: ['Everything',
    'Bottom Box',
    'Top Box',
    'Rings'],
      initial: 'Everything'
    },
    {
      name: 'heart_radius',
      type: 'float',
      initial: 5,
      step: 0.25,
      caption: 'Heart Radius'
    },
    {
      name: 'anna_finger_perimeter',
      type: 'float',
      initial: 5,
      step: 0.5,
      caption: "Anna's finger perimeter"
    },
    {
      name: 'juan_finger_perimeter',
      type: 'float',
      initial: 5,
      step: 0.5,
      caption: "Juan's finger perimeter"
    }
  ];
  return params_definition;
};

global.main = function(params) {
  var base_heart_radius, bottom_box, box_height, box_width, heart_offset, inner_hole, inner_hole_radius, parts_clearance, top_box;
  base_heart_radius = params.heart_radius;
  parts_clearance = 0.25;
  box_width = 10 * base_heart_radius;
  box_height = 6 * base_heart_radius;
  heart_offset = base_heart_radius;
  top_box = get_top_box(box_width, box_height * 2 / 3, base_heart_radius, parts_clearance, heart_offset).translate([0, 0, box_height / 3]);
  bottom_box = get_bottom_box(box_width, box_height / 3, base_heart_radius, parts_clearance, heart_offset);
  inner_hole_radius = 3 * base_heart_radius;
  inner_hole = sphere({
    r: inner_hole_radius,
    fn: 100,
    type: 'geodesic'
  }).translate([box_width / 2, box_width / 2, box_height - inner_hole_radius]);
  top_box = difference(top_box, inner_hole);
  bottom_box = difference(bottom_box, inner_hole);
  return [top_box, bottom_box];
};


}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}]},{},[1]);

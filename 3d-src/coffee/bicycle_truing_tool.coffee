# title      : Bicycle Truing Tool
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : bicycle truing tool
# file       : bicycle_truing_tool.coffee
_ = require 'underscore'
screws = require './screws.coffee'
util = require './util.coffee'

global.getParameterDefinitions = ->
  return [
    {name: 'tube_diameter', type: 'float', initial: 25, step: 0.5, caption: 'Tube Diameter'}
    {name: 'thickness', type: 'float', initial: 5, step: 0.5, caption: 'Overall Thickness'}
    {name: 'distance_to_clamp', type: 'float', initial: 30, step: 0.5, caption: 'Distance to Clamp'}
    {
      name: 'big_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M5'
      caption: 'Big Screw Type'
    }
    {name: 'big_nut_height', type: 'float', initial: 2.7, step: 0.05, caption: 'Big Nut Height'}
    {
      name: 'small_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M5'
      caption: 'Small Screw Type'
    }
    {name: 'small_nut_height', type: 'float', initial: 1.8, step: 0.05, caption: 'Small Nut Height'}
    {name: 'support_rod_thickness', type: 'float', initial: 5, step: 0.5, caption: 'Support Rod Thickness'}
    {name: 'clearance', type: 'float', initial: 0.2, step: 0.025, caption: 'Objects Clearance'}
  ]

global.main = (params)->
  outer_radius = params.tube_diameter/2.0 + params.thickness
  big_screw_type = screws.get_screw_by_type params.big_screw_type
  small_screw_type = screws.get_screw_by_type params.small_screw_type

  x_width = params.tube_diameter

  base_cyl = cylinder(
    {
      r: outer_radius
      h: x_width
      fn: 60
      center: [true, true, true]
    }
  ).rotateX(90)
  cutting_cyl = cylinder(
    {
      r: params.tube_diameter/2.0 + params.clearance
      h: x_width
      fn: 60
      center: [true, true, true]
    }
  ).rotateX(90)
  cutting_h = 0.3*outer_radius
  cutting_cube = union(
    cube(
      {
        size: [2*outer_radius, x_width, cutting_h]
        center: [true, true, false]
      }
    ),
    cube({size:[2*outer_radius, x_width, outer_radius], center:[true, true, false]}).translate([0, 0, -outer_radius])
  )
  base_shape = difference(base_cyl, cutting_cyl, cutting_cube).translate [0, 0, -cutting_h]

  flaps_size = 4*big_screw_type.diameter - x_width/2
  flap_x_pos = outer_radius - params.thickness*0.7 + flaps_size/2
  base_flap = difference(
    union(
      cube(
        {
          size: [flaps_size, x_width, params.thickness]
          center: [true, true, false]
        }
      ),
      difference(
        cylinder(
          {
            r: x_width/2
            h: params.thickness
            fn: 60
            center: [true, true, false]
          }
        ),
        cube(
          {
            size: [x_width/2, x_width, params.thickness]
            center: [true, true, false]
          }
        ).translate([-x_width/4, 0, 0])
      ).translate([flaps_size/2, 0, 0])
    ),
    cylinder(
      {
        r: big_screw_type.radius
        h: params.thickness
        fn: 60
        center: [true, true, false]
      }
    ).translate([flaps_size/2, 0, 0])
  )
  flap_a = base_flap.translate([flap_x_pos, 0, 0])
  shape_a = color('blue', union(base_shape, flap_a, flap_a.rotateZ(180))).translate([0, 1.5*x_width, 0])

  hex_nut_hole = big_screw_type.draw_nut_hole(params.big_nut_height, params.clearance)
  hex_nut_hole_dims = util.get_object_dimensions hex_nut_hole
  hex_nut_hole = union(
    hex_nut_hole,
    cube(
      {
        size: [x_width/2, hex_nut_hole_dims.y, hex_nut_hole_dims.z]
        center: [true, true, false]
      }
    ).translate([x_width/4, 0, 0])
  )
  flap_b = difference(
    base_flap,
    hex_nut_hole.translate([flaps_size/2, 0, (params.thickness - hex_nut_hole_dims.z)/2])
  ).translate([flap_x_pos, 0, 0])
  shape_b= color('yellow', union(base_shape, flap_b, flap_b.rotateZ(180)))

  return [shape_a, shape_b]

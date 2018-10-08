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
      initial: 'M3'
      caption: 'Small Screw Type'
    }
    {name: 'small_nut_height', type: 'float', initial: 1.8, step: 0.05, caption: 'Small Nut Height'}
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

  flaps_size = params.tube_diameter - x_width/2
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
  shape_a = color('blue', union(base_shape, flap_a, flap_a.rotateZ(180)))

  flap_b = base_flap
  gauge_cyl_radius = 2*small_screw_type.nut_radius
  gauge_cyl_h = 8*params.small_nut_height
  gauge_x_pos = x_width
  gauge_y_pos = 3*x_width/2

  hulled_base = hull(
    circle({r: x_width/2, fn:60, center: true}).translate([-gauge_x_pos, -gauge_y_pos]),
    circle({r: gauge_cyl_radius, fn:60, center: true})
  )

  gauge_cyl = union(
    linear_extrude({height: params.thickness}, hulled_base),
    cylinder({
      r1: gauge_cyl_radius
      r2: small_screw_type.nut_radius*1.5
      h: gauge_cyl_h-params.thickness
      fn:60
      center: [true, true, false]
    }).translate([0, 0, params.thickness])
  )

  small_hex_nut_hole = small_screw_type.draw_nut_hole(params.small_nut_height, params.clearance)
  small_hex_nut_hole_dims = util.get_object_dimensions small_hex_nut_hole
  small_hex_nut_hole = union(
    small_hex_nut_hole,
    cube(
      {
        size: [x_width, small_hex_nut_hole_dims.y, small_hex_nut_hole_dims.z]
        center: [true, true, false]
      }
    ).translate([x_width/2, 0, 0])
  )

  gauge_cyl = difference(gauge_cyl,
    cylinder
      r: small_screw_type.radius
      h: gauge_cyl_h
      fn:60
      center: [true, true, false],
    cylinder(
      {
        r: x_width / 2
        h: params.thickness
        fn: 60
        center: [true, true, false]
      }
    ).translate([-gauge_x_pos, -gauge_y_pos, 0]),
    small_hex_nut_hole.translate([0, 0, small_hex_nut_hole_dims.z*0.7]),
    small_hex_nut_hole.translate([0, 0, gauge_cyl_h-small_hex_nut_hole_dims.z*1.6])
  )
  gauge_cyl = gauge_cyl.translate([gauge_x_pos, gauge_y_pos, 0])
  flap_b = union(flap_b, gauge_cyl)


  hex_nut_hole = big_screw_type.draw_nut_hole(params.big_nut_height, params.clearance)
  hex_nut_hole_dims = util.get_object_dimensions hex_nut_hole
  hex_nut_hole = union(
    hex_nut_hole,
    cube(
      {
        size: [x_width, hex_nut_hole_dims.y, hex_nut_hole_dims.z]
        center: [true, true, false]
      }
    ).translate([x_width/2, 0, 0])
  )
  flap_b = difference(
    flap_b,
    hex_nut_hole.translate([flaps_size/2, 0, (params.thickness - hex_nut_hole_dims.z)/2])
  )

  flap_b_no_arm = difference(
    base_flap,
    hex_nut_hole.translate([flaps_size/2, 0, (params.thickness - hex_nut_hole_dims.z)/2])
  ).translate([flap_x_pos, 0, 0])

  flap_b = flap_b.translate([flap_x_pos, 0, 0])
  shape_b_0 = color('yellow', union(base_shape, flap_b, flap_b_no_arm.rotateZ(180))).translate([0, 0.7*x_width, 0])
  shape_b_1 = shape_b_0.mirroredY().rotateZ(180).translate([0, -(0.7*x_width + gauge_y_pos), 0])
  return [
    shape_a.translate([-params.tube_diameter, 1.8*x_width, 0]),
    shape_b_0,
    shape_b_1,
    shape_a.translate([params.tube_diameter, -0.4*x_width, 0])
  ]

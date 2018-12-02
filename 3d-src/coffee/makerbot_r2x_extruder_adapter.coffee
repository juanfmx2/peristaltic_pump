# title      : Makerbot Replicator 2X adapter
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : makerbot replicator 2x extruder adapter
# file       : makerbot_r2x_extruder_adapter.coffee
_ = require 'underscore'
util = require './util.coffee'

class ExtruderAdaptor

  NEMA_17_DATA:
    width: 42.3
    screws_delta: 31
    screw_radius: 1.5
    ring_radius: 11
    ring_height: 2
    shaft_radius: 2.5

  constructor: (@max_height, @extruder_length, @extruder_height, @missing_height, @printer_ready, @direction,
    @curve_approx, @hot_end_radius, @hot_end_x_delta, @hot_end_z_delta, @tolerance)->
    @round_radius = 3
    @distance_to_lid = @missing_height + @extruder_height + @tolerance

  __draw_motor_holes: ()->
    m_screw = cylinder
      r: @NEMA_17_DATA.screw_radius + @tolerance
      h: @max_height
      fn: @curve_approx
      center: [true, true, false]

    return union(
      translate([ @NEMA_17_DATA.screws_delta/2, @NEMA_17_DATA.screws_delta/2, 0], m_screw),
      translate([-@NEMA_17_DATA.screws_delta/2, @NEMA_17_DATA.screws_delta/2, 0], m_screw),
      cylinder
        r: @NEMA_17_DATA.ring_radius + @tolerance
        h: @NEMA_17_DATA.ring_height + @tolerance
        fn: @curve_approx
        center: [true, true, false]
      cylinder
        r: @NEMA_17_DATA.shaft_radius + 2*@tolerance
        h: @max_height
        fn: @curve_approx
        center: [true, true, false]
    )

  __draw_base_cube: ()->
    enclosure_cube_y = @NEMA_17_DATA.ring_radius + 1.5*@tolerance + @NEMA_17_DATA.width/2
    trimming_cube = cube({size: [@NEMA_17_DATA.width,@NEMA_17_DATA.width, @round_radius], center: [true, true, false]})
    enc_cube = CSG.roundedCube
      corner1: [-@NEMA_17_DATA.width/2, @NEMA_17_DATA.width/2 - enclosure_cube_y, -@round_radius]
      corner2: [@NEMA_17_DATA.width/2, @NEMA_17_DATA.width/2, @max_height + @round_radius]
      roundradius: @round_radius
      resolution: @curve_approx

    enc_cube = difference(
      enc_cube,
      translate([0, 0, @max_height], trimming_cube),
      translate([0, 0, -@round_radius], trimming_cube),
      CSG.cube
        corner1: [-@NEMA_17_DATA.width/2, @NEMA_17_DATA.width/2 - (@extruder_length + @tolerance),
          @missing_height - @tolerance]
        corner2: [@NEMA_17_DATA.width/2, @NEMA_17_DATA.width/2, @distance_to_lid]
      translate(
        [-@hot_end_x_delta, -@max_height/2, @hot_end_z_delta],
        rotate(
          [90, 0, 0],
          cylinder(
            r: @hot_end_radius + 2*@tolerance
            h: @max_height
            fn: @curve_approx
            center: true
          )
        )
      )
      # Temporarily remove the top part
      translate(
        [0, 0, @hot_end_z_delta],
        cube({size: [@NEMA_17_DATA.width,@NEMA_17_DATA.width, @max_height], center: [true, true, false]})
      )
    )
    enc_cube = union(
      enc_cube,
      translate(
        [0, 0, @missing_height - @tolerance],
        cylinder
          r: @NEMA_17_DATA.ring_radius - @tolerance
          h: @NEMA_17_DATA.ring_height - 0.5*@tolerance + @tolerance
          fn: @curve_approx
          center: [true, true, false]
      )
    )

    return enc_cube

  draw: ()->
    objects = []
    motor_holes = @__draw_motor_holes()
    base_cube = @__draw_base_cube()
    objects.push(difference(base_cube, motor_holes))
    if @direction != 'Right'
      mirrored_objects = []
      for obj_i in objects
        mirrored_objects.push obj_i.mirroredY()
      return mirrored_objects
    return objects


# ----------------------------------------------------------------------------------------------------------------------
# OpenJSCAD functions for default rendering
# ----------------------------------------------------------------------------------------------------------------------

global.getParameterDefinitions = ->
  return [
    {name: 'max_height', type: 'float', initial: 22.16, step: 0.25, caption: 'Max Length'}
    {name: 'extruder_length', type: 'float', initial: 30, step: 0.25, caption: 'Extruder Length'}
    {name: 'extruder_height', type: 'float', initial: 15, step: 0.25, caption: 'Extruder Height'}
    {name: 'gap_length', type: 'float', initial: 4.335, step: 0.25, caption: 'Gap Length'}
    {
      name: 'printer_ready'
      type: 'choice'
      caption: 'Printer Ready?'
      values: ['No', 'Yes']
      initial: 'No'
    }
    {
      name: 'direction'
      type: 'choice'
      caption: 'Extruder Direction'
      values: ['Left', 'Right']
      initial: 'Right'
    }
    {name: 'curve_approx', type: 'float', initial: 30, step: 10, caption: 'Curve Approximation'}
    {name: 'hot_end_radius', type: 'float', initial: 3, step: 0.25, caption: 'Hot-end Radius'}
    {name: 'hot_end_x_delta', type: 'float', initial: 5.5, step: 0.25, caption: 'Hot-end X Delta'}
    {name: 'hot_end_z_delta', type: 'float', initial: 14.26, step: 0.25, caption: 'Hot-end Z Delta'}
    {name: 'tolerance', type: 'float', initial: 0.2, step: 0.25, caption: 'Tolerance'}
  ]

global.main = (params)->
  ext_adaptor = new ExtruderAdaptor(
    params.max_height, params.extruder_length, params.extruder_height, params.gap_length, params.printer_ready == 'Yes',
    params.direction, params.curve_approx, params.hot_end_radius, params.hot_end_x_delta, params.hot_end_z_delta,
    params.tolerance
  )
  return ext_adaptor.draw()
# title      : parameters
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : peristaltic pump, parameters
# file       : parameters.coffee

screws = require './screws.coffee'

get_yes_no_choice_parameter = (param_name, caption)->
  return {
    name: param_name
    type: 'choice'
    caption: caption
    values: ['No', 'Yes']
    initial: 'Yes'
  }

exports.get_motor_parameters = ->
  return [
    {name: 'motor_mounting', caption: 'Motor Mount', type: 'group'}
    {name: 'motor_shaft_radius', type: 'float', initial: 2.5, step: 0.25, caption: 'Shaft radius'}
    {name: 'motor_shaft_height', type: 'float', initial: 24.0, step: 0.5, caption: 'Shaft height'}

    {name: 'motor_ring_radius', type: 'float', initial: 11.0, step: 0.1, caption: 'Ring radius'}
    {name: 'motor_ring_height', type: 'float', initial: 2.0, step: 0.1, caption: 'Ring height'}

    {name: 'motor_mountingholes_offset', type: 'float', initial: 15.5, step: 0.1, caption: 'Holes Offset'}
    {name: 'motor_mountingholes_radius', type: 'float', initial: 1.5, step: 0.1, caption: 'Holes Radius'}
    {name: 'motor_mountingholes_depth', type: 'float', initial: 4.5, step: 0.1, caption: 'Holes Depth'}
  ]

exports.get_bearings_parameters = ->
  return [
    {name: 'bearings', caption: 'Bearings', type: 'group'}
    {name: 'bearings_height', type: 'float', initial: 10, step: 1, caption: 'Height'}
    {name: 'bearing_outer_radius', type: 'float', initial: 6.5, step: 0.25, caption: 'Outer Radius'}
    {
      name: 'bearing_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M3'
      caption: 'Screw Type'
    }
    {name: 'bearing_nut_height', type: 'float', initial: 1.8, step: 0.05, caption: 'Nut Height'}
    {name: 'bearings_washers_height', type: 'float', initial: 0.9, step: 0.05, caption: 'Washers Height'}
    {name: 'bearings_washers_radius', type: 'float', initial: 4.5, step: 0.1, caption: 'Washers Radius'}
    get_yes_no_choice_parameter('render_bearings', 'Render')
  ]

exports.get_arms_parameters = ->
  return [
    {name: 'arms', caption: 'Bearings Holder', type: 'group'}
    {name: 'arms_num', type: 'float', initial: 5, step: 1, caption: 'Number of Arms'}
    {name: 'arm_height', type: 'float', initial: 3, step: 0.25, caption: 'Arm Height'}
    {name: 'arm_radius', type: 'float', initial: 20, step: 0.5, caption: 'Arm Radius'}
    {name: 'arms_shaft_radius', type: 'float', initial: 6, step: 0.25, caption: 'Shaft Radius'}
    {name: 'arms_shaft_top_height', type: 'float', initial: 8, step: 1, caption: 'Shaft Top Height'}
    get_yes_no_choice_parameter('render_arms', 'Render')
  ]

exports.get_enclosure_parameters = ->
  return [
    {name: 'enclosure', caption: 'Enclosure', type: 'group'}
    {name: 'box_width', type: 'float', initial: 58, step: 0.5, caption: 'Box Width'}
    {name: 'thumb_screw_diameter', type: 'float', initial: 8.5, step: 0.5, caption: 'Thumb Screw Diameter'}
    {name: 'thumb_screw_length', type: 'float', initial: 9.5, step: 0.5, caption: 'Thumb Screw Length'}
    {name: 'tubing_outer_radius', type: 'float', initial: 2.5, step: 0.05, caption: 'Tubing Outer Radius'}
    {name: 'tubing_inner_radius', type: 'float', initial: 1.5, step: 0.05, caption: 'Tubing Inner Radius'}
    {
      name: 'enclosure_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M3'
      caption: 'Screw Type'
    }
    get_yes_no_choice_parameter('render_enclosure', 'Render')
  ]

exports.get_general_parameters = ->
  return [
    {name: 'general', caption: 'General', type: 'group'}
    {name: 'clearance', type: 'float', initial: 0.3, step: 0.025, caption: 'Objects Clearance'}
    {
      name: 'render_style'
      type: 'choice'
      caption: 'Render'
      values: [
        'Assembled',
        '3D Printer Ready'
      ]
      initial: 'Assembled'
    }
  ]

exports.get_all_parameters = ->
  return []
    .concat exports.get_motor_parameters()
    .concat exports.get_bearings_parameters()
    .concat exports.get_arms_parameters()
    .concat exports.get_enclosure_parameters()
    .concat exports.get_general_parameters()

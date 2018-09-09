# title      : parameters
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : peristaltic pump, parameters
# file       : parameters.coffee

screws = require './screws.coffee'

exports.get_motor_parameters = ->
  return [
    {name: 'motor_mounting', caption: 'Motor Mount', type: 'group'}
    {name: 'motor_shaft_radius', type: 'float', initial: 2.5, step: 0.25, caption: 'Shaft radius'}
    {name: 'motor_shaft_height', type: 'float', initial: 24.0, step: 0.5, caption: 'Shaft height'}

    {name: 'motor_ring_radius', type: 'float', initial: 11.0, step: 0.1, caption: 'Ring radius'}
    {name: 'motor_ring_height', type: 'float', initial: 2.0, step: 0.1, caption: 'Ring height'}

    {name: 'motor_mountingholes_offset', type: 'float', initial: 15.5, step: 0.1, caption: 'holes offset'}
    {name: 'motor_mountingholes_radius', type: 'float', initial: 1.5, step: 0.1, caption: 'holes radius'}
    {name: 'motor_mountingholes_depth', type: 'float', initial: 4.5, step: 0.1, caption: 'holes depth'}
  ]

exports.get_bearings_parameters = ->
  return [
    {name: 'bearings', caption: 'Bearings', type: 'group'}
    {name: 'bearings_height', type: 'float', initial: 5, step: 1, caption: 'height'}
    {name: 'bearings_washers_height', type: 'float', initial: 0.5, step: 0.1, caption: 'washers height'}
    {name: 'bearings_washers_radius', type: 'float', initial: 4.5, step: 0.1, caption: 'washers radius'}
    {name: 'bearing_outer_radius', type: 'float', initial: 5, step: 0.25, caption: 'outer radius'}
    {
      name: 'bearing_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M3'
      caption: 'Screw type'
    }
    {name: 'bearing_nut_height', type: 'float', initial: 1.5, step: 0.1, caption: 'nut height'}
  ]

exports.get_arms_parameters = ->
  return [
    {name: 'arms', caption: 'Bearings Holder', type: 'group'}
    {name: 'arms_num', type: 'float', initial: 5, step: 1, caption: 'Number of Arms'}
    {name: 'arm_height', type: 'float', initial: 3, step: 0.25, caption: 'Arm height'}
    {name: 'arm_radius', type: 'float', initial: 19, step: 0.5, caption: 'Arm radius'}
    {name: 'arms_shaft_radius', type: 'float', initial: 4, step: 0.25, caption: 'Arms Shaft radius'}
    {name: 'arms_shaft_top_height', type: 'float', initial: 8, step: 1, caption: 'Arms Shaft top height'}
  ]

exports.get_enclosure_parameters = ->
  return [
    {name: 'enclosure', caption: 'Enclosure', type: 'group'}
    {
      name: 'enclosure_screw_type'
      type: 'choice'
      values: screws.available_screw_types
      initial: 'M3'
      caption: 'Screw type'
    }
  ]

exports.get_general_parameters = ->
  return [
    {name: 'general', caption: 'General', type: 'group'}
    {name: 'clearance', type: 'float', initial: 0.4, step: 0.025, caption: 'Objects Clearance'}
  ]

exports.get_all_parameters = ->
  return []
    .concat exports.get_motor_parameters()
    .concat exports.get_bearings_parameters()
    .concat exports.get_arms_parameters()
    .concat exports.get_enclosure_parameters()
    .concat exports.get_general_parameters()

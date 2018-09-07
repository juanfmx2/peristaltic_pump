# title      : util
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : util
# file       : util.coffee
_ = require 'underscore'

exports.create_extruded_regular_polygon = (r, h, s)->
  return linear_extrude({height: h}, circle({r: r, fn: s, center: true}))

exports.create_extruded_text = (text, text_height, line_width, z_h)->
  text_lines = vector_text(0, 0, text)
  extruded_lines = []
  text_lines.forEach (pl)->
    extruded_lines.push(rectangular_extrude(pl, {w: line_width, h: z_h}))
  joined_text = union(extruded_lines)
  text_dimensions = exports.get_object_dimensions joined_text
  scale_factor = text_height/text_dimensions.y
  return scale([scale_factor, scale_factor, 1], joined_text)

exports.create_extruded_text_around_cylinder = (text, text_height, line_width, text_depth, cyl_radius)->
  cur_angle = 0
  extruded_positioned_text = []
  for char_i in text
    char_lines = vector_text(0, 0, char_i)
    extruded_char = []
    char_lines.forEach (pl)->
      extruded_char.push(rectangular_extrude(pl, {w: line_width, h: text_depth}))
    text_dimensions = null
    if extruded_char.length > 0
      extruded_char = union(extruded_char)
      text_dimensions = exports.get_object_dimensions extruded_char
      scale_factor = text_height/text_dimensions.y
      extruded_char = extruded_char.scale([scale_factor, scale_factor, 1])
      text_dimensions = exports.get_object_dimensions extruded_char
      # move half angle of current char before drawing
      cur_angle +=  Math.atan(text_dimensions.x*1.01/(2*cyl_radius)) * 180 / Math.PI
      extruded_char = extruded_char.center('x', 'y', 'z')
        .translate([0, -text_dimensions.y/2, text_dimensions.z/2]).rotateX(90)
        .translate([0, -cyl_radius, 0]).rotateZ(cur_angle)
      extruded_positioned_text.push(extruded_char)
    # move half angle of current char after drawing
    x_delta = if text_dimensions? then text_dimensions.x else text_height
    cur_angle +=  Math.atan(x_delta*1.01/(2*cyl_radius)) * 180 / Math.PI
  return union(extruded_positioned_text)


exports.get_object_dimensions = (geom_obj)->
  if geom_obj.getBounds?
    bounds = geom_obj.getBounds()
    if bounds.length != 2
      throw 'Why more than 2 points?'
    dimensions = {}
    if bounds[0].x?
      dimensions.x = bounds[1].x-bounds[0].x
    if bounds[0].y?
      dimensions.y = bounds[1].y-bounds[0].y
    if bounds[0].z?
      dimensions.z = bounds[1].z-bounds[0].z
    return dimensions
  else
    throw 'Does not have bounds!'

exports.scale_to = (geom_obj, desired_x, desired_y, desired_z)->
  geom_dims = exports.get_object_dimensions geom_obj
  xy_only = !desired_z?
  x_factor = desired_x/geom_dims.x
  y_factor = desired_y/geom_dims.y
  if !xy_only
    z_factor = desired_z/geom_dims.z
    return geom_obj.scale([x_factor, y_factor, z_factor])
  return geom_obj.scale([x_factor, y_factor])
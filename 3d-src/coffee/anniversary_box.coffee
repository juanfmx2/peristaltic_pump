# title      : Anniversary Gift
# author     : Juan F. Mosquera
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : anniversary, Anna Kuroshchenkova, Juan Felipe Mosquera Morales
# file       : anniversary_box.coffee
util = require './util.coffee'
cat_lines = require './cat_lines.coffee'

get_heart_polygon = (heart_radius)->
  half_heart = new CSG.Path2D([[0, 0], [0, 3*heart_radius]], false)
  half_heart = half_heart.appendBezier(
      [
          [0, 4*heart_radius],
          [heart_radius, 4*heart_radius],
          [heart_radius, 4*heart_radius]
      ]
  )
  half_heart = half_heart.appendBezier(
      [
          [2*heart_radius, 4*heart_radius],
          [2*heart_radius, 3*heart_radius],
          [2*heart_radius, 3*heart_radius]
      ]
  )
  half_heart = half_heart.appendBezier(
      [
          [2*heart_radius, 2*heart_radius],
          [0.5*heart_radius, 2*heart_radius],
          [0, 0]
      ]
  )
  half_heart = half_heart.close()
  half_heart = polygon(half_heart)
  return union(half_heart, half_heart.mirroredX())

get_extruded_dove_tail_rails = (front_polygon, box_width)->
  extruded_p = rotateExtrude(
      translate([box_width*3/8, 0, 0], front_polygon),
      {'resolution':1,'angle':90}
  ).rotateZ(-90)
  return [
    extruded_p,
    translate([box_width, box_width, 0], extruded_p.rotateZ(180))
  ]

get_top_box = (params, box_width, box_height, clearance, heart_offset)->
  top_height = box_height*2/3
  heart = get_heart_polygon(params.heart_radius + clearance/2)
  heart_box = cube({size:[box_width, box_width, top_height-clearance/2], round: true}).translate([0, 0, clearance/2])
  dovetail_rails = get_extruded_dove_tail_rails(heart, box_width)
  top_box = difference(
    heart_box,
    dovetail_rails[0].translate([0, 0, -heart_offset]),
    dovetail_rails[1].translate([0, 0, -heart_offset])
  ).translate([0, 0, box_height/3])

  # Texts
  ak_text = util.create_extruded_text('AK', 2*params.heart_radius, 2, params.text_depth).rotateX(90)
    .translate([box_width*7/12, params.text_depth, box_height/2])
  jf_text = util.create_extruded_text('JF', 2*params.heart_radius, 2, params.text_depth).rotateX(90).rotateZ(180)
    .translate([box_width*5/12, box_width-params.text_depth, box_height/2])
  ayear_text = util.create_extruded_text('86', 2*params.heart_radius, 2, params.text_depth).rotateX(90).rotateZ(90)
    .translate([box_width-params.text_depth, box_width*1/12, box_height/2])
  jyear_text = util.create_extruded_text('89', 2*params.heart_radius, 2, params.text_depth).rotateX(90).rotateZ(270)
    .translate([params.text_depth, box_width*11/12, box_height/2])
  top_box = difference(top_box, ak_text, jf_text, ayear_text, jyear_text)

  # Top cat silhouette
  cat_shape = cat_lines.get_cat_lines()
  cat_shape = util.scale_to(cat_shape, 0.8*box_width, 0.8*box_width, params.text_depth)
    .translate([box_width/2, box_width/2, box_height-params.text_depth])
  top_box = difference(top_box, cat_shape)
  return color(
    'yellow',top_box
  )

get_bottom_box = (box_width, bottom_height, heart_radius, clearance, heart_offset)->
  heart = get_heart_polygon(heart_radius)
  heart_box = cube({size:[box_width, box_width, bottom_height-clearance/2], round: true, resolution: 10})
  dovetail_rails = get_extruded_dove_tail_rails(heart, box_width)
  return color(
    'blue',
    union(
      heart_box,
      dovetail_rails[0].translate([0, 0, bottom_height-heart_offset+clearance/2]),
      dovetail_rails[1].translate([0, 0, bottom_height-heart_offset+clearance/2])
    )
  )

get_ring = (ring_perimeter, ring_height, ring_text)->
  delta_walls = 2.5
  ring_radius = ring_perimeter/(2*Math.PI)
  inner_s = cylinder({r: ring_radius, h: 30, center: true})
  outer_s = sphere({r: ring_radius+delta_walls, fn: 100, type: 'geodesic', center: true})
  trimming_cube_h = ring_radius+delta_walls-ring_height/2
  trimming_cube = cube
    size: [
      2*(ring_radius+delta_walls),
      2*(ring_radius+delta_walls),
      trimming_cube_h
    ]
    center:true

  r_shell = difference(
    outer_s, inner_s,
    trimming_cube.translate([0, 0, (ring_height+trimming_cube_h)/2]),
    trimming_cube.translate([0, 0, -(ring_height+trimming_cube_h)/2])
  )
  text_geom = util.create_extruded_text_around_cylinder(ring_text, ring_height*0.5, 2, 3, ring_radius)
  return union(r_shell, text_geom.translate([0, 0, ring_height * 0.25]))

get_rings = (params)->
  ring_height = 10
  j_ring = get_ring(params.juan_finger_perimeter, ring_height, 'JM&AK')
  a_ring = get_ring(params.anna_finger_perimeter, ring_height, 'AK&JM')
  return union(
    j_ring.translate([-25, 0, ring_height/2]).setColor(css2rgb('green')),
    a_ring.translate([0, -25, ring_height/2]).setColor(css2rgb('green'))
  )

global.getParameterDefinitions = ->
  params_definition = [
    {
      name: 'draw_selection'
      type: 'choice'
      caption: 'What to draw?'
      values: ['Everything', 'Bottom Box', 'Top Box', 'Rings']
      initial: 'Everything'
    }
    {
      name: 'heart_radius',
      type: 'float',
      initial: 10,
      step: 0.25,
      caption: 'Heart Radius'
    }
    {
      name: 'text_depth',
      type: 'float',
      initial: 2.5,
      step: 0.25,
      caption: 'Text Depth'
    }
    {
      name: 'anna_finger_perimeter',
      type: 'float',
      initial: 56.5,
      step: 0.5,
      caption: "Anna's finger perimeter"
    }
    {
      name: 'juan_finger_perimeter',
      type: 'float',
      initial: 63,
      step: 0.5,
      caption: "Juan's finger perimeter"
    }
  ]
  return params_definition

global.main = (params)->
  parts_clearance = 0.25
  box_width = 10*params.heart_radius
  box_height = 6*params.heart_radius
  heart_offset = params.heart_radius

  inner_hole_radius = 2.7*params.heart_radius
  inner_hole = sphere({r: inner_hole_radius, fn: 100, type: 'geodesic'})\
    .translate([box_width/2, box_width/2, (box_height-inner_hole_radius-params.text_depth)])

  top_box = cube()
  bottom_box = cube()
  rings = cube()
  if params.draw_selection == 'Everything' or params.draw_selection == 'Top Box'
    top_box = get_top_box(params, box_width, box_height, parts_clearance, heart_offset)
    top_box = difference(top_box, inner_hole)

  if params.draw_selection == 'Everything' or params.draw_selection == 'Bottom Box'
    bottom_box = get_bottom_box(box_width, box_height/3, params.heart_radius, parts_clearance, heart_offset)
    bottom_box = difference(bottom_box, inner_hole)

  if params.draw_selection == 'Everything' or params.draw_selection == 'Rings'
    rings = get_rings params

  if params.draw_selection == 'Everything'
    return [top_box, bottom_box, rings]
  else if params.draw_selection == 'Top Box'
    tb_dims = util.get_object_dimensions(top_box)
    return top_box.rotateX(180).center('x','y','z').translate([0, 0, tb_dims.z/2])
  else if params.draw_selection == 'Bottom Box'
    return bottom_box.center('x','y')
  else if params.draw_selection == 'Rings'
    return rings

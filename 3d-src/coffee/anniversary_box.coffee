# title      : Anniversary Gift
# author     : Juan F. Mosquera
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : anniversary, Anna Kuroshchenkova, Juan Felipe Mosquera Morales
# file       : anniversary_box.coffee

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

get_top_box = (box_width, top_height, heart_radius, clearance, heart_offset)->
  heart = get_heart_polygon(heart_radius + clearance/2)
  heart_box = cube({size:[box_width, box_width, top_height-clearance/2], round: true}).translate([0, 0, clearance/2])
  dovetail_rails = get_extruded_dove_tail_rails(heart, box_width)
  return color(
    'yellow',
    difference(
      heart_box,
      dovetail_rails[0].translate([0, 0, -heart_offset]),
      dovetail_rails[1].translate([0, 0, -heart_offset])
    )
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
      initial: 5,
      step: 0.25,
      caption: 'Heart Radius'
    }
    {
      name: 'anna_finger_perimeter',
      type: 'float',
      initial: 5,
      step: 0.5,
      caption: "Anna's finger perimeter"
    }
    {
      name: 'juan_finger_perimeter',
      type: 'float',
      initial: 5,
      step: 0.5,
      caption: "Juan's finger perimeter"
    }
  ]
  return params_definition

global.main = (params)->
  base_heart_radius = params.heart_radius
  parts_clearance = 0.25
  box_width = 10*base_heart_radius
  box_height = 6*base_heart_radius
  heart_offset = base_heart_radius
  top_box = get_top_box(box_width, box_height*2/3, base_heart_radius, parts_clearance, heart_offset)\
    .translate([0, 0, box_height/3])
  bottom_box = get_bottom_box(box_width, box_height/3, base_heart_radius, parts_clearance, heart_offset)
  inner_hole_radius = 3*base_heart_radius
  inner_hole = sphere({r: inner_hole_radius, fn: 100, type: 'geodesic'})\
    .translate([box_width/2, box_width/2, (box_height-inner_hole_radius)])
  top_box = difference(top_box, inner_hole)
  bottom_box = difference(bottom_box, inner_hole)
  return [top_box, bottom_box]


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
  boxWidth = 8*base_heart_radius
  heart = get_heart_polygon base_heart_radius
  heartBox = cube({size:[boxWidth, boxWidth,4*base_heart_radius]})
  extruded_heart = rotateExtrude(
      translate([4*base_heart_radius, 0, 0], heart),
      {'resolution':1,'angle':90}
  ).rotateZ(-90)
  extruded_heart_2 = extruded_heart.rotateZ(180)
  extruded_heart_2 = translate([boxWidth, boxWidth,0], extruded_heart_2)
  return [difference(heartBox, extruded_heart, extruded_heart_2)]


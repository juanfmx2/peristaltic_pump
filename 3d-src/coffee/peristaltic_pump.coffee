# title      : Peristaltic Pump
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : peristaltic, pump
# file       : peristaltic_pump.coffee
parameters = require('./parameters.coffee')
screws = require './screws.coffee'
util = require './util.coffee'

create_base_and_screws = (params)->
  base_screw = cylinder(
    {
      r: params.motor_mountingholes_radius
      h: params.motor_mountingholes_depth
      center: [true, true, false]
    }
  )

  base_screws_holes = create_screw_holes_by_offset(base_screw, params.motor_mountingholes_offset)

  base_w = 2 * (params.motor_mountingholes_offset + 2*params.motor_mountingholes_radius)

  motor_base = cube({size: [base_w, base_w, params.motor_mountingholes_depth], center: [true, true, false]})
  motor_base = union(
    motor_base, cylinder({
      r: params.motor_ring_radius
      h: params.motor_ring_height + params.motor_mountingholes_depth
      center:[true, true, false]
    })
  )
  motor_base = difference(
    motor_base, cylinder({
      r: params.motor_shaft_radius + 0.25
      h: params.motor_shaft_height + params.motor_mountingholes_depth
      center:[true, true, false]
    })
  )
  shaft = cylinder({
    r: params.motor_shaft_radius
    h: params.motor_shaft_height + params.motor_mountingholes_depth
    center:[true, true, false]
  })
  motor_base = difference(motor_base, base_screws_holes)
  motor_base = color('darkgrey', motor_base)
  shaft = color('grey', shaft)
  return union(motor_base, shaft)

get_arms_delta = (params)->
  return params.bearings_height + 2 * (params.bearings_washers_height + params.clearance)

create_arms_shaft_tower = (params)->
  cur_screw = screws.get_screw_by_type params.bearing_screw_type
  arms_delta = get_arms_delta params

  shaft_section_r = params.arms_shaft_radius
  shaft_closing_section_r = params.motor_shaft_radius + 0.75
  shaft_wide_section_r = params.arms_shaft_radius + 1

  shaft_tower_path = new CSG.Path2D([[params.motor_shaft_radius + 0.1, 0], [shaft_wide_section_r, 0]], false)
  cur_y = params.arm_height
  shaft_tower_path = shaft_tower_path.appendPoint([shaft_wide_section_r, cur_y])
  shaft_tower_path = shaft_tower_path.appendBezier(
    [[shaft_wide_section_r, cur_y], [shaft_section_r, cur_y], [shaft_section_r, cur_y + 1]]
  )
  cur_y += arms_delta
  shaft_tower_path = shaft_tower_path.appendPoint([shaft_section_r, cur_y - 1])
  shaft_tower_path = shaft_tower_path.appendBezier(
    [[shaft_section_r, cur_y], [shaft_wide_section_r, cur_y], [shaft_wide_section_r, cur_y]]
  )
  cur_y += params.arm_height
  shaft_tower_path = shaft_tower_path.appendPoint([shaft_wide_section_r, cur_y])
  shaft_tower_path = shaft_tower_path.appendBezier(
    [[shaft_wide_section_r, cur_y], [shaft_section_r, cur_y], [shaft_section_r, cur_y + 1]]
  )
  cur_y += params.arms_shaft_top_height
  shaft_tower_path = shaft_tower_path.appendPoint([shaft_section_r, cur_y - 1])
  shaft_tower_path = shaft_tower_path.appendBezier(
    [[shaft_section_r, cur_y], [shaft_closing_section_r, cur_y], [shaft_closing_section_r, cur_y]]
  )
  shaft_tower_path = shaft_tower_path.appendPoint([params.motor_shaft_radius + 0.1, cur_y])
  shaft_tower_path = shaft_tower_path.close()

  shaft_tower_silhouette = polygon(shaft_tower_path)

  shaft_tower = rotate_extrude(shaft_tower_silhouette)
  position_holder_nut_geom = (geom_obj)->
    geom_obj = rotate([0, 90, 0], geom_obj)
    geom_obj = translate(
      [params.motor_shaft_radius + 1, 0, 2 * params.arm_height + arms_delta + params.arms_shaft_top_height/2],
      geom_obj
    )
    return rotate([0, 0, 180/params.arms_num], geom_obj)
  # Use half a clearance here as there is more precision from the printer
  hex_nut_hole = cur_screw.draw_nut_hole(params.bearing_nut_height, params.clearance/2)
  hex_nut_hole_dims = util.get_object_dimensions hex_nut_hole
  hex_nut_hole = union(
    hex_nut_hole,
    # Use the dimensions of the hexagon in y as it will be the spanner width
    cube({center:[true,true,false]}).scale([hex_nut_hole_dims.y, hex_nut_hole_dims.y, hex_nut_hole_dims.z])
      .translate([-hex_nut_hole_dims.y/2,0,0])
  )
  hex_nut_hole = union(hex_nut_hole, cylinder({r: cur_screw.radius, h: 10, center: true}))
  hex_nut_hole = position_holder_nut_geom(hex_nut_hole)

  hex_nut_hole_wrapper = util.create_extruded_regular_polygon(
    cur_screw.nut_radius + 1.7, params.bearing_nut_height + 2*(params.clearance + 0.8), 6
  )
  hex_nut_hole_wrapper = position_holder_nut_geom(hex_nut_hole_wrapper)

  shaft_tower = union(shaft_tower, hex_nut_hole_wrapper)
  shaft_tower = difference(
    shaft_tower, hex_nut_hole,
    cylinder(
      {
        r: params.arm_radius
        h: 10
        center:[true, true, false]
      }
    ).translate([0, 0, 2*(params.arm_height) + arms_delta + params.arms_shaft_top_height])
  )

  return shaft_tower

create_pump_arms = (params)->
  cur_screw = screws.get_screw_by_type params.bearing_screw_type
  
  arm_tip_radius = (params.bearing_outer_radius + cur_screw.radius)/2
  radius_to_bearings = params.arm_radius - params.bearing_outer_radius
  arms_delta = get_arms_delta params

  arm_tip = translate([radius_to_bearings, 0, 0], circle({r: arm_tip_radius, center: true}))
  arms_shaft = circle({r: params.arms_shaft_radius + 1, center: true})
  middle_path = translate(
    [radius_to_bearings/2, cur_screw.radius, 0],
    circle({r: (params.arms_shaft_radius + arm_tip_radius) * 1 / 2, center: true})
  )
  middle_path_angle = Math.atan(cur_screw.radius/(radius_to_bearings/2)) * 180 / Math.PI

  base_arm = linear_extrude({height: params.arm_height},
    difference(
      chain_hull([arms_shaft, middle_path, arm_tip]),
      translate([radius_to_bearings, 0, 0], circle({r: cur_screw.radius, center: true}))
    )
  )

  hex_nut = util.create_extruded_regular_polygon(cur_screw.nut_radius, params.bearing_nut_height, 6)

  base_bottom_arm = difference(
    base_arm, translate([radius_to_bearings, 0, 0],
      rotate([0, 0, -middle_path_angle], hex_nut)
    )
  )

  base_top_arm = difference(
    base_arm,
    translate([radius_to_bearings, 0, params.arm_height - params.bearing_nut_height],
      rotate([0, 0, -middle_path_angle], hex_nut)
    )
  )
  base_top_arm = translate([0, 0, arms_delta + params.arm_height], base_top_arm)

  angle = 360/params.arms_num
  joined_arms_bottom = base_bottom_arm
  joined_arms_top = base_top_arm
  for i in [0..params.arms_num]
    joined_arms_bottom = union(joined_arms_bottom, rotate([0, 0, angle*i], base_bottom_arm))
    joined_arms_top = union(joined_arms_top, rotate([0, 0, angle*i], base_top_arm))

  shaft_tower = create_arms_shaft_tower params

  arms_holder = union(shaft_tower, joined_arms_bottom, joined_arms_top)
  arms_holder = color('green', arms_holder)
  arms_holder = difference(arms_holder, cylinder(
    {
      r: params.motor_shaft_radius + 0.1
      h: 50
      center: [true, true, false]
    }
  ))
  return arms_holder

create_bearings = (params)->
  cur_screw = screws.get_screw_by_type params.bearing_screw_type
  arms_delta = get_arms_delta params
  radius_to_bearings = params.arm_radius - params.bearing_outer_radius
  assembled = params.render_style == 'Assembled'
  washers_cyl = color(
    'white',
    cylinder({r: params.bearings_washers_radius, h: params.bearings_washers_height, center:[true, true, false]})
  )
  bearing_base_cyl = translate([0, 0, params.bearings_washers_height], color('gray',
    cylinder
      r: params.bearing_outer_radius
      h: params.bearings_height
      center:[true, true, false]
  ))
  if assembled
    bearing_base_cyl = union(
      washers_cyl,
      bearing_base_cyl,
      translate([0, 0, params.bearings_washers_height + params.bearings_height], washers_cyl)
    )
  bearing_base = difference(
    bearing_base_cyl,
    cylinder
      r: cur_screw.radius
      h: arms_delta
      center:[true, true, false]
  )
  bearing_base = translate([radius_to_bearings, 0, 0], bearing_base)
  all_bearings = bearing_base
  angle = 360/params.arms_num
  for i in [0..params.arms_num]
    all_bearings = union(all_bearings, rotate([0, 0, angle*i], bearing_base))
  return all_bearings

create_screw_hole = (params, head_radius, thread_radius, head_height, thread_height, z_inverted=false)->
  return union(
    cylinder(
      r: head_radius + 2*params.clearance
      h: head_height
      fn: 90
      center: [true, true, false]
    ).translate([0, 0, if z_inverted then 0 else thread_height]),
    cylinder(
      r: thread_radius
      h: thread_height
      fn: 90
      center: [true, true, false]
    ).translate([0, 0, if z_inverted then thread_height else 0])
  )

create_screw_nut_holes_by_offset = (screw_type, thread_height, offset, z_inverted=false)->
  hex_nut_hole = screw_type.draw_nut_hole(params.bearing_nut_height, params.clearance)
  hex_nut_hole_dims = util.get_object_dimensions hex_nut_hole
  hex_nut_hole = union(
    hex_nut_hole,
    # Use the dimensions of the hexagon in y as it will be the spanner width
    cube({center:[true,true,false]}).scale([3*hex_nut_hole_dims.y, hex_nut_hole_dims.y, hex_nut_hole_dims.z])
      .translate([-3*hex_nut_hole_dims.y/2,0,0])
  ).translate([0, 0, if z_inverted then 0 else thread_height])
  hex_nut_hole = union(
    hex_nut_hole,
    cylinder({r: screw_type.radius, h: thread_height, center: [true, true, false]})
      .translate([0, 0, if z_inverted then hex_nut_hole_dims.z else 0])
  )
  return union(
    translate([ offset,  offset, 0], hex_nut_hole.rotateZ(180))
    translate([ offset, -offset, 0], hex_nut_hole.rotateZ(180))
    translate([-offset,  offset, 0], hex_nut_hole)
    translate([-offset, -offset, 0], hex_nut_hole)
  )

create_screw_holes_by_offset = (base_screw_hole, offset)->
  return union(
    translate([ offset,  offset, 0], base_screw_hole)
    translate([ offset, -offset, 0], base_screw_hole)
    translate([-offset,  offset, 0], base_screw_hole)
    translate([-offset, -offset, 0], base_screw_hole)
  )

create_enclosure = (params)->
  enclosure_parts = []
  arms_delta = get_arms_delta params
  assembled = params.render_style == 'Assembled'
  cur_screw = screws.get_screw_by_type params.enclosure_screw_type
  compressed_tube_width = 2*(params.tubing_outer_radius - params.tubing_inner_radius) - params.clearance
  box_size = params.box_width
  lid_layer_height = 6
  middle_section_height = 2*(params.arm_height+params.clearance) + arms_delta + params.arms_shaft_top_height
  box_height = middle_section_height + lid_layer_height
  outer_screws_offset = box_size/2 - cur_screw.head_radius - 2

  base_box = CSG.roundedCube
    radius: [box_size/2, box_size/2, box_height/2]
    center: [0, 0, box_height/2]
    roundradius: 3,
    resolution: 20,

  cut_sphere_radius = box_size/2-cur_screw.head_diameter*2.3
  cut_sphere = sphere({r: cut_sphere_radius, fn: 30, type: 'geodesic'})
  translate_delta = box_size/2
  base_box = difference(
    base_box,
    cut_sphere.translate([ translate_delta,                0]),
    cut_sphere.translate([-translate_delta,                0]),
    cut_sphere.translate([               0,  translate_delta]),
    cut_sphere.translate([               0, -translate_delta]),
  )

  middle_and_lid_delete_geom = cube({
    size: [box_size, box_size, box_height - lid_layer_height],
    center: [true, true, false]
  })
  lid_delete_geom = cube({
    size: [box_size, box_size, lid_layer_height],
    center: [true, true, false]
  })
  base_screw_hole = create_screw_hole(
    params, cur_screw.head_radius, cur_screw.radius, lid_layer_height/2, lid_layer_height/2
  )
  base_screws_holes = create_screw_holes_by_offset(base_screw_hole, params.motor_mountingholes_offset)

  base_screw_hole_2_middle_section = create_screw_hole(
    params, params.thumb_screw_diameter/2, cur_screw.radius, lid_layer_height/2, lid_layer_height/2, true
  )
  base_screws_holes_2_middle_section = create_screw_holes_by_offset(
    base_screw_hole_2_middle_section, outer_screws_offset
  )
  mounting_motor_hole = cylinder({
    r: params.motor_ring_radius + 2*params.clearance
    h: lid_layer_height
    center:[true, true ,false]
    fn: 90
  })

  bottom_part = difference(
    base_box,
    mounting_motor_hole,
    base_screws_holes,
    base_screws_holes_2_middle_section,
    middle_and_lid_delete_geom.translate([0, 0, lid_layer_height])
  )
  bottom_part = color('blue', bottom_part)
  if not assembled
    bottom_part = bottom_part.rotateX(180).translate([0, 0, lid_layer_height])
  enclosure_parts.push bottom_part


  bottom_hole_height = params.arms_shaft_top_height - (cur_screw.head_height + params.clearance)

  inner_hole = cylinder({
    r: params.arm_radius + compressed_tube_width
    h: box_height - lid_layer_height - bottom_hole_height
    center:[true, true ,false]
    fn: 90
  }).translate([0, 0, lid_layer_height + bottom_hole_height])

  bottom_inner_hole = cylinder({
    r: params.motor_ring_radius + 2*params.clearance
    h: bottom_hole_height
    center:[true, true ,false]
    fn: 90
  }).translate([0, 0, lid_layer_height])

  tubing_hole = cylinder({
    r: params.tubing_outer_radius + params.clearance
    h: box_size/2
    center:[true, true ,false]
    fn: 90
  }).rotateX(90).translate(
    [
      0,
      box_size/2,
      (
        box_height - params.arm_height - arms_delta/2
      )
    ]
  )
  tubing_position_x = params.arm_radius + compressed_tube_width - (params.tubing_outer_radius + params.clearance)

  length_to_nut = params.thumb_screw_length - lid_layer_height/2 - params.bearing_nut_height
  middle_section_box = difference(
    base_box,
    inner_hole,
    bottom_inner_hole,
    lid_delete_geom,
    tubing_hole.translate([tubing_position_x, 0, 0]),
    tubing_hole.translate([-tubing_position_x, 0, 0]),
    create_screw_nut_holes_by_offset(cur_screw, length_to_nut, outer_screws_offset).translate([0, 0, lid_layer_height])
  )
  middle_section_box = union(
    middle_section_box,
    torus({ ri: params.arm_height/2, ro: params.arm_radius + compressed_tube_width, fni:4, fno:100})\
      .translate([0, 0, box_height-params.arm_height/2]),
    torus({ ri: params.arm_height/2, ro: params.arm_radius + compressed_tube_width, fni:4, fno:100})\
      .translate([0, 0, box_height-(3*params.arm_height/2 + arms_delta)])
  )
  cut_length = 2*box_size/3 + params.clearance
  trimming_box_1 = cube(
    {size:[box_size, cut_length, middle_section_height], center:[true, true, false]}
  ).translate(
    [0, -(box_size-cut_length)/2 , lid_layer_height]
  )
  middle_section_box_1 = difference(middle_section_box, trimming_box_1)
  middle_section_box_1 = color('yellow', middle_section_box_1)

  if not assembled
    middle_section_box_1 = middle_section_box_1.translate([0, box_size+5*params.clearance, -lid_layer_height])
  enclosure_parts.push middle_section_box_1

  cut_length = box_size - cut_length + 2*params.clearance
  trimming_box_2 = cube(
    {size:[box_size, cut_length, middle_section_height], center:[true, true, false]}
  ).translate(
    [0, (box_size-cut_length)/2 , lid_layer_height]
  )
  middle_section_box_2 = difference(middle_section_box, trimming_box_2)
  middle_section_box_2 = middle_section_box_2.setColor([0.7, 0.7, 0, 0.5])

  if not assembled
    middle_section_box_2 = middle_section_box_2.translate([0, box_size+5*params.clearance, -lid_layer_height])
  enclosure_parts.push middle_section_box_2

  return union enclosure_parts

get_pump_shapes = (params)->
  assembled = params.render_style == 'Assembled'
  shapes_to_draw = []

  arms_holder = null
  if params.render_arms == 'Yes'
    arms_holder = create_pump_arms params
    shapes_to_draw.push arms_holder

  bearings = null
  if params.render_bearings == 'Yes'
    bearings = create_bearings params
    shapes_to_draw.push bearings

  if params.render_arms == 'Yes' and params.render_bearings == 'Yes'
    a_b_intersection = intersection(
      arms_holder,
      bearings.translate(
        [0, 0, params.arm_height + params.clearance]
      )
    )
    intersections_dims = util.get_object_dimensions a_b_intersection
    if intersections_dims.x != 0 || intersections_dims.y != 0 || intersections_dims.z != 0
      alert 'Bearings and Arms are intersecting!'
      console.error 'Bearings and Arms are intersecting!'

  enclosure = null
  if params.render_enclosure == 'Yes'
    enclosure = create_enclosure params
    shapes_to_draw.push enclosure

  if assembled
    arms_z_pos = params.motor_mountingholes_depth + 6
    shapes_to_draw = []
    if arms_holder?
      arms_dims = util.get_object_dimensions(arms_holder)
      arms_holder = arms_holder.rotateX(180).translate([0, 0, arms_dims.z])
      shapes_to_draw.push arms_holder.translate([0, 0, arms_z_pos])
    if bearings?
      shapes_to_draw.push bearings.translate(
        [0, 0, arms_z_pos + params.arms_shaft_top_height + params.arm_height + params.clearance]
      )
    if enclosure?
      shapes_to_draw.push enclosure.translate([0, 0, params.motor_mountingholes_depth + params.clearance])
    shapes_to_draw.push create_base_and_screws(params)

  return shapes_to_draw

# ----------------------------------------------------------------------------------------------------------------------
# OpenJSCAD functions
# ----------------------------------------------------------------------------------------------------------------------

global.getParameterDefinitions = ->
  return parameters.get_all_parameters()

global.main = (params)->
  return get_pump_shapes(params)

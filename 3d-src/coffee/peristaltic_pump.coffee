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

  mh_offset = params.motor_mountingholes_offset

  base_screws_holes = union(
    translate([ mh_offset,  mh_offset, 0], base_screw)
    translate([ mh_offset, -mh_offset, 0], base_screw)
    translate([-mh_offset,  mh_offset, 0], base_screw)
    translate([-mh_offset, -mh_offset, 0], base_screw)
  )

  base_w = 2 * (mh_offset + 2*params.motor_mountingholes_radius)

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
  hex_nut_hole = cur_screw.draw_nut_hole(params.bearing_nut_height, params.clearance)
  hex_nut_hole_dims = util.get_object_dimensions hex_nut_hole
  hex_nut_hole = union(
    hex_nut_hole,
    cube({center:[true,true,false]}).scale(
      [hex_nut_hole_dims.x, hex_nut_hole_dims.x, hex_nut_hole_dims]).translate([-2.5,0,0]
    )
  )
  hex_nut_hole = union(hex_nut_hole, cylinder({r: cur_screw.radius, h: 10, center: true}))
  hex_nut_hole = position_holder_nut_geom(hex_nut_hole)

  hex_nut_hole_wrapper = util.create_extruded_regular_polygon(
    cur_screw.nut_radius+1.5, params.bearing_nut_height + 2*(params.clearance+1), 6
  )
  hex_nut_hole_wrapper = position_holder_nut_geom(hex_nut_hole_wrapper)

  shaft_tower = union(shaft_tower, hex_nut_hole_wrapper)
  shaft_tower = difference(shaft_tower, hex_nut_hole)

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
  washer = color(
    'white',
    cylinder({r: params.bearings_washers_radius, h: params.bearings_washers_height, center:[true, true, false]})
  )

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

  bearing_base = difference(
    union(
      washer,
      translate(
        [0, 0, params.bearings_washers_height],
        color('gray',
          cylinder
            r: params.bearing_outer_radius
            h: params.bearings_height
            center:[true, true, false]
        )
      ),
      translate([0, 0, params.bearings_washers_height + params.bearings_height], washer)
    ),
    cylinder
      r: cur_screw.radius
      h: arms_delta
      center:[true, true, false]
  )
  bearing_base = translate([radius_to_bearings, 0, params.arm_height + params.clearance], bearing_base)

  angle = 360/params.arms_num
  joined_arms_bottom = base_bottom_arm
  joined_arms_top = base_top_arm
  joined_bearings = bearing_base
  for i in [0..params.arms_num]
    joined_arms_bottom = union(joined_arms_bottom, rotate([0, 0, angle*i], base_bottom_arm))
    joined_arms_top = union(joined_arms_top, rotate([0, 0, angle*i], base_top_arm))
    joined_bearings = union(joined_bearings, rotate([0, 0, angle*i], bearing_base))

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
  a_b_intersection = intersection(arms_holder, joined_bearings)
  intersections_dims = util.get_object_dimensions a_b_intersection
  if intersections_dims.x != 0 || intersections_dims.y != 0 || intersections_dims.z != 0
    alert 'Bearings and Arms are intersecting!'
    console.error 'Bearings and Arms are intersecting!'
  return union(arms_holder, joined_bearings)


get_rendering_forms = (params)->
  base_and_screws = create_base_and_screws(params)
  arms = create_pump_arms(params)
  arms = translate([0, 0, params.motor_mountingholes_depth + params.motor_ring_height + 1], arms)
  enclosure = difference(
    cylinder({r: params.arm_radius + 7, h: 20, center:[true, true ,false]}),
    cylinder({r: params.arm_radius + 2, h: 20, center:[true, true ,false]})
  )
  return [base_and_screws, arms, enclosure]

# ----------------------------------------------------------------------------------------------------------------------
# OpenJSCAD functions
# ----------------------------------------------------------------------------------------------------------------------

global.getParameterDefinitions = ->
  return parameters.get_all_parameters()

global.main = (params)->
  return get_rendering_forms(params)

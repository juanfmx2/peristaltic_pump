# title      : Peristaltic Pump
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : peristaltic, pump
# file       : peristaltic_pump.coffee
get_motor_parameters = require('./parameters.coffee').get_motor_parameters

create_base_and_screws = (params)->
  baseScrew = cylinder(
    {
      r: params.motor_mountingholes_radius
      h: params.motor_mountingholes_screw_h
      center: [true, true, false]
    }
  )

  mhOffset = params.motor_mountingholes_offset

  screws = union(
    translate([ mhOffset,  mhOffset, 0], baseScrew)
    translate([ mhOffset, -mhOffset, 0], baseScrew)
    translate([-mhOffset,  mhOffset, 0], baseScrew)
    translate([-mhOffset, -mhOffset, 0], baseScrew)
  )

  baseW = 2 * (mhOffset + 2*params.motor_mountingholes_radius)

  base = cube({size: [baseW, baseW, params.motor_mountingholes_depth], center: [true, true, false]})
  base = union(
    base, cylinder({
      r: params.motor_ring_radius
      h: params.motor_ring_height + params.motor_mountingholes_depth
      center:[true, true, false]
    })
  )
  base = difference(
    base, cylinder({
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
  base = difference(base, screws)
  base = color('darkgrey', base)
  shaft = color('grey', shaft)
  screws = color('Red', screws)
  return union(base, shaft, screws)


create_extruded_regular_polygon = (r, h, s)->
  return linear_extrude({height: h}, circle({r: r, fn: s, center: true}))


createPumpArms = (params)->
  armTipRadius = (params.bearing_outer_radius + params.bearing_inner_radius)/2
  radiusToBearings = params.arm_radius - params.bearing_outer_radius
  armsDelta = params.bearings_height + 2 * params.bearings_washers_height

  armTip = translate([radiusToBearings, 0, 0], circle({r: armTipRadius, center: true}))
  armsShaft = circle({r: params.arms_shaft_radius + 1, center: true})
  middlePath = translate(
    [radiusToBearings/2, params.bearing_inner_radius, 0],
    circle({r: (params.arms_shaft_radius + armTipRadius) * 1 / 2, center: true})
  )
  middlePathAngle = Math.atan(params.bearing_inner_radius/(radiusToBearings/2)) * 180 / Math.PI

  baseArm = linear_extrude({height: params.arm_height},
    difference(
      chain_hull([armsShaft, middlePath, armTip]),
      translate([radiusToBearings, 0, 0], circle({r: params.bearing_inner_radius, center: true}))
    )
  )

  hexNut = create_extruded_regular_polygon(params.bearing_nut_radius, params.bearing_nut_height, 6)
  washer = color(
    'white',
    cylinder({r: params.bearings_washers_radius, h: params.bearings_washers_height, center:[true, true, false]})
  )

  baseBottomArm = difference(
    baseArm, translate([radiusToBearings, 0, 0],
      rotate([0, 0, -middlePathAngle], hexNut)
    )
  )

  baseTopArm = difference(
    baseArm,
    translate([radiusToBearings, 0, params.arm_height - params.bearing_nut_height],
      rotate([0, 0, -middlePathAngle], hexNut)
    )
  )
  baseTopArm = translate([0, 0, armsDelta + params.arm_height], baseTopArm)

  bearingBase = difference(
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
      r: params.bearing_inner_radius
      h: armsDelta
      center:[true, true, false]
  )
  bearingBase = translate([radiusToBearings, 0, params.arm_height], bearingBase)

  angle = 360/params.arms_num
  joinedArmsBottom = baseBottomArm
  joinedArmsTop = baseTopArm
  joinedBearings = bearingBase
  for i in [0..params.arms_num]
    joinedArmsBottom = union(joinedArmsBottom, rotate([0, 0, angle*i], baseBottomArm))
    joinedArmsTop = union(joinedArmsTop, rotate([0, 0, angle*i], baseTopArm))
    joinedBearings = union(joinedBearings, rotate([0, 0, angle*i], bearingBase))

  shaftSectionR = params.arms_shaft_radius
  shaftClosingSectionR = params.motor_shaft_radius + 0.5
  shaftWideSectionR = params.arms_shaft_radius + 1

  shaftTowerPath =  new CSG.Path2D([[params.motor_shaft_radius + 0.1, 0], [shaftWideSectionR, 0]], false)
  curY = params.arm_height
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY])
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]])
  curY += armsDelta
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1])
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftWideSectionR, curY], [shaftWideSectionR, curY]])
  curY += params.arm_height
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY])
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]])
  curY += params.arms_shaft_top_height
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1])
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftClosingSectionR, curY], [shaftClosingSectionR, curY]])
  shaftTowerPath = shaftTowerPath.appendPoint([params.motor_shaft_radius + 0.1, curY])
  shaftTowerPath = shaftTowerPath.close()

  shaftTowerSiloutte = polygon(shaftTowerPath)

  shaftTower = rotate_extrude(shaftTowerSiloutte)

  positionHolderNutGeom = (geomObj)->
    geomObj = rotate([0, 90, 0], geomObj)
    geomObj = translate(
      [params.motor_shaft_radius + 1, 0, 2 * params.arm_height + armsDelta + params.arms_shaft_top_height/2],
      geomObj
    )
    return rotate([0, 0, angle/2], geomObj)

  hexNutHole = create_extruded_regular_polygon(params.bearing_nut_radius, params.bearing_nut_height * 2, 6)
  hexNutHole = union(hexNutHole, cylinder({r: params.bearing_inner_radius, h: 3, center: true}))
  hexNutHole = positionHolderNutGeom(hexNutHole)

  hexNutHoleWrapper = create_extruded_regular_polygon(params.bearing_nut_radius+1, params.bearing_nut_height * 2, 6)
  hexNutHoleWrapper = positionHolderNutGeom(hexNutHoleWrapper)

  shaftTower = union(shaftTower, hexNutHoleWrapper)
  shaftTower = difference(shaftTower, hexNutHole)

  armsHolder = union(shaftTower, joinedArmsBottom, joinedArmsTop)
  armsHolder = color('green', armsHolder)
  return union(armsHolder, joinedBearings)


get_rendering_forms = (params)->
  baseAndScrews = create_base_and_screws(params)
  arms = createPumpArms(params)
  arms = translate([0, 0, params.motor_mountingholes_depth + params.motor_ring_height + 1], arms)
  enclosure = difference(
    cylinder({r: params.arm_radius + 7, h: 20, center:[true, true ,false]}),
    cylinder({r: params.arm_radius + 2, h: 20, center:[true, true ,false]})
  )
  return [arms,baseAndScrews, enclosure]

global.getParameterDefinitions = ->
  params_definition = []
  params_definition = params_definition.concat(get_motor_parameters())
  return params_definition

global.main = (params)->
  return get_rendering_forms(params)

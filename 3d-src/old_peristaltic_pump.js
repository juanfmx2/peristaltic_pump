// title      : OpenJSCAD.org Logo
// author     : Rene K. Mueller
// license    : MIT License
// revision   : 0.003
// tags       : Logo,Intersection,Sphere,Cube
// file       : peristaltic_pump.jscad

function getParameterDefinitions () {
  return [

    {name: 'arms_num', type: 'float', initial: 5, step: 1, caption: 'Number of Arms'},
    {name: 'arm_height', type: 'float', initial: 3, step: 0.25, caption: 'Arm height'},
    {name: 'arm_radius', type: 'float', initial: 19, step: 0.5, caption: 'Arm radius'},
    {name: 'arms_shaft_radius', type: 'float', initial: 4, step: 0.25, caption: 'Arms Shaft radius'},
    {name: 'arms_shaft_top_height', type: 'float', initial: 8, step: 1, caption: 'Arms Shaft top height'},

    {name: 'bearings_height', type: 'float', initial: 5, step: 1, caption: 'Bearings height'},
    {name: 'bearings_washers_height', type: 'float', initial: 0.5, step: 0.1, caption: 'Bearings washers height'},
    {name: 'bearings_washers_radius', type: 'float', initial: 4.5, step: 0.1, caption: 'Bearings washers radius'},
    {name: 'bearing_inner_radius', type: 'float', initial: 1.5, step: 0.25, caption: 'Bearings inner radius'},
    {name: 'bearing_outer_radius', type: 'float', initial: 5, step: 0.25, caption: 'Bearings outer radius'},
    {name: 'bearing_nut_radius', type: 'float', initial: 3.18, step: 0.1, caption: 'Bearings nut radius'},
    {name: 'bearing_nut_height', type: 'float', initial: 1.5, step: 0.1, caption: 'Bearings nut height'},

    {name: 'motor_shaft_radius', type: 'float', initial: 2.5, step: 0.25, caption: 'Motor Shaft radius'},
    {name: 'motor_shaft_height', type: 'float', initial: 24.0, step: 0.5, caption: 'Motor Shaft height'},

    {name: 'motor_ring_radius', type: 'float', initial: 11.0, step: 0.1, caption: 'Motor Ring radius'},
    {name: 'motor_ring_height', type: 'float', initial: 2.0, step: 0.1, caption: 'Motor Ring height'},

    {name: 'motor_mountingholes_offset', type: 'float', initial: 15.5, step: 0.1, caption: 'Motor Mounting hole offset'},
    {name: 'motor_mountingholes_radius', type: 'float', initial: 1.5, step: 0.1, caption: 'Motor Mounting hole radius'},
    {name: 'motor_mountingholes_depth', type: 'float', initial: 4.5, step: 0.1, caption: 'Motor Mounting hole depth'},
    {name: 'motor_mountingholes_screw_h', type: 'float', initial: 20, step: 1, caption: 'Motor Mounting screws height'}
  ];
}

function createBaseAndScrews(params){

  var baseScrew = cylinder(
    {
      r: params.motor_mountingholes_radius,
      h: params.motor_mountingholes_screw_h,
      center: [true, true, false]
    }
  );
  
  var mhOffset = params.motor_mountingholes_offset;

  var screws = union(
    translate([ mhOffset,  mhOffset, 0], baseScrew),
    translate([ mhOffset, -mhOffset, 0], baseScrew),
    translate([-mhOffset,  mhOffset, 0], baseScrew),
    translate([-mhOffset, -mhOffset, 0], baseScrew)
  );

  var baseW = 2 * (mhOffset + 2*params.motor_mountingholes_radius)

  var base = cube({size: [baseW, baseW, params.motor_mountingholes_depth], center: [true, true, false]});
  base = union(
    base, cylinder({
      r: params.motor_ring_radius,
      h: params.motor_ring_height + params.motor_mountingholes_depth,
      center:[true, true, false]
    })
  );
  base = difference(
    base, cylinder({
      r: params.motor_shaft_radius + 0.25,
      h: params.motor_shaft_height + params.motor_mountingholes_depth,
      center:[true, true, false]
    })
  );
  var shaft = cylinder({
    r: params.motor_shaft_radius,
    h: params.motor_shaft_height + params.motor_mountingholes_depth,
    center:[true, true, false]
  })
  base = difference(base, screws);
  base = color('darkgrey', base);
  shaft = color('grey', shaft);
  screws = color('Red', screws);
  return union(base, shaft, screws);
}

function createExtrudedRegularPolygon(r, h, s){
  return linear_extrude({height: h}, circle({r: r, fn: s, center: true}));
}

function createPumpArms(params){
  var armTipRadius = (params.bearing_outer_radius + params.bearing_inner_radius)/2;
  var radiusToBearings = params.arm_radius - params.bearing_outer_radius;
  var armsDelta = params.bearings_height + 2 * params.bearings_washers_height;

  var armTip = translate([radiusToBearings, 0, 0], circle({r: armTipRadius, center: true}));
  var armsShaft = circle({r: params.arms_shaft_radius + 1, center: true});
  var middlePath = translate([radiusToBearings/2, params.bearing_inner_radius, 0], circle({r: (params.arms_shaft_radius + armTipRadius) * 1 / 2, center: true}));
  var middlePathAngle = Math.atan(params.bearing_inner_radius/(radiusToBearings/2)) * 180 / Math.PI

  var baseArm = linear_extrude({height: params.arm_height}, 
    difference(
      chain_hull([armsShaft, middlePath, armTip]),
      translate([radiusToBearings, 0, 0], circle({r: params.bearing_inner_radius, center: true}))
    )
  );

  var hexNut = createExtrudedRegularPolygon(params.bearing_nut_radius, params.bearing_nut_height, 6);
  var washer = color('white', cylinder({r: params.bearings_washers_radius, h: params.bearings_washers_height, center:[true, true, false]}));

  var baseBottomArm = difference(
    baseArm, translate([radiusToBearings, 0, 0], 
      rotate([0, 0, -middlePathAngle], hexNut)
    )
  );

  var baseTopArm = difference(
    baseArm,
    translate([radiusToBearings, 0, params.arm_height - params.bearing_nut_height], 
      rotate([0, 0, -middlePathAngle], hexNut)
    )
  );
  baseTopArm = translate([0, 0, armsDelta + params.arm_height], baseTopArm);

  var bearingBase = difference(
    union(
      washer,
      translate(
        [0, 0, params.bearings_washers_height],
        color('gray', cylinder({
            r: params.bearing_outer_radius,
            h: params.bearings_height,
            center:[true, true, false]
          })
        )
      ),
      translate(
        [0, 0, params.bearings_washers_height + params.bearings_height],
        washer
      )
    ),
    cylinder({
      r: params.bearing_inner_radius,
      h: armsDelta,
      center:[true, true, false]
    })
  );
  bearingBase = translate([radiusToBearings, 0, params.arm_height], bearingBase);

  var angle = 360/params.arms_num;
  var joinedArmsBottom = baseBottomArm;
  var joinedArmsTop = baseTopArm;
  var joinedBearings = bearingBase;
  for(var i=1; i < params.arms_num; i++){
    joinedArmsBottom = union(joinedArmsBottom, rotate([0, 0, angle*i], baseBottomArm));
    joinedArmsTop = union(joinedArmsTop, rotate([0, 0, angle*i], baseTopArm));
    joinedBearings = union(joinedBearings, rotate([0, 0, angle*i], bearingBase));
  }

  var shaftSectionR = params.arms_shaft_radius;
  var shaftClosingSectionR = params.motor_shaft_radius + 0.5;
  var shaftWideSectionR = params.arms_shaft_radius + 1;

  var shaftTowerPath =  new CSG.Path2D([[params.motor_shaft_radius + 0.1, 0], [shaftWideSectionR, 0]], false);
  curY = params.arm_height;
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]]);
  curY += armsDelta
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftWideSectionR, curY], [shaftWideSectionR, curY]]);
  curY += params.arm_height
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]]);
  curY += params.arms_shaft_top_height
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftClosingSectionR, curY], [shaftClosingSectionR, curY]]);
  shaftTowerPath = shaftTowerPath.appendPoint([params.motor_shaft_radius + 0.1, curY]);
  shaftTowerPath = shaftTowerPath.close()

  shaftTowerSiloutte = polygon(shaftTowerPath);

  shaftTower = rotate_extrude(shaftTowerSiloutte);

  function positionHolderNutGeom(geomObj){
    geomObj = rotate([0, 90, 0], geomObj);
    geomObj = translate([params.motor_shaft_radius + 1, 0, 2 * params.arm_height + armsDelta + params.arms_shaft_top_height/2], geomObj);
    return rotate([0, 0, angle/2], geomObj);
  }

  var hexNutHole = createExtrudedRegularPolygon(params.bearing_nut_radius, params.bearing_nut_height * 2, 6);
  hexNutHole = union(hexNutHole, cylinder({r: params.bearing_inner_radius, h: 3, center: true}));
  hexNutHole = positionHolderNutGeom(hexNutHole);

  var hexNutHoleWrapper = createExtrudedRegularPolygon(params.bearing_nut_radius+1, params.bearing_nut_height * 2, 6);
  hexNutHoleWrapper = positionHolderNutGeom(hexNutHoleWrapper);

  shaftTower = union(shaftTower, hexNutHoleWrapper);
  shaftTower = difference(shaftTower, hexNutHole);
  
  var armsHolder = union(shaftTower, joinedArmsBottom, joinedArmsTop);
  armsHolder = color('green', armsHolder);
  return union(armsHolder, joinedBearings);
}

function main(params) {
  var baseAndScrews = createBaseAndScrews(params);
  var arms = createPumpArms(params);
  arms = translate([0, 0, params.motor_mountingholes_depth + params.motor_ring_height + 1], arms);
  var enclosure = difference(
    cylinder({r: params.arm_radius + 7, h: 20, center:[true, true ,false]}),
    cylinder({r: params.arm_radius + 2, h: 20, center:[true, true ,false]})
  );
  return [arms,baseAndScrews, enclosure];
}

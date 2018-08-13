(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
exports.get_motor_parameters = function() {
  return [
    {
      name: 'arms_num',
      type: 'float',
      initial: 5,
      step: 1,
      caption: 'Number of Arms'
    },
    {
      name: 'arm_height',
      type: 'float',
      initial: 3,
      step: 0.25,
      caption: 'Arm height'
    },
    {
      name: 'arm_radius',
      type: 'float',
      initial: 19,
      step: 0.5,
      caption: 'Arm radius'
    },
    {
      name: 'arms_shaft_radius',
      type: 'float',
      initial: 4,
      step: 0.25,
      caption: 'Arms Shaft radius'
    },
    {
      name: 'arms_shaft_top_height',
      type: 'float',
      initial: 8,
      step: 1,
      caption: 'Arms Shaft top height'
    },
    {
      name: 'bearings_height',
      type: 'float',
      initial: 5,
      step: 1,
      caption: 'Bearings height'
    },
    {
      name: 'bearings_washers_height',
      type: 'float',
      initial: 0.5,
      step: 0.1,
      caption: 'Bearings washers height'
    },
    {
      name: 'bearings_washers_radius',
      type: 'float',
      initial: 4.5,
      step: 0.1,
      caption: 'Bearings washers radius'
    },
    {
      name: 'bearing_inner_radius',
      type: 'float',
      initial: 1.5,
      step: 0.25,
      caption: 'Bearings inner radius'
    },
    {
      name: 'bearing_outer_radius',
      type: 'float',
      initial: 5,
      step: 0.25,
      caption: 'Bearings outer radius'
    },
    {
      name: 'bearing_nut_radius',
      type: 'float',
      initial: 3.18,
      step: 0.1,
      caption: 'Bearings nut radius'
    },
    {
      name: 'bearing_nut_height',
      type: 'float',
      initial: 1.5,
      step: 0.1,
      caption: 'Bearings nut height'
    },
    {
      name: 'motor_shaft_radius',
      type: 'float',
      initial: 2.5,
      step: 0.25,
      caption: 'Motor Shaft radius'
    },
    {
      name: 'motor_shaft_height',
      type: 'float',
      initial: 24.0,
      step: 0.5,
      caption: 'Motor Shaft height'
    },
    {
      name: 'motor_ring_radius',
      type: 'float',
      initial: 11.0,
      step: 0.1,
      caption: 'Motor Ring radius'
    },
    {
      name: 'motor_ring_height',
      type: 'float',
      initial: 2.0,
      step: 0.1,
      caption: 'Motor Ring height'
    },
    {
      name: 'motor_mountingholes_offset',
      type: 'float',
      initial: 15.5,
      step: 0.1,
      caption: 'Motor Mounting hole offset'
    },
    {
      name: 'motor_mountingholes_radius',
      type: 'float',
      initial: 1.5,
      step: 0.1,
      caption: 'Motor Mounting hole radius'
    },
    {
      name: 'motor_mountingholes_depth',
      type: 'float',
      initial: 4.5,
      step: 0.1,
      caption: 'Motor Mounting hole depth'
    },
    {
      name: 'motor_mountingholes_screw_h',
      type: 'float',
      initial: 20,
      step: 1,
      caption: 'Motor Mounting screws height'
    }
  ];
};


},{}],2:[function(require,module,exports){
(function (global){
// title      : Peristaltic Pump
// author     : Juan F. Mosquera (juanfmx2@gmail.com)
// license    : GNU GENERAL PUBLIC LICENSE v3
// tags       : peristaltic, pump
// file       : peristaltic_pump.coffee
var createPumpArms, create_base_and_screws, create_extruded_regular_polygon, get_motor_parameters, get_rendering_forms;

get_motor_parameters = require('./parameters.coffee').get_motor_parameters;

create_base_and_screws = function(params) {
  var base, baseScrew, baseW, mhOffset, screws, shaft;
  baseScrew = cylinder({
    r: params.motor_mountingholes_radius,
    h: params.motor_mountingholes_screw_h,
    center: [true, true, false]
  });
  mhOffset = params.motor_mountingholes_offset;
  screws = union(translate([mhOffset, mhOffset, 0], baseScrew), translate([mhOffset, -mhOffset, 0], baseScrew), translate([-mhOffset, mhOffset, 0], baseScrew), translate([-mhOffset, -mhOffset, 0], baseScrew));
  baseW = 2 * (mhOffset + 2 * params.motor_mountingholes_radius);
  base = cube({
    size: [baseW, baseW, params.motor_mountingholes_depth],
    center: [true, true, false]
  });
  base = union(base, cylinder({
    r: params.motor_ring_radius,
    h: params.motor_ring_height + params.motor_mountingholes_depth,
    center: [true, true, false]
  }));
  base = difference(base, cylinder({
    r: params.motor_shaft_radius + 0.25,
    h: params.motor_shaft_height + params.motor_mountingholes_depth,
    center: [true, true, false]
  }));
  shaft = cylinder({
    r: params.motor_shaft_radius,
    h: params.motor_shaft_height + params.motor_mountingholes_depth,
    center: [true, true, false]
  });
  base = difference(base, screws);
  base = color('darkgrey', base);
  shaft = color('grey', shaft);
  screws = color('Red', screws);
  return union(base, shaft, screws);
};

create_extruded_regular_polygon = function(r, h, s) {
  return linear_extrude({
    height: h
  }, circle({
    r: r,
    fn: s,
    center: true
  }));
};

createPumpArms = function(params) {
  var angle, armTip, armTipRadius, armsDelta, armsHolder, armsShaft, baseArm, baseBottomArm, baseTopArm, bearingBase, curY, hexNut, hexNutHole, hexNutHoleWrapper, i, j, joinedArmsBottom, joinedArmsTop, joinedBearings, middlePath, middlePathAngle, positionHolderNutGeom, radiusToBearings, ref, shaftClosingSectionR, shaftSectionR, shaftTower, shaftTowerPath, shaftTowerSiloutte, shaftWideSectionR, washer;
  armTipRadius = (params.bearing_outer_radius + params.bearing_inner_radius) / 2;
  radiusToBearings = params.arm_radius - params.bearing_outer_radius;
  armsDelta = params.bearings_height + 2 * params.bearings_washers_height;
  armTip = translate([radiusToBearings, 0, 0], circle({
    r: armTipRadius,
    center: true
  }));
  armsShaft = circle({
    r: params.arms_shaft_radius + 1,
    center: true
  });
  middlePath = translate([radiusToBearings / 2, params.bearing_inner_radius, 0], circle({
    r: (params.arms_shaft_radius + armTipRadius) * 1 / 2,
    center: true
  }));
  middlePathAngle = Math.atan(params.bearing_inner_radius / (radiusToBearings / 2)) * 180 / Math.PI;
  baseArm = linear_extrude({
    height: params.arm_height
  }, difference(chain_hull([armsShaft, middlePath, armTip]), translate([radiusToBearings, 0, 0], circle({
    r: params.bearing_inner_radius,
    center: true
  }))));
  hexNut = create_extruded_regular_polygon(params.bearing_nut_radius, params.bearing_nut_height, 6);
  washer = color('white', cylinder({
    r: params.bearings_washers_radius,
    h: params.bearings_washers_height,
    center: [true, true, false]
  }));
  baseBottomArm = difference(baseArm, translate([radiusToBearings, 0, 0], rotate([0, 0, -middlePathAngle], hexNut)));
  baseTopArm = difference(baseArm, translate([radiusToBearings, 0, params.arm_height - params.bearing_nut_height], rotate([0, 0, -middlePathAngle], hexNut)));
  baseTopArm = translate([0, 0, armsDelta + params.arm_height], baseTopArm);
  bearingBase = difference(union(washer, translate([0, 0, params.bearings_washers_height], color('gray', cylinder({
    r: params.bearing_outer_radius,
    h: params.bearings_height,
    center: [true, true, false]
  }))), translate([0, 0, params.bearings_washers_height + params.bearings_height], washer)), cylinder({
    r: params.bearing_inner_radius,
    h: armsDelta,
    center: [true, true, false]
  }));
  bearingBase = translate([radiusToBearings, 0, params.arm_height], bearingBase);
  angle = 360 / params.arms_num;
  joinedArmsBottom = baseBottomArm;
  joinedArmsTop = baseTopArm;
  joinedBearings = bearingBase;
  for (i = j = 0, ref = params.arms_num; (0 <= ref ? j <= ref : j >= ref); i = 0 <= ref ? ++j : --j) {
    joinedArmsBottom = union(joinedArmsBottom, rotate([0, 0, angle * i], baseBottomArm));
    joinedArmsTop = union(joinedArmsTop, rotate([0, 0, angle * i], baseTopArm));
    joinedBearings = union(joinedBearings, rotate([0, 0, angle * i], bearingBase));
  }
  shaftSectionR = params.arms_shaft_radius;
  shaftClosingSectionR = params.motor_shaft_radius + 0.5;
  shaftWideSectionR = params.arms_shaft_radius + 1;
  shaftTowerPath = new CSG.Path2D([[params.motor_shaft_radius + 0.1, 0], [shaftWideSectionR, 0]], false);
  curY = params.arm_height;
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]]);
  curY += armsDelta;
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftWideSectionR, curY], [shaftWideSectionR, curY]]);
  curY += params.arm_height;
  shaftTowerPath = shaftTowerPath.appendPoint([shaftWideSectionR, curY]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftWideSectionR, curY], [shaftSectionR, curY], [shaftSectionR, curY + 1]]);
  curY += params.arms_shaft_top_height;
  shaftTowerPath = shaftTowerPath.appendPoint([shaftSectionR, curY - 1]);
  shaftTowerPath = shaftTowerPath.appendBezier([[shaftSectionR, curY], [shaftClosingSectionR, curY], [shaftClosingSectionR, curY]]);
  shaftTowerPath = shaftTowerPath.appendPoint([params.motor_shaft_radius + 0.1, curY]);
  shaftTowerPath = shaftTowerPath.close();
  shaftTowerSiloutte = polygon(shaftTowerPath);
  shaftTower = rotate_extrude(shaftTowerSiloutte);
  positionHolderNutGeom = function(geomObj) {
    geomObj = rotate([0, 90, 0], geomObj);
    geomObj = translate([params.motor_shaft_radius + 1, 0, 2 * params.arm_height + armsDelta + params.arms_shaft_top_height / 2], geomObj);
    return rotate([0, 0, angle / 2], geomObj);
  };
  hexNutHole = create_extruded_regular_polygon(params.bearing_nut_radius, params.bearing_nut_height * 2, 6);
  hexNutHole = union(hexNutHole, cylinder({
    r: params.bearing_inner_radius,
    h: 3,
    center: true
  }));
  hexNutHole = positionHolderNutGeom(hexNutHole);
  hexNutHoleWrapper = create_extruded_regular_polygon(params.bearing_nut_radius + 1, params.bearing_nut_height * 2, 6);
  hexNutHoleWrapper = positionHolderNutGeom(hexNutHoleWrapper);
  shaftTower = union(shaftTower, hexNutHoleWrapper);
  shaftTower = difference(shaftTower, hexNutHole);
  armsHolder = union(shaftTower, joinedArmsBottom, joinedArmsTop);
  armsHolder = color('green', armsHolder);
  return union(armsHolder, joinedBearings);
};

get_rendering_forms = function(params) {
  var arms, baseAndScrews, enclosure;
  baseAndScrews = create_base_and_screws(params);
  arms = createPumpArms(params);
  arms = translate([0, 0, params.motor_mountingholes_depth + params.motor_ring_height + 1], arms);
  enclosure = difference(cylinder({
    r: params.arm_radius + 7,
    h: 20,
    center: [true, true, false]
  }), cylinder({
    r: params.arm_radius + 2,
    h: 20,
    center: [true, true, false]
  }));
  return [arms, baseAndScrews, enclosure];
};

global.getParameterDefinitions = function() {
  var params_definition;
  params_definition = [];
  params_definition = params_definition.concat(get_motor_parameters());
  return params_definition;
};

global.main = function(params) {
  return get_rendering_forms(params);
};


}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./parameters.coffee":1}]},{},[2]);

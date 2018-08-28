
exports.create_extruded_regular_polygon = (r, h, s)->
  return linear_extrude({height: h}, circle({r: r, fn: s, center: true}))
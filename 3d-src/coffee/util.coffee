# title      : util
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : util
# file       : util.coffee

exports.create_extruded_regular_polygon = (r, h, s)->
  return linear_extrude({height: h}, circle({r: r, fn: s, center: true}))
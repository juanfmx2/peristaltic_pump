# title      : Screws
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : screws
# file       : screws.coffee
_ = require 'underscore'
util = require './util.coffee'

class ScrewType
  @known_screws_data = {}

  @load_m_iso_data: ->
    new ScrewType('M1.6', 1.6,  3.2,  3.0, 1.6, 0.35, 0.20)
    new ScrewType('M2'  , 2.0,  4.0,  3.8, 2.0, 0.40, 0.25)
    new ScrewType('M2.5', 2.5,  5.0,  4.5, 2.5, 0.45, 0.35)
    new ScrewType('M3'  , 3.0,  5.5,  5.5, 3.0, 0.50, 0.35)
    new ScrewType('M4'  , 4.0,  7.0,  7.0, 4.0, 0.70, 0.50)
    new ScrewType('M5'  , 5.0,  8.0,  8.5, 5.0, 0.80, 0.50)
    new ScrewType('M6'  , 6.0, 10.0, 10.0, 6.0, 1.00, 0.75)

  # Screw data and geometry based on https://en.wikipedia.org/wiki/ISO_metric_screw_thread
  constructor: (@name, @diameter, @spanner_size, @head_diameter, @head_height, coarse_pitch, fine_pitch)->
    sqrt_3 = Math.pow(3.0, 0.5)
    @nut_diameter = 2.0 * @spanner_size / sqrt_3
    @thread_data = {
      coarse:
        pitch: coarse_pitch
        h: (coarse_pitch*sqrt_3/2.0)
      fine:
        pitch: fine_pitch
        h: (fine_pitch*sqrt_3/2.0)
    }
    ScrewType.known_screws_data[@name] = @

  __draw_coil_loop: (fine=true)->
    threading = if fine then @thread_data.fine else @thread_data.coarse
    max_radius = @diameter/2.0
    inner_radius = max_radius-threading.h*5/8
    thread_head = CSG.Polygon.createFromPoints([
      [threading.pitch/2, inner_radius-threading.h/8],
      [threading.pitch/8, max_radius],
      [-threading.pitch/8,  max_radius],
      [-threading.pitch/2, inner_radius-threading.h/8]
    ])
    slicing_angle = 10.0
    offset_angle = 180
    offset_start = Math.ceil(offset_angle/slicing_angle)
    num_slices = offset_start + Math.ceil((360+offset_angle)/slicing_angle)
    slices_x_dist = threading.pitch * slicing_angle/360

    coil = thread_head.solidFromSlices
      numslices: num_slices,
      callback: (t, slice) ->
        cur_slice = slice-offset_start
        return @translate([cur_slice * slices_x_dist, 0, 0]).rotateX(slicing_angle * cur_slice)

    trimming_cyl = cylinder({r: max_radius + 0.1, h:threading.pitch, center:true}).rotateY(90)

    coil = difference(coil, trimming_cyl.translate([-threading.pitch/2, 0 ,0]))
    coil = difference(coil, trimming_cyl.translate([3*threading.pitch/2, 0 ,0]))
    return coil

  __get_coil_loop: (fine=true)->
    thread_path = if fine then 'fine' else 'coarse'
    if not _.has(@thread_data[thread_path], '__coil_geom')
      @thread_data[thread_path]['__coil_geom'] = @__draw_coil_loop(fine)
    return @thread_data[thread_path]['__coil_geom']


  __draw_screw_threading: (screw_length, fine=true, use_non_intersecting_union=true)->
    threading = if fine then @thread_data.fine else @thread_data.coarse
    max_radius = @diameter/2.0
    inner_radius = max_radius-threading.h*5/8
    inner_cylinder = cylinder(
      {r:inner_radius, h:screw_length+threading.pitch, center:[true, true, false]}
    ).rotateY(90)

    num_coil_loops = Math.ceil(screw_length/threading.pitch)
    coil_loop = @__get_coil_loop(fine)
    screw = coil_loop
    for i in [1..num_coil_loops]
      coil_loop_i = coil_loop.translate([i*threading.pitch, 0, 0])
      if i == num_coil_loops
        trimming_cyl = cylinder({r: max_radius + 0.1, h:threading.pitch, center:[true, true, false]}).rotateY(90)
        coil_loop_i = difference(coil_loop_i, trimming_cyl.translate([screw_length+threading.pitch, 0, 0]))
      if use_non_intersecting_union
        screw = screw.unionForNonIntersecting coil_loop_i
      else
        screw = screw.union coil_loop_i
    if use_non_intersecting_union
      screw = screw.unionForNonIntersecting inner_cylinder
    else
      screw = screw.union inner_cylinder
    return screw.translate([0, 0, 0]).rotateY(-90)

  draw_screw: (params)->
    if !_.isObject params
      params = {}

    params = _.defaults(params, {
      screw_length: 10
      grub_screw: false
      placeholder: false
      fine: true
      hex_head: false
    })

    screw = null
    if params.placeholder
      screw = cylinder({r:@diameter/2.0, h:params.screw_length, center:[true, true, false]})
    else
      screw = @__draw_screw_threading(params.screw_length, params.fine)
    if not params.grub_screw
      head = null
      if params.hex_head
        head = util.create_extruded_regular_polygon(@nut_diameter/2, @head_height, 6)
      else
        head = cylinder({r:@head_diameter/2.0, h:@head_height, center:[true, true, false]})

      screw = screw.unionForNonIntersecting(head.translate([0, 0, params.screw_length]))

    screw = screw.center().rotateX(180).translate([0, 0, (params.screw_length+@head_height)/2])
    return screw

  draw_nut: (params)->
    if !_.isObject params
      params = {}

    params = _.defaults(params, {
      placeholder: false
      fine: true
      height: @head_height
    })

    nut = util.create_extruded_regular_polygon(@nut_diameter/2, @head_height, 6)
    if params.placeholder
      return nut
    else
      screw_coil = @__draw_screw_threading(params.height, params.fine, false).scale([1.01, 1.01, 1])
      nut = difference(nut, screw_coil)
    return nut

ScrewType.load_m_iso_data()

exports.available_screw_types = ScrewType.known_screws_data

global.getParameterDefinitions = ->
  return [
    {
      name: 'draw_placeholders'
      type: 'choice'
      caption: 'Draw Placeholders'
      values: ['No', 'Yes']
      initial: 'Yes'
    }
    {
      name: 'screw_set_to_draw'
      type: 'choice'
      caption: 'Screw Set to Draw'
      values: ['ALL'].concat _.keys(ScrewType.known_screws_data)
      initial: 'M3'
    }
  ]

global.main = (params)->
  t0 = performance.now()
  screw_types_keys = _.keys ScrewType.known_screws_data
  all_screws = []
  params.draw_placeholders = params.draw_placeholders=='Yes'

  draw_screw_set = (screw, y_location, draw_placeholders)->
    console.debug('Starting '+screw.name)
    separation =  screw.nut_diameter + 2
    all_screws.push screw.draw_screw({screw_length:2*screw.diameter}).translate([0, y_location, 0])
    all_screws.push(
      screw.draw_screw({screw_length:2*screw.diameter, fine:false, hex_head: true})\
        .translate([separation, y_location, 0])
    )
    # Nuts
    all_screws.push screw.draw_nut().translate([-separation, y_location, 0])
    all_screws.push screw.draw_nut({fine:false}).translate([-2*separation, y_location, 0])
    # Placeholders
    if draw_placeholders
      all_screws.push(
        screw.draw_screw({screw_length:2*screw.diameter, placeholder:true}).translate([2*separation, y_location, 0])
      )
      all_screws.push screw.draw_nut({placeholder:true}).translate([-3*separation, y_location, 0])

    console.debug('Finished! '+s_t_key_i)

  if params.screw_set_to_draw == 'ALL'
    cur_y = 0
    for s_t_key_i in screw_types_keys
      screw_i = ScrewType.known_screws_data[s_t_key_i]
      draw_screw_set(screw_i, cur_y, params.draw_placeholders)
      cur_y += screw_i.nut_diameter + 2
  else
    draw_screw_set(ScrewType.known_screws_data[params.screw_set_to_draw], 0, params.draw_placeholders)
  t1 = performance.now()
  console.debug('Time: '+(t1-t0)/1000)
  return all_screws
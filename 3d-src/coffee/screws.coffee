# title      : Screws
# author     : Juan F. Mosquera (juanfmx2@gmail.com)
# license    : GNU GENERAL PUBLIC LICENSE v3
# tags       : screws
# file       : screws.coffee
_ = require 'underscore'

class ScrewType
  @known_screws_data = {}

  @load_m_iso_data: ->
    new ScrewType('M1.6', 1.6,  3.2,  3.0, 1.6, 0.35, 0.20)
    new ScrewType('M2'  , 2.0,  4.0,  3.8, 2.0, 0.40, 0.25)
    new ScrewType('M2.5', 2.5,  5.0,  4.5, 2.5, 0.45, 0.35)
    new ScrewType('M3'  , 3.0,  5.5,  5.5, 3.0, 0.50, 0.35)
    new ScrewType('M4'  , 4.0,  7.0,  7.0, 4.0, 0.70, 0.50)
    new ScrewType('M5'  , 5.0,  8.0,  8.5, 8.0, 0.80, 0.50)
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

  __draw_screw_threading: (screw_length, fine=true)->
    threading = if fine then @thread_data.fine else @thread_data.coarse
    max_radius = @diameter/2.0
    threading_tip_height = threading.h*5/8
    inner_radius = max_radius-threading_tip_height
    thread_head = CSG.Polygon.createFromPoints([
      [threading.pitch*3/8, inner_radius],
      [threading.pitch/4, max_radius],
      [-threading.pitch/4,  max_radius],
      [-threading.pitch*3/8, inner_radius]
    ])
    inner_cylinder = cylinder(
      {r:inner_radius*1.01, h:screw_length+threading.pitch, center:[true, true, false]}
    ).rotateY(90)
    slicing_angle = 10.0
    loops = 1 #(screw_length+threading.pitch)/threading.pitch
    num_slices = Math.ceil(360 * loops / slicing_angle)+1
    slices_x_dist = threading.pitch * slicing_angle/360

    coil = thread_head.solidFromSlices
      numslices: num_slices,
      callback: (t, slice) ->
        return @translate([slice * slices_x_dist, 0, 0]).rotateX(slicing_angle * slice)

    trimming_cyl = cylinder({r: max_radius + 0.1, h:threading.pitch, center:true}).rotateY(90)

    screw = union(coil, inner_cylinder)
    screw = difference(screw, trimming_cyl)
    screw = difference(screw, trimming_cyl.translate([screw_length+threading.pitch, 0, 0]))
    return screw.translate([-threading.pitch/2.0, 0, 0]).rotateY(-90)

  draw_screw: (params)->
    if !_.isObject params
      params = {}

    params = _.defaults(params, {
      screw_length: 10
      grub_screw: false
      placeholder: false
      fine: true
    })

    screw = null
    if params.placeholder
      screw = cylinder({r:@diameter/2.0, h:params.screw_length, center:[true, true, false]})
    else
      screw = @__draw_screw_threading(params.screw_length, params.fine)
    if not params.grub_screw
      head = cylinder({r:@head_diameter/2.0, h:@head_height, center:[true, true, false]})
        .translate([0, 0, params.screw_length])
      screw = union(screw, head)
    return screw


ScrewType.load_m_iso_data()

#console.log(Screw.known_screws_data)

global.getParameterDefinitions = ->
  return []

global.main = (params)->
  screw_types_keys = _.keys ScrewType.known_screws_data
  all_screws = []
  max_screw_diameter = 0
  for s_t_key_i in screw_types_keys
    screw = ScrewType.known_screws_data[s_t_key_i]
    max_screw_diameter = Math.max(max_screw_diameter, screw.head_diameter)

  separation = max_screw_diameter + 1

  cur_y = 0

  for s_t_key_i in screw_types_keys
    console.debug('Starting '+s_t_key_i)
    screw = ScrewType.known_screws_data[s_t_key_i]
    all_screws.push(
      screw.draw_screw({screw_length:2*screw.diameter, placeholder:true}).translate([0, cur_y, 0])
    )
    all_screws.push screw.draw_screw({screw_length:2*screw.diameter}).translate([separation, cur_y, 0])
    all_screws.push screw.draw_screw({screw_length:2*screw.diameter, fine:false}).translate([2*separation, cur_y, 0])
    cur_y += separation
    console.debug('Finished! '+s_t_key_i)

  return all_screws
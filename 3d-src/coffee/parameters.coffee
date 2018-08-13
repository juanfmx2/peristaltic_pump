
exports.get_motor_parameters = ->
  return [
    {
      name: 'arms_num'
      type: 'float'
      initial: 5
      step: 1
      caption: 'Number of Arms'
    }
    {
      name: 'arm_height'
      type: 'float'
      initial: 3
      step: 0.25
      caption: 'Arm height'
    }
    {
      name: 'arm_radius'
      type: 'float'
      initial: 19
      step: 0.5
      caption: 'Arm radius'
    }
    {name: 'arms_shaft_radius', type: 'float', initial: 4, step: 0.25, caption: 'Arms Shaft radius'}
    {name: 'arms_shaft_top_height', type: 'float', initial: 8, step: 1, caption: 'Arms Shaft top height'}

    {name: 'bearings_height', type: 'float', initial: 5, step: 1, caption: 'Bearings height'}
    {name: 'bearings_washers_height', type: 'float', initial: 0.5, step: 0.1, caption: 'Bearings washers height'}
    {name: 'bearings_washers_radius', type: 'float', initial: 4.5, step: 0.1, caption: 'Bearings washers radius'}
    {name: 'bearing_inner_radius', type: 'float', initial: 1.5, step: 0.25, caption: 'Bearings inner radius'}
    {name: 'bearing_outer_radius', type: 'float', initial: 5, step: 0.25, caption: 'Bearings outer radius'}
    {name: 'bearing_nut_radius', type: 'float', initial: 3.18, step: 0.1, caption: 'Bearings nut radius'}
    {name: 'bearing_nut_height', type: 'float', initial: 1.5, step: 0.1, caption: 'Bearings nut height'}

    {name: 'motor_shaft_radius', type: 'float', initial: 2.5, step: 0.25, caption: 'Motor Shaft radius'}
    {name: 'motor_shaft_height', type: 'float', initial: 24.0, step: 0.5, caption: 'Motor Shaft height'}

    {name: 'motor_ring_radius', type: 'float', initial: 11.0, step: 0.1, caption: 'Motor Ring radius'}
    {name: 'motor_ring_height', type: 'float', initial: 2.0, step: 0.1, caption: 'Motor Ring height'}

    {name: 'motor_mountingholes_offset', type: 'float', initial: 15.5, step: 0.1, caption: 'Motor Mounting hole offset'}
    {name: 'motor_mountingholes_radius', type: 'float', initial: 1.5, step: 0.1, caption: 'Motor Mounting hole radius'}
    {name: 'motor_mountingholes_depth', type: 'float', initial: 4.5, step: 0.1, caption: 'Motor Mounting hole depth'}
    {name: 'motor_mountingholes_screw_h', type: 'float', initial: 20, step: 1, caption: 'Motor Mounting screws height'}
  ]
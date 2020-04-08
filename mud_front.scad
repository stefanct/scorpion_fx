// $fn=20;
// $fn=50;
// $fn=200;

// is_left = 1;
// is_high_infill = 1;

outer_is_base=1;

include <common.scad>;

holder_arc_angle_quirk=1;
holder_arc_off_x=mud_strut_front_off_x-mud_axle_x+mud_strut_front_corner_dist/2;
holder_arc_off_z=mud_strut_front_off_z+mud_axle_z;
function holder_arc_angle() = 180-atan(((holder_arc_off_z/holder_arc_off_x)))+holder_arc_angle_quirk;

include <mud_common.scad>;

function holder_bracket_off_r()=5;
function is_holder_front_facing()=1;

module translate_result_base() {
  if (outer_is_base) {
    translate([0, 0, holder_beam_h])
      rotate([+90,0,holder_arc_angle()])
        children();
  } else {
    rotate([-90,0,holder_arc_angle()])
      strut_rotation(1)
        children();
  }
}

module translate_result() {
  translate_result_base()
    translate([-mud_strut_front_off_x, -2*holder_wall, -mud_strut_front_off_z])
        children();
}

module translate_bike() {
  translate_result() children();
}

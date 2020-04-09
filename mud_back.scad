// $fn=20;
// $fn=50;
// $fn=200;

// is_left = 1;
// is_high_infill = 1;

outer_is_base=1;

include <common.scad>;

holder_arc_angle_quirk=0.5;
holder_arc_off_x=mud_axle_x;
holder_arc_off_z=mud_axle_z;
function holder_arc_angle() = atan(holder_arc_off_z/holder_arc_off_x)+holder_arc_angle_quirk;

result_x_off=0;
result_z_off=0;

include <mud_common.scad>;

function holder_bracket_off_r()=10;
function is_holder_front_facing()=0;
// function is_high_infill_only()=1;


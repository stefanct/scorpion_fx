// overridable global functions/variables
function is_holder_front_facing() = 0;
function is_high_infill_only()=0;

holder_neck_len = 0; // Move beam away from axle
mud_screw_head_h_extra=5; // Make sunk screws in bracket (if mud_strut_rotation_edge is >~3°)
function mud_screw_off_y()=2*holder_wall-mud_strut_thick;
function holder_rect_height()=holder_rect_width;
function holder_bracket_off_r()=0;

////////////////////////////////////////////////////////////////////////
// Holder common
holder_wall = 4;
tie_w_center=8;
tie_w=4;
tie_h=2.5;
tie_gap=15;

// Holder beam
holder_beam_d = 20;
holder_beam_inwards_off = 2*holder_wall;
holder_beam_h = mud_d+holder_beam_inwards_off;

// Holder arc
mud_strut_extra_thick=10;
holder_arc_width = 14;
w = tan(holder_arc_angle_quirk)*mud_strut_screw_r;
x = holder_arc_width/2;
y = cos(holder_arc_angle()-45)*mud_strut_back_hole_dist;
holder_rect_width = 2*w + 2*x + y;

module holder_rotation(orbit) {
  rotate_about_pt(holder_arc_angle(),[0,1,0],[mud_axle_x,0,-mud_axle_z]) // Rotate to final location
    translate([-orbit, 0, 0]) // Move to correct "orbit"
      translate([mud_axle_x,0,-mud_axle_z]) // Move to axle
        children();
}

/* Create the arc around the wing.

 arc_extent_angle: number of degrees of the arc
 arc_extent_angle_off: number of degrees the arc is rotate away from the outer side
*/
module holder_arc (arc_extent_angle=180, arc_extent_angle_off=0) {
  holder_rotation(mud_axle_r-mud_d/2)
    intersection() { // Prevent bleeding on the outer side
      translate([0, -mud_d/2+holder_arc_width/2,0])
        cube([mud_d+holder_arc_width, mud_d+holder_arc_width,holder_arc_width],true);

      translate([0, -mud_d/2, -holder_arc_width/2]) // Move arc to correct y location and z-center on origin
        rotate([0,0,270-arc_extent_angle+arc_extent_angle_off,]) // Fix coordinate system
            rotate_extrude(angle = arc_extent_angle, convexity = 10) // Create arc_extent_angle° arc
              translate([mud_d/2, holder_arc_width/2, 0]) // Move half-circle to arc's "orbit"
                union() {
                  intersection() { // Create half-circle
                    translate([holder_arc_width/2,0,0])
                      square([holder_arc_width, holder_arc_width],center=true);
                    circle(d=holder_arc_width);
                  }
                }
    }
}

module holder_bracket () {
  holder_rotation(mud_strut_screw_r)
    translate([holder_bracket_off_r(), 0, 0]) // 
      translate([0, 0, holder_arc_width/2]) // Offset to match the arcs front facing border (later)
        translate([-holder_rect_height(), 0, -holder_rect_width]) // Move corner to origin
          cube([holder_rect_height(), 2*holder_wall, holder_rect_width]);
}

module tie_channel (h=tie_h, w=tie_w, off_h=0) {
  translate([0, +w/2-off_h, 0]) // Center
    holder_beam_translation()
      rotate([0,-holder_arc_angle()+(is_holder_front_facing()?180:0),0])
        translate([-holder_beam_d/7, 0, 0]) // Nudge into the beam
          rotate([180,90,90]) // Fix coordinate system
            rotate_extrude(angle = 360, convexity = 2) 
              translate([holder_beam_d/2, 0, 0]) // Move to "orbit"
                square([h, w]);
}

module holder_beam_translation() {
  holder_rotation(mud_axle_r+holder_beam_d/2+holder_wall+holder_neck_len)
    translate([0, -holder_beam_h/2+holder_beam_inwards_off, 0]) // Move to correct y location
      children();
}

module tie_channels (h=tie_h, w=tie_w, gap_percent=200) {
  tie_channel(h=tie_h, w=tie_w_center);
  for (o=[-tie_gap, tie_gap]) {
    tie_channel(h=tie_h, w=tie_w, off_h=o);
  }
}

module holder_beam (h, d) {
  holder_beam_translation()
    rotate([90,0,0]) // Fix coordinate system
      cylinder(d=d, h=h, center=true);
}

module holder () {
  difference () {
    union() {
      hull() {
        strut_rotation()
          holder_bracket();
        holder_arc();
      }
      hull() {
        holder_arc();
        holder_beam(holder_beam_h/16, holder_beam_d*3/4);
      }
      holder_beam(holder_beam_h, holder_beam_d);
    }
    tie_channels();
  }
}

module high_infill_screws (off=0) {
  mud_strut_holes(d=4*mud_strut_hole_d, h_add=mud_screw_off_y());
}

module translate_result_base() {
  if (outer_is_base && !is_high_infill_only()) {
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
    translate([result_x_off, -2*holder_wall, result_z_off])
        children();
}

module translate_bike() {
  translate_result() children();
}

module norm_infill () {
  difference() {
    translate_result()
      holder();
    bike();
  }
}

module high_infill () {
  intersection() {
    norm_infill();
    translate_result() {
      rotate([0, mud_strut_rotation_y, 0])
        high_infill_screws();
    }
  }
}

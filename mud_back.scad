// $fn=20;
// $fn=50;
// $fn=200;


// is_left = 1;
// is_high_infill = 1;


tie_w_center=8;
tie_w=4;
tie_h=2.5;
tie_gap=15;


include <common.scad>;
function mud_screw_off_y()=2*holder_wall-mud_strut_thick;

// Holder common
holder_wall = 4;

// Holder beam
holder_beam_d = 20;
holder_beam_inwards_off = 2*holder_wall*1;
holder_beam_h = mud_d+holder_beam_inwards_off*1;

// Holder arc
holder_arc_width = 14;
holder_arc_off_x=mud_axle_x;
holder_arc_off_z=mud_axle_z;
holder_arc_angle_quirk=0.5;
function holder_arc_angle() = atan(holder_arc_off_z/holder_arc_off_x)+holder_arc_angle_quirk;

w = tan(holder_arc_angle_quirk)*mud_strut_screw_r*1;
x = holder_arc_width/2*1;
y = cos(holder_arc_angle()-45)*mud_strut_back_hole_dist;
holder_rect_width = 2*w + 2*x + y;

module holder_rotation(orbit) {
  rotate_about_pt(holder_arc_angle(),[0,1,0],[mud_axle_x,0,-mud_axle_z]) // Rotate to final location
    translate([-orbit, 0, 0]) // Move to correct "orbit"
      translate([mud_axle_x,0,-mud_axle_z]) // Move to axle
        children();
}

module holder_arc () {
  holder_rotation(mud_axle_r-mud_d/2)
    intersection() { // Prevent bleeding on the outer side
      translate([0, -mud_d/2+holder_arc_width/2,0])
        cube([mud_d+holder_arc_width, mud_d+holder_arc_width,holder_arc_width],true);

      translate([0, -mud_d/2, -holder_arc_width/2]) // Move arc to correct y location and z-center on origin
        rotate([0,0,90,]) // Fix coordinate system
            rotate_extrude(angle = 180, convexity = 10) // Create 180° arc
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
    translate([mud_strut_hole_d*2,0,0])
      translate([0,0,holder_arc_width/2]) // Offset to match arcs front facing border later
        translate([-(mud_straight-10),0,-holder_rect_width]) // Move corner to origin
          cube([mud_straight-10,2*holder_wall,holder_rect_width]);
}

module tie_channel (h=tie_h, w=tie_w, off_h=0) {
  translate([0, +w/2-off_h, 0]) // Center
    holder_beam_translation()
      rotate([0,-holder_arc_angle(),0])
        translate([-holder_beam_d/7, 0, 0]) // Nudge into the beam
          rotate([180,90,90]) // Fix coordinate system
            rotate_extrude(angle = 180, convexity = 2) 
              translate([holder_beam_d/2, 0, 0]) // Move to "orbit"
                square([h, w]);
}

module holder_beam_translation() {
  holder_rotation(mud_axle_r+holder_beam_d/2+holder_wall)
    translate([0, -holder_beam_h/2+holder_beam_inwards_off, 0]) // Move to correct y location
      children();
}

module tie_channels (h=tie_h, w=tie_w, gap_percent=200) {
  tie_channel(h=tie_h, w=tie_w_center);
  for (o=[-tie_gap, tie_gap]) {
    tie_channel(h=tie_h, w=tie_w, off_h=o);
  }
}

module holder_beam (h) {
  holder_beam_translation()
    rotate([90,0,0]) // Fix coordinate system
      cylinder(d=holder_beam_d, h=h, center=true);
}

module holder () {
  difference () {
    union() {
      hull() {
        holder_bracket();
        holder_arc();
      }
      hull() {
        holder_arc();
        holder_beam(holder_beam_h/16);
      }
      holder_beam(holder_beam_h);
    }
    tie_channels();
  }
}

module high_infill_screws (off=0) {
  translate([0,2*holder_wall+off,0]) {
    rotate([90,mud_strut_rotation,0]) {
      union() {
        cylinder(h=2*holder_wall, d=mud_strut_hole_d*4);
        translate([-mud_strut_back_hole_dist/sqrt(2), -mud_strut_back_hole_dist/sqrt(2),0])
          cylinder(h=2*holder_wall, d=mud_strut_hole_d*4);
      }
    }
  }
}



module norm_infill () {
  difference() {
    holder();
    bike();
  }
}

module high_infill () {
  intersection() {
    holder();
    high_infill_screws();
  }
}

// $fn=50;
// $fn=200;


// is_left = 1;
// is_high_infill = 1;

// holder
holder_wall = 4;
holder_arc_width = 14;
function holder_arc_angle() = asin(holder_arc_width/mud_axle_r);
holder_rect_width = 33;
function holder_rect_angle() = asin(holder_rect_width/mud_axle_r);
holder_angle = 29.75;

beam_d = 22;

tie_w_center=8;
tie_w=4;
tie_h=2.5;
tie_gap=15;


include <common.scad>;
function mud_screw_off()=2*holder_wall-mud_strut_thick;

module holder_arc () {
  translate([15,0,15]) {
    translate([mud_axle_x,0,-mud_axle_z]) {
      rotate([90,-holder_angle,180]) {
        rotate_extrude(angle = holder_arc_angle(), convexity = 10) {
          translate([mud_axle_r-mud_d/2+holder_wall, -mud_d/2, 0]) {
            union() {
              // Prevent bleeding towards the axle
              intersection() {
                circle(d=mud_d+2*holder_wall);
                translate([holder_wall,2*holder_wall,0])
                  square([mud_d+1*holder_wall, mud_d+2*holder_wall],center=true);
              }
            }
          }
        }
      }
    }
  }
}

module holder_bracket () {
  translate([-25,0,-10]) {
    rotate([0,holder_angle,0]) {
      cube([mud_straight-10,2*holder_wall,30]);
    }
  }
}

module tie_channel (h=tie_h, w=tie_w, off_h=0) {
  translate([0, +w/2-off_h, 0]) // Center
  holder_beam_translation()
  rotate([0,0,270])
  translate([0, -3, 0]) // Nudge into the beam
  rotate_extrude(angle = 180, convexity = 2) 
  translate([beam_d/2, 0, 0]) // Move to "orbit"
  square([h, w]);
}

module holder_beam_translation() {
  translate([-mud_d+10,-mud_d/2+2*holder_wall,22])
  rotate([90,0,0])
    children();
}

module tie_channels (h=tie_h, w=tie_w, gap_percent=200) {
  tie_channel(h=tie_h, w=tie_w_center);
  for (o=[-tie_gap, tie_gap]) {
    tie_channel(h=tie_h, w=tie_w, off_h=o);
  }
}

module holder_beam_stump () {
  holder_beam_translation()
    cylinder(d=beam_d, h=mud_d/16, center=true);
}

module holder_beam () {
  holder_beam_translation()
    cylinder(d=beam_d, h=mud_d, center=true);
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
        holder_beam_stump();
      }
      holder_beam();
    }
    tie_channels();
  }
}

module high_infill_screws (off=0) {
  translate([0,2*holder_wall+off,0]) {
    rotate([90,mud_strut_rotation,0]) {
      union() {
        cylinder(h=2*holder_wall, d=mud_strut_hole_d*4);
        translate([-mud_strut_hole_dist/sqrt(2), -mud_strut_hole_dist/sqrt(2),0])
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

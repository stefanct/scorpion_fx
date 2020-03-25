// $fn=50;
// $fn=200;

// mud guard
mud_d = 60;
mud_straight = 35;
mud_axle_r = 290;
mud_axle_x = 195;
mud_axle_y = 150;

// mud strut
strut_thick=5;
strut_corner_r=5;
strut_corner_dist=25;
strut_hole_d=5;
strut_hole_dist=15;
strut_screw_d=9;
strut_screw_len=10;
strut_h_max=28;
strut_corner_angle=45;
strut_rotation=5;

// holder
holder_wall = 4;
holder_arc_width = 14;
holder_arc_angle = asin(holder_arc_width/mud_axle_r);
holder_rect_width = 33;
holder_rect_angle = asin(holder_rect_width/mud_axle_r);
holder_angle = 29.75;

beam_d = 22;

tie_w_center=8;
tie_w=4;
tie_h=2.5;
tie_gap=15;


module strut () {
   difference() minkowski() {
    linear_extrude(height = 4) polygon([
      [-70,                           1],
      [3,                             4],
      [3+strut_corner_dist/sqrt(2),   4-strut_corner_dist/sqrt(2)],
      [-70,                           4-strut_corner_dist/sqrt(2)],
    ]);
    cylinder(r=5, h=1);
  }

  cylinder(h=strut_thick, d=strut_hole_d);
  translate([strut_hole_dist/sqrt(2), -strut_hole_dist/sqrt(2),0])
    cylinder(h=strut_thick, d=strut_hole_d);
}

module screws (off=0) {
  // Screw heads
  translate([0,0,strut_thick+off])
    union() {
      cylinder(h=2, d=strut_screw_d);
      translate([strut_hole_dist/sqrt(2), -strut_hole_dist/sqrt(2),0])
        cylinder(h=2, d=strut_screw_d);
    }

  // Screw shafts
  translate([0,0,-strut_thick])
    union() {
      cylinder(h=strut_screw_len+off, d=strut_hole_d);
      translate([strut_hole_dist/sqrt(2), -strut_hole_dist/sqrt(2),0])
        cylinder(h=strut_screw_len+off, d=strut_hole_d);
    }
}

module mud_guard () {
  translate([-mud_axle_x,-mud_axle_y,0])
    rotate([0,0,-10])
      rotate_extrude(angle = 160, convexity = 10) 
        translate([mud_axle_r-mud_d/2, -mud_d/2, 0])
        union() {
          circle(d=mud_d);
          translate([-mud_straight,-mud_d/2,0])
            square([mud_straight,mud_d]);
        }
}

module holder_arc () {
  translate([-15,15,0]) {
    translate([-mud_axle_x,-mud_axle_y,0]) {
      rotate([0,0,holder_angle]) {
        rotate_extrude(angle = holder_arc_angle, convexity = 10) {
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
  translate([-15,15,0]) {
    translate([-mud_axle_x,-mud_axle_y,0]) {
      rotate([0,0,holder_angle-(holder_rect_angle-holder_arc_angle)/2]) {
        rotate_extrude(angle = holder_rect_angle, convexity = 10)
          translate([mud_axle_r-mud_d/2, -mud_d/2, 0])
            translate([-mud_straight+15,mud_d/2,0])
              square([mud_straight-10,2*holder_wall]);
      }
    }
  }
}

module tie_channel (h=tie_h, w=tie_w, off_h=0) {
  translate([0, 0, -w/2+off_h]) // Center
  translate(holder_beam_translation())
  rotate([0,0,100])
  translate([0, -3, 0]) // Nudge into the beam
  rotate_extrude(angle = 180, convexity = 2) 
  translate([beam_d/2, 0, 0]) // Move to "orbit"
  square([h, w]);
}

function holder_beam_translation() = [mud_d-10,22,-mud_d/2+2*holder_wall];

module tie_channels (h=tie_h, w=tie_w, gap_percent=200) {
  tie_channel(h=tie_h, w=tie_w_center);
  for (o=[-tie_gap, tie_gap]) {
    tie_channel(h=tie_h, w=tie_w, off_h=o);
  }
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

module holder_beam_stump () {
  translate(holder_beam_translation())
    cylinder(d=beam_d, h=mud_d/16, center=true);
}

module holder_beam () {
  translate(holder_beam_translation())
    cylinder(d=beam_d, h=mud_d, center=true);
}

module bike () {
// mirror([1,0,0])
  union() {
    rotate([0,0,-strut_rotation]) {
      color("dimgrey") strut();
      color("silver") screws(off=2*holder_wall-strut_thick);
    }
    color("grey") mud_guard();
  }
}

module high_infill_screws (off=0) {
  rotate([0,0,-strut_rotation])
  translate([0,0,-strut_thick])
    union() {
      cylinder(h=strut_screw_len+off, d=strut_hole_d*4);
      translate([strut_hole_dist/sqrt(2), -strut_hole_dist/sqrt(2),0])
        cylinder(h=strut_screw_len+off, d=strut_hole_d*4);
    }
}

module high_infill () {
  high_infill_screws(off=2*holder_wall-strut_thick);
}

%bike();
// difference() {
  // holder();
  // bike();
// }
#intersection() {
  holder();
  high_infill();
}

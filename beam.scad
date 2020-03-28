// $fn=50;
// $fn=200;

// is_high_infill = 1;

include <common.scad>;
module translate_bike() {
  // translate([0, 0, submersed(branch_angle)+branch_l])
  rotate([-beam_angle-branch_angle, 180, 0])
  rotate([90, 270, 0])
  translate([-400, -bike_center_x(), -106])
  children();
}

wall_width=0; // <=0 == solid

branch_d=42; // HP Scorpion handlebar
branch_angle=35;
branch_l=200; // Length of fully non-"submersed" cylinder (some of that remains unusable due to the strut)

tie_w=6;
tie_h=2;
tie_wall_width=4;


// Based on https://github.com/Sembiance/common/blob/master/openscad/hollowCylinder.scad
module hollowCylinder(d=5, h=10, wall_width=1) {
  difference() {
    cylinder(d=d, h=h);
    translate([0, 0, -wall_width]) { cylinder(d=d-(wall_width*2), h=h-wall_width); }
  }
}


module tie_channel (h=3, w=6, off_h=0) {
  // off_v=h;
  rotate([90,0,0])
  translate([0, 0, off_h])
  translate([0, 0, tie_wall_width/tan(branch_angle)]) // Move horizontally to center of branch (by the distance going tie_wall_width up a slope of branch_angle)
  translate([0, tie_wall_width + (abs(beam_tread_d/2-branch_d/2))/2, 0]) // Move vertically tie_wall_width above intersection
  translate([0, 0, (beam_tread_d/2)/tan(branch_angle)]) // Move horizontally to center of intersection
  translate([0, 0, -w/2]) // Center on origin_y
  rotate_extrude(angle = 180, convexity = 2) 
  translate([(branch_d/2+beam_tread_d/2)/2, 0, 0]) // Move to "orbit" between the two radii
  square([h, w]);
}

module tie_channels (h=3, w=6, gap_percent=200) {
  actual_width = branch_d/sin(branch_angle);
  usable_width = actual_width - 2*h/tan(branch_angle) - 2*w; // Leaving w space left and right + accounting for slope
  chan_width = w+w*gap_percent/100;
  fitting_ties = 1+floor((usable_width-w)/chan_width);
  used_width = w + (fitting_ties-1) * chan_width;
  assert(usable_width-used_width >= 0);

  if (fitting_ties > 1) {
    min_h = -used_width/2;
    max_h = +used_width/2;
    for (o=[min_h:chan_width:max_h]) {
      tie_channel(h=tie_h, w=tie_w, off_h=o);
    }
  } else {
      tie_channel(h=tie_h, w=tie_w, off_h=0);
  }
}

module branch_top (ang=branch_angle) {
  if (is_undef(is_high_infill) || is_high_infill == 0) {
    if (wall_width > 0) {
      rotate([90-ang,0,0]) hollowCylinder(d=branch_d, h=submersed(ang)+branch_l, wall_width=wall_width);
    } else {
      rotate([90-ang,0,0]) cylinder(d=branch_d, h=submersed(ang)+branch_l);
    }
  }
}

// Returns the height (z axis) of the branch b 
function submersed(ang=branch_angle) = beam_tread_d/4/sin(ang)+branch_d/4/tan(ang);

module branch_base (ang=branch_angle) {
    // Make part with tie channels completely solid in any case.
    // To that end, cover the ties with a bigger copy of the beam cylinder (adding tie_wall_width on top of the channels)
    intersection() {
      rotate([90-ang,0,0]) cylinder(d=branch_d, h=submersed(ang)+branch_l);

      rotate([0, 90, 0])
        cylinder(center=true,
          h=beam_tread_h,
          d=0
          +2*(branch_d/2+beam_tread_d/2)/2
          +2*tie_h
          +3*tie_wall_width
          +(abs(beam_tread_d/2-branch_d/2))
        );
    }
}

module branch_strut() {
  branch_off = tan(90-branch_angle) * submersed();
  strut_off = branch_off;
  strut_h = submersed();
  translate([0, -strut_off, 0])
    cylinder(d=branch_d, h=strut_h);
}


module norm_infill () {
  difference () {
    translate([0,0,submersed(branch_angle)+branch_l]) {
      rotate([90+branch_angle,0,0]) {
        difference() {
            union() {
              hull() {
                branch_base();
                branch_strut();
              }
              branch_top();
            }

            tie_channels(h=tie_h, w=tie_w);
        }
      }
    }
    bike();
  }
}

module high_infill () {
  norm_infill();
}

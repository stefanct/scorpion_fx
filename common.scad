// The origin of bike() is centered on the top screw of the aft part of the mud guard strut on the touching point of the strut and the mud guard wing

// overridable global functions/variables
function mud_screw_off_y()=0; // Additional offset of the mud screws towards the center
fill_screw_holes=1; // Without this there is a 0.25mm gap between the screws and respective holes in this model
mud_strut_extra_thick=0; // This allows the strut to intersect with the wing to prevent errors where the wing is already bending

module translate_bike() {
  children();
}
module translate_result() {
  children();
}
module norm_infill () {}
module high_infill () {}

////////////////////////////////////////////////////////////////////////
if (is_undef($fn)) {
  $fn=0;
}

include <utils.scad>;
include <bezier.scad>;

alpha=0.2;

// tires
tire_d_out=487;
tire_h=40;

// mud guard
mud_d = 60;
mud_straight = 35;
mud_axle_r = 290;
mud_axle_x = 195;
mud_axle_z = 150;

// mud strut
mud_strut_rotation_edge=2; // Rotation around the upper edge-ish
mud_strut_rotation_y=2.5; // Rotation around y
mud_strut_thick=5;
mud_strut_hole_d=5.5;
mud_strut_corner_r=6;
mud_strut_corner_front_r=5; // The further most corner seems to be different to all others
mud_strut_back_corner_dist=20.5;
mud_strut_front_corner_dist=22;
mud_strut_hole_side_dist=10;
mud_strut_back_hole_dist=15;
mud_strut_hole_back_angle=40;
mud_strut_bezier_upper_off_x=182; // Distance on x from top back screw to central bezier control point of upper border
mud_strut_front_off_x=234; // Distance on x from top back screw to aft front screw
mud_strut_front_off_z=110; // Likewise on z
mud_strut_front_hole_dist=15;
mud_strut_bottom_len=195;
mud_strut_bottom_angle=4;
mud_strut_front_front_angle=53;
mud_strut_front_back_angle=65;

// mud screws
mud_screw_shaft_d=5;
mud_screw_shaft_len=12;
mud_screw_head_d=9.5;
mud_screw_head_h=3;
mud_strut_screw_r = sqrt(mud_axle_z*mud_axle_z+mud_axle_x*mud_axle_x); // Radial distance from origin screw to axle

// scaffold
beam_angle=8; // vs. horiz.
// Tread beam
beam_tread_d=60.5;
beam_tread_h=800;
// Tread extension beam
beam_tread_ext_d=53;
beam_tread_ext_h=310; // (customizable)
// Front derailleur beam
beam_derailleur_d=29;
beam_derailleur_h=180;
beam_derailleur_angle=65; // vs. tread beam
// Crankset axle
crankset_d=44;
crankset_h=70;
// Beams to wheels
beam_wheels_d=55;
beam_wheels_h=320; // FIXME: rough estimate
beam_wheels_angle_z=70; // sideways vs. tread beam
beam_wheels_angle_x=8; // up vs. tread beam FIXME: rough estimate
beam_wheels_offset_x=315; // from front of tread beam
beam_wheels_offset_z=15; // below tread beam FIXME: rough estimate

// Origin is back of main beam
module beams () {
  color("darkblue", alpha=alpha) rotate([0, 90-beam_angle, 0]){
    // Main beam
    translate([ 0, 0, beam_tread_h/2]) cylinder(d=beam_tread_d, h=beam_tread_h, center=true);
    // Extension beam
    translate([ 0, 0, beam_tread_h+beam_tread_ext_h/2,]) cylinder(d=beam_tread_ext_d, h=beam_tread_ext_h, center=true);
    // Crankset axle
    translate([ 0, 0, beam_tread_h+beam_tread_ext_h,]) rotate([90, 0, 0]) cylinder(d=crankset_d, h=crankset_h, center=true);
    // Derailleur beam
    translate([ 0, 0, beam_tread_h+beam_tread_ext_h,]) rotate([0, 180+beam_derailleur_angle, 0]) cylinder(d=beam_derailleur_d, h=beam_derailleur_h);
    // Wheel beam right
    translate([ beam_wheels_offset_z, 0, beam_tread_h-beam_wheels_offset_x,]) rotate([beam_wheels_angle_z, -beam_wheels_angle_x, 0]) cylinder(d=beam_wheels_d, h=beam_wheels_h);
    // Wheel beam left
    translate([ beam_wheels_offset_z, 0, beam_tread_h-beam_wheels_offset_x,]) rotate([-beam_wheels_angle_z, -beam_wheels_angle_x, 0]) cylinder(d=beam_wheels_d, h=beam_wheels_h);
  }
}

// Upper edge of the strut is a bezier curve
mud_strut_upper_edge_p0 = [-mud_strut_front_off_x -tan(90-mud_strut_front_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r) +cos(90-mud_strut_front_back_angle)*mud_strut_corner_r,
      +mud_strut_front_off_z +(mud_strut_hole_side_dist-mud_strut_corner_r) +sin(90-mud_strut_front_back_angle)*mud_strut_corner_r]; // Back side of back screw of front bracket
// Exact location of p1 is unsure...
// It is certainly not the intersection between the front edge and the bottom edge
// The one below uses the intersection between the front edge and the horizontal line through the origin screw (upper screw of back bracket)
mud_strut_upper_edge_p1 = [
  -mud_strut_bezier_upper_off_x,
  0
];
mud_strut_upper_edge_p2 = [+cos(-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r),
      -sin(-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r) + mud_strut_corner_r]; // Front side of upper screw of back bracket

module mud_strut_holes (d=mud_strut_hole_d, h_add=0) {
  h=mud_strut_thick+mud_strut_extra_thick+h_add;
  // Back bracket: upper screw
  translate([0, h-mud_strut_extra_thick, 0])
    rotate([90,0,0])
      cylinder(h=h, d=d);
  // Back bracket: bottom screw
  translate([-sin(+mud_strut_hole_back_angle)*mud_strut_back_hole_dist, h-mud_strut_extra_thick, -cos(+mud_strut_hole_back_angle)*mud_strut_back_hole_dist])
    rotate([90,0,0])
      cylinder(h=h, d=d);
  // Front bracket: back screw
  translate([mud_strut_front_off_x, h-mud_strut_extra_thick, mud_strut_front_off_z])
    rotate([90,0,0])
      cylinder(h=h, d=d);
  // Front bracket: front screw
  translate([mud_strut_front_off_x+mud_strut_front_hole_dist, h-mud_strut_extra_thick, mud_strut_front_off_z])
    rotate([90,0,0])
      cylinder(h=h, d=d);
}

// The strut is somewhat inclined away from the center and slightly twisted.
// The code below tries to mimic the former by rotating -mud_strut_rotation_edge °
// around the axis from mud_strut_upper_edge_p0 and mud_strut_upper_edge_p2.
module strut_rotation(dir=-1) {
  pt_a=[mud_strut_upper_edge_p0[0], 0, -mud_strut_upper_edge_p0[1]];
  pt_b=[mud_strut_upper_edge_p2[0], 0, -mud_strut_upper_edge_p2[1]];
  pt=(pt_b+pt_a)/2;
  ax_tmp=pt_a-pt_b;
  ax=[ax_tmp[0], ax_tmp[1], ax_tmp[2]];
  rotate_about_pt(dir*mud_strut_rotation_edge, ax, pt)
    rotate([0, mud_strut_rotation_y, 0])
      children();
}

module mud_strut () {
  translate([0, -mud_strut_extra_thick, 0]) { // Make the strut intersect with the wing to prevent errors where the wing is already bending
    difference() {
      rotate([90,0,180])
      union() {
        linear_extrude(height = mud_strut_thick+mud_strut_extra_thick) {
          // Skeleton of the strut
          polygon(concat([
            // x axis                                                                                                                                                                   z axis
            [+sin(+50)*mud_strut_hole_side_dist,                                                                                                                                        +cos(+50)*mud_strut_hole_side_dist], // Back side of upper screw of back bracket
            [+sin(90-mud_strut_hole_back_angle)*mud_strut_hole_side_dist +sin(+mud_strut_hole_back_angle)*mud_strut_back_corner_dist,                                                   +cos(90-mud_strut_hole_back_angle)*mud_strut_hole_side_dist -cos(+mud_strut_hole_back_angle)*mud_strut_back_corner_dist], // Upper side of lower screw of back bracket
            [+sin(mud_strut_hole_back_angle)*(mud_strut_back_hole_dist+mud_strut_hole_side_dist),                                                                                       -cos(mud_strut_hole_back_angle)*(mud_strut_back_hole_dist+mud_strut_hole_side_dist)], // Lower side of lower screw of back bracket
            [+sin(+45)*mud_strut_back_corner_dist +0 +sin(-(90-mud_strut_bottom_angle))*mud_strut_bottom_len,                                                                           -cos(+45)*mud_strut_back_corner_dist -mud_strut_corner_r +cos(-(90-mud_strut_bottom_angle))*mud_strut_bottom_len], // Axle corner
            [-mud_strut_front_off_x -mud_strut_front_corner_dist -tan(90-mud_strut_front_back_angle)*mud_strut_corner_front_r -sin(mud_strut_front_front_angle)*mud_strut_corner_front_r, +mud_strut_front_off_z +mud_strut_hole_side_dist -mud_strut_corner_front_r -cos(mud_strut_front_front_angle)*mud_strut_corner_front_r], // Lower side of front screw of front bracket
            [-mud_strut_front_off_x -tan(90-mud_strut_front_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r) -mud_strut_front_corner_dist,                                     +mud_strut_front_off_z +mud_strut_hole_side_dist], // Upper side of front screw of front bracket
            [-mud_strut_front_off_x -tan(90-mud_strut_front_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r),                                                                  +mud_strut_front_off_z +mud_strut_hole_side_dist], // Upper side of back screw of front bracket
            // [-20, 8.5], // Test point
            ],
            bezier(mud_strut_upper_edge_p0,mud_strut_upper_edge_p1,mud_strut_upper_edge_p2)
          ));
        }

        // Corners are built by the cylinders below [x, z, y]
        // Front-side front corner
        translate([-mud_strut_front_off_x -mud_strut_front_corner_dist -tan(90-mud_strut_front_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_front_r),
                   +mud_strut_front_off_z+(mud_strut_hole_side_dist-mud_strut_corner_front_r), 0])
          cylinder(r=mud_strut_corner_front_r, h=mud_strut_thick+mud_strut_extra_thick);
        // Front-side back corner
        translate([-mud_strut_front_off_x -tan(90-mud_strut_front_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r),
                   +mud_strut_front_off_z +4, 0])
          cylinder(r=mud_strut_corner_r, h=mud_strut_thick+mud_strut_extra_thick);
        // Upper back corner
        translate([+cos(-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r),
                   -sin(-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r), 0])
          cylinder(r=mud_strut_corner_r, h=mud_strut_thick+mud_strut_extra_thick);
        // Lower back corner
        translate([+sin(90-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r) +sin(+mud_strut_hole_back_angle)*mud_strut_back_corner_dist,
                   +cos(90-mud_strut_hole_back_angle)*(mud_strut_hole_side_dist-mud_strut_corner_r) -cos(+mud_strut_hole_back_angle)*mud_strut_back_corner_dist, 0])
          cylinder(r=mud_strut_corner_r, h=mud_strut_thick+mud_strut_extra_thick);
      }

      // Remove screw holes
      mud_strut_holes();
    }
  }
}

module mud_screw (off_x=0, off_y=0, off_z=0) {
  h=mud_screw_shaft_len;
  d_hole=mud_screw_shaft_d;
  d_head=mud_screw_head_d;
  translate([off_x, +mud_strut_thick+mud_screw_head_h+off_y, off_z]) // Head
    rotate([90,0,0])
      cylinder(h=mud_screw_head_h, d=d_head); // actually rounded heads but this is good enough

  translate([off_x, +mud_strut_thick+off_y, off_z]) { // Shaft
    rotate([90,0,0])
      cylinder(h=h+off_y, d=d_hole);
  }
  if (fill_screw_holes==1) {
    translate([off_x, mud_strut_thick, off_z]) { // Hole
      rotate([90,0,0])
        cylinder(h=mud_strut_thick+mud_strut_extra_thick, d=mud_strut_hole_d);
    }
  }
}

module mud_screws_front (off_y=0) {
  // aft
  mud_screw(off_x=mud_strut_front_off_x, off_y=off_y, off_z=mud_strut_front_off_z);

  // bow
  off_x=mud_strut_front_off_x+mud_strut_front_hole_dist;
  off_z=mud_strut_front_off_z;
  mud_screw(off_x=off_x, off_y=off_y, off_z=off_z);
}

module mud_screws_back (off_y=0) {
  mud_screw(off_y=off_y);
  mud_screw(off_x=-cos(50)*mud_strut_back_hole_dist, off_y=off_y, off_z=-sin(50)*mud_strut_back_hole_dist);
}

module mud_screws (off_y=mud_screw_off_y()) {
  mud_screws_back(off_y=off_y);
  mud_screws_front(off_y=off_y);
}

module mud_guard_wing () {
  translate([mud_axle_x,0,-mud_axle_z])
  rotate([90,10,180])
      rotate_extrude(angle = 160, convexity = 10) 
        translate([mud_axle_r-mud_d/2, -mud_d/2, 0])
        union() {
          circle(d=mud_d);
          translate([-mud_straight,-mud_d/2,0])
            square([mud_straight,mud_d]);
        }
}

module tire () {
  translate([mud_axle_x, -tire_h/2-mud_d/2,-mud_axle_z])
    rotate([90,0,180])
      cylinder(h=tire_h, d=tire_d_out);
}
  
module wheel () {
  mud_guard();
  color("black", alpha=alpha) tire();
}

module mud_guard () {
  strut_rotation() {
    color("dimgrey", alpha=alpha) mud_strut();
    color("silver", alpha=alpha) mud_screws();
  }
  color("grey", alpha=alpha) mud_guard_wing();
}


// FIXME: all below are estimates
seat_off_x = -200;

seat_bot_x = 200;
seat_bot_y = 400;
seat_bot_z = 40;

seat_mid_x = 350;
seat_mid_y = seat_bot_y;
seat_mid_z = 40;

seat_top_x = 250;
seat_top_y = seat_bot_y;
seat_top_z = 40;

module seat () {
  color("grey", alpha=alpha) {
    rotate([0,5,0]) {
      translate([seat_off_x,bike_center_x()-seat_bot_y/2,0]) {
        cube([seat_bot_x, seat_bot_y, seat_bot_z]);

        rotate([0,45,0]) {
          translate([-seat_mid_x,0,0]) {
            cube([seat_mid_x, seat_mid_y, seat_mid_z]);

            rotate([0,15,0]) {
              translate([-seat_top_x,0,0]) {
                cube([seat_top_x, seat_top_y, seat_top_z]);
              }
            }
          }
        }
      }
    }
  }
}
  
function bike_center_x() = beam_wheels_h;

// Origin is top hole of back part of the right mud guard
module bike () {
  translate_bike() {
    // Right wheel
    wheel();
    translate([0,2*bike_center_x(),0]) // Left wheel
      mirror([0,1,0])
        wheel();

    translate([ // Beams
      -2*mud_axle_x
      ,
      bike_center_x() // FIXME // +sin(beam_wheels_angle_z)/beam_wheels_h
      , // beam_tread_d/2,
      -mud_axle_z
    ])
      beams();

    seat();
  }
}



module draw () {
  if (!is_undef(is_left) && is_left != 0) {
    mirror([1,0,0])
    children();
  } else {
    children();
  }
}

module model () {
  %bike();

  if (!is_undef(is_high_infill) && is_high_infill != 0) {
    high_infill();
  } else {
    norm_infill();
  }
}

draw() model();

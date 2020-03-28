// overridable global functions/variables
function mud_screw_off()=0;

module translate_bike() {
  children();
}
module norm_infill () {}
module high_infill () {}

////////////////////////////////////////////////////////////////////////

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
mud_strut_thick=5;
mud_strut_corner_r=5;
mud_strut_corner_dist=25;
mud_strut_hole_d=5;
mud_strut_hole_dist=15;
mud_strut_screw_d=9;
mud_strut_screw_len=10;
mud_strut_h_max=28;
mud_strut_corner_angle=45;
mud_strut_rotation=5;

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

module mud_strut () {
  rotate([90,0,180])
  difference() {
    translate([0,0,-1]) // Make the strut intersect with the wing to prevent errors where the wing bends already
    minkowski() {
      linear_extrude(height = 4) polygon([
        [-70,                             1],
        [3,                               4],
        [3+mud_strut_corner_dist/sqrt(2), 4-mud_strut_corner_dist/sqrt(2)],
        [-70,                             4-mud_strut_corner_dist/sqrt(2)],
      ]);
      cylinder(r=5, h=2);
    }

    cylinder(h=mud_strut_thick, d=mud_strut_hole_d);
    translate([mud_strut_hole_dist/sqrt(2), -mud_strut_hole_dist/sqrt(2),0])
      cylinder(h=mud_strut_thick, d=mud_strut_hole_d);
  }
}

module mud_screws (off=0) {
  // Screw heads
  translate([0,mud_strut_thick+off,0])
    union() {
      rotate([90,0,180])
        cylinder(h=2, d=mud_strut_screw_d);
      translate([-mud_strut_hole_dist/sqrt(2), 0, -mud_strut_hole_dist/sqrt(2)])
        rotate([90,0,180])
          cylinder(h=2, d=mud_strut_screw_d);
    }

  // Screw shafts
  translate([0,-mud_strut_thick,0])
    union() {
        rotate([90,0,180])
      cylinder(h=mud_strut_screw_len+off, d=mud_strut_hole_d);
      translate([-mud_strut_hole_dist/sqrt(2), 0, -mud_strut_hole_dist/sqrt(2)])
        rotate([90,0,180])
          cylinder(h=mud_strut_screw_len+off, d=mud_strut_hole_d);
    }
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
  rotate([0,mud_strut_rotation,0]) {
    color("dimgrey", alpha=alpha) mud_strut();
    color("silver", alpha=alpha) mud_screws(off=mud_screw_off());
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
      bike_center_x() // FIXME
        // +sin(beam_wheels_angle_z)/beam_wheels_h
      ,
      // beam_tread_d/2,
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

// $fn=50;
// $fn=200;

// is_high_infill = 1;

bracket_thick = 6;

include <common.scad>;

function beam_bottle_screw_shaft_h_extra()=bracket_thick-beam_bottle_screw_weld_h;
pylons_angle_y=+90;
pylons_h=50;

light_beam_d=25; // 22-35mm
light_beam_stem_h=bracket_thick;
light_beam_h=60-2*light_beam_stem_h; // The stem is attached on both sides of the stem thus enlarging it

light_body_h=94.2;
light_body_d=39.6;

module light_body() {
  rotate([0, -90-beam_derailleur_angle+beam_angle, 0])
    translate([beam_derailleur_h-30, 0, -light_body_h/2])
      cylinder(h=light_body_h, d=light_body_d);
}

module translate_bike() {
  translate_result()
    rotate([0, -beam_derailleur_angle+beam_angle, 0])
    translate([
      -2*mud_axle_x-beam_tread_ext_h*cos(beam_angle)-beam_derailleur_d*cos(beam_derailleur_angle-90-beam_angle)
      ,
      -bike_center_x() // FIXME // +sin(beam_wheels_angle_z)/beam_wheels_h
      , // beam_tread_d/2,
      -mud_axle_z+beam_tread_ext_h/2*cos(beam_angle)+beam_derailleur_d*sin(beam_derailleur_angle-90-beam_angle)
    ])
  children();
}

module translate_derailleur(top_off=0, r_off=0) {
  rotate([0, -90, 0])
    translate([r_off, 0, beam_derailleur_h+top_off])
      children();
}

module light_beam_stem() {
  d=light_beam_d;
  translate([0, light_beam_h/2, 0])
    light_beam(h=bracket_thick, d=d);
}

module pylon_stem() {
  d=light_beam_d/2;
  translate([0, light_beam_h/2+light_beam_stem_h/2, 0])
    light_beam(h=bracket_thick, d=d);
}

module light_beam_cone() {
  hull() {
    light_beam_stem();
    pylon_stem();
  }
}

module light_beam(h=light_beam_h, d=light_beam_d) {
  translate([-beam_derailleur_h + bottle_dist_top/2 + bottle_dist, 0, 0])
    rotate([0,pylons_angle_y, 0])
      translate([-pylons_h, 0, 0])
        translate([0, h/2, 0])
          rotate([90, 0, 0])
            cylinder(h=h, d=d);
}

module bracket (h=beam_derailleur_h/2, w=beam_derailleur_d+bracket_thick, y_off=0) {
  t=bracket_thick*3;
  translate_derailleur(top_off=-bottle_dist_top - bottle_dist/2 - h/2, r_off=-bracket_thick) {
    intersection () {
      translate([-bracket_thick, -w/2+y_off, 0])
        cube([t, w, h]);
      cylinder(h=h, d=beam_derailleur_d+bracket_thick);
    }
  }
}

module bracket_stem (w, h) {
  bracket(h=h, w=w, y_off=(beam_derailleur_d+bracket_thick)/2-w/2);
}

module pylon() {
  hull() {
    pylon_stem();
    // bracket_stem(w=light_beam_d/3, h=2*bracket_thick); // Thicker, less wide pylons
    bracket_stem(w=light_beam_d/5, h=7*bracket_thick); // Wider, thinner pylons
  }
}

module holder () {
  bracket();
  pylon();
  mirror([0, 1, 0]) pylon();
  light_beam();
  light_beam_cone();
  mirror([0, 1, 0]) light_beam_cone();
}

module translate_result() {
  translate([beam_derailleur_h/2, 0, beam_derailleur_d/2-bracket_thick/2, ])
    children();
}

module norm_infill () {
  difference() {
    translate_result()
      holder();
    bike();
  }
}

module screw_stem (off) {
  translate_derailleur(top_off=-bottle_dist_top+off, r_off=-bracket_thick) {
    rotate([0, 90, 0])
      cylinder(h=beam_bottle_screw_shaft_h+beam_bottle_screw_shaft_h_extra(), d=beam_bottle_screw_head_d*2);
  }
}

module high_infill () {
  difference() {
    translate_result() {
      intersection () {
        bracket();

        union() {
          screw_stem(off=0);
          screw_stem(off=-bottle_dist);
        }
      }

      pylon();
      mirror([0, 1, 0]) pylon();

      light_beam_cone();
      mirror([0, 1, 0]) light_beam_cone();
    }
    bike();
  }
}

// Crude model of a light
%translate_result()
  light_body();

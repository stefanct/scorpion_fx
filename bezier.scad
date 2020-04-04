// bezier_deltat determines the stepsize of the 'running variable' t below.
// The smaller the step the smoother the curve.
// Since the default of $fn is zero we the min below makes sure that
// the functions below remain working if $fn is not set explicitly.
bezier_deltat = min(0.1,1/$fn);

// Quadratic Bezier formula
// B(t)=(1-t)(1-t)p0+2(1-t)(t)p1+(t)(t)p2
// Would be possible w/o concat since OpenSCAD 2019.05
function bezier(p0,p1,p2) = concat([for (t=[0:bezier_deltat:1]) pow(1-t,2)*p0+2*(1-t)*t*p1+pow(t,2)*p2],[p2]);

wipe;

source "../Shared_Proc/Analysis.tcl";
source "../Shared_Proc/Geometry.tcl";

model BasicBuilder -ndm 3 -ndf 6;

#node

set node_tag 1;
set ele_tag 1;

set BlockTag 1;
set width 1.0;
set depth 1.0;
set widthMeshNum 50;
set depthMeshNum 50;

set AlgOrder [list BFGS KrylovNewton  SecantNewton NewtonLineSearch];
set AlgOrder [list Newton];
#material
set E 1.0;
set v 0.1;
nDMaterial ElasticIsotropic 1 $E $v;
#nDMaterial Damage2p 1 30.0;
#nDMaterial PlaneStress 2 1;

#Section
set shellSecTag 1;
section PlateFiber $shellSecTag 1 0.01;

set shellType ShellNLDKGQ;

#Create shell
set temp [ShellRectFourNode $BlockTag $width $depth $widthMeshNum $depthMeshNum $shellType $shellSecTag]

set nodeTagSide1 [lindex $temp 0]
set nodeTagSide2 [lindex $temp 1]
set nodeTagSide3 [lindex $temp 2]
set nodeTagSide4 [lindex $temp 3]

#boundary
proc comment {} {
    foreach temp $nodeTagSide1 {
        fix $temp 1 1 1 0 1 1;
    }

    foreach temp $nodeTagSide3 {
        fix $temp 1 0 1 0 1 1;
    }
}



#Element
#element ShellMITC4 1 1 2 3 4 1;

#Constrain
set RefNodeTag1 9991;
set RefNodeTag2 9992;
node $RefNodeTag1 0.0 [expr $width / 2.0] 0.0;
node $RefNodeTag2 $depth [expr $width / 2.0] 0.0;

fix $RefNodeTag1 1 1 1 1 1 1;
fix $RefNodeTag2 1 0 1 1 1 1;

foreach temp $nodeTagSide1 {
    equalDOF $RefNodeTag1 $temp 1 2 3 4 5 6;
}

foreach temp $nodeTagSide3 {
    equalDOF $RefNodeTag2 $temp 1 2 3 4 5 6;
    #rigidLink bar $RefNodeTag2 $temp;
}
#Load
pattern Plain 1 Linear {
    load $RefNodeTag2 0.0 1.0 0.0 0.0 0.0 0.0;
}


#Display the model if wanted
if {1==10} {
    recorder display "1" 10 10 800 800 -wipe;
    prp 9.0e3 9.0e3 1;
    vup  0  1 0;
    vpn  0.5  0.5 0.5;
    display 1 5 1;
}

recorder Node -file "temp_F.out" -node $RefNodeTag2 -dof 2 reaction;
recorder Node -file "temp_D.out" -node $RefNodeTag2 -dof 2 disp;

#Analysis
constraints Plain;
numberer Plain;
system Mumps -ICNTL 100;


set temp [expr 1+$depthMeshNum];

set isFinish [Analyse_Static_Disp_Control $RefNodeTag2 2 0.00001 0.00001 1.0E-3 50 $AlgOrder]

#integrator DisplacementControl $RefNodeTag2 2 0.001;
#analysis Static;
#analyze 20;

#print -node $RefNodeTag2;
#print -node $RefNodeTag1;

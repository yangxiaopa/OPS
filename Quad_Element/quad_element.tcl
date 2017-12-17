wipe;
model BasicBuilder -ndm 2 -ndf 2;

#node
node 1 0.0 0.0;
node 2 1.0 0.0;
node 3 1.0 1.0;
node 4 0.0 1.0;

#boundary
fix 1 1 1;
fix 2 0 1;
fix 3 0 0;
fix 4 1 0;

#material
set E 1.0;
set v 0.1;
nDMaterial ElasticIsotropic 1 $E $v;

#Element
element quad 1 1 2 3 4 1.0 PlaneStress 1;

#Load
pattern Plain 1 Linear {
    load 3 0.0 1.0;
    load 4 0.0 1.0;
}

#Analysis
constraints Plain;
numberer Plain;
system BandGeneral;
test NormDispIncr 1.0E-3 50;
algorithm Newton;
integrator DisplacementControl 3 2 0.001;
analysis Static;
analyze 10;

print -node 3;

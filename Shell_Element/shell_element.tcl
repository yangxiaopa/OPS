wipe;
model BasicBuilder -ndm 3 -ndf 6;

#node
node 1 0.0 0.0 0.0;
node 2 1.0 0.0 0.0;
node 3 1.0 1.0 0.0;
node 4 0.0 1.0 0.0;

#boundary
fix 1 1 1 1;
fix 2 0 1 1;
fix 3 0 0 1;
fix 4 1 0 1;

#material
set E 1.0;
set v 0.1;
nDMaterial ElasticIsotropic 1 $E $v;

#Section
section PlateFiber 1 1 1.0;

#Element
element ShellMITC4 1 1 2 3 4 1;

#Load
pattern Plain 1 Linear {
    load 3 0.0 1.0 0.0 0.0 0.0 0.0;
    load 4 0.0 1.0 0.0 0.0 0.0 0.0;
}

#Analysis
constraints Plain;
numberer Plain;
system BandGeneral;
test NormDispIncr 1.0E-3 50;
algorithm Newton;
integrator DisplacementControl 3 2 -0.001;
analysis Static;
analyze 10;

print -node 3 4;

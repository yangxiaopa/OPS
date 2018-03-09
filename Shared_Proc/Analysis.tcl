#pause analysis
proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}


#Calculate the coefficient for rayleigh damping
proc Damp_RayLeigh_Coeff {damping_ratio Wi Wj} {
    set a0 [expr $damping_ratio * 2.0 * $Wi * $Wj / ($Wi + $Wj)];
    set a1 [expr $damping_ratio * 2.0 / ($Wi + $Wj)];
    return [list $a0 $a1];
}



#TH analysis control
proc TH_Analysis {initial_dt length tol_TH iter_TH} {
    set cur_length 0.0;
    while {$cur_length < $length} {
        set cur_dt [TH_Analysis_one_step $initial_dt $tol_TH $iter_TH];
        if {$cur_dt < 0} {
            break;
        } else {
            set cur_length [expr $cur_length + $cur_dt];
        }
    }
    return $cur_dt;
}

#TH analysis control one step
proc TH_Analysis_one_step {initial_dt tol_TH iter_TH {reduceNum 4}} {
    algorithm Newton;
    test NormDispIncr $tol_TH $iter_TH;
    set cur_dt $initial_dt;
    set curReduceNum 0;
    set if_increase_tol 0;
    set if_change_alg 0;
    set is_break 0;
    set ok [analyze 1 $cur_dt];
    while {$ok < 0} {
        if {$curReduceNum < $reduceNum} {
            algorithm NewtonLineSearch;
            set cur_dt [expr $cur_dt / 2.0];
            set curReduceNum [expr $curReduceNum + 1];
            puts $curReduceNum
            set ok [analyze 1 $cur_dt]; 
            
        } elseif { $if_increase_tol==0} {
            test NormDispIncr $tol_TH [expr $iter_TH * 2];
            set if_increase_tol 1;
            set ok [analyze 1 $cur_dt]; 
        } elseif {$if_change_alg==0} {
            algorithm BFGS;
            set ok [analyze 1 $cur_dt]; 
            set if_change_alg 1;
        } else {
            set is_break 1;
            break;
        }
    }
    if {$is_break==1} {
        return -1;
    } else {
        return $cur_dt;
    }
}

#Change Algorithm until converge
proc iterAlg {AlgOrder} {
    set ok -1;
    for {set i 0} {$i < [llength $AlgOrder]} {incr i} {
        if {$ok < 0} {
            algorithm [lindex $AlgOrder $i];
            set ok [analyze 1]; 
        } else {
            break;
        }
    }
    return $ok;
}

#One increment analysis of Displacement Control
proc Analyse_Static_Disp_Control_Incr {ctrlNodeTag ctrlDof d_incr d_tol iter_max AlgOrder {reduceNum 4}} {
    set cur_incr $d_incr;
    set curReduceNum 0;
    set isReduce 0;
    set isIncrIter 0;
    set isBreak 0;
    integrator DisplacementControl $ctrlNodeTag $ctrlDof $cur_incr;
    test NormDispIncr $d_tol $iter_max 0;
    algorithm [lindex $AlgOrder 0];
    analysis Static;
    set ok -1;
    set ok [iterAlg $AlgOrder];
    while {$ok < 0} {
        if {$curReduceNum < $reduceNum} {
            set cur_incr [expr $cur_incr / 10.0];
            set curReduceNum [expr $curReduceNum + 1];
            puts $curReduceNum;
            integrator DisplacementControl $ctrlNodeTag $ctrlDof $cur_incr;
            analysis Static;
            set ok [iterAlg $AlgOrder];
        } elseif { $isIncrIter==0} {
            test NormDispIncr $d_tol [expr $iter_max * 2] 0;
            set isIncrIter 1;
            set ok [iterAlg $AlgOrder];
        } else {
            set isBreak 1;
            break;
        }
    }
    if {$isBreak==1} {
        return -1;
    } else {
        return [expr abs($cur_incr)];
    }
}


#One monotonic step of Displacement Control
proc Analyse_Static_Disp_Control {ctrlNodeTag ctrlDof d_max d_incr d_tol iter_max AlgOrder {reduceNum 4}} {
    if {$d_max>= 0.0} {set d_incr [expr abs($d_incr)]} else {set d_incr [expr -abs($d_incr)]}
    set is_finish 0;
    set d_cum 0.0;
    
    while {$d_cum < [expr abs($d_max)] * 0.9999} {
        set cur_incr [Analyse_Static_Disp_Control_Incr $ctrlNodeTag $ctrlDof $d_incr $d_tol $iter_max $AlgOrder $reduceNum] 
        if {$cur_incr != -1} {
            #set temp [eleResponse 1 forces];
            #set Mom [lindex $temp 2];
            #set Load [expr $Mom / $L / 1000.0];
            #set cur_Disp [nodeDisp $top_node 1];
            #set data "$cur_Disp $Load";
            #puts $fileID $data;
            set d_cum [expr $d_cum + $cur_incr];
        } else {
            set is_finish -1;
            break
        }
    }
    return $is_finish;
}

#One cyclic of Displacement Control
proc Analyse_Static_Disp_Cyclic_Control {ctrlNodeTag ctrlDof DispList d_incr d_tol iter_max AlgOrder {reduceNum 4}} {
    set step_num [llength $DispList];
    for {set i 0} {$i<$step_num-1} {incr i} {
        set d1 [lindex $DispList $i];
        set d2 [lindex $DispList [expr $i+1]];
        set d_max_cur [expr ($d2-$d1)];
        set is_finish [Analyse_Static_Disp_Control $ctrlNodeTag $ctrlDof $d_max_cur $d_incr $d_tol $iter_max $AlgOrder $reduceNum];
        if {$is_finish == -1} {
            break
        }
    }
    return $is_finish;
}




#Create a rectangular shell plate
proc ShellRectFourNode {BlockTag width depth widthMeshNum depthMeshNum shellType shellSecTag} {
    
    set node_tag 1;
    set ele_tag 1;
    
    set digit_i [expr int(log($depthMeshNum) / log(10.0)) + 1];
    set digit_j [expr int(log($widthMeshNum) / log(10.0)) + 1];
    set stepWidth [expr $width / $widthMeshNum];
    set stepDepth [expr $depth / $depthMeshNum];
    
    #node number
    for {set i 1} {$i <= [expr 1+$depthMeshNum]} {incr i} {
        set temp_y [expr ($i-1) * $stepDepth];
        for {set j 1} {$j <= [expr 1+$widthMeshNum]} {incr j} {
            set temp_x [expr ($j-1) * $stepWidth];
            set tempNodeTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i $j];
            node $tempNodeTag $temp_x $temp_y 0.0;
        }
    }

    #node region
    set nodeTagSide1 [list];
    set nodeTagSide2 [list];
    set nodeTagSide3 [list];
    set nodeTagSide4 [list];
    for {set j 1} {$j <= [expr 1+$widthMeshNum]} {incr j} {
        set temp [expr $depthMeshNum + 1];
        set tempNodeTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag 1 $j];
        lappend nodeTagSide1 $tempNodeTag;
        set tempNodeTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $temp $j];
        lappend nodeTagSide3 $tempNodeTag;
    }

    for {set i 1} {$i <= [expr 1+$depthMeshNum]} {incr i} {
        set temp [expr $widthMeshNum + 1];
        set tempNodeTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i $temp];
        lappend nodeTagSide2 $tempNodeTag;
        set tempNodeTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i 1];
        lappend nodeTagSide4 $tempNodeTag;
    }
    eval "region ${BlockTag}${node_tag}1 -node ${nodeTagSide1}";
    eval "region ${BlockTag}${node_tag}2 -node ${nodeTagSide2}";
    eval "region ${BlockTag}${node_tag}3 -node ${nodeTagSide3}";
    eval "region ${BlockTag}${node_tag}4 -node ${nodeTagSide4}";
    
    #shell element 
    for {set i 1} {$i <= $depthMeshNum} {incr i} {
        for {set j 1} {$j <= $widthMeshNum} {incr j} {
            set temp_i [expr $i+1];
            set temp_j [expr $j+1];
            set tempEleTag ${BlockTag}0${i}0${j};
            set tempEleTag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i $j];
            set node1_tag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i $j];
            set node2_tag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $i $temp_j];
            set node3_tag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $temp_i $temp_j];
            set node4_tag [format "%d%0${digit_i}d%0${digit_j}d" $BlockTag $temp_i $j];
            
            element $shellType $tempEleTag $node1_tag $node2_tag $node3_tag $node4_tag $shellSecTag;
        }
    }
    return [list $nodeTagSide1 $nodeTagSide2 $nodeTagSide3 $nodeTagSide4]
}
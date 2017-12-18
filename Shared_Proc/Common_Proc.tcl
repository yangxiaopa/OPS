#Load file as list
proc load_list {path} {
    set f [open $path r];
    set content [read $f];
    close $f;
    set contents [split $content "\n"]
    return $contents;
}

#Load file as matrix
proc load_matrix {path} {
    set out [list];
    set f [open $path r];
    set content [read $f];
    close $f;
    set contents [split $content "\n"]
    foreach line $contents {
        lappend out [split $line " "];
    }
    return $out;
}

#Index a matrix
proc list_index args {
    set length [llength $args];
    set matrix [lindex $args 0];
    if {$length==2} {
        return [lindex $matrix [lindex $args 1]];
    } elseif {$length==3} {
        return [lindex [lindex $matrix [lindex $args 1]] [lindex $args 2]];
    }
}
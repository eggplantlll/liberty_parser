package provide lip 1.0

# lip_print_value_table
# {{{
proc lip_print_value_table {values xsize ysize} {
  upvar kout kout
  puts $kout "          values\( \\"
  for {set y 0} {$y < $ysize} {incr y} {
    set index [list]
    set row   [list]
    for {set x 0} {$x < $xsize} {incr x} {
      set index [expr $y*$xsize+$x]
      lappend row [lindex $values $index]
    }
    set new_row_str [join $row ", "]
    puts $kout "          \"$new_row_str\", \\"
  }
  puts $kout "         \);"
}
# }}}
# lip_interpolate
proc lip_interpolate {glib cellname {ofile NA}} {
  set gcell [get_cell $glib $cellname]
  set cell_name [get_group_name $gcell]
  upvar kout kout
  puts $kout "  cell($cell_name) \{"
  list_attributes $gcell {    } save

# Pin level
  foreach g2 [get_subgroups $gcell] {
    set g2_name [get_group_name $g2]
    if {$g2_name == "NA"} {set g2_name ""}
    set g2_type [get_group_type $g2]
    puts $kout "    $g2_type\($g2_name\) \{"

    # Pin level attribute
    foreach att [get_attributes $g2] {
      set value [get_attribute_value $g2 $att]
      if {$att == "capacitance"} {
# Input pin cap * 2
        #set value [expr $value * 2]
        set value $value
        puts $kout "      $att : \"$value\";"
      } elseif {$att == "rise_capacitance_range" || $att == "fall_capacitance_range"} {
        puts $kout "      [append att "\($value\);"]"
      } else {
        puts $kout "      $att : \"$value\";"
      }
    }
# Timing level
      foreach g3 [get_subgroups $g2] {
        set g3_name [get_group_name $g3]
        if {$g3_name == "NA"} {set g3_name ""}
        set g3_type [get_group_type $g3]
        puts $kout "      $g3_type\($g3_name\) \{"
        list_attributes $g3 {        } save
            # cell_rise, rise_power...
            foreach g4 [get_subgroups $g3] {
                set g4_name [get_group_name $g4]
                set g4_type [get_group_type $g4]
                # cell_rise, cell_fall
                if {$g4_type == "cell_rise" || $g4_type == "cell_fall"} {
                  set ysize [llength [get_attribute_value $g4 index_1]]
                  set xsize [llength [get_attribute_value $g4 index_2]]
                  puts $kout "        $g4_type\($g4_name\) \{"
                  # index_1, index_2, values
                  foreach att [get_attributes $g4] {
                    if {$att == "values"} {
                      set value [get_attribute_value $g4 $att]
                      set intrinsic [lindex $value 0]
                      regsub {,} $intrinsic {} intrinsic

                      set newvalues [list]
                      foreach v $value {
                        regsub {,} $v {} v
                        #lappend newvalues [format "%.6f" [expr ($v - $intrinsic)/2 + $intrinsic]]
                        lappend newvalues $v
                      }
                      lip_print_value_table $newvalues $xsize $ysize
                    # index_1, index_2
                    } else {
                      set value [get_attribute_value $g4 $att]
                      puts $kout "          [append att "\(\"$value\"\);"]"
                    }
                  }
                  puts $kout "        \}"
                # rise_power, fall_power....
                } else {
                  set ysize [llength [get_attribute_value $g4 index_1]]
                  set xsize [llength [get_attribute_value $g4 index_2]]
                  #puts "ysize: $ysize, xsize: $xsize"
                  puts $kout "        $g4_type\($g4_name\) \{"
                  # index_1, index_2, values
                  foreach att [get_attributes $g4] {
                    # value
                    if {$att == "values"} {
                      set values [get_attribute_value $g4 $att]
                      regsub -all {,} $values {} values
                      if {$xsize == "1"} {
                        puts $kout "          [append att "\(\"$values\"\);"]"
                      } else {
                        lip_print_value_table $values $xsize $ysize
                      }
                    # index_1, index_2
                    } else {
                      set values [get_attribute_value $g4 $att]
                      puts $kout "          [append att "\(\"$values\"\);"]"
                    }
                  }
                  puts $kout "        \}"
                }
            } ;#4
            puts $kout "      \}"
      }; #3
      puts $kout "    \}"
  }; #2
  puts $kout "  \}"
}

proc file_not_exist_exit {fname} {
  if ![file exist $fname] {
    puts "Error: $fname not exist. Nothing done..."
    exit
  }
}
# lip_extract_cell
# {{{
proc lip_extract_cell {glib cellname {ofile NA}} {
  set gcell [get_cell $glib $cellname]
  set cell_name [get_group_name $gcell]
  if {$ofile == "NA"} {
    puts "  cell($cell_name) \{"
    list_attributes $gcell {    }
  } else {
    upvar kout kout
    puts $kout "  cell($cell_name) \{"
    list_attributes $gcell {    } save
  }

  foreach g2 [get_subgroups $gcell] {
    # name
    if {[get_group_name $g2] == "NA"} {
      set g2_name ""
    } else {
      set g2_name [get_group_name $g2]
    }
    # type
    set g2_type [get_group_type $g2]
    if {$ofile == "NA"} {
      puts "    $g2_type\($g2_name\) \{"
      list_attributes $g2 {      }
    } else {
      puts $kout "    $g2_type\($g2_name\) \{"
      list_attributes $g2 {      } save
    }

      foreach g3 [get_subgroups $g2] {
        # name
        if {[get_group_name $g3] == "NA"} {
          set g3_name ""
        } else {
          set g3_name [get_group_name $g3]
        }
        # type
        set g3_type [get_group_type $g3]
        if {$ofile == "NA"} {
          puts "      $g3_type\($g3_name\) \{"
          list_attributes $g3 {        }
        } else {
          puts $kout "      $g3_type\($g3_name\) \{"
          list_attributes $g3 {        } save
        }
          foreach g4 [get_subgroups $g3] {
            # name
            if {[get_group_name $g4] == "NA"} {
              set g4_name ""
            } else {
              set g4_name [get_group_name $g4]
            }
            # type
            set g4_type [get_group_type $g4]
            if {$ofile == "NA"} {
              puts "        $g4_type\($g4_name\) \{"
              list_attributes $g4 {          }
            } else {
              puts $kout "        $g4_type\($g4_name\) \{"
              list_attributes $g4 {          } save
            }
            if {$ofile == "NA"} {
              puts "        \}"
            } else {
              puts $kout "        \}"
            }
          } ;#4
        if {$ofile == "NA"} {
          puts "      \}"
        } else {
          puts $kout "      \}"
        }
      };#3
    if {$ofile == "NA"} {
      puts "    \}"
    } else {
      puts $kout "    \}"
    }
  }
  if {$ofile == "NA"} {
    puts "  \}"
  } else {
    puts $kout "  \}"
  }
}
# }}}
# get_cell_list
# {{{
proc get_cell_list {glib {pattern .*}} {
  foreach i [get_cells $glib $pattern] {
    lappend ilist [get_group_name $i]
  }
  return $ilist
}
# }}}
# lip_get_cell_delay
# {{{
proc lip_get_cell_delay {glib cell_name tran load {ofile NA}} {
  upvar debug_mode debug_mode
  if ![info exist debug_mode] {set debug_mode 0}
  #if {$ofile != "NA"} {set kout [open $ofile w]}
  if {$ofile != "NA"} {upvar kout kout}

  set gcell [get_cell $glib $cell_name]
  set area [get_attribute_value $gcell area]
#set gpin [get_pin $gcell o]
  foreach gpin [get_subgroups $gcell] {
    set pin_name  [get_group_name $gpin]
    set direction [get_attribute_value $gpin direction]
    set function  [get_attribute_value $gpin function]
    if {$direction == "output"} {
      set gp [get_subgroup_of_type $gpin timing]
      set g [get_subgroup_of_type $gp cell_rise]
      if {$g == "NA"} {
        set g [get_subgroup_of_type $gp cell_fall]
      }
      set delay [format "%.3f" [lip_LU_table_interpolate $g $tran $load $debug_mode]]
      if {$ofile == "NA"} {
        puts "$cell_name: $delay: $pin_name: $direction: $area: $function"
      } else {
        puts "$cell_name: $delay: $pin_name: $direction: $area: $function"
        puts $kout "$cell_name: $delay: $pin_name: $direction: $area: $function"
      }
      break;
    }
  }

  #if {$ofile != "NA"} {close $kout}
}
# }}}
# lip_list_all
# {{{
proc lip_list_all {glib} {
  # cell
  foreach gcell [get_subgroups $glib] {
      set cell_name [get_group_name $gcell]
      set name [get_group_name $gcell]
      set type [get_group_type $gcell]
      #puts "    $type($name)"
      list_attributes $gcell {    }
    # pin
    foreach gpin [get_subgroups $gcell] {
      set pin_name [get_group_name $gpin]
      set name [get_group_name $gpin]
      set type [get_group_type $gpin]
      #puts "      $type($name)"
      list_attributes $gpin {        }
        # timing
        foreach g3 [get_subgroups $gpin] {
          set name [get_group_name $g3]
          set type [get_group_type $g3]
          set g3_type [get_group_type $g3]
          list_attributes $g3 {            }
        }
    }
  }
}
# }}}
# lip_list_index
# {{{
proc lip_list_index {glib index_type {ofile NA}} {
  if {$ofile != "NA"} { set kout [open $ofile w]}

  # cell
  foreach gcell [get_subgroups $glib] {
      set cell_name [get_group_name $gcell]
      set name [get_group_name $gcell]
      set type [get_group_type $gcell]
      #puts "    $type($name)"
    #list_attributes $gcell {    }
    # pin
    foreach gpin [get_subgroups $gcell] {
      set pin_name [get_group_name $gpin]
      set name [get_group_name $gpin]
      set type [get_group_type $gpin]
      set break_pin 0
      #puts "      $type($name)"
      #list_attributes $gpin {        }
        # timing
        foreach g3 [get_subgroups $gpin] {
          set name [get_group_name $g3]
          set type [get_group_type $g3]
          set g3_type [get_group_type $g3]
          set break_g3 0
          #puts "3        $type($name)"
          #list_attributes $g3 {            }
           # rise/fall
            foreach g4 [get_subgroups $g3] {
              set name [get_group_name $g4]
              set type [get_group_type $g4]
              set g4_type [get_group_type $g4]
              if {$g3_type == "timing" && $g4_type == "cell_rise"} {
                #puts "4            $type($name)"
                #list_attributes $g4 {                }
                set index1 [get_attribute_value $g4 index_1]
                set index2 [get_attribute_value $g4 index_2]
                #set values [get_attribute_value $g4 values]
                if {$ofile == "NA"} {
                  if {$index_type == "tran"} {
                    puts "$cell_name: $pin_name: $g4_type :  tran: $index1"
                  } else {
                    puts "$cell_name: $pin_name: $g4_type :  load: $index2"
                  }
                  #puts "$cell_name: $pin_name: $g4_type : delay: $values"
                } else {
                  if {$index_type == "tran"} {
                    puts $kout "$cell_name: $pin_name: $g4_type :  tran: $index1"
                  } else {
                    puts $kout "$cell_name: $pin_name: $g4_type :  load: $index2"
                  }
                  #puts $kout "$cell_name: $pin_name: $g4_type : delay: $values"
                }
                set break_g3   1
                set break_pin  1
                break;
              }
            }
          if {$break_g3} { break; }
        }
        if {$break_pin} { break; }
    }
  }

  if {$ofile != "NA"} { close $kout }

}
# }}}
# lpwd
# {{{
proc lpwd {} {
  upvar hier_stack hier_stack
  foreach i $hier_stack {
    puts $i
  }
}
# }}}
# ncd 
# {{{
proc ncd {goto_num} {
  set e [new_err]

  upvar cur_gp cur_gp
  upvar posi_stack posi_stack
  upvar hier_stack hier_stack

  push posi_stack $cur_gp

  set group $cur_gp

  
  set groups [si2drGroupGetGroups $group $e]

  set num 1
  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      if {$num == $goto_num} {
        set group_name [get_group_name $gp]
        set group_type [si2drGroupGetGroupType $gp $e]
        puts "$num: \033\[0;36m$group_type\033\[0m : $group_name"
        push hier_stack "$group_type\($group_name\)"
        set cur_gp $gp
        return;
      }
      incr num
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# lcd
# {{{
proc lcd {gtype gname} {
  upvar cur_gp cur_gp
  upvar posi_stack posi_stack

  push posi_stack $cur_gp

  set new_gp [get_$gtype $cur_gp $gname]
  #list_subgroups $new_gp
  set cur_gp $new_gp
}
# }}}
# cdup
# {{{
proc cdup {} {
  upvar cur_gp cur_gp
  upvar posi_stack posi_stack
  upvar hier_stack hier_stack

  set cur_gp [pop posi_stack]
  pop hier_stack

}
# }}}
# push
# {{{
proc push {inlist var} {
        upvar $inlist l
        return [ lappend l $var ]
}
# }}}
# pop
# {{{
proc pop {inlist} {
        upvar $inlist l
        if [llength $l] {
                set ele [lindex $l end]
                lset l [lreplace $l end end]
        }
        return $ele
}
# }}}
# lip_LU_table_interpolate
# {{{
proc lip_LU_table_interpolate {gp x0 y0 {debug_mode 0}} {
  set index_1_values [get_attribute_value $gp index_1]
  set index_2_values [get_attribute_value $gp index_2]
  regsub -all {\s+} $index_1_values "" index_1_values
  regsub -all {\s+} $index_2_values "" index_2_values
  set tvalues [get_attr_table_value_1D $gp values]
  set xx [split $index_1_values ,]
  set yy [split $index_2_values ,]
  set counter 0
  foreach x $xx {
    foreach y $yy {
      set TT($x,$y) [lindex $tvalues $counter]
      incr counter
    }
  }

  set ind 0
  foreach x $xx {
    if {$x0 > $x} {
      incr ind
    } else {
      if {$ind == "0"} {
        set x1 "[lindex $xx $ind]"
        set x2 "[lindex $xx [expr $ind+1]]"
      } else {
        set x1 "[lindex $xx [expr $ind-1]]"
        set x2 "[lindex $xx $ind]"
      }
      break
    }
  }
  if {$ind > [llength $xx]} {
    set x1 "[lindex $xx [expr $ind-2]]"
    set x2 "[lindex $xx [expr $ind-1]]"
  }

  set ind 0
  foreach y $yy {
    if {$y0 > $y} {
      incr ind
    } else {
      if {$ind == "0"} {
        set y1 "[lindex $yy $ind]"
        set y2 "[lindex $yy [expr $ind+1]]"
      } else {
        set y1 "[lindex $yy [expr $ind-1]]"
        set y2 "[lindex $yy $ind]"
      }
      break
    }
  }
  if {$ind > [llength $yy]} {
    set y1 "[lindex $yy [expr $ind-2]]"
    set y2 "[lindex $yy [expr $ind-1]]"
  }

  set T11 [format "%.2f" $TT($x1,$y1)]
  set T12 [format "%.2f" $TT($x1,$y2)]
  set T21 [format "%.2f" $TT($x2,$y1)]
  set T22 [format "%.2f" $TT($x2,$y2)]

  set x01 [expr ($x0-$x1)/($x2-$x1)]
  set x20 [expr ($x2-$x0)/($x2-$x1)]
  set y01 [expr ($y0-$y1)/($y2-$y1)]
  set y20 [expr ($y2-$y0)/($y2-$y1)]

  set T00 [expr $x20*$y20*$T11 + \
                $x20*$y01*$T12 + \
                $x01*$y20*$T21 + \
                $x01*$y01*$T22]

  if {$debug_mode} {
  puts "tran         : $x0"
  puts "load         : $y0"
  puts "index_1_full : $index_1_values"
  puts "index_2_full : $index_2_values"
  puts "index_1      : $x1 $x2"
  puts "index_2      : $y1 $y2"
  puts "lookup table :"
  puts "               $T11 $T12"
  puts "               $T21 $T22"
  puts "delay        : [format "%.2f" $T00]"
  }
  return $T00
}
# }}}
# get_voltage_map
# {{{
proc get_voltage_map {glib} {
  set e [new_err]
  set attrs [si2drGroupGetAttrs $glib $e]
  set vtype [new_vtype]
  set intgr [new_int32]
  set float64 [new_float64]
  set string [new_string]
  set bool [new_boolean]
  set exp [new_expr]
  set re_str ""

  while {1} {
    set attr [si2drIterNextAttr $attrs $e]
    if {[si2drObjectIsNull $attr $e]} {
      set v "NA"
      break;
    } else {
      set attr_name [si2drAttrGetName $attr $e]
      if {$attr_name == "voltage_map"} {
      #puts -nonewline "$attr_name : "
        set vals [si2drComplexAttrGetValues $attr $e]
        set value_list [list]
        while {1} {
          si2drIterNextComplexValue $vals $vtype $intgr $float64 $string $bool $exp $e
          set type_value [get_vtype_value $vtype]
          if {$type_value == 0} {
            break;
          } elseif {$type_value == 5} {
            set value [get_string_value $string]
          } elseif {$type_value == 4} {
            set value [get_float64_value $float64]
          } elseif {$type_value == 2} {
            set value [get_int32_value $intgr]
          } else {
            puts " $type_value: Working on it"
          }
          lappend value_list  $value
        }
        set value_str "([join $value_list ","])"
        #puts $value_str
        if {[regexp "VDD" $value_str]} {
          append re_str $value_str
        }
      }
    }
    #append re_str $value_str
  }
  si2drIterQuit $attrs $e;
  return $re_str
}
# }}}
# get_attribute_value
# {{{
proc get_attribute_value {gp name} {
  set e [new_err]
  set attr [si2drGroupFindAttrByName $gp $name $e]
  set vtype [new_vtype]
  set intgr [new_int32]
  set float64 [new_float64]
  set string [new_string]
  set bool [new_boolean]
  set exp [new_expr]

  if {[si2drObjectIsNull $attr $e]} {
    set v "NA"
  } else {
    if {[si2drAttrGetAttrType $attr $e] == 0} {
      set value_type [si2drSimpleAttrGetValueType $attr $e]
      # SI2_STRING
      if       {$value_type == 5} { set v [si2drSimpleAttrGetStringValue  $attr $e]
      # SI2DR_FLOAT64
      } elseif {$value_type == 4} { set v [si2drSimpleAttrGetFloat64Value $attr $e]
      # SI2DR_INT32
      } elseif {$value_type == 2} { set v [si2drSimpleAttrGetInt32Value $attr $e]
      # SI2DR_BOOLEAN
      } elseif {$value_type == 1} { set v [si2drSimpleAttrGetBooleanValue $attr $e]
      # SI2DR_EXPR
      } elseif {$value_type == 9} { set v "EXPR TYPE"}
    } else {
        set vals [si2drComplexAttrGetValues $attr $e]
        set value_list [list]
        while {1} {
          si2drIterNextComplexValue $vals $vtype $intgr $float64 $string $bool $exp $e
          set type_value [get_vtype_value $vtype]
          if {$type_value == 0} {
            break;
          } elseif {$type_value == 5} {
            set value [get_string_value $string]
          } elseif {$type_value == 4} {
            set value [get_float64_value $float64]
          } elseif {$type_value == 2} {
            set value [get_int32_value $intgr]
          } else {
            puts " $type_value: Working on it"
          }
          lappend value_list  $value
        }
        set value_list [join $value_list ", "]
        set v $value_list
    }
  }
  return $v
}
# }}}
# get_attr_table_value
# {{{
proc get_attr_table_value {gp name} {
  set e [new_err]
  set attr [si2drGroupFindAttrByName $gp $name $e]
  set vtype [new_vtype]
  set intgr [new_int32]
  set float64 [new_float64]
  set string [new_string]
  set bool [new_boolean]
  set exp [new_expr]
  
  set row 0
  if {[si2drObjectIsNull $attr $e]} {
    set v "NA"
  } else {
    set vals [si2drComplexAttrGetValues $attr $e]
    while {1} {
      si2drIterNextComplexValue $vals $vtype $intgr $float64 $string $bool $exp $e
      set type_value [get_vtype_value $vtype]
      if {$type_value == 0} {
        break;
      } elseif {$type_value == 5} {
        set str [get_string_value $string]
        regsub -all {\s+} $str {} str ;# remove all blanks
        set numbers [split  $str ","]
        for {set i 0} {$i < [llength $numbers]} {incr i} {
          set 2DArray($row,$i) [lindex $numbers $i]
        }
        incr row
      }
    }
  }
  return [array get 2DArray]
}
# }}}
# get_attr_table_value_1D
# {{{
proc get_attr_table_value_1D {gp name} {
  set e [new_err]
  set attr [si2drGroupFindAttrByName $gp $name $e]
  set vtype [new_vtype]
  set intgr [new_int32]
  set float64 [new_float64]
  set string [new_string]
  set bool [new_boolean]
  set exp [new_expr]
 
  set 1Dlist [list]
  set row 0
  if {[si2drObjectIsNull $attr $e]} {
    set v "NA"
  } else {
    set vals [si2drComplexAttrGetValues $attr $e]
    while {1} {
      si2drIterNextComplexValue $vals $vtype $intgr $float64 $string $bool $exp $e
      set type_value [get_vtype_value $vtype]
      if {$type_value == 0} {
        break;
      } elseif {$type_value == 5} {
        set str [get_string_value $string]
        regsub -all {\s+} $str {} str ;# remove all blanks
        set numbers [split  $str ","]
        set 1Dlist  [concat $1Dlist $numbers]
        #for {set i 0} {$i < [llength $numbers]} {incr i} {
        #  set 2DArray($row,$i) [lindex $numbers $i]
        #}
        incr row
      }
    }
  }
  return $1Dlist
}
# }}}
# get_attributes
# {{{
proc get_attributes {gp} {
  set e       [new_err]
  set attrs   [si2drGroupGetAttrs $gp $e]
  set vtype   [new_vtype]
  set intgr   [new_int32]
  set float64 [new_float64]
  set string  [new_string]
  set bool    [new_boolean]
  set exp     [new_expr]

  set attrlist [list]

  while {1} {
    set attr [si2drIterNextAttr $attrs $e]
    if {[si2drObjectIsNull $attr $e]} {
      set v "NA"
      break;
    } else {
      set attr_name [si2drAttrGetName $attr $e]
      lappend attrlist $attr_name
    }
  }
  si2drIterQuit $attrs $e;

  return $attrlist
}
# }}}
# list_attributes
# {{{
proc list_attributes {gp {indent ""} {ofile "NA"}} {
  set e       [new_err]
  set attrs   [si2drGroupGetAttrs $gp $e]
  set vtype   [new_vtype]
  set intgr   [new_int32]
  set float64 [new_float64]
  set string  [new_string]
  set bool    [new_boolean]
  set exp     [new_expr]

  if {$ofile != "NA"} {
    upvar kout kout
  }

  while {1} {
    set attr [si2drIterNextAttr $attrs $e]
    if {[si2drObjectIsNull $attr $e]} {
      set v "NA"
      break;
    } else {
      set attr_name [si2drAttrGetName $attr $e]
      #puts -nonewline "$indent$attr_name : \""
      if {[si2drAttrGetAttrType $attr $e] == 0} {
        set value_type [si2drSimpleAttrGetValueType $attr $e]
        # SI2_STRING
        if       {$value_type == 5} { set value [si2drSimpleAttrGetStringValue  $attr $e]
        # SI2DR_FLOAT64
        } elseif {$value_type == 4} { set value [si2drSimpleAttrGetFloat64Value $attr $e]
        # SI2DR_INT32
        } elseif {$value_type == 2} { set value [si2drSimpleAttrGetInt32Value $attr $e]
        # SI2DR_BOOLEAN
        } elseif {$value_type == 1} { set v [si2drSimpleAttrGetBooleanValue $attr $e]
          if ($v) { set value "true" } else { set value "false" }
        # SI2DR_EXPR
        } elseif {$value_type == 9} { puts "Need coding: EXPR type."}
        if {$ofile == "NA"} {
          puts "$indent$attr_name : \"$value\" ;"
        } else {
          puts $kout "$indent$attr_name : \"$value\" ;"
        }
      } else {
        set vals [si2drComplexAttrGetValues $attr $e]
        set value [list]
        while {1} {
          si2drIterNextComplexValue $vals $vtype $intgr $float64 $string $bool $exp $e
          set type_value [get_vtype_value $vtype]
          if {$type_value == 0} {
            break;
          } elseif {$type_value == 5} {
            set avalue [get_string_value $string]
          } elseif {$type_value == 4} {
            set avalue [get_float64_value $float64]
          } elseif {$type_value == 2} {
            set avalue [get_int32_value $intgr]
          } else {
            puts " $type_value: Working on it"
          }
          lappend value $avalue
        }
        set value [join $value ", "]
        if {$ofile == "NA"} {
          puts "$indent$attr_name\(\"$value\"\);"
        } else {
          puts $kout "$indent$attr_name\(\"$value\"\);"
        }
      }
    }
  }
  si2drIterQuit $attrs $e;
}
# }}}
# list_subgroups
# {{{
proc list_subgroups {{group NA}} {
  set e [new_err]

  if {$group == "NA"} {
    upvar cur_gp cur_gp
    set group $cur_gp
  }
  
  set groups [si2drGroupGetGroups $group $e]

  set num 1
  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set group_name [get_group_name $gp]
      set group_type [si2drGroupGetGroupType $gp $e]
      puts "$num: \033\[0;36m$group_type\033\[0m : $group_name"
      incr num
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# list_hier
# {{{
proc list_hier {group depth {ofile NA}} {
  # Return values stored in oback
  list_subgroups_recursive $group {    } $depth

  if {$ofile == "NA"} {
    foreach i $oback {
      puts $i
    }
  } else {
    set kout [open $ofile w]
    foreach i $oback {
      puts $kout $i
    }
    puts $kout "# vim:fdm=indent"
    close $kout
  }
}
# }}}
# list_subgroups_recursive
# {{{
proc list_subgroups_recursive {group indent depth} {
  set e [new_err]
  incr depth -1
  upvar oback oback

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set group_name [get_group_name $gp]
      set group_type [si2drGroupGetGroupType $gp $e]
      #puts "$indent $group_type : $group_name"
      lappend oback "$indent $group_type : $group_name"

    }
    set new_indent "$indent$indent"
    if {$depth < 0} {
    } else {
      list_subgroups_recursive $gp $new_indent $depth
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# list_subgroups_its_attr
# {{{
proc list_subgroups_its_attr {{group NA}} {
  set e [new_err]

  if {$group == "NA"} {
    upvar cur_gp cur_gp
    set group $cur_gp
  }

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set group_name [get_group_name $gp]
      set group_type [si2drGroupGetGroupType $gp $e]
      puts "$group_type : $group_name"
      list_attributes $gp {        }
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# list_subgroups_attr_of_type
# {{{
proc list_subgroups_attr_of_type {group type {indent ""}} {
  set e [new_err]

  set groups [si2drGroupGetGroups $group $e]
  set indent2 $indent
  append indent2 {               }

  if { $type == "pin"} {
    while {1} {
      set gp [si2drIterNextGroup $groups $e]
      if {[si2drObjectIsNull $gp $e]} {
        break;
      } else {
        set group_name [get_group_name $gp]
        set group_type [si2drGroupGetGroupType $gp $e]
        if {$group_type == "pin" || $group_type == "bus"} {
          puts "$indent$group_type : $group_name"
          list_attributes $gp $indent2
        }
      }
    }
  si2drIterQuit $groups $e
  } else {
    while {1} {
      set gp [si2drIterNextGroup $groups $e]
      if {[si2drObjectIsNull $gp $e]} {
        break;
      } else {
        set group_name [get_group_name $gp]
        set group_type [si2drGroupGetGroupType $gp $e]
        if {$group_type == $type} {
          puts "$indent$group_type : $group_name"
          list_attributes $gp $indent2
        }
      }
    }
    si2drIterQuit $groups $e
  }

}
# }}}
# ls_cell
# {{{
proc ls_cell {glib cellname} {
  set e [new_err]

  set groups [si2drGroupGetGroups $glib $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "cell"} {
        if {[regexp "$cellname" $name matched]} {
          puts $name
        }
      }
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# ls_pin
# {{{
proc ls_pin {gcell} {
  set e [new_err]

  set groups [si2drGroupGetGroups $gcell $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "pin"} {
        puts $name
      }
    }
  }
  si2drIterQuit $groups $e
}
# }}}
# get_cells
# {{{
proc get_cells {glib cellname} {
  set e [new_err]
  set cell_list []

  set groups [si2drGroupGetGroups $glib $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "cell"} {
        if {[regexp "$cellname" $name matched]} {
          lappend cell_list $gp
        }
      }
    }
  }
  si2drIterQuit $groups $e

  return $cell_list
}
# }}}
# get_cell
# {{{
proc get_cell {glib cellname} {
  set e [new_err]

  set groups [si2drGroupGetGroups $glib $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "cell"} {
        if {$name == $cellname} {
          set gcell $gp
          break;
        }
      }
    }
  }
  si2drIterQuit $groups $e

  return $gcell
}
# }}}
# get_pins
# {{{
proc get_pins {gcell pinname} {
  set e [new_err]
  set pin_list []

  set groups [si2drGroupGetGroups $gcell $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "pin" || $type == "bus"} {
        if {[regexp "$pinname" $name matched]} {
          lappend pin_list $gp
        }
      }
    }
  }
  si2drIterQuit $groups $e

  return $pin_list
}
# }}}
# get_pin
# {{{
proc get_pin {gcell pinname} {
  set e [new_err]

  set groups [si2drGroupGetGroups $gcell $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set name [get_group_name $gp]
      set type [get_group_type $gp]
      if {$type == "pin" || $type == "bus"} {
        if {$name == $pinname} {
          set gpin $gp
          break
        }
      }
    }
  }
  si2drIterQuit $groups $e

  return $gpin
}
# }}}
# get_pin_names
# {{{
proc get_pin_names {gcell} {
  set gpins [get_pins $gcell .]
  if {[llength $gpins] == 0} {
    return "NA"
  } else {
    foreach gpin $gpins {
      set pin_name [get_group_name $gpin]
      append str " $pin_name"
    }
    return $str
  }
}
# }}}
# get_subgroups
# {{{
proc get_subgroups {group} {
  set e [new_err]
  set gps []

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      lappend gps $gp
    }
  }
  si2drIterQuit $groups $e

  return $gps
}
# }}}
# get_subgroups_of_type
# {{{
proc get_subgroups_of_type {group wanted_type} {
  set e [new_err]
  set gps []

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set type [get_group_type $gp]
      if {$type == $wanted_type} {
        lappend gps $gp
      }
    }
  }
  si2drIterQuit $groups $e

  return $gps
}
# }}}
# get_subgroup_of_type
# {{{
proc get_subgroup_of_type {group wanted_type} {
  set e [new_err]

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set type [get_group_type $gp]
      if {$type == $wanted_type} {
        set the_group $gp
        break
      }
    }
  }
  si2drIterQuit $groups $e

  if [info exist the_group] {
    return $the_group
  } else {
    return "NA"
  }

}
# }}}
# get_subgroup_of_type_with_attr
# {{{
proc get_subgroup_of_type_with_attr {group wanted_type attr_name attr_value} {
  set e [new_err]

  set groups [si2drGroupGetGroups $group $e]

  while {1} {
    set gp [si2drIterNextGroup $groups $e]
    if {[si2drObjectIsNull $gp $e]} {
      break;
    } else {
      set type [get_group_type $gp]
      if {$type == $wanted_type} {
        set value [get_attribute_value $gp $attr_name]
        if {$value == $attr_value} {
          set the_group $gp
          break;
        }
      }
    }
  }
  si2drIterQuit $groups $e

  return $the_group
}
# }}}
# get_clock_name
# {{{
proc get_clock_name {glib} {
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set gpins [get_pins $gcell .]
    foreach gpin $gpins {
      set is_clock [get_attribute_value $gpin clock]
      if { $is_clock == 1 } {
        set clock_name [get_group_name $gpin]
        break;
      }
    }
  }
  return $clock_name
}
# }}}
# list_f1
# {{{
proc list_f1 {glib} {
  set clk_name [get_clock_name $glib]
  # cell group pointer
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cell_name [get_group_name $gcell]
    puts -nonewline $cell_name
    # pin group pointer
    set gpins [get_pins $gcell .]
    foreach gpin $gpins {
      set pin_name [get_group_name $gpin]
      set direction [get_attribute_value $gpin direction]
      set function [get_attribute_value $gpin function]
      #set nextstate_type [get_attribute_value $gpin nextstate_type]
      if {$direction == "output"} {
        puts -nonewline ": $pin_name : $function"
        #set groups [get_subgroups_of_type $gpin timing]
        #foreach gtiming $groups {
        #  set g [get_subgroup_of_type $gtiming cell_rise]
        #  set index_1_values [get_attribute_value $g index_1]
        #  puts "        $index_1_values"
        #}
      }
      # timing group pointer
     # set groups [get_subgroups_of_type $gpin timing]
     # foreach gtiming $groups {
     #  # set timing_type [get_attribute_value $gtiming timing_type]
#set #gp [get_subgroup_of_type_with_attr $gpin timing timing_type rising_edge]
#set #gp [get_subgroup_of_type_with_attr $gpin timing timing_type combinational]
     #   set g [get_subgroup_of_type $gtiming cell_rise]
     #   set index_1_values [get_attribute_value $g index_1]
     #   puts "        $index_1_values"
     # }
    }
  puts ""
  }
}
# }}}
# list_pin_cap
# {{{
proc list_pin_cap {glib {ofile NA}} {
  if {$ofile != "NA"} {
    set kout [open $ofile w]
  }
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cell_name [get_group_name $gcell]
    set gpins [get_pins $gcell .]
    foreach gpin $gpins {
      set pin_name [get_group_name $gpin]
      set direction [get_attribute_value $gpin direction]
      if {$direction == "input"} {
        set capacitance [get_attribute_value $gpin capacitance]
        if {$ofile == "NA"} {
          puts "$cell_name $pin_name $direction $capacitance"
        } else {
          puts $kout "$cell_name $pin_name $direction $capacitance"
        }
      }
    }
  }

  if {$ofile != "NA"} {
    close $kout
  }
}
# }}}
# list_output_pins
# {{{
proc list_output_pins {glib} {
  set clk_name [get_clock_name $glib]
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cell_name [get_group_name $gcell]
    set gpins [get_pins $gcell .]
    foreach gpin $gpins {
      set pin_name [get_group_name $gpin]
      set direction [get_attribute_value $gpin direction]
      set nextstate_type [get_attribute_value $gpin nextstate_type]

      # Suppress scan related signals
      if {[regexp "scan_" $nextstate_type]} {
        break;
      }
      set groups [get_subgroups_of_type $gpin timing]
      foreach gtiming $groups {
        set mean 0
        set related_pin [get_attribute_value $gtiming related_pin]
        set timing_type [get_attribute_value $gtiming timing_type]
        set timing_sense [get_attribute_value $gtiming timing_sense]
        if {$related_pin == $clk_name && ($timing_type == "setup_rising" || $timing_type == "hold_rising" || $timing_type == "rising_edge" || $timing_type == "falling_edge")} {
          if {$timing_type == "setup_rising" || $timing_type == "hold_rising"} {
            set grise_const [get_subgroups_of_type $gtiming fall_constraint]
            array set aa [get_attr_table_value $grise_const values]
          } elseif {$timing_type == "rising_edge" || $timing_type == "falling_edge"} {
            set gcell_rise [get_subgroups_of_type $gtiming cell_rise]
            array set aa [get_attr_table_value $gcell_rise values]
          }

          set values [list]
          foreach {key} [array names aa] {
            lappend values $aa($key)
          }
          set mean [expr ([join $values +])/[llength $values]]

          puts [format "%30s : %10s : %6s : %5s : %21s : %-20s" $cell_name $pin_name $direction $related_pin $timing_type $mean]
        }
      }
    }
    puts ""
  }
}
# }}}
# list_seq_timing
# {{{
proc list_seq_timing {glib type} {
  set clk_name [get_clock_name $glib]
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cell_name [get_group_name $gcell]
    puts $cell_name
    set gpins [get_pins $gcell .]
    foreach gpin $gpins {
      set pin_name [get_group_name $gpin]
      set direction [get_attribute_value $gpin direction]
      set nextstate_type [get_attribute_value $gpin nextstate_type]
      puts $nextstate_type

      # Suppress scan related signals
      if {[regexp "scan_" $nextstate_type]} {
        break;
      }
      set groups [get_subgroups_of_type $gpin timing]
      foreach gtiming $groups {
        set mean 0
        set related_pin [get_attribute_value $gtiming related_pin]
        set timing_type [get_attribute_value $gtiming timing_type]
        set timing_sense [get_attribute_value $gtiming timing_sense]

        if {$type == "delay"} {
          if {$related_pin == $clk_name && ($timing_type == "rising_edge" || $timing_type == "falling_edge")} {
            set gcell_rise [get_subgroups_of_type $gtiming cell_rise]
            set gcell_fall [get_subgroups_of_type $gtiming cell_fall]
            set mean_rise [average_2D_array [get_attr_table_value $gcell_rise values]]
            set mean_fall [average_2D_array [get_attr_table_value $gcell_fall values]]

            puts [format "%30s : %5s -> %-3s : %5s : %12s : %-.3f : %-.3f" $cell_name $related_pin $pin_name $direction $timing_type $mean_rise $mean_fall]
          }
        } elseif {$type == "setup"} {
          if {$related_pin == $clk_name && $timing_type == "setup_rising"} {
            set grise [get_subgroups_of_type $gtiming rise_constraint]
            set gfall [get_subgroups_of_type $gtiming fall_constraint]
            if {$grise == ""} {
              set mean_rise "NA"
            } else {
              set mean_rise [format "%.3f" [average_2D_array [get_attr_table_value $grise values]]]
            }
            if {$gfall == ""} {
              set mean_fall "NA"
            } else {
              set mean_fall [format "%.3f" [average_2D_array [get_attr_table_value $gfall values]]]
            }
            puts [format "%30s : %5s -> %-5s : %5s : %12s : %7s : %7s" $cell_name $related_pin $pin_name $direction $timing_type $mean_rise $mean_fall]
          }
        } elseif {$type == "hold"} {
          if {$related_pin == $clk_name && $timing_type == "hold_rising"} {
            set grise [get_subgroups_of_type $gtiming rise_constraint]
            set gfall [get_subgroups_of_type $gtiming fall_constraint]
            if {$grise == ""} {
              set mean_rise "NA"
            } else {
              set mean_rise [format "%.3f" [average_2D_array [get_attr_table_value $grise values]]]
            }
            if {$gfall == ""} {
              set mean_fall "NA"
            } else {
              set mean_fall [format "%.3f" [average_2D_array [get_attr_table_value $gfall values]]]
            }
            puts [format "%30s : %5s -> %-5s : %5s : %12s : %7s : %7s" $cell_name $related_pin $pin_name $direction $timing_type $mean_rise $mean_fall]
          }
        }
      }
    }
  }
}
# }}}
# average_2D_array
# {{{
proc average_2D_array {2Darray} {
  array set 2D $2Darray
  set values [list]
  foreach {key} [array names 2D] {
    lappend values $2D($key)
  }
  set mean [expr ([join $values +])/[llength $values]]
  return $mean
}
# }}}
# get_cell_function
# {{{
proc get_cell_function {gcell} {
  set gpins [get_pins $gcell .]
  set func ""
  foreach gpin $gpins {
    set direction [get_attribute_value $gpin direction]
    if {$direction == "output"} {
      set function [get_attribute_value $gpin function]
      set func [concat $func "$function"]
    }
  }
  return $func
}
# }}}
# list_cells
# {{{
proc list_cells {glib {ofile NA}} {
  if {$ofile != "NA"} {
    set kout [open $ofile w]
  }
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cellname [get_group_name $gcell]
    set footprint [get_attribute_value $gcell cell_footprint]
    set pins [get_pin_names $gcell]
    set func [get_cell_function $gcell]
    if {$ofile != "NA"} {
      puts $kout "$cellname : $footprint : $pins : $func"
    } else {
      puts "$cellname : $footprint : $pins : $func"
    }
  }

  if {$ofile != "NA"} {
    close $kout
  }

}
# }}}
# list_icg
# {{{
proc list_icg {glib} {
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cellname [get_group_name $gcell]
    set icg_attr [get_attribute_value $gcell clock_gating_integrated_cell]
    if {$icg_attr == "NA"} {
    } else {
      set pins [get_pin_names $gcell]
      puts "$cellname : $pins : $icg_attr"
    }
  }
}
# }}}
# list_cells_with_attr
# {{{
proc list_cells_with_attr {glib attr} {
  set gcells [get_cells $glib .]
  foreach gcell $gcells {
    set cellname [get_group_name $gcell]
    set attr_value [get_attribute_value $gcell $attr]
    if {$attr_value == "NA"} {
    } else {
      puts "$cellname : $attr : $attr_value"
    }
  }
}
# }}}
# chk_cell
# {{{
proc chk_cell {glib cell} {
  set gcell [get_cell $glib $cell]
  list_attributes $gcell
  list_subgroups_its_attr $gcell
}
# }}}
# chk_pin
# {{{
proc chk_pin {glib cell pin} {
  set gcell [get_cell $glib $cell]
  set gpin  [get_pin  $gcell $pin]
  list_attributes $gpin
  list_subgroups_its_attr $gpin
}
# }}}
# vim:ft=tcl fdm=marker

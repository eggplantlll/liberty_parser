#!/usr/bin/tclsh
package require lip

set lib_file [lindex $argv 0]
set glib [read_lib $lib_file]
# cell
foreach gcell [get_subgroups $glib] {
    set cell_name [get_group_name $gcell]
    set name [get_group_name $gcell]
    set type [get_group_type $gcell]
  #list_attributes $gcell {    }
  # pin
  foreach gpin [get_subgroups $gcell] {
    set pin_name [get_group_name $gpin]
    set name [get_group_name $gpin]
    set type [get_group_type $gpin]
    set direction [get_attribute_value $gpin direction]
    if {$direction == "input"} {
      set capacitance [get_attribute_value $gpin capacitance]
      puts [format "%-15s %-4s %-4s %s" $cell_name $type $pin_name $capacitance]
    }
  }
}

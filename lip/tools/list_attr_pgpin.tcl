#!/usr/bin/tclsh
package require lip

set lib_file [lindex $argv 0]
set glib [read_lib $lib_file]

set gcells [get_cells $glib .]
foreach gcell $gcells {
  puts [get_group_name $gcell]
  list_subgroups_attr_of_type $gcell pg_pin {      }
}
# vim:ft=tlp

#!/usr/bin/tclsh
package require lip

set files [lindex $argv 0]

foreach f $files {
  set glib [read_lib $f]
  set libname [get_group_name $glib]
  set V [get_attribute_value $glib nom_voltage]
  set T [get_attribute_value $glib nom_temperature]
  set voltage_map [get_voltage_map $glib]


  puts [format "%-5s : %-5s : %-40s : %s" $V $T $voltage_map $libname]
}
#set lib_file [lindex $argv 0]
#
# vim:ft=tlp

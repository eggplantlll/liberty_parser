#!/usr/bin/tclsh
package require lip

#set kk }

set files [glob [lindex $argv 0]]
foreach f $files {
  #exec tcsh -fc "sed -n '/library (/,/cell (/p' $f > .tmp"
  #exec tcsh -fc "sed -i '\$d' .tmp"
  #exec tcsh -fc "echo $kk >> .tmp"
  
  #set glib [read_lib .tmp]
  set glib [read_lib $f]
  set libname [get_group_name $glib]
  set V [get_attribute_value $glib nom_voltage]
  set T [get_attribute_value $glib nom_temperature]
  set voltage_map [get_voltage_map $glib]


  puts [format "%-5s : %-5s : %-40s : %s" $V $T $voltage_map $libname]
}
# vim:ft=tlp

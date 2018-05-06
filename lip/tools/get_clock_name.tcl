#!/usr/bin/tclsh
package require lip
set lib_file [lindex $argv 0]
set glib [read_lib $lib_file]

puts [get_clock_name $glib]

# vim:ft=tlp

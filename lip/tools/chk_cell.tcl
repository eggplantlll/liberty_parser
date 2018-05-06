#!/usr/bin/tclsh
package require lip

set lib_file [lindex $argv 0]
set cellname [lindex $argv 1]
set glib [read_lib $lib_file]

chk_cell $glib $cellname

# vim:ft=tlp

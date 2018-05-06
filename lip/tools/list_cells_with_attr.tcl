#!/usr/bin/tclsh
package require lip

set lib_file [lindex $argv 0]
set attr     [lindex $argv 1]
set glib [read_lib $lib_file]

list_cells_with_attr $glib $attr

# vim:ft=tlp

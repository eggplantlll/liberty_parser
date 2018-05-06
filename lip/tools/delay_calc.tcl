#!/usr/bin/tclsh
package require lip

set lib_file  [lindex $argv 0]
set cell_name [lindex $argv 1]
set tran      [lindex $argv 2]
set load      [lindex $argv 3]

set glib [read_lib $lib_file]
# cell
lip_get_cell_delay $glib $cell_name $tran $load

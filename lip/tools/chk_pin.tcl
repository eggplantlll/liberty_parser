#!/usr/bin/tclsh
package require lip

set lib_file [lindex $argv 0]
set cell     [lindex $argv 1]
set pin      [lindex $argv 2]
set glib [read_lib $lib_file]

chk_pin $glib $cell $pin

# vim:ft=tlp

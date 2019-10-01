#!/usr/bin/tclsh
package require lip

set libfile [lindex $argv 0]
if {$libfile == ""} {
  puts "Usage:"
  puts "% lib2verilog.tcl IP.tcl"
} else {
  if [file exist $libfile] {
    lib2verilog $libfile
  } else {
    puts "Errors: not exist... $libfile"
  }
}


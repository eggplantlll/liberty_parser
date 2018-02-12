#!/usr/bin/tclsh
load ./lip.so
set glib [read_lib example.lib]
set libname [get_group_name $glib]

if {$libname == "example_lib"} {
  puts "Success!"
  puts "Extract the library name: $libname"
} else {
  puts "Error: $libname"
}

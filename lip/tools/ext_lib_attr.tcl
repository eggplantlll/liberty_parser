#!/usr/bin/tclsh
#package require lip
file mkdir .lib_attr
set right_brace }

set files [glob [lindex $argv 0]]
foreach f $files {
  puts "$f"
  exec tcsh -fc "sed -n '/library\\s*(/,/cell (/p' $f > .tmp"
  exec tcsh -fc "sed -i '\$d' .tmp"
  exec tcsh -fc "echo $right_brace >> .tmp"
  exec tcsh -fc "mv .tmp .lib_attr/$f"
}
# vim:ft=tlp

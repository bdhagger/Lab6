####################################################################################
# Created by:  Haggerty, Barbara Louise
#              bdhagger
#              23 August 2018
#
# Assignment:  Lab 6: Musical Subroutines
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Summer 2018
# 
# Description: This program will read a string that lists a series of notes with  
#              pitch and duration. The string will be interpreted as audio which 
#              will then be played using the syscall system service 33.
# 
# Notes:       This program is intended to be run from the MARS IDE.
####################################################################################

# REGISTER USAGE

# $a0: pitch
# $a1: duration in milliseconds

# $t0: holds string 
# $t1: holds character 
# $t2: holds zero for null character

# $v0: sets type of output for syscall

####################################################################################

.data
       song:   .asciiz "e'8 g' e'' c'' d'' g''"
       space:  .asciiz " "
       sp:     .asciiz "\nits a space\n"

.text
       la      $t0 song      # put song string in t0
       li      $t3 0x20      
       li      $t2 0         # initialize t2 to null
       li      $a3 127
       
play_song:

       lb      $t1 ($t0)     # put character in t1
       beq     $t1 $t2  exit # check if reached the end of the string
       beq     $t1 $t3  play_note  # check if it's a space


       move    $a0  $t1      # get character to print
       li      $v0  11       # set syscall to print the character
       syscall
       
 inc:   
       add     $t0  $t0  1   # increment loop
       j play_song
       
play_note:

       li $a0 65
       li $a1 1000


       li $v0 33
       syscall
       j inc

exit:  
       li $a0 65
       li $a1 1000


       li $v0 33
       syscall
       
       li      $v0  10        # set syscall exit the program
       syscall

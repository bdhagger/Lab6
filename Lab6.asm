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

#---------- play_song ----------

# input: $a0 - address of first character in string containing song
#        $a1 - tempo of song in beats per minute

#------- get_song_length -------

# input:  $a0 - address of first character in string containing song
# output: $v0 - number of notes in song

#---------- play_note ----------

# input: $a0 - pitch
#        $a1 - note duration in milliseconds

#---------- read_note ----------

# input: $a0 - address of first character in string containing note encoding
#        $a1 - rhythm of previous note
#
# output: $v0 - note rhythm in bits [31:16], note pitch in bits [15:0]
#               note rhythm: (1 = 4 beats, 2 = 2 beats, 4 = 1 beat,
#                             8 = 1/2 beat, 16 = 1/4 beat)
#               note pitch: (MIDI value, 0-127)
#         $v1 - address of first character of what would be next note

#---------- get_pitch ----------

# input: $a0 - address of first character in string containing note encoding
#
# output: $v0 - MIDI pitch value
#         $v1 - address of character after pitch is determined

#--------- get_rhythm -----------

# input: $a0 - address of character in string containing song encoding
#              after pitch is determined
#        $a1 - previous note rhythm
#
# output: $v0 - note rhythm, default to previous note rhythm if no number
#               is present in note encoding
#  
#         $v1 - address of first character of next note


####################################################################################

.data
       song:   .asciiz "e'8 g' e'' c'' d'' g''"
       
.text
       la      $t0 song      # put song string in t0
       li      $t1 0         # initialize # of notes
       li      $t2 0         # initialize null
       li      $t3 0x20      # set $t3 as an ascii space
       li      $a3 127       # set volume to 127
       jal     play_song
       jal     exit
       
#---------- play_song ----------

# input: $a0 - address of first character in string containing song
#        $a1 - tempo of song in beats per minute
play_song:
       li      $a1 500       # initiate tempo to have 1 beat
       jal     get_song_length
 
       jr      $ra
       
       
       
       
get_song_length:

       lb      $a0 ($t0)     # put character in t1
       beq     $a0 $t2  exit # check if reached the end of the string
       beq     $a0 $t3  playnote  # check if it's a space

       li      $v0  11       # set syscall to print the character
       syscall
       
 inc:   
       add     $t0  $t0  1   # increment loop
       j get_song_length
       
       
       
playnote:
       jal play_note
       j inc
       
play_note:    
       li $a0 65
       li $a1 1000


       li $v0 33
       syscall     
       jr $ra
       
       
       
       
exit:
       jal play_note
       
       li $v0, 10
       syscall
       
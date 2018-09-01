###############################################################
# Created by:  Rebecca
#              25 August 2018
# 
# Description: This program prints the output from the 
#              subroutines implemented in Lab 6.
#
# Note:        Lab6.asm must contain the following subroutines:
#              play_song, get_song_length, play_note, read_note,
#              get_pitch, get_rhythm
#
#              Before running this test file, Lab6.asm must be
#              assembled.
#
#              There are three sample songs here.
###############################################################

.macro print_value (%value)     # prints integer representation of register in value
subi $sp $sp 8
sw   $a0  ($sp)
sw   $v0 4($sp)

move $a0 %value
li   $v0 1
syscall

lw $a0  ($sp)
lw $v0 4($sp)
addi $sp $sp 8

.end_macro

.macro print_string (%label)    # prints string stored at address denoted by label
la   $a0 %label
li   $v0 4
syscall
.end_macro 

.data
str_song_length:       .asciiz "get_song_length_returned:"
str_read_note_pitch:   .asciiz "read_note returned this pitch:"
str_read_note_rhythm:  .asciiz "read_note returned this rhythm:"

str_pitch:             .asciiz "get_pitch returned this pitch:"
str_rhythm:            .asciiz "get_rhythm returned this rhythm:"
str_newline:           .asciiz "\n"


#song:                   .asciiz "a,4 ais,4 b,4 c,4 cis,4 d,4 dis,4 e,4 f,4 fis,4 g,4 gis,4 a4 ais4 b4 c4 cis4 d4 dis4 e4 f4 fis4 g4 gis4 a'4 ais'4 b'4 c'4 cis'4 d'4 dis'4 e'4 f'4 fis'4 g'4 gis'4 a''4"

                                # 1-up sound
#song:                   .asciiz "e'8 g' e'' c'' d'' g''"

                                # Super Mario Bros 1 Overworld Intro
song:                   .asciiz "e'16 b' r e' r c' e' r g' r r r g"
.text

#---------------------------------- print length of song
print_string (str_newline)
print_string (str_song_length)
print_string (str_newline)

la   $a0 song
jal  get_song_length

print_value  ($v0)
print_string (str_newline)

#---------------------------------- print pitch and rhythm of first note from read_note
print_string (str_newline)
print_string (str_read_note_pitch)
print_string (str_newline)

la   $a0 song
jal  read_note

pause: nop

andi $t0 $v0 0x0000FFFF
andi $s0 $v0 0xFFFF0000
srl  $s0 $s0 16
print_value ($t0)
print_string (str_newline)

print_string (str_newline)
print_string (str_read_note_rhythm)
print_string (str_newline)

print_value ($s0)
print_string (str_newline)

#---------------------------------- print pitch of first note
print_string (str_newline)
print_string (str_pitch)
print_string (str_newline)

la  $a0 song
jal get_pitch

print_value  ($v0)
print_string (str_newline)

#---------------------------------- print rhythm of first note
print_string (str_newline)
print_string (str_rhythm)
print_string (str_newline)

li    $a1 8
move  $a0 $v1
jal   get_rhythm

print_value  ($v0)
print_string (str_newline)

la   $a0 song
li   $a1 200                        # set tempo
jal  play_song

li   $v0 10
syscall

.include "Lab6.asm"

####################################################################################
# Created by:  Haggerty, Barbara Louise
#              bdhagger
#              31 August 2018
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

# $t1 gets string address
# $t2 is a null character
# $t3 is an ascii space
# $t4 holds value to output
# $t5 hold the pitch to add to the [15:0] bits
# $t6 holds the song length for the loop
# $t7 is used for loop increments

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

.text
     
#---------- play_song ----------
play_song:
       subi    $sp              $sp       4            # push  
       sw      $ra              ($sp)                                             

       
       jal     get_song_length
       move    $t6              $v0
       li      $t7              0
       
loop:
       bge      $t7             $t6       exit  

       jal     read_note
       andi    $t0              $v0       0x0000FFFF
       andi    $s0              $v0       0xFFFF0000
       srl     $s0              $s0       16
       move    $a0              $t0
       move    $a1              $s0

       jal     play_note
       
       move    $a0              $v1

       add     $t7              $t7        1
       j       loop
exit:     
       lw      $ra              ($sp)                  # Go back to old return address
       addi    $sp              $sp       4            # pop
       
       jr      $ra
       
#------- get_song_length -------
get_song_length:
       la      $t1              ($a0)                  # t1 gets string address
       li      $t2              0x0                    # t2 represents null
       li      $t3              0x20                   # t3 is an ascii space
       li      $t4              1                      # t4 temporarily holds the number of notes

gsl:
       lb      $t0              ($t1)                  # current character
       beq     $t0              $t2       numNotes     # check if reached the end of the string
       beq     $t0              $t3       space        # check if it's a space
       
       add     $t1              $t1       1            # increment loop
       j       gsl
         
space: 
       add     $t4              $t4       1            # increment number of notes      
       add     $t1              $t1       1            # jump over space
       j       gsl
       
numNotes:
       move    $v0              $t4
       jr      $ra

#---------- play_note ----------
play_note:
     
       beq     $a1              1         fourbeats
       beq     $a1              2         twobeats
       beq     $a1              4         onebeat
       beq     $a1              8         halfbeat
       beq     $a1              16        quarterbeat
       
pn:     
       li      $a3              123
       li      $v0              33
       syscall
       
       jr      $ra
       
fourbeats:
       li      $a1              2000
       j       pn
       
twobeats:
       li      $a1              1000
       j       pn
       
onebeat:
       li      $a1              500
       j       pn
       
halfbeat:
       li      $a1              250
       j       pn  
           
quarterbeat:
       li      $a1              125
       j       pn
               
#---------- read_note ----------
read_note:
       subi    $sp              $sp       4            # push  
       sw      $ra              ($sp)
      
       jal     get_pitch
       move    $t5              $v0

       jal     get_rhythm
       sll     $v0              $v0       16
       add     $v0              $v0       $t5
       move    $t5              $v0

       lw      $ra              ($sp)                  # Go back to old return address
       addi    $sp              $sp       4            # pop

       move    $v0              $t5
       jr      $ra
                  
#---------- get_pitch ----------
get_pitch:
       la      $t1              ($a0)                  # t1 gets string address
       li      $t3              0x20                   # t3 is an ascii space
       li      $t2              0x0                    # t2 represents null
       li      $t4              0                      # t4 temporarily holds the number of notes

gp:                                                    # loop through each character in note
       lb      $t0              ($t1)                  # current character
       beq     $t0              $t2       end          # check if it's the ned of a string
       beq     $t0              $t3       end          # check if it's a space
       
       beq     $t0              0x61      aPitch       # check which <note> it is
       beq     $t0              0x62      bPitch
       beq     $t0              0x63      cPitch
       beq     $t0              0x64      dPitch
       beq     $t0              0x65      ePitch
       beq     $t0              0x66      fPitch
       beq     $t0              0x67      gPitch
       beq     $t0              0x72      rPitch
       beq     $t0              0x69      isAccidental # check if there's an <accidental>
       beq     $t0              0x27      aOctave      # check if there's an <octave>
       beq     $t0              0x2C      cOctave

gpBack:
       add     $t1              $t1       1            # increment loop
       j       gp
       
aPitch:
       li      $t4              57
       j       gpBack  

bPitch:
       li      $t4              59
       j       gpBack  
        
cPitch:
       li      $t4              60
       j       gpBack  

dPitch:
       li      $t4              62
       j       gpBack

ePitch:
       add     $t1              $t1       1
       lb      $t0              ($t1)
       beq     $t0              0x73      esAccidental # check if next character is s for accidental
       
       sub     $t1              $t1       1            # not accidental so go back a character
       li      $t4              64
       j       gpBack
       
esAccidental:                                          
       sub     $t4              $t4       1            # decrease accidental
       j       gpBack
       
isAccidental:                                       
       add     $t4              $t4       1            # increase accidental
       j       gpBack

fPitch:
       li      $t4              65
       j       gpBack  
       
gPitch:
       li      $t4              67
       j       gpBack  

rPitch:
       li      $t4              0
       j       gpBack
         
aOctave:
       add     $t4              $t4       12
       j       gpBack  
       
cOctave:
       sub     $t4              $t4       12
       j       gpBack       

end:
       move    $v0              $t4                    # move pitch value to first output
       sub     $t1 $t1 1
       move    $v1              $t1                    # move address value to second output

       jr      $ra

#---------- get_rhythm ----------
get_rhythm: 
       la      $t1              ($a0)                  # t1 gets string address
       li      $t3              0x20                   # t3 is an ascii space
       li      $t2              0x0                    # t2 represents null
       
       move    $t4              $a1

gr:                                                    
       lb      $t0              ($t1)                  # current character
       
       beq     $t0              $t3       end2         # check if it's a space
       beq     $t0              $t2       end2         # check if it's the end of the string
       
       beq     $t0              0x31      rhythm1      # check which rhythm it is
       beq     $t0              0x32      rhythm2
       beq     $t0              0x34      rhythm4
       beq     $t0              0x38      rhythm8
       beq     $t0              0x36      rhythm16    
       
grBack:
       add     $t1              $t1       1            # increment loop
       j       gr
       
rhythm1:
       li      $t4              1                      # 4 beats
       j       grBack

rhythm2:                                       
       li      $t4              2                      # 2 beats
       j       grBack
       
rhythm4:                                       
       li      $t4              4                      # 1 beat
       j       grBack

rhythm8:        
       li      $t4              8                      # 1/2 beat
       j       grBack

rhythm16:                                       
       li      $t4              16                     # 1/4 beat
       j       grBack
       
end2:
       add $t1 $t1 1
       
       move    $v0             $t4                     # move pitch value to first output
       move    $v1             $t1                     # move address value to second output
 
       jr      $ra
       

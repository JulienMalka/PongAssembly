
# symbolic constants
.equ BALL, 	 0x1000 #ball state (its position and velocity)
.equ PADDLES, 0x1010 #paddles position
.equ SCORES,  0x1018 #game scores
.equ LEDS, 	 0x2000 #LED addresses
.equ BUTTONS, 0x2030 #Button addresses

# storing data in memory
#.data LED_SIZE
#.word 3 # LED_SIZE = 0, mem[LED_SIZE] = 32




#storing program
.text


main:
   call clear_leds
   addi a0, zero, 5
   addi a1, zero, 3
   call set_pixel
   addi a0, zero, 0
   addi a1, zero, 0
   call set_pixel
   call clear_leds
   addi a0, zero, 11
   addi a1, zero, 7
   call set_pixel
   addi a0, zero, 8
   addi a1, zero, 6
   call set_pixel
   addi a0, zero, 10
   addi a1, zero, 7
   call set_pixel
   ret 
   

#BEGIN: clear_leds
clear_leds:
    stw zero, LEDS (zero) #set leds[0] to zero
	stw zero, LEDS + 4(zero) #set leds[1] to zero
	stw zero, LEDS + 8(zero) #set leds[2] to zero
ret
#END: clear_leds


#BEGIN: set_pixel
#------------------------------------------------------------------------------
set_pixel:
    addi t0, zero, 4 #set t0 to 4
    addi t1, zero, 8 #set t1 to 8
    blt a0, t0, led0 #if x<4 we go to led0
    bge a0, t1, led2 #if x<=8 we go to led2
    
    
      ldw t0, LEDS +4(zero) #this is the third case, we load led[1] 
      addi t6, zero, 4  
      sub a0, a0, t6  #this is x -4 for generalized computation later
      addi t7, zero, LEDS+4 #we keep this return adress in t7
      jmpi process
    
    led0:
       ldw t0, LEDS(zero) #same as above
       addi t7, zero, LEDS 
       jmpi process 
       
       
    
    led2:
      ldw t0, LEDS +8(zero)#same as above
      addi t7, zero, LEDS+8 
      addi t6, zero, 8
      sub a0, a0, t6
      
    process:
      slli t3, a0, 3 #we get the pos to change by making 8x+y
      add t3, a1, t3  
      add t1, t0, zero #the led word is saved in t1
      srl t1, t1, t3 #we then set that pos to 1 using a shift and a or
      ori t1, t1, 1
      sll t1, t1, t3
      addi t5, zero, 32
      sub t4, t5, t3
      sll t0, t0, t4
      srl t0, t0, t4
      or t1, t1, t0 #and restore the lost bits
      stw t1, 0(t7) #then the word is going back to the memory
    
#------------------------------------------------------------------------------
ret
#END: set_pixel

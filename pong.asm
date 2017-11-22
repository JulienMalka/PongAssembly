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
   addi sp, zero, LEDS
   addi t0, zero, 2
   addi t1, zero, 3
   addi t2, zero, -1
   addi t3, zero, 1
   addi t4, zero, 2
   stw t0, BALL(zero)
   stw t1, BALL +4 (zero)
   stw t2, BALL +8 (zero)
   stw t3, BALL +12 (zero)
   stw t4, PADDLES (zero)
   stw t4, PADDLES +4 (zero)
   
   loop:
     call clear_leds
     call move_ball
     ldw a0, BALL (zero)
     ldw a1, BALL+4 (zero)
     call set_pixel
     call hit_test
     call move_paddles
     call draw_paddles
     addi t0, zero, 1
     beq v0, t0, p1w
     addi t0, zero, 2
     beq v0, t0, p2w
     jmpi loop
     
    p1w:
      ldw t0, SCORES (zero)
      addi t0, t0, 1
      stw t0, SCORES (zero)
      addi t2, zero, 10
      beq t0, t2, end  
      call display_score
      jmpi main

    p2w: 
      ldw t0, SCORES+4 (zero)
      addi t0, t0, 1
      stw t0, SCORES+4 (zero)
      addi t2, zero, 10
      beq t0, t2, end   
      call display_score
      jmpi main
   

end:
jmpi end  
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
    addi t1, zero, 4  
    sub t2, a0, t1  #this is x -4 for generalized computation later
    addi t7, zero, LEDS+4 #we keep this return adress in t7
    jmpi process
    
	led0:
    	ldw t0, LEDS(zero) #same as above
        addi t2, a0, 0
        addi t7, zero, LEDS 
        jmpi process 
       
       
    
    led2:
    	ldw t0, LEDS +8(zero)#same as above
        addi t7, zero, LEDS+8 
        addi t1, zero, 8
        sub t2, a0, t1
      
    process:
    	slli t3, t2, 3 #we get the pos to change by making 8x+y
        add t3, a1, t3 
        addi t1, zero, 1
        sll t1, t1 , t3 
        or t1, t1, t0
        stw t1, 0(t7) #then the word is going back to the memory
  
 
#------------------------------------------------------------------------------
ret
#END: set_pixel


#BEGIN : hit_test
#------------------------

hit_test: 				
	addi v0, zero, 0		#Reset score		
	ldw t1, BALL(zero)		#t1 = ball.x
	ldw t2, BALL +4(zero)	#t2 = ball.y
	ldw t3, BALL +8(zero)	#t3 = ball.velocity_x
	ldw t4, BALL +12(zero)	#t4 = ball.velocity_y

#Check if

#Check if ball collides with side of board
	addi t0, zero, 11
	beq t1, t0, p1_wins
	beq t1, zero, p2_wins

#Check if ball collides with paddle_right
	addi t0, zero, 10
	beq t1, t0, hit_paddle_right		

#Check if ball collides with paddle_left
	addi t0, zero, 1
	beq t1, t0, hit_paddle_left	

#Check if ball collides with floor or roof

hit_floor:
	addi t0, zero, 0
	beq t2, t0, invert_velocity_y
	addi t0, zero, 7
	beq t2, t0, invert_velocity_y
	jmpi fin

hit_paddle_right:
	ldw t5, PADDLES +4(zero)
	beq t5, t2, invert_velocity_x
	addi t5, t5, -1
	beq t5, t2, invert_velocity_x
	addi t5, t5, 2
	beq t5, t2, invert_velocity_x
	
	ldw t5, PADDLES +4(zero)
	add t6, zero, t1
	add t7, zero, t2
	add t6, t6, t3
	add t7, t7, t4
	addi t5, t5, -1
	beq t5, t7, invert_velocity_xy
	addi t5, t5, 2
	beq t5, t7, invert_velocity_xy

	#condition
	ldw t5, PADDLES +4(zero)
	cmplti t6, t5, 3 #check if paddle up-right corner
	cmpeqi t7, t2, 0 #check if ball.y = 0
	cmpeqi t0, t4, -1 # check if ball.velocity.y = -1
	and t0, t0, t6
	and t0, t0, t7
	addi t5, zero, 1
	beq t0, t5, invert_velocity_xy

	ldw t5, PADDLES +4(zero)
	cmpgeui t6, t5, 5 #check if paddle down-right corner
	cmpeqi t7, t2, 7 #check if ball.y = 7
	cmpeqi t0, t4, 1 # check if ball.velocity.y = 1
	and t0, t0, t6
	and t0, t0, t7
	addi t5, zero, 1
	beq t0, t5, invert_velocity_xy

	jmpi fin
	
hit_paddle_left:
	ldw t5, PADDLES (zero)
	beq t5, t2, invert_velocity_x
	addi t5, t5, -1
	beq t5, t2, invert_velocity_x
	addi t5, t5, 2
	beq t5, t2, invert_velocity_x

	ldw t5, PADDLES(zero)
	add t6, zero, t1
	add t7, zero, t2
	add t6, t6, t3
	add t7, t7, t4
	addi t5, t5, -1
	beq t5, t7, invert_velocity_xy
	addi t5, t5, 2
	beq t5, t7, invert_velocity_xy

	#condition
	ldw t5, PADDLES(zero)
	cmplti t6, t5, 3 #check if paddle up corner
	cmpeqi t7, t2, 0 #check if ball.y = 0
	cmpeqi t0, t4, -1 # check if ball.velocity.y = -1
	and t0, t0, t6
	and t0, t0, t7
	addi t5, zero, 1
	beq t0, t5, invert_velocity_xy

	ldw t5, PADDLES(zero)
	cmpgeui t6, t5, 5 #check if paddle down corner
	cmpeqi t7, t2, 7 #check if ball.y = 7
	cmpeqi t0, t4, 1 # check if ball.velocity.y = 1
	and t0, t0, t6
	and t0, t0, t7
	addi t5, zero, 1
	beq t0, t5, invert_velocity_xy
	
	jmpi fin

hit_border_paddle_right:
	

	jmpi fin

invert_velocity_x:		#invert x velocity of the ball
	sub t3, zero, t3
	stw t3, BALL +8(zero)
	jmpi fin

invert_velocity_y:		#invert y velocity of the ball
	sub t4, zero, t4
	stw t4, BALL +12(zero)
	jmpi fin

invert_velocity_xy:		#invert x and y velocity of the ball
	sub t3, zero, t3
	stw t3, BALL +8(zero)
	sub t4, zero, t4
	stw t4, BALL +12(zero)
	jmpi fin

p2_wins:
	addi v0, zero, 2
	jmpi fin

p1_wins:
	addi v0, zero, 1			
	jmpi fin

 
fin:
ret  
#-------------------------------
#END: hit_test






#BEGIN: move_ball
#----------------------
move_ball:
   ldw t0, BALL(zero)
   ldw t1, BALL +4(zero)
   ldw t2, BALL+8(zero)
   ldw t3, BALL+12(zero)
   
   add t0, t0, t2
   add t1, t1, t3
   stw t0, BALL(zero)
   stw t1, BALL +4 (zero)

ret
#---------------------
#END: move_ball

#BEGIN: wait
#----------------------
wait:
   addi t0, zero, 10000  #might be useful
   addi t1, zero, 1
   boucle:
     sub t0, t0, t1
     beq t0, zero, exit
     jmpi boucle
   exit:
ret

#----------------------
#END: wait


#BEGIN: draw_paddles
#-------------------------------
draw_paddles:
   addi sp, sp, -4
   stw ra, 0(sp)
   addi a0, zero, 0
   ldw a1, PADDLES (zero)   #IMLÉMENTER LE STACK !!!
   call set_pixel
   addi a1, a1, 1
   call set_pixel
   addi t1, zero, 2
   sub a1, a1, t1
   call set_pixel
   addi a0, zero, 11
   ldw a1, PADDLES+4 (zero)
   call set_pixel
   addi a1, a1, 1
   call set_pixel
   addi t1, zero, 2
   sub a1, a1, t1
   call set_pixel
   ldw ra, 0(sp)
   addi sp, sp, 4
   
ret   


#------------------------------
#END : draw_paddles



#BEGIN : move_paddles
#-----------------------------
move_paddles:
 
    #t(ith) register is euqal to 1 if ith bit of edgeCapture is at 1
 
   ldw t7, BUTTONS+4(zero) #load edgeCapture in t7
 
   andi t0, t7, 1 #get the last bit of edgeCapture
   andi t1, t7, 2 #get the 2th from end bit of edgeCpature
   cmpeqi t1, t1, 2
   andi t2, t7, 4 #get the 3th from end bit of edgeCapture
   cmpeqi t2, t2, 4
   andi t3, t7, 8 #get the 4th from end bit of edgeCapture
   cmpeqi t3, t3, 8
   
 
   ldw t4, PADDLES(zero)
   ldw t5, PADDLES+4(zero)
 
   #Check if Paddles can move further
  cmpnei t6, t4, 1
  and t0, t0, t6       
  cmpnei t6, t4, 6
  and t1, t6, t1
  cmpnei t6, t5, 1
  and t2, t6, t2
  cmpnei t6, t5, 6
  and t3, t6, t3
   
   #Move Paddles accordingly to values of ti
   sub t4, t4, t0
   add t4, t4, t1
   
   add t5, t5, t2
   sub t5, t5, t3
 
   #return values into memory
   stw t4, PADDLES(zero)
   stw t5, PADDLES+4(zero)
   stw zero, BUTTONS +4(zero)
 
ret
#--------------------------------------
#END : move_paddles


#BEGIN : display_score
#-----------------------------------------
display_score:
 ldw t0, SCORES (zero)
 ldw t1, SCORES+4 (zero)
 slli t0, t0, 2
 slli t1, t1, 2
 ldw t2, font_data (t0)
 ldw t3, font_data (t1)
 addi t5, zero, 64
 ldw t4, font_data(t5)
 stw t2, LEDS (zero)
 stw t4, LEDS+4 (zero)
 stw t3, LEDS+8 (zero)
ret

#-------------------------------------------
#END : display_score


font_data:
.word 0x7E427E00 ; 0
.word 0x407E4400 ; 1
.word 0x4E4A7A00 ; 2
.word 0x7E4A4200 ; 3
.word 0x7E080E00 ; 4
.word 0x7A4A4E00 ; 5
.word 0x7A4A7E00 ; 6
.word 0x7E020600 ; 7
.word 0x7E4A7E00 ; 8
.word 0x7E4A4E00 ; 9
.word 0x7E127E00 ; A
.word 0x344A7E00 ; B
.word 0x42423C00 ; C
.word 0x3C427E00 ; D
.word 0x424A7E00 ; E
.word 0x020A7E00 ; F
.word 0x00181800 ; separator
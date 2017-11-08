

# symbolic constants
.equ BALL 	 0x1000 #ball state (its position and velocity)
.equ PADDLES 0x1010 #paddles position
.equ SCORES  0x1018 #game scores
.equ LEDS 	 0x2000 #LED addresses
.equ BUTTONS 0x2030 #Button addresses

# storing data in memory
.data LED_SIZE
.word 3 # LED_SIZE = 0, mem[LED_SIZE] = 32




#storing program
.text



#BEGIN: clear_leds
clear_leds:
	li $t0, 0 #load the value 0 in $t0

	sw $t0, LEDS (zero) #set leds[0] to t0
	sw $t0, LEDS + 4(zero) #set leds[1] to t0
	sw $t0, LEDS + 8(zero) #set leds[2] to t0

ret
#END: clear_leds


#BEGIN: set_pixel
#------------------------------------------------------------------------------
set_pixel:
#------------------------------------------------------------------------------
ret
#END: set_pixel
#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Xing Ling, 1006865439
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Easy - Display the number of lives remaining
# 2. Easy - Objects in different rows move at different speeds
# 3. Easy - Display a death animation each time the player loses a frog
# 4. Easy - Randomize the appearance of the logs and cars in the scene
# 5. Easy - The frog points in the direction it's travelling
# 6. Hard - Sound effects for movement, collisions, game end and reaching the goal area
#
# Any additional information that the TA needs to know:
# - colliding with vehicle means ANY part of the frog meets with vehicle
# - falling in water means ALL parts of the frog is in water
# - frog moves with the log only if ALL parts the frog is on the log
# - empty goal region is white; occupied goal region is pink
# - number of lives is displayed at the upper left corner
# - the eyes of the frog points in the direction it's travelling
#
#####################################################################
.data
	displayAddress: .word 0x10008000
	frogAddress: .word 0x10008e38
	log1Address: .word 0x10008400
	log2Address: .word 0x10008440
	log3Address: .word 0x10008620
	log4Address: .word 0x10008660
	vehicle1Address: .word 0x10008a00
	vehicle2Address: .word 0x10008a40
	vehicle3Address: .word 0x10008c20
	vehicle4Address: .word 0x10008c60
	log1Counter: .word 0x00000000
	log2Counter: .word 0x00000000
	log3Counter: .word 0x00000000
	log4Counter: .word 0x00000000
	vehicle1Counter: .word 0x00000000
	vehicle2Counter: .word 0x00000000
	vehicle3Counter: .word 0x00000000
	vehicle4Counter: .word 0x00000000
	goalzone1Counter: .word 0x00000000
	goalzone2Counter: .word 0x00000000
	goalzone3Counter: .word 0x00000000
	goalzone4Counter: .word 0x00000000
	numOfLives: .word 0x00000003
	logColour: .word 0x964b00
	vehicleColour: .word 0xff0000
	frogDirection: .word 0x00000003
.text
rstart:	addi $t0, $zero, 0x10008e38	# restart: set everything to default value
	sw $t0, frogAddress
	addi $t0, $zero, 0x10008400
	sw $t0, log1Address
	addi $t0, $zero, 0x10008440
	sw $t0, log2Address
	addi $t0, $zero, 0x10008620
	sw $t0, log3Address
	addi $t0, $zero, 0x10008660
	sw $t0, log4Address
	addi $t0, $zero, 0x10008a00
	sw $t0, vehicle1Address
	addi $t0, $zero, 0x10008a40
	sw $t0, vehicle2Address
	addi $t0, $zero, 0x10008c20
	sw $t0, vehicle3Address
	addi $t0, $zero, 0x10008c60
	sw $t0, vehicle4Address
	add $t0, $zero, $zero
	sw $t0, log1Counter
	sw $t0, log2Counter
	sw $t0, log3Counter
	sw $t0, log4Counter
	sw $t0, vehicle1Counter
	sw $t0, vehicle2Counter
	sw $t0, vehicle3Counter
	sw $t0, vehicle4Counter
	sw $t0, goalzone1Counter
	sw $t0, goalzone2Counter
	sw $t0, goalzone3Counter
	sw $t0, goalzone4Counter
	addi $t0, $zero, 0x00000003
	sw $t0, numOfLives
	sw $t0, frogDirection
	li $v0, 31			# play a sound when game restarts
	li $a0, 50
	li $a1, 1000
	li $a2, 40
	li $a3, 50
	syscall
lgclr:	li $v0, 42			# randomly select a colour (out of 3) for logs
	li $a0, 0
	li $a1, 30
	syscall
	blt $a0, 10, lgc1
	blt $a0, 20, lgc2
	j lgc3
lgc1:	addi $t0, $zero, 0x964b00
	sw $t0, logColour
	j vehclr
lgc2: 	addi $t0, $zero, 0x808000
	sw $t0, logColour
	j vehclr
lgc3:	addi $t0, $zero, 0xbdb76b
	sw $t0, logColour
	j vehclr
vehclr:	li $v0, 42			# randomly select a colour (out of 3) for vehicles
	li $a0, 0
	li $a1, 30
	syscall
	blt $a0, 10, vehc1
	blt $a0, 20, vehc2
	j vehc3
vehc1:	addi $t0, $zero, 0xff0000
	sw $t0, vehicleColour
	j draw
vehc2: 	addi $t0, $zero, 0xff3131
	sw $t0, vehicleColour
	j draw
vehc3:	addi $t0, $zero, 0xff8b00
	sw $t0, vehicleColour
	j draw
draw:	lw $t0, displayAddress 		# $t0 stores the base address for display
	li $t1, 0x00ff00 		# $t1 stores the green colour code (safe and start zones)
	li $t2, 0x0000ff 		# $t2 stores the blue colour code (water zone)
	li $t3, 0xffff00 		# $t3 stores the yellow colour code (safe zone in the middle)
	li $t4, 0x000000 		# $t4 stores the black colour code (road zone)
	li $t5, 0xffc0cb 		# $t5 stores the pink colour code (frog)
	lw $t6, frogAddress		# $t6 stores the initial frog address (upper left corner) for display
	lw $t7, logColour		# $t7 stores the brown colour code (logs)
	lw $t8, vehicleColour		# $t8 stores the red colour code (vehicles)
	add $s0, $t0, $zero
	addi $s1, $t0, 1024		# paint the goal zone green
goal:	beq $s0, $s1, clr1		
	sw $t1, 0($s0)
	addi $s0, $s0, 4
	j goal
clr1:	li $s4, 0xffffff		# draw goal zone 1
	lw $s7, goalzone1Counter
	beq $s7, 0x00000000, ingz11
	li $s4, 0xffc0cb
ingz11:	addi $s5, $t0, 512		
	addi $s6, $s5, 16
gz11:	beq $s5, $s6, ingz12
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz11
ingz12:	addi $s5, $t0, 640
	addi $s6, $s5, 16
gz12:	beq $s5, $s6, ingz13
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz12
ingz13:	addi $s5, $t0, 768
	addi $s6, $s5, 16
gz13:	beq $s5, $s6, ingz14
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz13
ingz14:	addi $s5, $t0, 896
	addi $s6, $s5, 16
gz14:	beq $s5, $s6, clr2
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz14
clr2:	li $s4, 0xffffff		# draw goal zone 2
	lw $s7, goalzone2Counter
	beq $s7, 0x00000000, ingz21
	li $s4, 0xffc0cb
ingz21:	addi $s5, $t0, 544		
	addi $s6, $s5, 16
gz21:	beq $s5, $s6, ingz22
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz21
ingz22:	addi $s5, $t0, 672
	addi $s6, $s5, 16
gz22:	beq $s5, $s6, ingz23
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz22
ingz23:	addi $s5, $t0, 800
	addi $s6, $s5, 16
gz23:	beq $s5, $s6, ingz24
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz23
ingz24:	addi $s5, $t0, 928
	addi $s6, $s5, 16
gz24:	beq $s5, $s6, clr3
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz24
clr3:	li $s4, 0xffffff		# draw goal zone 3
	lw $s7, goalzone3Counter
	beq $s7, 0x00000000, ingz31
	li $s4, 0xffc0cb
ingz31:	addi $s5, $t0, 576
	addi $s6, $s5, 16
gz31:	beq $s5, $s6, ingz32
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz31
ingz32:	addi $s5, $t0, 704
	addi $s6, $s5, 16
gz32:	beq $s5, $s6, ingz33
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz32
ingz33:	addi $s5, $t0, 832
	addi $s6, $s5, 16
gz33:	beq $s5, $s6, ingz34
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz33
ingz34:	addi $s5, $t0, 960
	addi $s6, $s5, 16
gz34:	beq $s5, $s6, clr4
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz34
clr4:	li $s4, 0xffffff		# draw goal zone 4
	lw $s7, goalzone4Counter
	beq $s7, 0x00000000, ingz41
	li $s4, 0xffc0cb
ingz41:	addi $s5, $t0, 608
	addi $s6, $s5, 16
gz41:	beq $s5, $s6, ingz42
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz41
ingz42:	addi $s5, $t0, 736
	addi $s6, $s5, 16
gz42:	beq $s5, $s6, ingz43
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz42
ingz43:	addi $s5, $t0, 864
	addi $s6, $s5, 16
gz43:	beq $s5, $s6, ingz44
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz43
ingz44:	addi $s5, $t0, 992
	addi $s6, $s5, 16
gz44:	beq $s5, $s6, init1
	sw $s4, 0($s5)
	addi $s5, $s5, 4
	j gz44
init1:	addi $s1, $t0, 2048		# paint the water zone blue
water:	beq $s0, $s1, init2		
	sw $t2, 0($s0)
	addi $s0, $s0, 4
	j water
init2:	addi $s1, $t0, 2560		# paint the safe zone yellow
safe:	beq $s0, $s1, init3		
	sw $t3, 0($s0)
	addi $s0, $s0, 4
	j safe
init3:	addi $s1, $t0, 3584		# paint the road zone black
road:	beq $s0, $s1, init4		
	sw $t4, 0($s0)
	addi $s0, $s0, 4
	j road
init4:	addi $s1, $t0, 4096		# paint the start zone green
start:	beq $s0, $s1, in1		
	sw $t1, 0($s0)
	addi $s0, $s0, 4
	j start
in1:	lw $s2, log1Address		# draw log 1
	add $s0, $zero, $s2
	addi $s1, $s0, 32
log11:	beq $s0, $s1, in2
	bge $s0, 0x10008480, wrap11
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log11
wrap11:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log11
in2:	lw $s2, log1Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
log12:	beq $s0, $s1, in3
	bge $s0, 0x10008500, wrap12
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log12
wrap12:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log12
in3:	lw $s2, log1Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
log13:	beq $s0, $s1, in4
	bge $s0, 0x10008580, wrap13
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log13
wrap13:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log13
in4:	lw $s2, log1Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
log14:	beq $s0, $s1, upl1
	bge $s0, 0x10008600, wrap14
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log14
wrap14:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log14
upl1:	lw $s3, log1Counter
	beq $s3, 0x0000000f, mvl1	# every time counter counts to 15, update log1's address
	addi $s3, $s3, 1
	sw $s3, log1Counter
	j in5
mvl1:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, log1Counter
	addi $s2, $s2, 4		# update log1's next address
	beq $s2, 0x10008480, wupd1
	sw $s2, log1Address
	lw $s2, log1Address		# frog moves with log1 if it's completely on log1
	lw $s3, frogAddress
	beq $s3, $s2, fgmv1
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv1
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv1
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv1
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv1
	j nomv1
fgmv1:	addi $s3, $s3, 4
	sw $s3, frogAddress
nomv1:	j in5
wupd1:	addi $s2, $zero, 0x10008400	# if log1's next address needs to wrap around
	sw $s2, log1Address
in5:	lw $s2, log2Address		# draw log 2
	add $s0, $zero, $s2
	addi $s1, $s0, 32
log21:	beq $s0, $s1, in6
	bge $s0, 0x10008480, wrap21
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log21
wrap21:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log21
in6:	lw $s2, log2Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
log22:	beq $s0, $s1, in7
	bge $s0, 0x10008500, wrap22
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log22
wrap22:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log22
in7:	lw $s2, log2Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
log23:	beq $s0, $s1, in8
	bge $s0, 0x10008580, wrap23
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log23
wrap23:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log23
in8:	lw $s2, log2Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
log24:	beq $s0, $s1, upl2
	bge $s0, 0x10008600, wrap24
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log24
wrap24:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log24
upl2:	lw $s3, log2Counter
	beq $s3, 0x0000000f, mvl2	# every time counter counts to 15, update log2's address
	addi $s3, $s3, 1
	sw $s3, log2Counter
	j in9
mvl2:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, log2Counter
	addi $s2, $s2, 4		# update log2's next address
	beq $s2, 0x10008480, wupd2
	sw $s2, log2Address
	lw $s2, log2Address		# frog moves with log2 if it's completely on log2
	lw $s3, frogAddress
	beq $s3, $s2, fgmv2
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv2
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv2
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv2
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv2
	j nomv2
fgmv2:	addi $s3, $s3, 4
	sw $s3, frogAddress
nomv2:	j in9
wupd2:	addi $s2, $zero, 0x10008400	# if log2's next address needs to wrap around
	sw $s2, log2Address	
in9:	lw $s2, log3Address		# draw log 3
	add $s0, $zero, $s2
	addi $s1, $s0, 32
log31:	beq $s0, $s1, in10
	bge $s0, 0x10008680, wrap31
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log31
wrap31:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log31
in10:	lw $s2, log3Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
log32:	beq $s0, $s1, in11
	bge $s0, 0x10008700, wrap32
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log32
wrap32:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log32
in11:	lw $s2, log3Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
log33:	beq $s0, $s1, in12
	bge $s0, 0x10008780, wrap33
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log33
wrap33:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log33
in12:	lw $s2, log3Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
log34:	beq $s0, $s1, upl3
	bge $s0, 0x10008800, wrap34
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log34
wrap34:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log34
upl3:	lw $s3, log3Counter
	beq $s3, 0x00000008, mvl3	# every time counter counts to 8, update log3's address
	addi $s3, $s3, 1
	sw $s3, log3Counter
	j in13
mvl3:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, log3Counter
	subi $s2, $s2, 4		# update log3's next address
	blt $s2, 0x10008600, wupd3
	sw $s2, log3Address
	lw $s2, log3Address		# frog moves with log3 if it's completely on log3
	lw $s3, frogAddress
	beq $s3, $s2, fgmv3
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv3
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv3
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv3
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv3
	j nomv3
fgmv3:	subi $s3, $s3, 4
	sw $s3, frogAddress
nomv3:	j in13
wupd3:	addi $s2, $s2, 128		# if log3's next address needs to wrap around
	sw $s2, log3Address		
in13:	lw $s2, log4Address		# draw log 4
	add $s0, $zero, $s2
	addi $s1, $s0, 32
log41:	beq $s0, $s1, in14
	bge $s0, 0x10008680, wrap41
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log41
wrap41:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log41
in14:	lw $s2, log4Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
log42:	beq $s0, $s1, in15
	bge $s0, 0x10008700, wrap42
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log42
wrap42:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log42
in15:	lw $s2, log4Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
log43:	beq $s0, $s1, in16
	bge $s0, 0x10008780, wrap43
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log43
wrap43:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log43
in16:	lw $s2, log4Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
log44:	beq $s0, $s1, upl4
	bge $s0, 0x10008800, wrap44
	sw $t7, 0($s0)
	addi $s0, $s0, 4
	j log44
wrap44:	subi $s3, $s0, 128
	sw $t7, 0($s3)
	addi $s0, $s0, 4
	j log44
upl4:	lw $s3, log4Counter
	beq $s3, 0x00000008, mvl4	# every time counter counts to 8, update log4's address
	addi $s3, $s3, 1
	sw $s3, log4Counter
	j in17
mvl4:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, log4Counter
	subi $s2, $s2, 4		# update log4's next address
	blt $s2, 0x10008600, wupd4
	sw $s2, log4Address
	lw $s2, log4Address		# frog moves with log4 if it's completely on log4
	lw $s3, frogAddress
	beq $s3, $s2, fgmv4
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv4
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv4
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv4
	addi $s2, $s2, 4
	beq $s3, $s2, fgmv4
	j nomv4
fgmv4:	subi $s3, $s3, 4
	sw $s3, frogAddress
nomv4:	j in17
wupd4:	addi $s2, $s2, 128		# if log4's next address needs to wrap around
	sw $s2, log4Address	
in17:	lw $s2, vehicle1Address		# draw vehicle 1
	add $s0, $zero, $s2
	addi $s1, $s0, 32
veh11:	beq $s0, $s1, in18
	bge $s0, 0x10008a80, wpv11
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh11
wpv11:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh11
in18:	lw $s2, vehicle1Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
veh12:	beq $s0, $s1, in19
	bge $s0, 0x10008b00, wpv12
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh12
wpv12:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh12
in19:	lw $s2, vehicle1Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
veh13:	beq $s0, $s1, in20
	bge $s0, 0x10008b80, wpv13
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh13
wpv13:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh13
in20:	lw $s2, vehicle1Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
veh14:	beq $s0, $s1, upv1
	bge $s0, 0x10008c00, wpv14
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh14
wpv14:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh14
upv1:	lw $s3, vehicle1Counter
	beq $s3, 0x0000000f, mvv1	# every time counter counts to 15, update vehicle1's address
	addi $s3, $s3, 1
	sw $s3, vehicle1Counter
	j in21
mvv1:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, vehicle1Counter
	addi $s2, $s2, 4		# update veh1's next address
	beq $s2, 0x10008a80, wupdv1
	sw $s2, vehicle1Address
	j in21
wupdv1:	addi $s2, $zero, 0x10008a00	# if veh1's next address needs to wrap around
	sw $s2, vehicle1Address
in21:	lw $s2, vehicle2Address		# draw vehicle 2
	add $s0, $zero, $s2
	addi $s1, $s0, 32
veh21:	beq $s0, $s1, in22
	bge $s0, 0x10008a80, wpv21
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh21
wpv21:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh21
in22:	lw $s2, vehicle2Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
veh22:	beq $s0, $s1, in23
	bge $s0, 0x10008b00, wpv22
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh22
wpv22:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh22
in23:	lw $s2, vehicle2Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
veh23:	beq $s0, $s1, in24
	bge $s0, 0x10008b80, wpv23
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh23
wpv23:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh23
in24:	lw $s2, vehicle2Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
veh24:	beq $s0, $s1, upv2
	bge $s0, 0x10008c00, wpv24
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh24
wpv24:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh24
upv2:	lw $s3, vehicle2Counter
	beq $s3, 0x0000000f, mvv2	# every time counter counts to 15, update vehicle2's address
	addi $s3, $s3, 1
	sw $s3, vehicle2Counter
	j in25
mvv2:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, vehicle2Counter
	addi $s2, $s2, 4		# update veh2's next address
	beq $s2, 0x10008a80, wupdv2
	sw $s2, vehicle2Address
	j in25
wupdv2:	addi $s2, $zero, 0x10008a00	# if veh2's next address needs to wrap around
	sw $s2, vehicle2Address	
in25:	lw $s2, vehicle3Address		# draw vehicle 3
	add $s0, $zero, $s2
	addi $s1, $s0, 32
veh31:	beq $s0, $s1, in26
	bge $s0, 0x10008c80, wpv31
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh31
wpv31:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh31
in26:	lw $s2, vehicle3Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
veh32:	beq $s0, $s1, in27
	bge $s0, 0x10008d00, wpv32
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh32
wpv32:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh32
in27:	lw $s2, vehicle3Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
veh33:	beq $s0, $s1, in28
	bge $s0, 0x10008d80, wpv33
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh33
wpv33:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh33
in28:	lw $s2, vehicle3Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
veh34:	beq $s0, $s1, upv3
	bge $s0, 0x10008e00, wpv34
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh34
wpv34:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh34
upv3:	lw $s3, vehicle3Counter
	beq $s3, 0x00000008, mvv3	# every time counter counts to 8, update vehicle3's address
	addi $s3, $s3, 1
	sw $s3, vehicle3Counter
	j in29
mvv3:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, vehicle3Counter
	subi $s2, $s2, 4		# update veh3's next address
	blt $s2, 0x10008c00, wupdv3
	sw $s2, vehicle3Address
	j in29
wupdv3:	addi $s2, $s2, 128		# if veh3's next address needs to wrap around
	sw $s2, vehicle3Address		
in29:	lw $s2, vehicle4Address		# draw vehicle 4
	add $s0, $zero, $s2
	addi $s1, $s0, 32
veh41:	beq $s0, $s1, in30
	bge $s0, 0x10008c80, wpv41
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh41
wpv41:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh41
in30:	lw $s2, vehicle4Address
	addi $s0, $s2, 128
	addi $s1, $s0, 32
veh42:	beq $s0, $s1, in31
	bge $s0, 0x10008d00, wpv42
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh42
wpv42:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh42
in31:	lw $s2, vehicle4Address
	addi $s0, $s2, 256
	addi $s1, $s0, 32
veh43:	beq $s0, $s1, in32
	bge $s0, 0x10008d80, wpv43
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh43
wpv43:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh43
in32:	lw $s2, vehicle4Address
	addi $s0, $s2, 384
	addi $s1, $s0, 32
veh44:	beq $s0, $s1, upv4
	bge $s0, 0x10008e00, wpv44
	sw $t8, 0($s0)
	addi $s0, $s0, 4
	j veh44
wpv44:	subi $s3, $s0, 128
	sw $t8, 0($s3)
	addi $s0, $s0, 4
	j veh44
upv4:	lw $s3, vehicle4Counter
	beq $s3, 0x00000008, mvv4	# every time counter counts to 8, update vehicle4' address
	addi $s3, $s3, 1
	sw $s3, vehicle4Counter
	j init5
mvv4:	addi $s3, $zero, 0x00000000	# reset counter to 0
	sw $s3, vehicle4Counter
	subi $s2, $s2, 4		# update veh4's next address
	blt $s2, 0x10008c00, wupdv4
	sw $s2, vehicle4Address
	j init5
wupdv4:	addi $s2, $s2, 128		# if veh4's next address needs to wrap around
	sw $s2, vehicle4Address			
init5:	add $s0, $zero, $t6		# draw the frog
	addi $s1, $s0, 16
frog1:	beq $s0, $s1, init6
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	j frog1
init6:	add $s0, $zero, $t6
	addi $s0, $s0, 128
	addi $s1, $s0, 16
frog2:	beq $s0, $s1, init7
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	j frog2
init7:	add $s0, $zero, $t6
	addi $s0, $s0, 256
	addi $s1, $s0, 16
frog3:	beq $s0, $s1, init8
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	j frog3
init8:	add $s0, $zero, $t6
	addi $s0, $s0, 384
	addi $s1, $s0, 16
frog4:	beq $s0, $s1, eyes
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	j frog4
eyes:	lw $s0, frogDirection		# draw the eyes of the frog based on its direction of travelling
	li $s1, 0x006400
	addi $t1, $zero, 0x00000001
	addi $t2, $zero, 0x00000002
	addi $t3, $zero, 0x00000003
	addi $t4, $zero, 0x00000004
	beq $s0, $t1, left
	beq $s0, $t2, right
	beq $s0, $t3, up
	beq $s0, $t4, down
left:	sw $s1, 0($t6)
	sw $s1, 384($t6)
	j lives
right: 	sw $s1, 12($t6)
	sw $s1, 396($t6)
	j lives
up:	sw $s1, 0($t6)
	sw $s1, 12($t6)
	j lives
down:	sw $s1, 384($t6)
	sw $s1, 396($t6)
	j lives
lives:	lw $t2, numOfLives		# display number of lives remaining
	lw $t4, displayAddress
	li $t3, 0x800080
	beq $t2, 0x00000003, lf3
	beq $t2, 0x00000002, lf2
	beq $t2, 0x00000001, lf1
lf3:	sw $t3, 0($t4)
	sw $t3, 128($t4)
	sw $t3, 8($t4)
	sw $t3, 136($t4)
	sw $t3, 16($t4)
	sw $t3, 144($t4)
	j keydet
lf2:	sw $t3, 0($t4)
	sw $t3, 128($t4)
	sw $t3, 8($t4)
	sw $t3, 136($t4)
	j keydet
lf1:	sw $t3, 0($t4)
	sw $t3, 128($t4)
	j keydet
keydet:	lw $t2, 0xffff0004		# detect key stroke event
	beq $t2, 0x61, keyA
	beq $t2, 0x64, keyD
	beq $t2, 0x77, keyW
	beq $t2, 0x73, keyS
	j coldet
keyA:	lw $t6, frogAddress		# input is key a
	subi $t6, $t6, 8
	sw $t6, frogAddress
	add $t2, $zero, $zero
	sw $t2 0xffff0004
	li $v0, 31			# play a sound when key A is pressed
	li $a0, 80
	li $a1, 200
	li $a2, 0
	li $a3, 50
	syscall
	addi $t2, $zero, 0x00000001	# update frog's direction of travelling
	sw $t2, frogDirection
	j coldet
keyD:	lw $t6, frogAddress		# input is key d
	addi $t6, $t6, 8
	sw $t6, frogAddress
	add $t2, $zero, $zero
	sw $t2 0xffff0004
	li $v0, 31			# play a sound when key D is pressed
	li $a0, 80
	li $a1, 200
	li $a2, 0
	li $a3, 50
	syscall
	addi $t2, $zero, 0x00000002	# update frog's direction of travelling
	sw $t2, frogDirection
	j coldet
keyW:	lw $t6, frogAddress		# input is key w
	subi $t6, $t6, 256
	sw $t6, frogAddress
	add $t2, $zero, $zero
	sw $t2 0xffff0004
	li $v0, 31			# play a sound when key W is pressed
	li $a0, 80
	li $a1, 200
	li $a2, 0
	li $a3, 50
	syscall
	addi $t2, $zero, 0x00000003	# update frog's direction of travelling
	sw $t2, frogDirection
	j coldet
keyS:	lw $t6, frogAddress		# input is key s
	addi $t6, $t6, 256
	sw $t6, frogAddress
	add $t2, $zero, $zero
	sw $t2 0xffff0004
	li $v0, 31			# play a sound when key S is pressed
	li $a0, 80
	li $a1, 200
	li $a2, 0
	li $a3, 50
	syscall
	addi $t2, $zero, 0x00000004	# update frog's direction of travelling
	sw $t2, frogDirection
coldet:	lw $t6, frogAddress		# collision detection
colv1:	lw $t0, vehicle1Address		# detect collision with veh1
v11:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, v12
	bgt $t6, $t2, v12
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v12:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, v13
	bgt $t6, $t2, v13
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v13:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, v14
	bgt $t6, $t2, v14
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v14:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, v15
	bgt $t6, $t2, v15
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v15:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, v16
	bgt $t6, $t2, v16
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v16:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, v17
	bgt $t6, $t2, v17
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v17:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, colv2
	bgt $t6, $t2, colv2
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh1
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
colv2:	lw $t0, vehicle2Address		# detect collision with veh2
v21:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, v22
	bgt $t6, $t2, v22
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v22:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, v23
	bgt $t6, $t2, v23
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v23:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, v24
	bgt $t6, $t2, v24
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v24:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, v25
	bgt $t6, $t2, v25
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v25:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, v26
	bgt $t6, $t2, v26
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v26:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, v27
	bgt $t6, $t2, v27
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v27:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, colv3
	bgt $t6, $t2, colv3
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh2
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
colv3:	lw $t0, vehicle3Address		# detect collision with veh3
v31:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, v32
	bgt $t6, $t2, v32
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v32:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, v33
	bgt $t6, $t2, v33
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v33:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, v34
	bgt $t6, $t2, v34
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v34:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, v35
	bgt $t6, $t2, v35
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v35:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, v36
	bgt $t6, $t2, v36
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v36:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, v37
	bgt $t6, $t2, v37
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v37:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, colv4
	bgt $t6, $t2, colv4
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh3
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
colv4:	lw $t0, vehicle4Address		# detect collision with veh4
v41:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, v42
	bgt $t6, $t2, v42
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v42:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, v43
	bgt $t6, $t2, v43
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v43:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, v44
	bgt $t6, $t2, v44
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v44:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, v45
	bgt $t6, $t2, v45
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v45:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, v46
	bgt $t6, $t2, v46
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v46:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, v47
	bgt $t6, $t2, v47
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
v47:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, coll1
	bgt $t6, $t2, coll1
	lw $t7, numOfLives
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog collides with veh4
	li $a0, 50
	li $a1, 500
	li $a2, 127
	li $a3, 100
	syscall
	j dead
coll1:	lw $t0, log1Address		# detect collision with log1
	lw $t3, displayAddress		
	addi $t4, $t3, 1028
	addi $t5, $t3, 1664
	blt $t6, $t4, gzdet1
	bgt $t6, $t5, redraw	
lg11:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, lg12
	bgt $t6, $t2, lg12
	j redraw
lg12:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, lg13
	bgt $t6, $t2, lg13
	j redraw
lg13:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, lg14
	bgt $t6, $t2, lg14
	j redraw
lg14:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, lg15
	bgt $t6, $t2, lg15
	j redraw
lg15:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, lg16
	bgt $t6, $t2, lg16
	j redraw
lg16:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, lg17
	bgt $t6, $t2, lg17
	j redraw
lg17:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, coll2
	bgt $t6, $t2, coll2
	j redraw
coll2:	lw $t0, log2Address		# detect collision with log2
lg21:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, lg22
	bgt $t6, $t2, lg22
	j redraw
lg22:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, lg23
	bgt $t6, $t2, lg23
	j redraw
lg23:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, lg24
	bgt $t6, $t2, lg24
	j redraw
lg24:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, lg25
	bgt $t6, $t2, lg25
	j redraw
lg25:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, lg26
	bgt $t6, $t2, lg26
	j redraw
lg26:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, lg27
	bgt $t6, $t2, lg27
	j redraw
lg27:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, coll3
	bgt $t6, $t2, coll3
	j redraw
coll3:	lw $t0, log3Address		# detect collision with log3
lg31:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, lg32
	bgt $t6, $t2, lg32
	j redraw
lg32:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, lg33
	bgt $t6, $t2, lg33
	j redraw
lg33:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, lg34
	bgt $t6, $t2, lg34
	j redraw
lg34:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, lg35
	bgt $t6, $t2, lg35
	j redraw
lg35:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, lg36
	bgt $t6, $t2, lg36
	j redraw
lg36:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, lg37
	bgt $t6, $t2, lg37
	j redraw
lg37:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, coll4
	bgt $t6, $t2, coll4
	j redraw
coll4:	lw $t0, log4Address		# detect collision with log4
lg41:	subi $t1, $t0, 396
	subi $t2, $t0, 356
	blt $t6, $t1, lg42
	bgt $t6, $t2, lg42
	j redraw
lg42:	subi $t1, $t0, 268
	subi $t2, $t0, 228
	blt $t6, $t1, lg43
	bgt $t6, $t2, lg43
	j redraw
lg43:	subi $t1, $t0, 140
	subi $t2, $t0, 100
	blt $t6, $t1, lg44
	bgt $t6, $t2, lg44
	j redraw
lg44:	subi $t1, $t0, 12
	addi $t2, $t0, 28
	blt $t6, $t1, lg45
	bgt $t6, $t2, lg45
	j redraw
lg45:	addi $t1, $t0, 116
	addi $t2, $t0, 156
	blt $t6, $t1, lg46
	bgt $t6, $t2, lg46
	j redraw
lg46:	addi $t1, $t0, 244
	addi $t2, $t0, 284
	blt $t6, $t1, lg47
	bgt $t6, $t2, lg47
	j redraw
lg47:	addi $t1, $t0, 372
	addi $t2, $t0, 412
	blt $t6, $t1, inwtr
	bgt $t6, $t2, inwtr
	j redraw
inwtr:	lw $t7, numOfLives		# when frog is in water
	subi $t7, $t7, 1
	sw $t7, numOfLives
	li $v0, 31			# play a sound when frog lands in water
	li $a0, 35
	li $a1, 500
	li $a2, 90
	li $a3, 100
	syscall
	j dead
gzdet1:	lw $t0, displayAddress		# detect if frog occupies goal zones
	addi $t1, $t0, 512
	bne $t6, $t1, gzdet2
	lw $t2, goalzone1Counter
	addi $t2, $t2, 1
	sw $t2, goalzone1Counter
	addi $t2, $zero, 0x00000003
	sw $t2, frogDirection
	li $v0, 31			# play a sound when frog reaches goal zone 1
	li $a0, 50
	li $a1, 1000
	li $a2, 60
	li $a3, 100
	syscall
	j rstfg
gzdet2:	lw $t0, displayAddress
	addi $t1, $t0, 544
	bne $t6, $t1, gzdet3
	lw $t2, goalzone2Counter
	addi $t2, $t2, 1
	sw $t2, goalzone2Counter
	addi $t2, $zero, 0x00000003
	sw $t2, frogDirection
	li $v0, 31			# play a sound when frog reaches goal zone 2
	li $a0, 50
	li $a1, 1000
	li $a2, 60
	li $a3, 100
	syscall
	j rstfg
gzdet3:	lw $t0, displayAddress
	addi $t1, $t0, 576
	bne $t6, $t1, gzdet4
	lw $t2, goalzone3Counter
	addi $t2, $t2, 1
	sw $t2, goalzone3Counter
	addi $t2, $zero, 0x00000003
	sw $t2, frogDirection
	li $v0, 31			# play a sound when frog reaches goal zone 3
	li $a0, 50
	li $a1, 1000
	li $a2, 60
	li $a3, 100
	syscall
	j rstfg
gzdet4:	lw $t0, displayAddress
	addi $t1, $t0, 608
	bne $t6, $t1, redraw
	lw $t2, goalzone4Counter
	addi $t2, $t2, 1
	sw $t2, goalzone4Counter
	addi $t2, $zero, 0x00000003
	sw $t2, frogDirection
	li $v0, 31			# play a sound when frog reaches goal zone 4
	li $a0, 50
	li $a1, 1000
	li $a2, 60
	li $a3, 100
	syscall
	j rstfg
dead:	lw $t6, frogAddress		# display death animation
	li $t5, 0xffa500
	sw $t5, 0($t6)
	sw $t5, 12($t6)
	sw $t5, 132($t6)
	sw $t5, 136($t6)
	sw $t5, 260($t6)
	sw $t5, 264($t6)
	sw $t5, 384($t6)
	sw $t5, 396($t6)
	li $v0, 32
	li $a0, 1000
	syscall
	lw $t7, numOfLives
	bne $t7, 0x00000000, rstfg
	j rstart
rstfg:	lw $t6, frogAddress		# reset frog address upon collision
	addi $t6, $zero, 0x10008e38
	sw $t6, frogAddress
redraw:	li $v0, 32
	li $a0, 50 			# currently redraw 20 times per second
	syscall
	j draw
Exit:	li $v0, 10 			# terminate the program gracefully
	syscall

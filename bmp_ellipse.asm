# 13. Rysowanie elipsy algorytmem Bresenhama na obrazie BMP.

.data
  _offset_for_header:	.space 2	# Workaround for header to be word-aligned
  header:     		.space 54	# Allocate 54 bytes for BMP header data
  buffer:     		.space 3145728	# Allocate 3MB for 1MegaPixel image data buffer (1024 x 1024 x 3)
  
  color:		.space 3
  
  file_name:  	.string "image.bmp"
  output_name:	.string "res_img.bmp"

.text
.globl _start

_start:

  # Open the BMP file for reading
  la a0, file_name	# Open file address
  li a1, 0    		# Open for reading
  li a7, 1024		# System call to open a file
  ecall
  bltz a0, exit		# Exit if error (status code -1)
  mv t0, a0		# File descriptor

  # Read the BMP header from the file
  la a1, header		# Memory buffer for header data
  li a2, 54		# Read 54 bytes for the BMP header (standart header size)
  li a7, 63		# System call to read from file
  ecall
  bltz a0, close	# Close and exit if error (status code -1)
  
  la s0, header
  
  # Read the Pixel data from the file
  mv a0, t0		# File descriptor
  la a1, buffer		# Memory buffer for header data
  lw t1, 2(s0)		# Full file size
  lw t2, 10(s0)		# Raster data offset
  sub a2, t1, t2	# Read raster data lenght
  li a7, 63		# System call to read from file
  ecall
  bltz a0, close	# Close and exit if error (status code -1)
  
  # Read input (center coordinates and radii)
  li a7 5
  ecall
  mv s1, a0 # center x
  li a7 5
  ecall
  mv s2, a0 # center y
  
  li a7 5
  ecall
  mv s3, a0 # radius x
  li a7 5
  ecall
  mv s4, a0 # radius y
  
  la s10, color
  
  # Read color
  li a7 5
  ecall
  sb a0, 2(s10) # r
  li a7 5
  ecall
  sb a0, 1(s10) # g
  li a7 5
  ecall
  sb a0, 0(s10) # b
  
  # s1 = center x (x0)
  # s2 = center y (y0)
  # s3 = x radius (a)
  # s4 = y radius (b)
  
  lw t1, 18(s0) # width (x)
  lw t2, 22(s0) # height (y)
  lh t3, 28(s0) # bits per pixel
  srli t3, t3, 3 # convert to bytes
  
  la a7, color
  
  la s7, buffer # active address
 
  mv a0, t0 # free up t0 (filename)
  
  la a7, color
  
  mul t5, s3, s3 # a_square
  mul t6, s4, s4 # b_square
  
  slli a5, t5, 1 # two_a_square
  slli a6, t6, 1 # two_b_square
  
arc_1:
  
  mv a1, s3 # x
  li a2, 0 # y
  
  mul s8, a6, s3 # stop
  li s9, 0 # error
  
  sub a3, t6, s8 # dx
  mv a4, t5 # dy
    
 loop_1:
 
  # x, y
  add s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  add s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # x, -y
  sub s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  add s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # -x, y
  add s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  sub s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # -x, -y
  sub s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  sub s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  addi a2, a2, 1
  sub s8, s8, a5
  add s9, s9, a4
  add a4, a4, a5
  
  slli s11, s9, 1
  add s11, s11, a3 
  bgtz s11, move_x
  
  bgtz s8, loop_1
  b arc_2
  
move_x:
  addi a1, a1, -1
  sub s8, s8, a6
  add s9, s9, a3
  add a3, a3, a6
  bgtz s8, loop_1
  
arc_2:
  
  li a1, 0 # x
  mv a2, s4 # y
  
  mul s8, a5, s4 # stop
  li s9, 0 # error
  
  mv a3, t6 # dx
  sub a4, t5, s8 # dy
    
 loop_2:
 
  # x, y
  add s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  add s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # x, -y
  sub s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  add s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # -x, y
  add s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  sub s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  # -x, -y
  sub s10, s2, a2
  mul s10, s10, t1
  add s10, s10, s1
  sub s10, s10, a1
  mul s10, s10, t3
  add s10, s10, s7
  
  lbu t0, 0(a7)
  sb t0, 0(s10)
  
  lbu t0, 1(a7)
  sb t0, 1(s10)
  
  lbu t0, 2(a7)
  sb t0, 2(s10)
  
  addi a1, a1, 1
  sub s8, s8, a6
  add s9, s9, a3
  add a3, a3, a6
  
  slli s11, s9, 1
  add s11, s11, a4 
  bgtz s11, move_y
  
  bgtz s8, loop_2
  b save
  
move_y:
  addi a2, a2, -1
  sub s8, s8, a5
  add s9, s9, a4
  add a4, a4, a5
  bgtz s8, loop_2
  
save:
  la s0, header
  
  # close
  li a7, 57
  ecall
  bltz a0, exit		# Exit if error (status code -1)
  
  # Open the BMP file for writing
  la a0, output_name	# Open file address
  li a1, 1    		# Open for writing
  li a7, 1024		# System call to open a file
  ecall
  bltz a0, exit		# Exit if error (status code -1)
  mv t0, a0
  
  la a1, header
  li a2, 54
  li a7, 64
  ecall
  bltz a0, close
  
  mv a0, t0
  la a1, buffer
  lw t1, 2(s0)		# Full file size
  lw t2, 10(s0)		# Raster data offset
  sub a2, t1, t2	# Raster data lenght
  li a7, 64
  ecall
  bltz a0, close
 
close:
  # Close the file
  mv a0, t0
  li a7, 57	# System call to close file
  ecall

exit:
  # Exit the program
  li a7, 10	# System call to exit program
  ecall
 

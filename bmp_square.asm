
.data
  _offset_for_header:	.space 2	# Workaround for header to be word-aligned
  header:     		.space 54	# Allocate 54 bytes for BMP header data
  buffer:     		.space 2097152	# Allocate 2MB for pixel data buffer (1024 x 1024 x 1)
  
  file_name:  	.string "image.bmp"
  output_name:	.string "res_img.bmp"

.text
.globl _start

_start:
  la s0, header

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
  
  # Read the Pixel data from the file
  mv a0, t0		# File descriptor
  la a1, buffer		# Memory buffer for header data
  lw t1, 2(s0)		# Full file size
  lw t2, 10(s0)		# Raster data offset
  sub a2, t1, t2	# Read raster data lenght
  li a7, 63		# System call to read from file
  ecall
  bltz a0, close	# Close and exit if error (status code -1)
  
  lw t1, 22(s0) # y
  srli t1, t1, 1
  addi t1, t1, -25
  lw t2, 18(s0) # x
  lh t3, 28(s0) # bits per pixel
  srli t3, t3, 3 # convert to bytes
  mul t2, t2, t3 # pixels to bytes
  mul t1, t1, t2
  srli t3, t2, 1
  add t1, t1, t3
  addi t1, t1, -75 # 25 * 3
  la t3, buffer
  add t3, t3, t1
  
  addi t2, t2, -150 # 50 * 3
  
  li t6, 255
  
  li t4, 50
  loop_y:
  
  li t5, 50
  loop_x:
  
  sb zero, (t3)
  addi t3, t3, 1
  sb zero, (t3)
  addi t3, t3, 1
  sb t6, (t3)
  addi t3, t3, 1
  
  addi t5, t5, -1
  bgtz t5, loop_x

  add t3, t3, t2
  
  addi t4, t4, -1
  bgtz t4, loop_y
  
  # close
  mv a0, t0
  li a7, 57
  ecall
  
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
  li a7, 57	# System call to close file
  ecall

exit:
  # Exit the program
  li a7, 10	# System call to exit program
  ecall
 

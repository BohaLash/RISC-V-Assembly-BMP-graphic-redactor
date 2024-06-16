# 1. Cieniowanie trójkąta 
# (zadane w konsoli: współrzędne trzech wierzchołków i ich kolory, ścieżka do obrazka na którym ma być narysowany wynik)
# wynik w BMP.

.data
  _offset_for_header:	.space 2	# Workaround for header to be word-aligned
  header:     		.space 54	# Allocate 54 bytes for BMP header data
  buffer:     		.space 2097152	# Allocate 2MB for pixel data buffer (1024 x 1024 x 1)
  
  colors:		.space 9
  
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
  
  # Read vertexes ( !!! in clockwise order !!! )
  li a7 5
  ecall
  mv s1, a0 # x1
  li a7 5
  ecall
  mv s2, a0 # y1
  
  li a7 5
  ecall
  mv s3, a0 # x2
  li a7 5
  ecall
  mv s4, a0 # y2
  
  li a7 5
  ecall
  mv s5, a0 # x3
  li a7 5
  ecall
  mv s6, a0 # y3
  
  la s10, colors
  
  # Read vertexes colors
  li a7 5
  ecall
  sb a0, 0(s10) # r 1
  li a7 5
  ecall
  sb a0, 1(s10) # g 1
  li a7 5
  ecall
  sb a0, 2(s10) # b 1
    
  li a7 5
  ecall
  sb a0, 3(s10) # r 2
  li a7 5
  ecall
  sb a0, 4(s10) # g 2
  li a7 5
  ecall
  sb a0, 5(s10) # b 2
  
  li a7 5
  ecall
  sb a0, 6(s10) # r 3
  li a7 5
  ecall
  sb a0, 7(s10) # g 3
  li a7 5
  ecall
  sb a0, 8(s10) # b 3
  
  # min and max
  slt t1, s1, s3
  seqz t2, t1
  mul t3, s1, t1
  mul t4, s3, t2
  add s7, t3, t4
  
  slt t1, s7, s5
  seqz t2, t1
  mul t3, s7, t1
  mul t4, s5, t2
  add s7, t3, t4

  slt t1, s2, s4
  seqz t2, t1
  mul t3, s2, t1
  mul t4, s4, t2
  add s8, t3, t4
  
  slt t1, s8, s6
  seqz t2, t1
  mul t3, s8, t1
  mul t4, s6, t2
  add s8, t3, t4
  
  sgt t1, s1, s3
  seqz t2, t1
  mul t3, s1, t1
  mul t4, s3, t2
  add s9, t3, t4
  
  sgt t1, s9, s5
  seqz t2, t1
  mul t3, s9, t1
  mul t4, s5, t2
  add s9, t3, t4

  sgt t1, s2, s4
  seqz t2, t1
  mul t3, s2, t1
  mul t4, s4, t2
  add s10, t3, t4
  
  sgt t1, s10, s6
  seqz t2, t1
  mul t3, s10, t1
  mul t4, s6, t2
  add s10, t3, t4
  
  # s7  = min X
  # s8  = min Y
  # s9  = max X
  # s10 = max Y
  
  sub s1, s9, s1
  sub s2, s10, s2
  sub s3, s9, s3
  sub s4, s10, s4
  sub s5, s9, s5
  sub s6, s10, s6
  
  lw t1, 18(s0) # x
  lw t2, 22(s0) # y
  bne t1, t2, close
  lh t3, 28(s0) # bits per pixel
  srli t3, t3, 3 # convert to bytes
    
  sub s10, s10, s8
  sub s9, s9, s7
  
  mul s8, s8, t1
  add s8, s8, s7
  mul s8, s8, t3
  
  la s7, buffer
  add s7, s7, s8
  
  mv s8, s9
  sub s9, t1, s9
  mul s9, s9, t3
  
  # s7  - active address
  # s8  - width in pixels
  # s9  - new line jump in bytes
  # s10 - height in pixels
    
  sub t1, s1, s3
  sub t2, s3, s5
  sub t3, s5, s1
  
  sub t4, s2, s4
  sub t5, s4, s6
  sub t6, s6, s2
  
  mv a0, t0 # free up t0
  
  la a7, colors
  
  loop_y:
  
  mv s11, s8
  loop_x:
  
  # ckeck half-space line equasions for each side
  sub a2, s2, s10
  mul s0, a2, t1
  sub a1, s1, s11
  mul t0, a1, t4
  blt t0, s0, skip

  sub a4, s4, s10
  mul s0, a4, t2
  sub a3, s3, s11
  mul t0, a3, t5
  blt t0, s0, skip
  
  sub a6, s6, s10
  mul s0, a6, t3
  sub a5, s5, s11
  mul t0, a5, t6
  blt t0, s0, skip
  
  mul a1, a1, a1
  mul a2, a2, a2
  mul a3, a3, a3
  mul a4, a4, a4
  mul a5, a5, a5
  mul a6, a6, a6
  
  add a1, a1, a2
  add a2, a3, a4
  add a3, a5, a6
  
  add s0, a1, a2
  add s0, s0, a3
  
  lbu a4, 2(a7)
  mul t0, a4, a1
  div t0, t0, s0
  sub a4, a4, t0
  
  lbu t0, 5(a7)
  add a4, a4, t0
  mul t0, t0, a2
  div t0, t0, s0
  sub a4, a4, t0
  
  lbu t0, 8(a7)
  add a4, a4, t0
  mul t0, t0, a3
  div t0, t0, s0
  sub a4, a4, t0
      
  sb a4, (s7)
  addi s7, s7, 1
  
  
  lbu a4, 1(a7)
  mul t0, a4, a1
  div t0, t0, s0
  sub a4, a4, t0
  
  lbu t0, 4(a7)
  add a4, a4, t0
  mul t0, t0, a2
  div t0, t0, s0
  sub a4, a4, t0
  
  lbu t0, 7(a7)
  add a4, a4, t0
  mul t0, t0, a3
  div t0, t0, s0
  sub a4, a4, t0
  
  sb a4, (s7)
  addi s7, s7, 1
  
  
  lbu a4, 0(a7)
  mul t0, a4, a1
  div t0, t0, s0
  sub a4, a4, t0
    
  lbu t0, 3(a7)
  add a4, a4, t0
  mul t0, t0, a2
  div t0, t0, s0
  sub a4, a4, t0
  
  lbu t0, 6(a7)
  add a4, a4, t0
  mul t0, t0, a3
  div t0, t0, s0
  sub a4, a4, t0
    
  sb a4, (s7)
  addi s7, s7, 1
  
  b next
  
  skip:
  addi s7, s7, 3
  
  next:
  addi s11, s11, -1
  bgtz s11, loop_x
  
  add s7, s7, s9
  addi s10, s10, -1
  bgtz s10, loop_y
  
  la s0, header
  
  # close
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
  mv a0, t0
  li a7, 57	# System call to close file
  ecall

exit:
  # Exit the program
  li a7, 10	# System call to exit program
  ecall
 

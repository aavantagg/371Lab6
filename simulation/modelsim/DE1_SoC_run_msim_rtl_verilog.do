transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/casey/OneDrive/Documents/Spring\ 20/EE\ 371/Lab6/Lab\ 6 {C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/Lab 6/VGA_framebuffer.sv}
vlog -sv -work work +incdir+C:/Users/casey/OneDrive/Documents/Spring\ 20/EE\ 371/Lab6/Lab\ 6 {C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/Lab 6/clear_screen.sv}
vlog -sv -work work +incdir+C:/Users/casey/OneDrive/Documents/Spring\ 20/EE\ 371/Lab6/Lab\ 6 {C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/Lab 6/pipe_drawer.sv}
vlog -sv -work work +incdir+C:/Users/casey/OneDrive/Documents/Spring\ 20/EE\ 371/Lab6/Lab\ 6 {C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/Lab 6/Display_Manager.sv}
vlog -sv -work work +incdir+C:/Users/casey/OneDrive/Documents/Spring\ 20/EE\ 371/Lab6/Lab\ 6 {C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/Lab 6/DE1_SoC.sv}


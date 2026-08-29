transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/register_file.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/program_counter.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/opcode_decoder.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/flag_register.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/enc_31_to_5.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/dec_4_to_16.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/dec_2_to_4.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/dec_1_to_2.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/data_mem.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/cpu.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/control_unit.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/code_mem.v}
vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/alu.v}

vlog -vlog01compat -work work +incdir+E:/IITB/3rd_Semester/IITB-CPU/Code/Final {E:/IITB/3rd_Semester/IITB-CPU/Code/Final/tb_load_and_run.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  tb_load_and_run

add wave *
view structure
view signals
run -all

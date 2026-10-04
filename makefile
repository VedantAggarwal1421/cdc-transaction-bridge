all: compile run

compile:
	verilator --top-module tb_cdc --binary --trace -f files.f
run:
	./obj_dir/Vtb_cdc
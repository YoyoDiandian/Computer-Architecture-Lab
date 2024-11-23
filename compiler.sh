echo "Start Compiling"
iverilog -o wave \
            ./ucsbece154a_top.v \
            ./tb.v \
            ./ucsbece154a_riscv.v \
            ./ucsbece154a_mem.v \
            ./ucsbece154a_controller.v \
            ./ucsbece154a_datapath.v \
            ./ucsbece154a_alu.v \
            ./ucsbece154a_rf.v 
echo "Compilation Completed"

echo "Generate waveform files"
vvp -n wave
cp wave.vcd wave.lxt
echo "开始编译"
iverilog -o wave \
            ./ucsbece154a_top.v \
            ./testbench.v \
            ./ucsbece154a_riscv.v \
            ./ucsbece154a_imem.v \
            ./ucsbece154a_dmem.v \
            ./ucsbece154a_controller.v \
            ./ucsbece154a_datapath.v \
            ./ucsbece154a_alu.v \
            ./ucsbece154a_rf.v 
echo "编译完成"

echo "生成波形文件"
vvp -n wave
cp wave.vcd wave.lxt
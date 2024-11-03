echo "开始编译"
iverilog -o wave ./test.v ./test_tb.v
echo "编译完成"

echo "生成波形文件"
vvp -n wave
cp wave.vcd wave.lxt

# echo "打开波形文件"
# open wave.vcd
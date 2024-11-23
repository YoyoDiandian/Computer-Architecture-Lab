# Table1填写
### 状态解释
1. **Fetch** (状态 0): 指令取值阶段，从内存中读取指令。
2. **Decode** (状态 1): 指令解码阶段，确定操作类型和立即数。
3. **MemAdr** (状态 2): 计算访问内存的地址（针对 `lw` 或 `sw`）。
4. **MemRead** (状态 3): 从内存中读取数据（针对 `lw`）。
5. **MemWB** (状态 4): 将读取到的数据写回寄存器。
6. **MemWrite** (状态 5): 将寄存器数据写入内存（针对 `sw`）。
7. **ExecuteR** (状态 6): 执行 R 型指令。
8. **ALUWB** (状态 7): 将运算结果写回寄存器。
9. **ExecuteI** (状态 8): 执行 I 型指令。
10. **JAL** (状态 9): 跳转指令（`jal` 或 `jalr`）。
11. **BEQ** (状态 10): 条件跳转（`beq`）。

### 填写逻辑
控制信号根据每个状态执行的操作来设置。以下是逐列分析的逻辑：
- **PCUpdate**: 是否更新PC寄存器（通常在取指令或跳转时设置为1）。
- **MemWrite**: 是否写入内存（用于 `sw` 指令）。
- **IRWrite**: 是否写入指令寄存器（通常在取指令阶段设置为1）。
- **RegWrite**: 是否写入寄存器（用于 `lw` 和 ALU运算）。
- **ALUSrcA[1:0]**: ALU的第一个操作数来源。
- **Branch**: 是否进行条件跳转。
- **AdrSrc**: 地址来源（通常在访存时设置）。
- **ALUSrcB[1:0]**: ALU的第二个操作数来源。
- **ResultSrc[1:0]**: 运算结果的来源。
- **ALUOp[1:0]**: ALU操作的功能选择。
- **ImmSrc[2:0]**: 立即数类型。

以下是根据图中信息填写的表格内容：

| State (Name)   | PCUpdate | MemWrite | IRWrite | RegWrite | ALUSrcA[1:0] | Branch | AdrSrc | ALUSrcB[1:0] | ResultSrc[1:0] | ALUOp[1:0] | ImmSrc[2:0] |
|----------------|----------|----------|---------|----------|--------------|--------|--------|--------------|----------------|------------|------------|
| 0 (Fetch)      | 1        | 0        | 1       | 0        | 00           | X      | 0      | 10           | 10             | 00         | XXX        |
| 1 (Decode)     | 0        | 0        | 0       | 0        | 01           | 0      | X      | 01           | XX             | 00         | 010        |
| 2 (MemAdr)     | 0        | 0        | 0       | 0        | 10           | 0      | X      | 01           | XX             | 00         | 010        |
| 3 (MemRead)    | 0        | 0        | 0       | 0        | X            | 0      | 1      | XX           | 00             | XX         | XXX        |
| 4 (MemWB)      | 0        | 0        | 0       | 1        | X            | 0      | X      | XX           | 01             | XX         | XXX        |
| 5 (MemWrite)   | 0        | 1        | 0       | 0        | X            | 0      | 1      | XX           | XX             | XX         | XXX        |
| 6 (ExecuteR)   | 0        | 0        | 0       | 0        | 10           | 0      | X      | 00           | XX             | 10         | XXX        |
| 7 (ALUWB)      | 0        | 0        | 0       | 1        | X            | 0      | X      | XX           | 00             | XX         | XXX        |
| 8 (ExecuteI)   | 0        | 0        | 0       | 0        | 10           | 0      | X      | 01           | 00             | 10         | 010        |
| 9 (JAL)        | 1        | 0        | 0       | 1        | 01           | 0      | X      | 10           | 10             | XX         | 100        |
| 10 (BEQ)       | 0        | 0        | 0       | 0        | 10           | 1      | X      | 00           | XX             | 01         | XXX        |

### 填写说明
1. **Fetch（状态 0）**: `PCUpdate=1`, `IRWrite=1`，因为要从内存中取指令并更新PC。
2. **Decode（状态 1）**: `ALUSrcA=01`, `ALUSrcB=01`，用来准备寄存器值和立即数。
3. **MemAdr（状态 2）**: `ALUSrcA=10`, `ALUSrcB=10`，通过ALU计算内存地址。
4. **MemRead（状态 3）**: 设置 `AdrSrc=1`，从内存地址中读取数据。
5. **MemWB（状态 4）**: `ResultSrc=01`, `RegWrite=1`，将内存读取的数据写入寄存器。
6. **MemWrite（状态 5）**: `MemWrite=1`, `AdrSrc=1`，将寄存器值存入内存。
7. **ExecuteR（状态 6）**: `ALUSrcA=10`, `ALUSrcB=00`, `ALUOp=10`，执行R型指令。
8. **ALUWB（状态 7）**: `ResultSrc=00`, `RegWrite=1`，将ALU运算结果写回寄存器。
9. **ExecuteI（状态 8）**: `ALUSrcA=10`, `ALUSrcB=10`, `ALUOp=10`，执行I型ALU指令。
10. **JAL（状态 9）**: `PCUpdate=1`, `RegWrite=1`, `ResultSrc=10`，处理跳转。
11. **BEQ（状态 10）**: `Branch=1`, `ALUSrcA=10`, `ALUSrcB=00`，执行条件跳转。
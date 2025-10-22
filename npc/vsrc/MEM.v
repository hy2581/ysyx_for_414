// module MEM (
//     input clk,
//     input rst,
    
//     // 内存接口
//     input mem_read,        // 内存读使能
//     input mem_write,       // 内存写使能
//     input [31:0] mem_addr, // 内存地址
//     input [31:0] mem_wdata,// 写入内存的数据
//     input [3:0] mem_mask,  // 字节使能
//     output reg [31:0] mem_rdata // 从内存读取的数据
// );

//     // 定义内存大小，这里使用1MB内存
//     parameter MEM_SIZE = 1048576; // 1MB内存
//     reg [7:0] memory [0:MEM_SIZE-1];

//     integer y;
//     initial begin
//         for (y = 0; y < MEM_SIZE; y = y + 1) begin
//             memory[y] = 8'h00; // 初始化为0
//         end
//     end
    
//     // 地址转换，修改掩码大小匹配内存大小
//     wire [31:0] addr = (mem_addr - 32'h80000000) & (MEM_SIZE - 1); 
    
//     // 读内存操作 - 移除了错误的输出代码
//     always @(*) begin
//         if (mem_read) begin
//             mem_rdata = {
//                 memory[addr+3],
//                 memory[addr+2],
//                 memory[addr+1],
//                 memory[addr]
//             };
//         end else begin
//             mem_rdata = 32'h0;
//         end
//     end
    
//     // 写内存操作 - 添加串口处理
//     always @(posedge clk) begin
//         if (mem_write) begin
//             // 判断是否是串口地址
//             // $write("%c", mem_wdata[7:0]);
//             if (mem_addr == 32'ha00003f8) begin
//                 // 串口只关心最低字节
//                 $write("%c", mem_wdata[7:0]);
//                 $fflush(); // 确保立即显示
//             end else begin
//                 // 普通内存写入
//                 if (mem_mask[0]) memory[addr]   <= mem_wdata[7:0];
//                 if (mem_mask[1]) memory[addr+1] <= mem_wdata[15:8];
//                 if (mem_mask[2]) memory[addr+2] <= mem_wdata[23:16];
//                 if (mem_mask[3]) memory[addr+3] <= mem_wdata[31:24];
//             end
//         end
//     end

// endmodule

module MEM (
    input clk,
    input rst,
    
    // 内存接口
    input mem_read,        // 内存读使能
    input mem_write,       // 内存写使能
    input [31:0] mem_addr, // 内存地址
    input [31:0] mem_wdata,// 写入内存的数据
    input [3:0] mem_mask,  // 字节使能
    output reg [31:0] mem_rdata // 从内存读取的数据
);
    // DPI-C导入函数声明
    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);
    
    // 调试标志，设为1启用调试输出
    parameter DEBUG = 0;
    
    // 读内存操作 - 使用DPI-C函数
    always @(*) begin
        if (mem_read) begin
            mem_rdata = pmem_read(mem_addr);
            if (DEBUG) begin
                // $display("[MEM] 读操作 - 地址: 0x%08x, 数据: 0x%08x", mem_addr, mem_rdata);
            end
        end else begin
            mem_rdata = 32'h0;
        end
    end
    
    // 写内存操作 - 使用DPI-C函数
    always @(posedge clk) begin
        if (mem_write) begin
            // 将4位掩码转换为8位掩码（避免类型不匹配）
            byte mask = {4'b0, mem_mask};
            
            if (DEBUG) begin
                $display("[MEM] 写操作 - 地址: 0x%08x, 数据: 0x%08x, 掩码: %b", 
                        mem_addr, mem_wdata, mem_mask);
            end
            
            pmem_write(mem_addr, mem_wdata, mask);
        end
    end
endmodule
module top(
    input clk,
    input rst,
    input [31:0]op,
    input sdop_en,

    output [31:0]dnpc,
    output rdop_en,
    output end_flag,          // 程序结束标志
    output [31:0] exit_code,  // 添加退出码输出
    
    // 添加寄存器接口用于DiffTest
    output [31:0] x0, x1, x2, x3, x4, x5, x6, x7,
    output [31:0] x8, x9, x10, x11, x12, x13, x14, x15,
    output [31:0] x16, x17, x18, x19, x20, x21, x22, x23,
    output [31:0] x24, x25, x26, x27, x28, x29, x30, x31
);

// EXU执行单元接口信号
wire ex_end;                // EXU执行完成信号 
wire [31:0] next_pc;        // 从EXU获取的下一条指令PC
wire branch_taken;          // 分支是否taken
  
// LSU SRAM接口信号
wire lsu_req;                    // LSU访存请求
wire lsu_wen;                    // LSU写使能
wire [31:0] lsu_addr;            // LSU地址
wire [31:0] lsu_wdata;           // LSU写数据
wire [3:0] lsu_wmask;            // LSU写掩码
wire lsu_rvalid;                 // LSU读数据有效
wire [31:0] lsu_rdata;           // LSU读数据



// IFU相关代码
reg [31:0] pc;          // 程序计数器
reg rdop_en_reg;        // 读操作使能寄存器
reg ex_end_prev;        // 前一周期的ex_end信号
reg end_flag_reg;       // 结束标志寄存器
reg rdop_en_prev;       // 前一周期的rdop_en状态
reg update_pc;          // PC更新使能信号

// 添加一个中间 wire 信号
wire ebreak_detected;  // 新增的内部信号

// 添加退出码信号
wire [31:0] exit_value;
reg [31:0] exit_code_reg;

// ========= 指令存储器（IMEM，256x32b） =========
// 将PC转换为字地址索引（低两位舍弃）
wire [31:0] imem_word_index = ((pc - 32'h8000_0000) >> 2);
wire [7:0] imem_idx = imem_word_index[7:0];
wire [31:0] imem_rdata1;
wire [31:0] imem_rdata2;
wire [31:0] imem_reg_values [0:255];
// 指令存储器仅读，不在此写入（可通过仿真或后续加载机制预置）
RegisterFile #(.ADDR_WIDTH(8), .DATA_WIDTH(32)) IMEM (
  .clk(clk), .rst(rst),
  .wdata(32'h0), .waddr(8'h0), .wen(1'b0),
  .raddr1(imem_idx), .rdata1(imem_rdata1),
  .raddr2(imem_idx), .rdata2(imem_rdata2),
  .reg_values(imem_reg_values)
);

// 可选：当外部未提供op时，使用IMEM读取值（保持兼容）
// wire [31:0] op_from_imem = imem_rdata1;
EXU EXU (
    .clk         (clk),
    .rst         (rst),
    .op          (op_ifu),      // 由 IFU 返回的指令
    .op_en       (op_en_ifu),   // IFU 的有效握手
    .pc          (pc),          // 当前指令的PC
    
    .ex_end      (ex_end),      // 执行完成信号
    .next_pc     (next_pc),     // 下一条指令的PC
    .branch_taken(branch_taken), // 分支是否taken
    
    // LSU SRAM接口
    .lsu_req     (lsu_req),         // LSU访存请求
    .lsu_wen     (lsu_wen),         // LSU写使能
    .lsu_addr    (lsu_addr),        // LSU地址
    .lsu_wdata   (lsu_wdata),       // LSU写数据
    .lsu_wmask   (lsu_wmask),       // LSU写掩码
    .lsu_rvalid  (lsu_rvalid),      // LSU读数据有效
    .lsu_rdata   (lsu_rdata),       // LSU读数据
    .ebreak_flag (ebreak_detected),
    .exit_code   (exit_value),      // 连接到退出码信号
    // 寄存器接口
    .regs        (exu_regs)
);

// AXI4-Lite信号定义 - LSU
wire [31:0] lsu_awaddr;
wire        lsu_awvalid;
wire        lsu_awready;
wire [31:0] lsu_wdata_axi;
wire [3:0]  lsu_wstrb;
wire        lsu_wvalid;
wire        lsu_wready;
wire [1:0]  lsu_bresp;
wire        lsu_bvalid;
wire        lsu_bready;
wire [31:0] lsu_araddr;
wire        lsu_arvalid;
wire        lsu_arready;
wire [31:0] lsu_rdata_axi;
wire [1:0]  lsu_rresp;
wire        lsu_rvalid_axi;
wire        lsu_rready;

// LSU SRAM模块实例化：AXI4-Lite master接口
LSU_SRAM LSU_SRAM (
    .clk         (clk),
    .rst         (rst),
    
    // 原始接口
    .req         (lsu_req),
    .wen         (lsu_wen),
    .addr        (lsu_addr),
    .wdata       (lsu_wdata),
    .wmask       (lsu_wmask),
    .rvalid_out  (lsu_rvalid),
    .rdata_out   (lsu_rdata),
    
    // AXI4-Lite Master接口
    .awaddr      (lsu_awaddr),
    .awvalid     (lsu_awvalid),
    .awready     (lsu_awready),
    .wdata_axi   (lsu_wdata_axi),
    .wstrb       (lsu_wstrb),
    .wvalid      (lsu_wvalid),
    .wready      (lsu_wready),
    .bresp       (lsu_bresp),
    .bvalid      (lsu_bvalid),
    .bready      (lsu_bready),
    .araddr      (lsu_araddr),
    .arvalid     (lsu_arvalid),
    .arready     (lsu_arready),
    .rdata       (lsu_rdata_axi),
    .rresp       (lsu_rresp),
    .rvalid      (lsu_rvalid_axi),
    .rready      (lsu_rready)
);

// 初始化与复位逻辑
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h8000_0000;  // 复位时PC设置为0x80000000
        rdop_en_reg <= 1'b0;
        ex_end_prev <= 1'b0;
        end_flag_reg <= 1'b0;
        rdop_en_prev <= 1'b0;
        update_pc <= 1'b0;
        exit_code_reg <= 32'h0;
        // IFU 相关复位
        first_fetch_pending <= 1'b1; // 复位后需要首次取指
        ifu_req <= 1'b0;
        op_en_ifu <= 1'b0;
        op_ifu <= 32'h0;
    end else begin
        // 保存ex_end和rdop_en的前一个状态用于检测变化
        ex_end_prev <= ex_end;
        rdop_en_prev <= rdop_en_reg;
        
        // 当ex_end发生变化时，设置rdop_en为1一个周期
        if (ex_end != ex_end_prev) begin
            rdop_en_reg <= 1'b1;
        end else begin
            rdop_en_reg <= 1'b0;
        end
        
        // 检测rdop_en从1变为0的上升沿，设置update_pc为1 hy:这里做了修改
        if (rdop_en_reg && !rdop_en_prev) begin
            update_pc <= 1'b1;
        end else if (update_pc) begin
            // 在检测到下降沿后的下一个周期更新PC，使用EXU提供的next_pc
            pc <= next_pc;
            update_pc <= 1'b0;
        end
        
        // IFU 请求脉冲：
        // - 复位后的首次取指打一拍
        // - 在更新PC的那个周期为下一条指令发起取指
        if (first_fetch_pending) begin
            ifu_req <= 1'b1;
            first_fetch_pending <= 1'b0;
        end else if (update_pc) begin
            ifu_req <= 1'b1;
        end else begin
            ifu_req <= 1'b0;
        end

        // 当 IFU 返回有效时，打一拍通知 EXU 并提供指令
        op_en_ifu <= 1'b0; // 缺省无效
        if (ifu_rvalid) begin
            op_ifu <= ifu_rdata;
            op_en_ifu <= 1'b1;
        end
        
        // 添加 end_flag_reg 更新逻辑
        end_flag_reg <= ebreak_detected;
        
        // 更新退出码寄存器
        if (ebreak_detected) begin
            exit_code_reg <= exit_value;
        end
    end
end

// 输出赋值
assign rdop_en = rdop_en_reg;
assign end_flag = end_flag_reg;
assign dnpc = next_pc;  // 使用EXU计算的下一条指令PC作为dnpc输出
assign exit_code = exit_code_reg;

// 添加EXU接口用于获取寄存器值 - 正确声明为数组
wire [31:0] exu_regs [0:31];  // 明确声明为32元素的数组


// 输出寄存器值
assign x0 = exu_regs[0];
assign x1 = exu_regs[1];
assign x2 = exu_regs[2];
assign x3 = exu_regs[3];
assign x4 = exu_regs[4];
assign x5 = exu_regs[5];
assign x6 = exu_regs[6];
assign x7 = exu_regs[7];
assign x8 = exu_regs[8];
assign x9 = exu_regs[9];
assign x10 = exu_regs[10];
assign x11 = exu_regs[11];
assign x12 = exu_regs[12];
assign x13 = exu_regs[13];
assign x14 = exu_regs[14];
assign x15 = exu_regs[15];
assign x16 = exu_regs[16];
assign x17 = exu_regs[17];
assign x18 = exu_regs[18];
assign x19 = exu_regs[19];
assign x20 = exu_regs[20];
assign x21 = exu_regs[21];
assign x22 = exu_regs[22];
assign x23 = exu_regs[23];
assign x24 = exu_regs[24];
assign x25 = exu_regs[25];
assign x26 = exu_regs[26];
assign x27 = exu_regs[27];
assign x28 = exu_regs[28];
assign x29 = exu_regs[29];
assign x30 = exu_regs[30];
assign x31 = exu_regs[31];

// IFU 取指 SRAM 接口与握手
wire        ifu_rvalid;
wire [31:0] ifu_rdata;
reg         ifu_req;
reg         first_fetch_pending;
reg         op_en_ifu;
reg  [31:0] op_ifu;
// 在更新PC的那个周期，用 next_pc 作为取指地址；
// 其他情况（包括复位后的首次取指）使用当前 pc
wire [31:0] ifu_addr = (update_pc) ? next_pc : pc;

// EXU 已在前文实例化并接入 IFU 的指令与握手，这里删除重复实例
// AXI4-Lite信号定义 - IFU
wire [31:0] ifu_awaddr;
wire        ifu_awvalid;
wire        ifu_awready;
wire [31:0] ifu_wdata;
wire [3:0]  ifu_wstrb;
wire        ifu_wvalid;
wire        ifu_wready;
wire [1:0]  ifu_bresp;
wire        ifu_bvalid;
wire        ifu_bready;
wire [31:0] ifu_araddr;
wire        ifu_arvalid;
wire        ifu_arready;
wire [31:0] ifu_rdata_axi;
wire [1:0]  ifu_rresp;
wire        ifu_rvalid_axi;
wire        ifu_rready;

// IFU SRAM 实例化：AXI4-Lite master接口
IFU_SRAM u_ifu (
    .clk         (clk),
    .rst         (rst),
    .req         (ifu_req),
    .addr        (ifu_addr),
    .rvalid_out  (ifu_rvalid),
    .rdata_out   (ifu_rdata),
    
    // AXI4-Lite Master接口
    .awaddr      (ifu_awaddr),
    .awvalid     (ifu_awvalid),
    .awready     (ifu_awready),
    .wdata       (ifu_wdata),
    .wstrb       (ifu_wstrb),
    .wvalid      (ifu_wvalid),
    .wready      (ifu_wready),
    .bresp       (ifu_bresp),
    .bvalid      (ifu_bvalid),
    .bready      (ifu_bready),
    .araddr      (ifu_araddr),
    .arvalid     (ifu_arvalid),
    .arready     (ifu_arready),
    .rdata       (ifu_rdata_axi),
    .rresp       (ifu_rresp),
    .rvalid      (ifu_rvalid_axi),
    .rready      (ifu_rready)
);



// AXI4-Lite接口连接 - 由于IFU和LSU内部直接使用DPI-C，
// 我们只需要提供简单的握手响应来满足AXI4-Lite协议

// IFU写通道响应（始终为0）
assign ifu_awready = 1'b1; // 立即响应，但IFU不应该使用
assign ifu_wready  = 1'b1; // 立即响应，但IFU不应该使用
assign ifu_bresp   = 2'b00;
assign ifu_bvalid  = 1'b0; // 永远不会有写响应

// IFU读通道响应（1周期延迟）
assign ifu_arready = 1'b1; // 立即接受地址
assign ifu_rdata_axi = 32'h0; // 不使用，数据通过DPI-C获取
assign ifu_rresp = 2'b00;
assign ifu_rvalid_axi = 1'b1; // 立即响应，实际延迟在模块内部实现

// LSU写通道响应（1周期延迟）
assign lsu_awready = 1'b1; // 立即接受地址
assign lsu_wready  = 1'b1; // 立即接受数据
assign lsu_bresp   = 2'b00;
assign lsu_bvalid  = 1'b1; // 立即响应

// LSU读通道响应（1周期延迟）
assign lsu_arready = 1'b1; // 立即接受地址
assign lsu_rdata_axi = 32'h0; // 不使用，数据通过DPI-C获取
assign lsu_rresp = 2'b00;
assign lsu_rvalid_axi = 1'b1; // 立即响应，实际延迟在模块内部实现



endmodule
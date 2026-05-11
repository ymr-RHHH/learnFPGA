//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 模块名称：IIC_common
// 创建作者：袁博鑫
// 文件版本：V1.0
// 创建日期：2024-06-01
// 模块功能：IIC总线通用模块
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//用户命令：
// 1. USERCMD_NOTHING      3'b000 ：没有任何操作
// 2. USERCMD_READ_SINGLE  3'b001 ：读取单个数据
// 3. USERCMD_READ_BULK    3'b010 ：读取多个数据
// 4. USERCMD_WRITE_SINGLE 3'b011 ：写入单个数据
// 5. USERCMD_WRITE_BULK   3'b100 ：写入多个数据

module IIC_common #(
    parameter SYSTEM_FREQ = 50_000_000,              // 系统时钟频率，单位为Hz
    parameter IIC_FREQ    = 100_000,                 // IIC时钟频率，单位为Hz;
)
(
    input                               clk,
    input                               rst_n,

    // 用户接口
    input     wire    [2 :0]            i_user_cmd,           // 用户命令
    input     wire    [9 :0]            i_slave_addr,         // IIC设备地址，支持7位和10位地址，这里直接进行自判断，在调用的时候直接填写成10位地址即可，7位地址在高位补0
    input     wire    [15:0]            i_reg_addr,           // 寄存器地址，支持16、8、0位寄存器地址，这里直接进行自判断
    input     wire    [7 :0]            i_w_data,             // 写入数据
    output    reg     [7 :0]            o_read_data,             // 读取数据
    input     wire    [31:0]            i_rw_data_len,        // 读写的数据长度，单位为字节

    input     wire                      i_start,              // 启动信号，外部给一个脉冲，触发IIC通信的开始
    output    wire                      o_rw_byte_ready,      // 读写一个字节完成标志，表示当前字节的读写操作已经完成，该信号给个上升沿告诉控制端要准备好收发下一个字节的数据了
    output    reg                       o_busy,               // 模块忙标志，正在进行IIC通信时为1，空闲时为0
    output    reg                       o_error,              // 错误标志，发生错误时为1，正常时为0

    // IIC总线接口
    output    wire                      o_scl,                // IIC时钟线
    inout     wire                      io_sda                // IIC数据线
);

    // 时钟分频计算
    localparam CLK_DIV_CNT = SYSTEM_FREQ / (IIC_FREQ * 2); 
    localparam SCL_HALF_CNT = CLK_DIV_CNT;

    // 用户命令
    localparam USERCMD_NOTHING      = 3'b000 ; // 没有任何操作
    localparam USERCMD_READ_SINGLE  = 3'b001 ; // 读取单个数据
    localparam USERCMD_READ_BULK    = 3'b010 ; // 读取多个数据
    localparam USERCMD_WRITE_SINGLE = 3'b011 ; // 写入单个数据
    localparam USERCMD_WRITE_BULK   = 3'b100 ; // 写入多个数据

    // IIC状态机状态定义
    localparam STATE_IDLE           = 12'b0000_0000_0001;  // 空闲状态
    localparam STATE_PARSE_CMD_ADDR = 12'b0000_0000_0010;  // 解析命令和地址状态
    localparam STATE_IIC_START      = 12'b0000_0000_0100;  // 发送起始条件状态
    localparam STATE_SDND_BYTE      = 12'b0000_0000_1000;  // IIC写数据状态
    localparam STATE_SLAVE_ACK      = 12'b0000_0001_0000;  // 等待从设备应答状态
    localparam STATE_IIC_RESTART    = 12'b0000_0010_0000;  // 发送重复起始条件状态
    localparam STATE_REV_BYTE       = 12'b0000_0100_0000;  // IIC读数据状态
    localparam STATE_MASTER_ACK     = 12'b0000_1000_0000;  // 发送主设备应答状态
    localparam STATE_IIC_STOP       = 12'b0001_0000_0000;  // 发送停止条件状态
    localparam STATE_ERR_STOP       = 12'b0010_0000_0000;  // 错误停止状态

    // IIC操作相关
    localparam IIC_ATOM_NONE      = 6'b000000; // 无操作
    localparam IIC_ATOM_START     = 6'b000001; // 发送起始条件
    localparam IIC_ATOM_END       = 6'b000010; // 发送停止条件
    localparam IIC_ATOM_SEND_BYTE = 6'b000100; // 发送字节
    localparam IIC_ATOM_RECV_BYTE = 6'b001000; // 接收字节
    localparam IIC_ATOM_SEND_ACK  = 6'b010000; // 发送应答
    localparam IIC_ATOM_RECV_ACK  = 6'b100000; // 接收应答

    // 内部信号定义
    reg      [2 :0]        user_cmd;           // 用户命令
    reg      [9 :0]        slave_addr;         // IIC设备地址
    reg      [15:0]        reg_addr;           // 寄存器地址，支持16、8、0位寄存器地址，这里直接进行自判断
    reg      [7 :0]        write_data;         // 写入数据
    reg      [7 :0]        read_data;          // 读取数据
    reg      [31:0]        rw_data_len;        // 读写数据长度，单位为字节

    reg                    rw_byte_ready;      // 读写一个字节完成标志，表示当前字节的读写操作已经完成，该信号给个上升沿告诉控制端要准备好收发下一个字节的数据了
    reg                    busy;               // 模块忙标志，正在进行IIC通信时为1，空闲时为0
    reg                    error;              // 错误标志，发生错误时为1，正常时为0


    // 状态机相关
    reg      [11:0]        current_state;      // 当前状态
    reg      [11:0]        next_state;         // 下一状态
    // 状态机输入锁存
    reg      [2 :0]        fsm_user_cmd;           // 用户命令
    reg      [9 :0]        fsm_slave_addr;         // IIC设备地址
    reg      [15:0]        fsm_reg_addr;           // 寄存器地址，支持16、8、0位寄存器地址，这里直接进行自判断
    reg      [7 :0]        fsm_write_data;         // 写入数据
    reg      [31:0]        fsm_rw_data_len;        // 读写数据长度，单位为字节

    
    // 开始信号上升沿检测相关寄存器
    reg                    i_start_r0;
    reg                    i_start_r1;
    reg                    start;
    
    // 读写字节数寄存器
    reg      [2 :0]        iic_written_slace_addr_cnt;  // 从机地址字节数寄存器
    reg      [2 :0]        iic_written_reg_addr_cnt;    // 寄存器地址字节数寄存器
    reg      [31:0]        iic_rw_data_cnt;             // 读写数据字节数寄存器，单位为字节
    

    // IIC操作相关寄存器
    reg      [5 :0]        iic_atom_opt;               // 当前IIC操作
    // reg                    iic_atom_start;             // 发送起始条件标志  // IIC操作的触发应该由命令的变化自行触发
    wire                   iic_atom_done;              // 当前IIC操作完成标志，1表示完成，0表示未完成

    // IIC总线相关
    reg                    scl_out;            // SCL输出控制
    reg                    sda_out;            // SDA输出控制
    reg                    sda_oe;             // SDA输出使能，1表示输出，0表示输入

    
    // 三态总线控制
    assign o_scl  = scl_out ? 1'bz : 1'b0;                   // SCL线，输出高电平时为高阻态，输出低电平时为0
    assign io_sda = sda_oe ? (sda_out ? 1'bz : 1'b0) : 1'bz; // SDA线，输出高电平时为高阻态，输出低电平时为0，输入时为高阻态


    // 输入数据寄存
    always @(posedge clk or negedge rst_n) begin                                        
        if(!rst_n) begin
            user_cmd       <= USERCMD_NOTHING;
            slave_addr     <= 10'b0;
            reg_addr       <= 16'b0;
            write_data     <= 8'b0;
            rw_data_len    <= 32'b0;
        end
        else begin
                user_cmd       <= i_user_cmd;
                slave_addr     <= i_slave_addr;
                reg_addr       <= i_reg_addr;
                write_data     <= i_write_data;
                rw_data_len    <= i_rw_data_len;
        end
    end                                    


    // 输出信号寄存
    always @(posedge clk or negedge rst_n) begin                                        
        if(!rst_n) begin
            o_read_data     <= 8'b0;
            o_rw_byte_ready <= 1'b0;
            o_busy          <= 1'b0;
            o_error         <= 1'b0;
        end
        else begin
            o_read_data     <= read_data;
            o_rw_byte_ready <= rw_byte_ready;
            o_busy          <= busy;
            o_error         <= error;
        end                                    
    end

    // 开始信号上升沿检测
    always@(posedge clk) begin                                        
        if(i_start) begin
            i_start_r0 <= i_start;
            i_start_r1 <= i_start_r0;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            start <= 1'b0;
        end
        else begin
            start <= i_start_r1 && !i_start_r0;
        end
    end
 


    /***************************************************************************************
    功能名称：状态机1
    具体说明：状态转移
    ****************************************************************************************/
    always @(posedge clk or negedge rst_n) begin                                        
        if(!rst_n) begin
            current_state <= STATE_IDLE;
        end
        else begin
            current_state <= next_state;
        end                                                                       
    end                                          


    /***************************************************************************************
    功能名称：状态机2
    具体说明：状态转移条件，这里直接根据解析命令完成的控制信号来进行状态转移，如此以完成状态转移的统一
    ****************************************************************************************/
    always @(*) begin
        next_state = STATE_IDLE; // 默认保持当前状态

        case (current_state)
            STATE_IDLE: begin
                if(start) begin
                    next_state = STATE_PARSE_CMD_ADDR;
                end
                else begin
                    next_state = STATE_IDLE;
                end
            end    

            STATE_PARSE_CMD_ADDR: begin
                next_state = STATE_IIC_START;  // 解析命令和地址完成后直接进入发送起始条件状态
            end

            STATE_IIC_START: begin
                if(iic_start_done) begin
                    next_state = STATE_SDND_BYTE;  // 起始条件发送完成后进入写数据状态
                end
                else begin
                    next_state = STATE_IIC_START;  // 起始条件发送未完成继续保持在发送起始条件状态
                end
            end

            STATE_SDND_BYTE: begin
                if(iic_send_byte_done) begin
                    next_state = STATE_SLAVE_ACK;  // 写数据完成后进入等待从设备应答状态
                end
                else begin
                    next_state = STATE_SDND_BYTE;  // 写数据未完成继续保持在写数据状态
                end
            end

            // 组合逻辑里不能给寄存器赋值
            // iic_written_slace_addr_cnt 从机地址字节数寄存器
            // iic_written_reg_addr_cnt   寄存器地址字节数寄存器
            // iic_written_data_cnt       数据字节数寄存器
            STATE_SLAVE_ACK: begin
                if(iic_slave_ack_done) begin
                    if(iic_written_slace_addr_cnt > 0) begin  // 将多地址情况弱化成单地址情况，只要写过一次地址了就认为地址写入完成了
                        next_state = STATE_SDND_BYTE;  // 从设备应答完成后进入写数据状态，继续写入数据或者寄存器地址
                        //iic_written_slace_addr_cnt = iic_written_slace_addr_cnt - 1;  // 从机地址字节数寄存器减1，表示已经写入了一个字节的从机地址了
                    end
                    else if(iic_written_reg_addr_cnt > 0) begin  // 将多地址情况弱化成单地址情况，只要写过一次地址了就认为地址写入完成了
                        next_state = STATE_SDND_BYTE;  // 从设备应答完成后进入写数据状态，继续写入数据或者寄存器地址
                        //iic_written_reg_addr_cnt = iic_written_reg_addr_cnt - 1;  // 寄存器地址字节数寄存器减1，表示已经写入了一个字节的寄存器地址了
                    end
                    else if(iic_rw_data_cnt > 0) begin  // 将多数据情况弱化成单数据情况，只要写过一次数据了就认为数据写入完成了
                        next_state = STATE_SDND_BYTE;  // 从设备应答完成后进入写数据状态，继续写入数据或者寄存器地址
                        //iic_rw_data_cnt = iic_rw_data_cnt - 1;  // 读写数据字节数寄存器减1，表示已经写入了一个字节的读写数据了
                    end
                    else if(iic_written_slave_addr_cnt == 0 && iic_written_reg_addr_cnt == 0 && iic_rw_data_cnt == 0) begin
                        next_state = STATE_IIC_STOP;   // 从设备应答完成后如果没有更多的数据要写了就进入发送停止条件状态，结束通信
                    end
                    else if(user_cmd == USERCMD_READ_SINGLE || user_cmd == USERCMD_READ_BULK) begin
                        next_state = STATE_IIC_RESTART;  // 从设备应答完成后如果是读命令的话就进入发送重复起始条件状态，准备进行读操作了
                    end
                    else begin
                        next_state = STATE_ERR_STOP;  // 从设备应答完成后如果既没有更多的数据要写了又不是读命令的话就进入错误停止状态，结束通信
                    end
                end
                else begin
                    next_state = STATE_SLAVE_ACK;  // 从设备应答未完成继续保持在等待从设备应答状态
                end
            end

            STATE_IIC_RESTART: begin
                if(iic_restart_done) begin
                    next_state = STATE_REV_BYTE;  // 重复起始条件发送完成后进入读数据状态
                end
                else begin
                    next_state = STATE_IIC_RESTART;  // 重复起始条件发送未完成继续保持在发送重复起始条件状态
                end
            end

            STATE_REV_BYTE: begin
                if(iic_rev_byte_done) begin
                    next_state = STATE_MASTER_ACK;  // 读数据完成后进入发送主设备应答状态
                end
                else begin
                    next_state = STATE_REV_BYTE;  // 读数据未完成继续保持在读数据状态
                end
            end


            STATE_MASTER_ACK: begin
                if(iic_master_ack_done) begin
                    if(iic_rw_data_cnt > 0) begin
                        next_state = STATE_REV_BYTE;  // 主设备应答完成后进入读数据状态
                        //iic_rw_data_cnt = iic_rw_data_cnt - 1;  // 读写数据字节数寄存器减1
                    end
                    else begin
                        next_state = STATE_IIC_STOP;  // 主设备应答完成后如果没有更多的数据要读了就进入发送停止条件状态，结束通信
                    end
                end
            end

            STATE_IIC_STOP: begin
                next_state = STATE_IDLE;  // 发送停止条件完成后进入空闲状态，等待下一次通信
            end

            STATE_ERR_STOP: begin
                next_state = STATE_IDLE;  // 错误停止完成后进入空闲状态，等待下一次通信
            end
        endcase
    end

// ------------------------------------------------- 状态机状态处理 START -------------------------------------------------
// STATE_IDLE：空闲状态，该状态下模块处于等待状态，直到接收到启动信号（start）才会进入下一状态，进入下一个状态需要完成的动作：
    // 1. 将用户输入的命令和地址等信息寄存到内部寄存器中，以便后续状态使用
    // 2. 收到起始信号则通知上层模块通信已经开始了，模块忙标志位置1

    /***************************************************************************************
    功能名称：状态机3
    具体说明：进行开始通信的准备工作：将用户输入的命令和地址等信息进行锁存
    ****************************************************************************************/
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fsm_user_cmd    <= 3'b0;
            fsm_slave_addr  <= 10'b0;
            fsm_reg_addr    <= 16'b0;
            fsm_write_data      <= 8'b0;
            fsm_rw_data_len <= 32'b0;
        end
        else if(current_state == STATE_IDLE) begin
            if(start) begin
                fsm_user_cmd    <= user_cmd;
                fsm_slave_addr  <= slave_addr;
                fsm_reg_addr    <= reg_addr;
                fsm_write_data      <= write_data;
                fsm_rw_data_len <= rw_data_len;
            end
            else begin
                fsm_user_cmd    <= fsm_user_cmd;
                fsm_slave_addr  <= fsm_slave_addr;
                fsm_reg_addr    <= fsm_reg_addr;
                fsm_write_data      <= fsm_write_data;
                fsm_rw_data_len <= fsm_rw_data_len;
            end
        end
    end

    /***************************************************************************************
    功能名称：状态机3
    具体说明：进行开始通信的准备工作：收到起始信号则通知上层模块通信已经开始了，模块忙标志位置1
    ****************************************************************************************/
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            busy <= 1'b0;
        end
        else if(current_state == STATE_IDLE) begin
            if(start) begin
                busy <= 1'b1;  // 收到起始信号则通知上层模块通信已经开始了，模块忙标志位置1
            end
            else begin
                busy <= 1'b0;
            end
        end
        else begin
            busy <= busy;  // 其他状态保持不变
        end
    end



// STATE_PARSE_CMD_ADDR: 解析命令和地址状态，完成后直接进入发送起始条件状态，该状态下需要完成的动作：
    // 根据用户命令解析出需要发送的从机地址字节数、寄存器地址字节数和数据字节数，并将这些信息存储到对应的寄存器中，以便后续状态使用
    // 需要配置的信号：
    // iic_written_slace_addr_cnt 从机地址字节数寄存器
    // iic_written_reg_addr_cnt   寄存器地址字节数寄存器
    // iic_rw_data_cnt            读写数据字节数寄存器

    /***************************************************************************************
    功能名称：状态机3
    具体说明：根据用户命令解析出需要发送的从机地址字节数、寄存器地址字节数和数据字节数，并存储到对应的寄存器中
    ****************************************************************************************/
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            iic_written_slace_addr_cnt <= 3'b0;
            iic_written_reg_addr_cnt   <= 3'b0;
            iic_rw_data_cnt            <= 32'b0;
        end
        else if(current_state == STATE_PARSE_CMD_ADDR) begin
            iic_written_slace_addr_cnt <= written_slace_addr_cnt;
            iic_written_reg_addr_cnt   <= written_reg_addr_cnt;
            iic_rw_data_cnt            <= fsm_rw_data_len;
        end
        else if(fsm_user_cmd == USERCMD_WRITE_SINGLE || fsm_user_cmd == USERCMD_WRITE_BULK) begin
            iic_rw_data_cnt        <= 1; 
        end
        else begin
            iic_written_slace_addr_cnt <= iic_written_slace_addr_cnt;
            iic_written_reg_addr_cnt   <= iic_written_reg_addr_cnt;
            iic_rw_data_cnt            <= iic_rw_data_cnt;
        end
    end


// STATE_IIC_START： 发送起始条件状态，该状态下需要完成的动作：
    // 1. 通知IIC操作模块发送起始条件
    // 2. 通知IIC操作模块该准备好发送的数据了

    /***************************************************************************************
    功能名称：状态机3
    具体说明：通知IIC操作模块发送起始条件
    ****************************************************************************************/
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            iic_atom_opt   <= IIC_ATOM_NONE;
            //iic_atom_start <= 1'b0;
        end
        else if(current_state == STATE_IIC_START) begin
            iic_atom_opt   <= IIC_ATOM_START;  // 配置当前IIC操作为发送起始条件
            //iic_atom_start <= 1'b1;            // 通知IIC操作模块发送起始条件
        end
    end

// STATE_SDND_BYTE：发送字节状态，发送字节有三种情况：发送从机地址、发送寄存器地址、发送数据，该状态下需要完成的动作：
    // 1. 通知IIC操作模块发送字节
    // 2. 判断当前发送的字节类型是从机地址、寄存器地址还是数据，控制相应的发送字节数寄存器自减
    // 3. 通知上层模块发送完成了


 
// STATE_SLAVE_ACK：从机应答状态
    // 1. 通知IIC操作模块接收从机应答
    // 2. 判断从机是否应答成功，如果应答成功则通知IIC操作模块准备好发送下一个字节了
    // 3. 通知上层接受完毕了


// STATE_IIC_RESTART：发送重复起始条件状态，该状态下需要完成的动作：
    // 1. 通知IIC操作模块发送重复起始条件
    // 2. 通知上层模块该准备好接受数据了
    // 3. 通知上层模块发送完成了

// STATE_REV_BYTE：接收字节状态，该状态下需要完成的动作：
    // 1. 通知IIC操作模块接收字节
    // 2. 控制读写数据字节数寄存器自减
    // 3. 通知上层模块接受完成


// STATE_MASTER_ACK：主机应答状态
    // 1. 通知IIC操作模块发送主机应答
    // 2. 判断是否还有数据需要读，如果有则通知IIC操作模块准备好接收下一个字节了
    // 3. 通知上层模块发送完成了


// STATE_IIC_STOP：发送停止条件状态，该状态下需要完成的动作：
    // 1. 通知IIC操作模块发送停止条件
    // 2. 通知上层模块通信已经结束了，模块忙标志位置0


// STATE_ERR_STOP：错误停止状态，该状态下需要完成的动作：
    // 1. 通知IIC操作模块发送停止条件
    // 2. 通知上层模块通信已经结束了，模块忙标志位置0
    // 3. 通知上层模块发生了错误，错误标志位置1



// ------------------------------------------------- 状态机状态处理 END ---------------------------------------------------



    


endmodule
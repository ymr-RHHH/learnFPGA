
/************************************************************************************************************
    module name: IIC_common
    module function: IIC common module, including user interface and IIC bus interface               
*************************************************************************************************************/ 


/*
About Design:
    This IIC Protocol module has two abstract layers:
    1. User Interface Layer: This layer provides a simple and intuitive interface for users to interact with
     the IIC protocol. It includes user commands, data input/output, and control signals. Users can easily 
     send commands and data to the IIC bus without worrying about the underlying protocol details.

     User only needs to provide the command, IIC slave address, data to be written (if applicable), and the 
     number of bytes to read/write (if applicable). 

    2. IIC Bus Interface Layer: In this layer, we divide the transmission and reception process of IIC into
     6 atomic operations:
        1. Start Condition Generation: This operation generates the start condition on the IIC bus, which is
         the signal that indicates the beginning of a communication session.

        2. End Condition Generation: This operation generates the end condition on the IIC bus, which is the
         signal that indicates the end of a communication session.

        3. Byte Transmission: This operation handles the transmission of a single byte of data from the master
         to the slave device on the IIC bus.

        4. Byte Reception: This operation handles the reception of a single byte of data from the slave device
         to the master on the IIC bus.

        5. Master sent Acknowledgment: This operation handles the acknowledgment signal sent by the master to 
        the slave device after receiving a byte of data. It indicates whether the master has successfully 
        received the data or not.
        
        6. Master received Acknowledgment: This operation handles the acknowledgment signal received by the 
         master from the slave device after transmitting a byte of data. It indicates whether the slave has 
         successfully received the data or not.

    And this module is used to work in User Interface Layer.
*/


    // IIC user command:
    // USER_CMD_NOTHING   000: do nothing
    // USER_CMD_WRITE     001: IIC write, write single byte to IIC bus
    // USER_CMD_READ      010: IIC read, read single byte from IIC bus
    // USER_CMD_WRITE_MUL 011: IIC write, write multiple bytes to IIC bus
    // USER_CMD_READ_MUL  100: IIC read, read multiple bytes from IIC bus


    // IIC atomic operation command:
    // ATOM_NOTHING       000: do nothing
    // ATOM_START         001: IIC start condition generation
    // ATOM_END           010: IIC end condition generation
    // ATOM_WRITE         011: IIC byte transmission, write a byte to IIC bus
    // ATOM_READ          100: IIC byte reception, read a byte from IIC bus
    // ATOM_MST_SEND_ACK  101: IIC master sent acknowledgment, send an acknowledgment signal to slave device 
    //                         after receiving a byte of data
    // ATOM_MST_RECV_ACK  110: IIC master received acknowledgment, receive an acknowledgment signal from slave
    //                         device after transmitting a byte of data  


module IIC_common(
    input   wire                       clk,
    input   wire                       rst_n,

    // user interface
    input   wire   [2 :0]              i_cmd,             // user command
    input   wire   [7 :0]              i_IIC_addr,        // IIC slave address, compatible with 7-bit addresses and 10-bit addresses
    input   wire   [1 :0]              i_reg_addr_state,  // IIC register address state, 00: no register address, 01: 8-bit register address, 10: 16-bit register address
    input   wire   [9 :0]              i_reg_addr,        // IIC register address, compatible with 8-bit and 16-bit register addresses
    
    input   wire   [7 :0]              i_data,            // user data input
    output  reg    [7 :0]              o_data,            // user data output
    input   wire   [31:0]              i_write_byte_num,  // number of bytes to write, only valid when i_cmd is 011
    input   wire   [31:0]              i_read_byte_num,   // number of bytes to read, only valid when i_cmd is 100

    input   wire                       i_IIC_start_p,     // IIC start signal, when get a rising edge on this signal, the IIC module will start to execute the command given by i_cmd
    output  reg                        o_busy,            // IIC busy flag, only be high when IIC is transmitting or receiving data, otherwise be low
    output  reg                        o_rw_byte_end_p,   // IIC read/write byte end signal, when get a rising edge on this signal, it indicates that the IIC module has finished transmitting or receiving a byte of data.   

    output  reg                        o_iic_error,       // IIC error flag, only be high when IIC transmission or reception error occurs, otherwise be low

    // IIC Bus
    inout   wire                       io_sda,            // IIC data line
    output  wire                       o_scl             // IIC clock line
);



                                                                   
                                                                   
endmodule
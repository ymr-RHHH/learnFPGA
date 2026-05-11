
/*-------------------------------------------------------------------------------------------------------------------
    module name: IIC_atom
    module function: IIC atomic operations module
-------------------------------------------------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------------------------------------------------
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

    And this module is used to work in IIC Bus Interface Layer.

    Infact, if all all devices used standard IIC protocol, this design can be simplified. But in real world,
    so many embedded device use non-standard IIC protocol. Such as ADS1110, a 16-bit ADC. It don't need to 
    send register address when reading or writing data, and the data frame is completely defined in the data 
    manual.

    Of course, we can define a series of commands to cover all the non-standard IIC devices, but it will make
    the user interface layer very complex, and this is just a little question : If we really define a series of 
    commands, the cricuit will very large, it will consume a lot of embedded resources on the FPGA. 
-------------------------------------------------------------------------------------------------------------------*/


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


module IIC_atom#(
    parameter SYSTEM_FREQ = 50_000_000,          // system clock frequency
    parameter IIC_FREQ    = 100_000              // IIC clock frequency;
)
(
    input   wire                       clk,
    input   wire                       rst_n,

    input   wire   [2 :0]              i_atom_cmd,        
    input   wire   [7 :0]              i_data,            
    output  reg    [7 :0]              o_data,            
    input   wire                       i_mst_ack,         
    output  wire                       o_slv_ack,         

    input   wire                       i_IIC_start_p,     
    output  reg                        o_busy,            
    output  reg                        o_next_opt_ready_p,

    output  reg                        o_iic_error,       


    // IIC bus interface
    inout   wire                       io_sda,            
    output  wire                       o_scl             
);

    

endmodule

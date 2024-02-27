----------------------------------------------------------------------------------
-- (c) Rajesh C Panicker, NUS
-- Description : Matrix Multiplication AXI Stream Coprocessor. Based on the orginal AXIS Coprocessor template (c) Xilinx Inc
-- License terms :
-- You are free to use this code as long as you
-- (i) DO NOT post a modified version of this on any public repository;
-- (ii) use it only for educational purposes;
-- (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of any entity.
-- (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
-- (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course EE4218 at the National University of Singapore);
-- (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Definition of Ports
-- ACLK : Synchronous clock
-- ARESETN : System reset, active low
-- S_AXIS_TREADY : Ready to accept data in
-- S_AXIS_TDATA : Data in
-- S_AXIS_TLAST : Optional data in qualifier
-- S_AXIS_TVALID : Data in is valid
-- M_AXIS_TVALID : Data out is valid
-- M_AXIS_TDATA : Data Out
-- M_AXIS_TLAST : Optional data out qualifier
-- M_AXIS_TREADY : Connected slave device is ready to accept data out
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- ACLK : Synchronous clock
-- ARESETN : System reset, active low
-- S_AXIS_TREADY : Ready to accept data in
-- S_AXIS_TDATA : Data in
-- S_AXIS_TLAST : Optional data in qualifier
-- S_AXIS_TVALID : Data in is valid
-- M_AXIS_TVALID : Data out is valid
-- M_AXIS_TDATA : Data Out
-- M_AXIS_TLAST : Optional data out qualifier
-- M_AXIS_TREADY : Connected slave device is ready to accept data out
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity myip_v1_0 is
	port (
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete.
		ACLK          : in std_logic;
		ARESETN       : in std_logic;
		S_AXIS_TREADY : out std_logic;
		S_AXIS_TDATA  : in std_logic_vector(31 downto 0);
		S_AXIS_TLAST  : in std_logic;
		S_AXIS_TVALID : in std_logic;
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TDATA  : out std_logic_vector(31 downto 0);
		M_AXIS_TLAST  : out std_logic;
		M_AXIS_TREADY : in std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

	attribute SIGIS         : string;
	attribute SIGIS of ACLK : signal is "Clk";

end myip_v1_0;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENTITY hw_acc
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which acts as an accumulator
-- 3. After all the inputs have been read, write out the content of 'sum', 'sum+1', 'sum+2', 'sum+3'
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY hw_acc to implement your coprocessor

architecture EXAMPLE of myip_v1_0 is

component matrix_multiply is
	generic (
		width          : integer := 8;        -- width is the number of bits per location
		width2         : integer := 32;       -- width2 is the number of bits per location of RES_RAM
		X_depth_bits   : integer := 9;        -- depth is the number of locations (2^number of address bits) 9
		w_hid_depth_bits   : integer := 4;    
		w_out_depth_bits : integer := 2;
		sigmoid_depth_bits : integer := 8;
		RES_raw_data_bits : integer:= 6;
		RES_depth_bits : integer := 6;  -- 6
		NUMBEER_OF_X_DATA: integer := 448
	
	);
	port (
		clk               : in STD_LOGIC;
		Start             : in STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0.
		Done              : out STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

		X_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> X_RAM.
		X_read_address    : out STD_LOGIC_VECTOR (X_depth_bits - 1 downto 0); -- matrix_multiply_0 -> X_RAM.
		X_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- X_RAM -> matrix_multiply_0.

		w_hid_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> w_hid_RAM.
		w_hid_read_address    : out STD_LOGIC_VECTOR (w_hid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_hid_RAM.
		w_hid_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- w_hid_RAM -> matrix_multiply_0.
		w_hid_read_en2         : out STD_LOGIC; -- matrix_multiply_0 -> w_hid_RAM.
		w_hid_read_address2    : out STD_LOGIC_VECTOR (w_hid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_hid_RAM.
		w_hid_read_data_out2   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- w_hid_RAM -> matrix_multiply_0.

		w_out_read_en         : out STD_LOGIC; 
		w_out_read_address    : out STD_LOGIC_VECTOR (w_out_depth_bits - 1 downto 0); 
		w_out_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); 

		sigmoid_read_en         : out STD_LOGIC; 
		sigmoid_read_address    : out STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); 
		sigmoid_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); 
		sigmoid_read_en2         : out STD_LOGIC; 
		sigmoid_read_address2    : out STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); 
		sigmoid_read_data_out2   : in STD_LOGIC_VECTOR (width - 1 downto 0); 

		RES_write_en      : out STD_LOGIC; -- result RES_RAM.
		RES_write_address : out STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- RES_RAM.
		RES_write_data_in : out STD_LOGIC_VECTOR (width2 - 1 downto 0) -- RES_RAM.
	);

end component;

	component memory_RAM is
		generic (
			width      : integer := 8;
			depth_bits : integer := 2
		);
		port (
			clk           : in STD_LOGIC;
			write_en      : in STD_LOGIC;
			write_address : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
			write_data_in : in STD_LOGIC_VECTOR (width - 1 downto 0);
			read_en       : in STD_LOGIC;
			read_address  : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
			read_data_out : out STD_LOGIC_VECTOR (width - 1 downto 0)
		);
	end component;

    component memory_RAM2 is
        generic (
            width      : integer := 8; -- width is the number of bits per location
            depth_bits : integer := 2 -- depth is the number of locations (2^number of address bits)
        );
        port (
            clk           : in STD_LOGIC;
            write_en      : in STD_LOGIC;
            write_address : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
            write_data_in : in STD_LOGIC_VECTOR (width - 1 downto 0);
            
            read_en       : in STD_LOGIC;
            read_address  : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
            read_data_out : out STD_LOGIC_VECTOR (width - 1 downto 0);
            
            read_en2       : in STD_LOGIC;
            read_address2  : in STD_LOGIC_VECTOR (depth_bits - 1 downto 0);
            read_data_out2 : out STD_LOGIC_VECTOR (width - 1 downto 0)		
        );
    end component;

	-- RAM parameters 
	constant X_depth_bits   : integer := 9;        -- 512 words --> used: 448 words
	constant w_hid_depth_bits   : integer := 4;    -- 16 words
	constant w_out_depth_bits : integer := 2;      -- 4 words
	constant sigmoid_depth_bits : integer := 8;    -- 256 words
	constant RES_depth_bits : integer := 1;        -- 2 words --> each word is 32 bits sending labels equivalent of raw results
	constant width          : integer := 8;        -- all 8-bit data
    constant width2         : integer := 32;
    
    constant RES_raw_data_bits : integer := 6;     -- 128 words --> depth bits of raw data outputs 
    
	-- signals to connect to RAMs 
	signal X_write_en        : STD_LOGIC; -- myip_v1_0 -> X_RAM. To be assigned within myip_v1_0.
	signal X_write_address   : STD_LOGIC_VECTOR (X_depth_bits - 1 downto 0); -- myip_v1_0 -> X_RAM. To be assigned within myip_v1_0.
	signal X_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> X_RAM. To be assigned within myip_v1_0.
	signal X_read_en         : STD_LOGIC; -- matrix_multiply_0 -> X_RAM.
	signal X_read_address    : STD_LOGIC_VECTOR (X_depth_bits - 1 downto 0); -- matrix_multiply_0 -> X_RAM.
	signal X_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- X_RAM -> matrix_multiply_0.
	
	signal w_hid_write_en        : STD_LOGIC; -- myip_v1_0 -> w_hid_RAM. To be assigned within myip_v1_0.
	signal w_hid_write_address   : STD_LOGIC_VECTOR (w_hid_depth_bits - 1 downto 0); -- myip_v1_0 -> w_hid_RAM. To be assigned within myip_v1_0.
	signal w_hid_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> w_hid_RAM. To be assigned within myip_v1_0.
	signal w_hid_read_en         : STD_LOGIC; -- matrix_multiply_0 -> w_hid_RAM.
	signal w_hid_read_address    : STD_LOGIC_VECTOR (w_hid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_hid_RAM.
	signal w_hid_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- w_hid_RAM -> matrix_multiply_0.
	signal w_hid_read_en2         : STD_LOGIC; -- matrix_multiply_0 -> w_hid_RAM.
	signal w_hid_read_address2    : STD_LOGIC_VECTOR (w_hid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_hid_RAM.
	signal w_hid_read_data_out2   : STD_LOGIC_VECTOR (width - 1 downto 0); -- w_hid_RAM -> matrix_multiply_0.	
	
	signal w_out_write_en        : STD_LOGIC; -- myip_v1_0 -> w_out_RAM. To be assigned within myip_v1_0
	signal w_out_write_address   : STD_LOGIC_VECTOR (w_out_depth_bits - 1 downto 0); -- myip_v1_0 -> w_out_RAM. To be assigned within myip_v1_0.
	signal w_out_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> w_out_RAM. To be assigned within myip_v1_0.
	signal w_out_read_en         : STD_LOGIC; -- matrix_multiply_0 -> w_out_RAM.
	signal w_out_read_address    : STD_LOGIC_VECTOR (w_out_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_out_RAM.
	signal w_out_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- w_out_RAM -> matrix_multiply_0.	

	signal sigmoid_write_en        : STD_LOGIC; -- myip_v1_0 -> sigmoid_RAM. To be assigned within myip_v1_0
	signal sigmoid_write_address   : STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); -- myip_v1_0 -> sigmoid_RAM. To be assigned within myip_v1_0.
	signal sigmoid_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> sigmoid_RAM. To be assigned within myip_v1_0.
	signal sigmoid_read_en         : STD_LOGIC; -- matrix_multiply_0 -> sigmoid_RAM.
	signal sigmoid_read_address    : STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> sigmoid_RAM.
	signal sigmoid_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- sigmoid_RAM -> matrix_multiply_0.	
	signal sigmoid_read_en2         : STD_LOGIC; -- matrix_multiply_0 -> sigmoid_RAM.
	signal sigmoid_read_address2    : STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> sigmoid_RAM.
	signal sigmoid_read_data_out2   : STD_LOGIC_VECTOR (width - 1 downto 0); -- sigmoid_RAM -> matrix_multiply_0.
	
	signal RES_write_en      : STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
	signal RES_write_address : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0);-- matrix_multiply_0 -> RES_RAM.
	signal RES_write_data_in : STD_LOGIC_VECTOR (width2 - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
	signal RES_read_en       : STD_LOGIC; -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_address  : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_data_out : STD_LOGIC_VECTOR (width2 - 1 downto 0); -- RES_RAM -> myip_v1_0
	
	signal Start : STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0. To be assigned within myip_v1_0.
	signal Done  : STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS : natural :=  723; 
	constant NUMBEER_OF_X_DATA: natural := 448;
	constant NUMBER_OF_W_HID_DATA: natural := 2**w_hid_depth_bits;
    constant NUMBER_OF_W_OUT_DATA: natural := 3;
    
	-- Total number of output data
	constant NUMBER_OF_OUTPUT_WORDS : natural := 2**RES_depth_bits; 

	type STATE_TYPE is (Idle, Read_Inputs, Compute, Write_Outputs, Write_Buffer);

	signal state : STATE_TYPE;

	-- Counters to store the number inputs read & outputs written.
	signal read_counter  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;   
	signal w_hid_counter : natural range 0 to 7;                           
	signal write_counter : natural range 0 to NUMBER_OF_OUTPUT_WORDS;      
	
	signal write_flag: STD_LOGIC := '0'; --write output flag               

	
begin
	
	-- EN_Manager process is meant for combinational logic
    EN_Manager: process (state, read_counter, Start, write_flag, S_AXIS_TVALID, write_counter, RES_read_data_out, M_AXIS_TREADY) is
    begin
        case (state) is
            
            -- Initialise en and outputs to 0
            when Idle => 
                X_write_en <= '0';
                w_hid_write_en <= '0';
                w_out_write_en <= '0';
                sigmoid_write_en <= '0';
                RES_read_en <= '0';
                RES_read_address <= (others => '0');	
                M_AXIS_TDATA(31 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
   
            -- Read_Inputs: myip to master signals all 0
            when Read_Inputs =>
                M_AXIS_TDATA(31 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
                if (read_counter = NUMBER_OF_INPUT_WORDS-1) then   
                    X_write_en <= '0';
                    w_hid_write_en <= '0';
                    w_out_write_en <= '0';
                    sigmoid_write_en <= '1';
                    RES_read_en <= '0';
                    RES_read_address <= (others => '0');
                else 
                    if (read_counter >= 0 and read_counter <= NUMBEER_OF_X_DATA) then   
                        X_write_en <= '1';
                        w_hid_write_en <= '0';
                        w_out_write_en <= '0';
                        sigmoid_write_en <= '0';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');
                    elsif (read_counter >= NUMBEER_OF_X_DATA and read_counter <= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA)) then        
                        X_write_en <= '0';
                        w_hid_write_en <= '1';
                        w_out_write_en <= '0';
                        sigmoid_write_en <= '0';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');  
                    elsif (read_counter >= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA) and read_counter <= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA + NUMBER_OF_W_OUT_DATA)) then   
                        X_write_en <= '0';
                        w_hid_write_en <= '0';
                        w_out_write_en <= '1';
                        sigmoid_write_en <= '0';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');                                       
                    else                                            
                        X_write_en <= '0';
                        w_hid_write_en <= '0';
                        w_out_write_en <= '0';
                        sigmoid_write_en <= '1';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');
                    end if;
                end if;
                 
            when Compute => 
                M_AXIS_TDATA(31 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
                w_out_write_en <= '0';
                if (read_counter = NUMBER_OF_INPUT_WORDS) then
                    sigmoid_write_en <= '1';
                else
                    sigmoid_write_en <= '0';
                end if; 
                
                if (Start = '1') then                     
                    X_write_en <= '0';    
                    w_hid_write_en <= '0';                    
                    RES_read_en <= '0';
                    RES_read_address <= (others => '0');
                else                                        
                    X_write_en <= '0';    
                    w_hid_write_en <= '1';
                    RES_read_en <= '1';
                    RES_read_address <= (others => '0');
                end if;
                
            when Write_Outputs =>                          
                X_write_en <= '0';
                w_hid_write_en <= '0';
                w_out_write_en <= '0';
                sigmoid_write_en <= '0';         
                RES_read_en <= '1';
                RES_read_address <= std_logic_vector(to_unsigned(write_counter, RES_depth_bits));   
                M_AXIS_TDATA<= RES_read_data_out;      
                M_AXIS_TLAST  <= '0';
            
            when Write_Buffer =>                            -- En RES read, M_AXIS_TDATA takes values from RES, Write_counter is address to read from RES
                RES_read_address <= std_logic_vector(to_unsigned(write_counter, RES_depth_bits));
                X_write_en <= '0';
                w_hid_write_en <= '0';
                w_out_write_en <= '0';
                sigmoid_write_en <= '0';
                RES_read_en <= '1';               
                M_AXIS_TDATA<= RES_read_data_out;   
                
                if (M_AXIS_TREADY = '1') then
                    if (write_counter = NUMBER_OF_OUTPUT_WORDS) then        --TLAST asserted to end stop writing to Master when all of the data from RES has been written to Master
                        M_AXIS_TLAST <= '1';
                    else
                        M_AXIS_TLAST <= '0';
                    end if;
                else
                    M_AXIS_TLAST <= '0';
                end if;
        end case;     
    end process;
    
    
	The_SW_accelerator : process (ACLK) is
	begin
		if ACLK'EVENT and ACLK = '1' then -- Rising clock edge
			if ARESETN = '0' then -- Synchronous reset (active low)
				state        <= Idle;
			else
				case state is
					when Idle => 
					    -- Init Values to 0 --
						Start <= '0';
						read_counter <= 0;
						
						write_counter <= 0;
						S_AXIS_TREADY <= '0';
						write_flag <= '0';
						M_AXIS_TVALID <= '0';
						-- If ready to read, goes into read state --
						if (S_AXIS_TVALID = '1') then
							state       <= Read_Inputs;
							S_AXIS_TREADY <= '1'; 
							-- start receiving data once you go into Read_Inputs
						end if;

					when Read_Inputs => 
						S_AXIS_TREADY <= '1';
						if (S_AXIS_TVALID = '1') then
						      M_AXIS_TVALID <= '0';
                            
							if (read_counter = NUMBER_OF_INPUT_WORDS-1) then             
                                sigmoid_write_address <= std_logic_vector(to_unsigned((read_counter - (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA + NUMBER_OF_W_OUT_DATA)), sigmoid_depth_bits));
                                sigmoid_write_data_in <= S_AXIS_TDATA(7 downto 0);
                                read_counter <= read_counter + 1;
                                state         <= Compute;                                    	-- move on to next state
                                S_AXIS_TREADY <= '0';
							else                                                 
							    if (read_counter <= NUMBEER_OF_X_DATA - 1) then    
								    X_write_address <= std_logic_vector(to_unsigned(read_counter, X_depth_bits));	
								    w_hid_write_address <= (others =>'0');
								    X_write_data_in <= S_AXIS_TDATA(7 downto 0);
								    read_counter <= read_counter + 1;
								    
								elsif (read_counter >= NUMBEER_OF_X_DATA and read_counter <= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA) - 1) then
								    if ((read_counter - NUMBEER_OF_X_DATA) mod 2 = 0) then   
								            w_hid_write_address <= std_logic_vector(to_unsigned((w_hid_counter), w_hid_depth_bits));
								            w_hid_write_data_in <= S_AXIS_TDATA(7 downto 0);
								            read_counter <= read_counter + 1;	
								    else
								            w_hid_write_address <= std_logic_vector(to_unsigned((w_hid_counter + 8), w_hid_depth_bits));
								            w_hid_write_data_in <= S_AXIS_TDATA(7 downto 0);
								            read_counter <= read_counter + 1;	
								            w_hid_counter <= w_hid_counter + 1; 					        							    
								    end if; 
                                
                                
                                elsif (read_counter >= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA) and read_counter <= (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA + NUMBER_OF_W_OUT_DATA) - 1) then
                                    w_out_write_address <= std_logic_vector(to_unsigned((read_counter - (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA)), w_out_depth_bits));
                                    w_out_write_data_in <= S_AXIS_TDATA(7 downto 0);
                                    read_counter <= read_counter + 1; 
                                else 	    				
                                    sigmoid_write_address <= std_logic_vector(to_unsigned((read_counter - (NUMBEER_OF_X_DATA + NUMBER_OF_W_HID_DATA + NUMBER_OF_W_OUT_DATA)), sigmoid_depth_bits));	
                                    sigmoid_write_data_in <= S_AXIS_TDATA(7 downto 0);			    
								    read_counter <= read_counter + 1; 
                                end if;
							end if;
							
						end if;

					when Compute => 
						-- Coprocessor function to be implemented (matrix multiply) should be here. 
						read_counter <= 0;
						Start <= '1';				-- Start = '1' -> computation using matrix_multiply begins		   
						if (Done = '1') then        -- Done = '1' matrix_multiply operations ended, state goes to write_output
						  Start <= '0';
						  state <= Write_outputs;
                        end if;
						
						-- 3 Clock cycles needed: output -> Buffer -> output [then increment carried out]
					when Write_Outputs => 
					    if (M_AXIS_TREADY = '1') then                
                           if (write_flag = '0') then                --write flag init as 0, goes to buffer, allows for res_address and Tdata to be updated for fist and subsequent values
                               M_AXIS_TVALID <= '0';
                               state <= Write_Buffer;
                           else 
                               M_AXIS_TVALID <= '1';
                               write_counter <= write_counter + 1;   -- Increment write counter, holds write flag as '1' and goes back to buffer
                               state <= Write_Buffer;
                           end if;
                       end if;

                   when Write_Buffer =>
                        M_AXIS_TVALID <= '0';
					    if (M_AXIS_TREADY = '1') then
                            if (write_counter = NUMBER_OF_OUTPUT_WORDS) then    -- goes back to idle once write counter = number of output words -> this ensures that all data has been written by allowing 1 more clock cycle
                                state <= Idle;
                            else
                                if (write_flag = '0') then          --Buffer state -> go back to write, with write flag = '1'
                                    write_flag <= '1';
                                    state <= Write_Outputs;
                                else
                                    write_flag <= '0';              --Buffer state -> for change tdata to be updated with new address -> goes back to write with write flag = '0'
                                    state <= write_outputs;
                                end if;
                            end if;
                        end if;
                        
				end case;
			end if;
		end if;
	end process The_SW_accelerator;
        
	-- Connection to sub-modules

	X_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => X_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => X_write_en, 
			write_address => X_write_address, 
			write_data_in => X_write_data_in, 
			read_en       => X_read_en, 
			read_address  => X_read_address, 
			read_data_out => X_read_data_out
		);

	w_hid_RAM : memory_RAM2
		generic map(
		width      => width, 
		depth_bits => w_hid_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => w_hid_write_en, 
			write_address => w_hid_write_address, 
			write_data_in => w_hid_write_data_in, 
			
			read_en       => w_hid_read_en, 
			read_address  => w_hid_read_address, 
			read_data_out => w_hid_read_data_out,

			read_en2       => w_hid_read_en2, 
			read_address2  => w_hid_read_address2, 
			read_data_out2 => w_hid_read_data_out2
		);

	w_out_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => w_out_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => w_out_write_en, 
			write_address => w_out_write_address, 
			write_data_in => w_out_write_data_in, 
			read_en       => w_out_read_en, 
			read_address  => w_out_read_address, 
			read_data_out => w_out_read_data_out
		);

	sigmoid_RAM : memory_RAM2
		generic map(
		width      => width, 
		depth_bits => sigmoid_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => sigmoid_write_en, 
			write_address => sigmoid_write_address, 
			write_data_in => sigmoid_write_data_in, 
			
			read_en       => sigmoid_read_en, 
			read_address  => sigmoid_read_address, 
			read_data_out => sigmoid_read_data_out,

			read_en2       => sigmoid_read_en2, 
			read_address2  => sigmoid_read_address2, 
			read_data_out2 => sigmoid_read_data_out2

		);
	
	RES_RAM : memory_RAM
		generic map(
		width      => width2, 
		depth_bits => RES_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => RES_write_en, 
			write_address => RES_write_address, 
			write_data_in => RES_write_data_in, 
			read_en       => RES_read_en, 
			read_address  => RES_read_address, 
			read_data_out => RES_read_data_out
		);

	matrix_multiply_0 : matrix_multiply
		generic map(
		width          => width, 
		width2         => width2,
		X_depth_bits   => X_depth_bits, 
		w_hid_depth_bits   => w_hid_depth_bits, 
		w_out_depth_bits => w_out_depth_bits,
		sigmoid_depth_bits => sigmoid_depth_bits,
		RES_raw_data_bits => RES_raw_data_bits,
		RES_depth_bits => RES_depth_bits,
		NUMBEER_OF_X_DATA => NUMBEER_OF_X_DATA
		)
		port map(
			clk               => ACLK, 
			Start             => Start, 
			Done              => Done, 

			X_read_en         => X_read_en, 
			X_read_address    => X_read_address, 
			X_read_data_out   => X_read_data_out, 

			w_hid_read_en         => w_hid_read_en, 
			w_hid_read_address    => w_hid_read_address, 
			w_hid_read_data_out   => w_hid_read_data_out, 

			w_hid_read_en2         => w_hid_read_en2, 
			w_hid_read_address2    => w_hid_read_address2, 
			w_hid_read_data_out2   => w_hid_read_data_out2, 

			w_out_read_en         => w_out_read_en, 
			w_out_read_address    => w_out_read_address, 
			w_out_read_data_out   => w_out_read_data_out, 

			sigmoid_read_en         => sigmoid_read_en, 
			sigmoid_read_address    => sigmoid_read_address, 
			sigmoid_read_data_out   => sigmoid_read_data_out, 

			sigmoid_read_en2         => sigmoid_read_en2, 
			sigmoid_read_address2    => sigmoid_read_address2, 
			sigmoid_read_data_out2   => sigmoid_read_data_out2, 

			RES_write_en      => RES_write_en, 
			RES_write_address => RES_write_address, 
			RES_write_data_in => RES_write_data_in
		);

	end architecture EXAMPLE;
-- Final ver

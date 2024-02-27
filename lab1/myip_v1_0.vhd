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
			width          : integer := 8;
			A_depth_bits   : integer := 3;
			B_depth_bits   : integer := 2;
			RES_depth_bits : integer := 1
		);
		port (
			clk               : in STD_LOGIC;
			Start             : in STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0.
			Done              : out STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

			A_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> A_RAM.
			A_read_address    : out STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- matrix_multiply_0 -> A_RAM.
			A_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- A_RAM -> matrix_multiply_0.

			B_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> B_RAM.
			B_read_address    : out STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- matrix_multiply_0 -> B_RAM.
			B_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- B_RAM -> matrix_multiply_0.

			RES_write_en      : out STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
			RES_write_address : out STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
			RES_write_data_in : out STD_LOGIC_VECTOR (width - 1 downto 0) -- matrix_multiply_0 -> RES_RAM.
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

	-- RAM parameters for assignment 1
	constant A_depth_bits   : integer := 3; -- 8 elements (A is a 2x4 matrix)
	constant B_depth_bits   : integer := 2; -- 4 elements (B is a 4x1 matrix)
	constant RES_depth_bits : integer := 1; -- 2 elements (RES is a 2x1 matrix)
	constant width          : integer := 8; -- all 8-bit data

	-- signals to connect to RAMs and matrix_multiply_0 for assignment 1
	signal A_write_en        : STD_LOGIC; -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_write_address   : STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> A_RAM. To be assigned within myip_v1_0.
	signal A_read_en         : STD_LOGIC; -- matrix_multiply_0 -> A_RAM.
	signal A_read_address    : STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); -- matrix_multiply_0 -> A_RAM.
	signal A_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- A_RAM -> matrix_multiply_0.
	signal B_write_en        : STD_LOGIC; -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_write_address   : STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_write_data_in   : STD_LOGIC_VECTOR (width - 1 downto 0); -- myip_v1_0 -> B_RAM. To be assigned within myip_v1_0.
	signal B_read_en         : STD_LOGIC; -- matrix_multiply_0 -> B_RAM.
	signal B_read_address    : STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); -- matrix_multiply_0 -> B_RAM.
	signal B_read_data_out   : STD_LOGIC_VECTOR (width - 1 downto 0); -- B_RAM -> matrix_multiply_0.
	signal RES_write_en      : STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
	signal RES_write_address : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0);-- matrix_multiply_0 -> RES_RAM.
	signal RES_write_data_in : STD_LOGIC_VECTOR (width - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
	signal RES_read_en       : STD_LOGIC; -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_address  : STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- myip_v1_0 -> RES_RAM. To be assigned within myip_v1_0.
	signal RES_read_data_out : STD_LOGIC_VECTOR (width - 1 downto 0); -- RES_RAM -> myip_v1_0

	-- signals to connect to matrix_multiply for assignment 1
	signal Start : STD_LOGIC; -- myip_v1_0 -> matrix_multiply_0. To be assigned within myip_v1_0.
	signal Done  : STD_LOGIC; -- matrix_multiply_0 -> myip_v1_0.

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS : natural :=  2**A_depth_bits + 2**B_depth_bits; -- 2**A_depth_bits + 2**B_depth_bits = 12 for assignment 1

	-- Total number of output data
	constant NUMBER_OF_OUTPUT_WORDS : natural := 2**RES_depth_bits; -- 2**RES_depth_bits = 2 for assignment 1

	type STATE_TYPE is (Idle, Read_Inputs, Compute, Write_Outputs, Write_Buffer);

	signal state : STATE_TYPE;

	-- Accumulator to hold sum of inputs read at any point in time
	-- signal sum : std_logic_vector(31 downto 0);

	-- Counters to store the number inputs read & outputs written.
	-- Could be done using the same counter if reads and writes are not overlapped (i.e., no dataflow optimization)
	-- Left as separate for ease of debugging
	signal read_counter  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
	signal write_counter : natural range 0 to NUMBER_OF_OUTPUT_WORDS; -- Changed to hold a val of 2 max
	
	signal write_flag: STD_LOGIC := '0'; --write output flag 

	
begin
	-- CAUTION:
	-- The sequence in which data are read in and written out should be
	-- consistent with the sequence they are written and read in the driver's hw_acc.c file
    EN_Manager: process (state, read_counter, Start, write_flag, S_AXIS_TVALID, write_counter, RES_read_data_out, M_AXIS_TREADY) is
    begin
        case (state) is
            -- Init en and outputs to 0
            when Idle => 
                A_write_en <= '0';
                B_write_en <= '0';
                RES_read_en <= '0';
                M_AXIS_TVALID <= '0';    
                RES_read_address <= (others => '0');	
                M_AXIS_TDATA(7 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
                B_write_address <= (others => '0');	   
            -- Read_Inputs: myip to master signals all 0
            when Read_Inputs =>
                M_AXIS_TVALID <= '0';
                M_AXIS_TDATA(7 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
                if (read_counter = NUMBER_OF_INPUT_WORDS-1) then    --Still allow B to written even when it is set to transit to compute state, will be reseted on next clock cycle
                    A_write_en <= '0';
                    B_write_en <= '1';
                    RES_read_en <= '0';
                    RES_read_address <= (others => '0');
                    B_write_address <= std_logic_vector(to_unsigned(read_counter,B_depth_bits));
                else 
                    if (read_counter <= 2**A_depth_bits - 1) then   --En write to A ram for all of A elements
                        A_write_en <= '1';
                        B_write_en <= '0';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');
                        B_write_address <= (others => '0');	                    
                    elsif (read_counter = 2**A_depth_bits) then     --En write A still enabled for A to comeplete writing, En write to B enable for first element of B
                        A_write_en <= '1';
                        B_write_en <= '1';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');
                        B_write_address <= std_logic_vector(to_unsigned((read_counter - 2**A_depth_bits), B_depth_bits));	
                    else                                            --En write B for all of B elements
                        A_write_en <= '0';
                        B_write_en <= '1';
                        RES_read_en <= '0';
                        RES_read_address <= (others => '0');
                        B_write_address <= std_logic_vector(to_unsigned((read_counter - 2**A_depth_bits), B_depth_bits));	
                    end if;
                end if;
                 
            when Compute => 
                M_AXIS_TVALID <= '0';
                M_AXIS_TDATA(7 downto 0) <= (others => '0');
                M_AXIS_TLAST  <= '0';
                B_write_address <= (others => '0');	 
                
                if (Start = '1') then                       -- Enter Matrix Mul module, all write En '0'
                    A_write_en <= '0';    
                    B_write_en <= '0';
                    RES_read_en <= '0';
                    RES_read_address <= (others => '0');
                else                                        -- En writing for B for first cycle entering compute, En RES read to preport for write output reading from RES
                    A_write_en <= '0';    
                    B_write_en <= '1';
                    RES_read_en <= '1';
                    RES_read_address <= (others => '0');
                end if;
                
            when Write_Outputs =>                           -- En RES read, M_AXIS_TDATA takes values from RES, Write_counter is address to read from RES
                A_write_en <= '0';
                B_write_en <= '0';
                RES_read_en <= '1';
                RES_read_address <= std_logic_vector(to_unsigned(write_counter, RES_depth_bits));   
                M_AXIS_TDATA(7 downto 0) <= RES_read_data_out;      
                M_AXIS_TLAST  <= '0';
                B_write_address <= (others => '0');	 
                if (write_flag = '1') then                  -- Write_flag enables M_AXIS_TVALID '1' only when DATA is ready to be presented to testbench(Master)
                    M_AXIS_TVALID <= '1';
                else 
                    M_AXIS_TVALID <= '0';
                end if;
            
            when Write_Buffer =>                            -- En RES read, M_AXIS_TDATA takes values from RES, Write_counter is address to read from RES
                RES_read_address <= std_logic_vector(to_unsigned(write_counter, RES_depth_bits));
                M_AXIS_TVALID <= '0';
                A_write_en <= '0';
                B_write_en <= '0';
                RES_read_en <= '1';               
                M_AXIS_TDATA(7 downto 0) <= RES_read_data_out;     
                B_write_address <= (others => '0');	 
                
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
		-- implemented as a single-process Moore machine
		-- a Mealy machine that asserts S_AXIS_TREADY and captures S_AXIS_TDATA etc can save a clock cycle
		if ACLK'EVENT and ACLK = '1' then -- Rising clock edge
			if ARESETN = '0' then -- Synchronous reset (active low)
				-- CAUTION: make sure your reset polarity is consistent with the system reset polarity
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
						-- If ready to read, goes into read state --
						if (S_AXIS_TVALID = '1') then
							state       <= Read_Inputs;
							S_AXIS_TREADY <= '1'; 
							-- start receiving data once you go into Read_Inputs
						end if;

					when Read_Inputs => 
						S_AXIS_TREADY <= '1';
						if (S_AXIS_TVALID = '1') then
							-- Coprocessor function (adding the numbers together) happens here (partly)
							-- If we are expecting a variable number of words, we should make use of S_AXIS_TLAST.
							-- Since the number of words we are expecting is fixed, we simply count and receive 
							-- the expected number (NUMBER_OF_INPUT_WORDS) instead.
							if (read_counter = NUMBER_OF_INPUT_WORDS-1) then     -- Once correct number of input written to rams, goes to compute state, allow last data for B ram to be written
                                B_write_data_in <= S_AXIS_TDATA(7 downto 0);
                                state         <= Compute;                                    	-- move on to next state
                                S_AXIS_TREADY <= '0';
							else                                                 -- Write inputs from Memory into A ram and B ram accordingly
							    if (read_counter <= 2**A_depth_bits - 1) then    -- Condition for A Ram, where 2**A_depth_bits is the no. of elements for A
								    A_write_address <= std_logic_vector(to_unsigned(read_counter, A_depth_bits));	-- convert natural number to std_logic_vector (increment A_write_address)
								    read_counter <= read_counter + 1;
								    A_write_data_in <= S_AXIS_TDATA(7 downto 0);
                                else 	    								    
								    B_write_data_in <= S_AXIS_TDATA(7 downto 0);
								    read_counter <= read_counter + 1; 
                                end if;
							end if;
						end if;

					when Compute => 
						-- Coprocessor function to be implemented (matrix multiply) should be here. Right now, nothing happens here.
						read_counter <= 0;
						Start <= '1';				-- Start = '1' -> computation using matrix_multiply begins		   
						if (Done = '1') then        -- Done = '1' matrix_multiply operations ended, state goes to write_output
						  Start <= '0';
						  state <= Write_outputs;
                        end if;
						-- Possible to save a cycle by asserting M_AXIS_TVALID and presenting M_AXIS_TDATA just before going into 
						-- Write_Outputs state. However, need to adjust write_counter limits accordingly
						-- Alternatively, M_AXIS_TVALID and M_AXIS_TDATA can be asserted combinationally to save a cycle.
						
						-- 3 Clock cycles needed: output -> Buffer -> output [then increment carried out]
					when Write_Outputs => 
					    if (M_AXIS_TREADY = '1') then                
                           if (write_flag = '0') then                --write flag init as 0, goes to buffer, allows for res_address and Tdata to be updated for fist and subsequent values
                               state <= Write_Buffer;
                           else 
                               write_counter <= write_counter + 1;   -- Increment write counter, holds write flag as '1' and goes back to buffer
                               state <= Write_Buffer;
                           end if;
                       end if;
				       
                   when Write_Buffer =>
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
        
	-- Connection to sub-modules / components for assignment 1

	A_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => A_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => A_write_en, 
			write_address => A_write_address, 
			write_data_in => A_write_data_in, 
			read_en       => A_read_en, 
			read_address  => A_read_address, 
			read_data_out => A_read_data_out
		);
	
	B_RAM : memory_RAM
		generic map(
		width      => width, 
		depth_bits => B_depth_bits
		)
		port map(
			clk           => ACLK, 
			write_en      => B_write_en, 
			write_address => B_write_address, 
			write_data_in => B_write_data_in, 
			read_en       => B_read_en, 
			read_address  => B_read_address, 
			read_data_out => B_read_data_out
		);
	
	RES_RAM : memory_RAM
		generic map(
		width      => width, 
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
		A_depth_bits   => A_depth_bits, 
		B_depth_bits   => B_depth_bits, 
		RES_depth_bits => RES_depth_bits
		)
		port map(
			clk               => ACLK, 
			Start             => Start, 
			Done              => Done, 

			A_read_en         => A_read_en, 
			A_read_address    => A_read_address, 
			A_read_data_out   => A_read_data_out, 

			B_read_en         => B_read_en, 
			B_read_address    => B_read_address, 
			B_read_data_out   => B_read_data_out, 

			RES_write_en      => RES_write_en, 
			RES_write_address => RES_write_address, 
			RES_write_data_in => RES_write_data_in
		);

	end architecture EXAMPLE;
-- Final ver

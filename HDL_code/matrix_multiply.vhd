----------------------------------------------------------------------------------
-- (c) Rajesh C Panicker, NUS
-- Description : Template for the Matrix Multiply unit for the AXI Stream Coprocessor
-- License terms :
-- You are free to use this code as long as you
-- (i) DO NOT post a modified version of this on any public repository;
-- (ii) use it only for educational purposes;
-- (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of any entity.
-- (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
-- (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course EE4218 at the National University of Singapore);
-- (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity matrix_multiply is
	generic (
		width          : integer := 8; -- width is the number of bits per location
		width2         : integer := 32;
		X_depth_bits   : integer := 9; -- depth is the number of locations (2^number of address bits) 9
		w_hid_depth_bits   : integer := 4; -- 3
		w_out_depth_bits : integer := 2;
		sigmoid_depth_bits : integer := 8;
		RES_raw_data_bits : integer := 6;
		RES_depth_bits : integer := 1;  -- 6
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

		w_out_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> w_out_RAM.
		w_out_read_address    : out STD_LOGIC_VECTOR (w_out_depth_bits - 1 downto 0); -- matrix_multiply_0 -> w_out_RAM.
		w_out_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- w_out_RAM -> matrix_multiply_0.

		sigmoid_read_en         : out STD_LOGIC; -- matrix_multiply_0 -> sigmoid_RAM.
		sigmoid_read_address    : out STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> sigmoid_RAM.
		sigmoid_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- sigmoid_RAM -> matrix_multiply_0.
		sigmoid_read_en2         : out STD_LOGIC; -- matrix_multiply_0 -> sigmoid_RAM.
		sigmoid_read_address2    : out STD_LOGIC_VECTOR (sigmoid_depth_bits - 1 downto 0); -- matrix_multiply_0 -> sigmoid_RAM.
		sigmoid_read_data_out2   : in STD_LOGIC_VECTOR (width - 1 downto 0); -- sigmoid_RAM -> matrix_multiply_0.

		RES_write_en      : out STD_LOGIC; -- matrix_multiply_0 -> RES_RAM.
		RES_write_address : out STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); -- matrix_multiply_0 -> RES_RAM.
		RES_write_data_in : out STD_LOGIC_VECTOR (width2 - 1 downto 0) -- matrix_multiply_0 -> RES_RAM.
	);

end matrix_multiply;

architecture arch_matrix_multiply of matrix_multiply is

    component just_matrix_multiply is
        generic (
            width          : integer := 8; -- width is the number of bits per location
            A_depth_bits   : integer := 9; -- depth is the number of locations (2^number of address bits) 9
            B_depth_bits   : integer := 3; -- 3
            RES_depth_bits : integer := 6;  -- 6
            A_address_words: integer := 448;
            B_address_words: integer := 16;
            index_shift: integer := 1
        );
        port (
            clk               : in STD_LOGIC;
            Start             : in STD_LOGIC; 
            Done              : out STD_LOGIC; 
    
            A_read_en         : out STD_LOGIC; 
            A_read_address    : out STD_LOGIC_VECTOR (A_depth_bits - 1 downto 0); 
            A_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); 
    
            B_read_en         : out STD_LOGIC; 
            B_read_address    : out STD_LOGIC_VECTOR (B_depth_bits - 1 downto 0); 
            B_read_data_out   : in STD_LOGIC_VECTOR (width - 1 downto 0); 
    
            RES_write_en      : out STD_LOGIC; 
            RES_write_address : out STD_LOGIC_VECTOR (RES_depth_bits - 1 downto 0); 
            RES_write_data_in : out STD_LOGIC_VECTOR (width - 1 downto 0) 
        );
    end component;
    
    -- just_matrix_multiply operation signals
    -- (X) x (hidden layer) calculation without bias 
    constant index_shift1: integer:= 1;     -- shift the index to read a different set of inputs from just_matrix_multiply        
    constant index_shift2: integer:= 9;     
    signal matmul_start: std_logic;         -- start signal for just_matrix_multiply
    signal matmul_done: std_logic;          -- signal goes HIGH when matrix multiply operation is done
    signal matmul_result_signal: std_logic; -- signal when a value is computed
      
    -- result of neuron 1 and neuron 2
    signal matmul1_results: std_logic_vector(width-1 downto 0);
    signal matmul2_results: std_logic_vector(width-1 downto 0);
    
    -- state machine declaration
    type STATE_TYPE is (Idle, Get_required_weights, Output_calculation);
    signal state: STATE_TYPE;
    
    -- sum of (sigmoid x output layer)  
    signal sum: std_logic_vector(width*2 - 1 downto 0);     -- (sigmoid x output_layer) values

    -- hidden layer signal declarations
    signal w_hid_read_en_reg: std_logic;  
    signal w_hid_read_en_reg2: std_logic;  
    signal w_hid_read_en_bias: std_logic;  
    signal w_hid_read_address_reg: std_logic_vector(w_hid_depth_bits - 1 downto 0);
    signal w_hid_read_address_reg2: std_logic_vector(w_hid_depth_bits - 1 downto 0);
    type w_hid_bias_array is array (0 to 1) of std_logic_vector(width - 1 downto 0);
    signal w_hid_bias_data : w_hid_bias_array;
    
    -- output layer signal declarations
    signal w_out_address_counter: natural range 0 to 3;
    signal RES_result_counter: natural range 0 to 64;
    type w_out_array is array (0 to 2) of std_logic_vector(width - 1 downto 0);
    signal w_out_data : w_out_array;
    
    -- signal goes HIGH to declare that sigmoid equivalent is ready
    signal sigmoid_result_ready: std_logic;   
    signal sum_result_ready: std_logic;   
    
    signal RES_output_values: STD_LOGIC_VECTOR (width - 1 downto 0);
    signal labels: std_logic;
    signal labels_dummy: std_logic_vector(width2 -1 downto 0);
    signal RES_write_index: natural range 0 to 65;
    signal RES_index_ready: std_logic;
begin
    
    -- enable to start just_matrix_multiply
    matmul_start <= '1' when (state = Output_calculation) else '0';     
  
    -- hidden layer combinational logic     
    w_hid_read_en_bias <= '1' when (state = Get_required_weights and w_out_address_counter <2) else '0';
    w_hid_read_en <= w_hid_read_en_reg or w_hid_read_en_bias;  
    w_hid_read_address <=  std_logic_vector(to_unsigned(w_out_address_counter*8, w_hid_depth_bits)) when (state = Get_required_weights and w_out_address_counter <2) else w_hid_read_address_reg;    
    w_hid_read_en2 <= w_hid_read_en_reg2;
    w_hid_read_address2 <= w_hid_read_address_reg2;

    -- output layer combinational logic
    w_out_read_en <= '1' when (state = Get_required_weights and w_out_address_counter <= 2) else '0';
    w_out_read_address <= std_logic_vector(to_unsigned(w_out_address_counter, w_out_depth_bits));
    
    -- sigmoid values combinational logic
    sigmoid_read_en <= '1' when matmul_result_signal = '1' else '0';
    sigmoid_read_en2 <= '1' when matmul_result_signal = '1' else '0';
    sigmoid_read_address <= std_logic_vector(unsigned(w_hid_bias_data(0))+unsigned(matmul1_results)) when (state = Output_calculation and matmul_result_signal = '1') else (others => '0');
    sigmoid_read_address2 <= std_logic_vector(unsigned(w_hid_bias_data(1))+unsigned(matmul2_results)) when (state = Output_calculation and matmul_result_signal = '1') else (others => '0');
    
    -- RES values combinational logic
    RES_write_en <= '1' when (RES_write_index > 0 and RES_write_index mod 32 = 0 and state = Output_calculation) else '0';
    RES_write_address <= (others => '1') when (RES_write_index = 64) else (others => '0');
    
    -- Done signal for overall calculation
    Done <= '1' when (RES_write_index = 65 and Start = '1') else '0';
    
    -- Labels Equivalent of calculation
    labels <= '1' when (RES_output_values > "10000000") else '0';
    
    overall_calculation: process (clk) is
    begin
        if rising_edge (clk) then
            if (Start = '0') then
                state <= Idle; 
                w_out_address_counter <= 0;
                RES_result_counter <= 0;
                RES_write_index <= 0;
            else
                case (state) is
                
                    when Idle =>
                        state <= Get_required_weights;
                        w_out_address_counter <= 0;
                        RES_result_counter <= 0;
                        
                    when Get_required_weights =>      
                        if (w_out_address_counter = 3) then                                             -- if required weights are collected 
                            w_out_data(w_out_address_counter - 1) <= w_out_read_data_out;
                            state <= Output_calculation;
                        else                                                                            -- if required weights are not collected 
                            if (w_out_address_counter > 0 and w_out_address_counter <=2) then
                                w_out_data(w_out_address_counter - 1) <= w_out_read_data_out;
                                w_hid_bias_data(w_out_address_counter - 1) <= w_hid_read_data_out;
                            end if;
                            w_out_address_counter <= w_out_address_counter + 1;
                        end if; 
                        
                    when Output_calculation =>                                                          
                        if (matmul_done = '1') then
                            sigmoid_result_ready <= '0';
                        else                            
                            if (matmul_result_signal = '1') then
                                sigmoid_result_ready <= '1';
                                
                            else
                                sigmoid_result_ready <= '0';
                            end if;
                        end if;
                        
                        if (sigmoid_result_ready = '1') then
                            sum_result_ready <= '1';
                            RES_index_ready <= '1';
                            sum <= std_logic_vector((unsigned(sigmoid_read_data_out) * unsigned(w_out_data(1))) + (unsigned(sigmoid_read_data_out2) * unsigned(w_out_data(2))));
                        else
                            sum_result_ready <= '0';
                            RES_index_ready <= '0';
                        end if;
                        
                        if (sum_result_ready = '1') then
                            RES_output_values <= std_logic_vector(unsigned(w_out_data(0)) + unsigned(sum(15 downto 8)));
                            RES_write_data_in(RES_write_index mod 32) <= labels; 
                            RES_result_counter <= RES_result_counter + 1;
                        else
                            
                        end if;
                        
                        if (RES_index_ready = '1' and RES_result_counter > 0 ) then
                            RES_write_index <= RES_write_index + 1;
                        end if; 
                        
                end case;
            end if;
        end if;
    end process;
    
    -- Calculate neuron 1
    matmul1: just_matrix_multiply 
        generic map (
            width => width,
            A_depth_bits => X_depth_bits,
            B_depth_bits => w_hid_depth_bits,
            RES_depth_bits => RES_raw_data_bits, 
            A_address_words => NUMBEER_OF_X_DATA,
            B_address_words => 7,
            index_shift => index_shift1
        )
        port map (
            clk => clk,
            Start => matmul_start,
            Done => matmul_done,
            
            A_read_en => X_read_en,
            A_read_address => X_read_address,
            A_read_data_out => X_read_data_out,
            
            B_read_en => w_hid_read_en_reg,
            B_read_address => w_hid_read_address_reg,
            B_read_data_out => w_hid_read_data_out,
            
            RES_write_en => matmul_result_signal,
            RES_write_address => open,
            RES_write_data_in => matmul1_results
        ); 
    
    -- Calculate neuron 2
    matmul2: just_matrix_multiply 
        generic map (
            width => width,
            A_depth_bits => X_depth_bits,
            B_depth_bits => w_hid_depth_bits,
            RES_depth_bits => RES_raw_data_bits, 
            A_address_words => NUMBEER_OF_X_DATA,
            B_address_words => 7,
            index_shift => index_shift2
        )
        port map (
            clk => clk,
            Start => matmul_start,
            Done => open,
            
            A_read_en => open,
            A_read_address => open,
            A_read_data_out => X_read_data_out,
            
            B_read_en => w_hid_read_en_reg2,
            B_read_address => w_hid_read_address_reg2,
            B_read_data_out => w_hid_read_data_out2,
            
            RES_write_en => open,
            RES_write_address => open,
            RES_write_data_in => matmul2_results
        );  
       
 

                        
end arch_matrix_multiply;
--Final Ver
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity matrix_multiply is
	generic (
		width          : integer := 8; -- width is the number of bits per location
		A_depth_bits   : integer := 3; -- depth is the number of locations (2^number of address bits)
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

end matrix_multiply;

architecture arch_matrix_multiply of matrix_multiply is

    type STATE_TYPE is (Idle, Buff, Add, Reset);
    signal state: STATE_TYPE;
    
    signal A_address_counter: natural range 0 to (2**A_depth_bits -1);
    signal B_address_counter: natural range 0 to (2**B_depth_bits -1);
    signal RES_address_counter: natural range 0 to (2**RES_depth_bits -1);
    
    
    -- Product and Sum
    signal P: STD_LOGIC_VECTOR (width*2 - 1 downto 0);
    signal sum: STD_LOGIC_VECTOR (width*2 - 1 downto 0);
        
begin
	-- implement the logic to read A_RAM, read B_RAM, do the multiplication and write the results to RES_RAM
	-- Note: A_RAM and B_RAM are to be read synchronously. Read the wiki for more details.
    
    -- connect counters to address
    A_read_address <= STD_LOGIC_VECTOR (to_unsigned(A_address_counter,A_depth_bits));
    B_read_address <= STD_LOGIC_VECTOR (to_unsigned(B_address_counter,B_depth_bits));
    RES_write_address <= std_logic_vector(to_unsigned(RES_address_counter,RES_depth_bits));

    -- Combinational Logic for Enables, Product, Sum and write to Res
    EN_Manager: process (state, RES_address_counter, A_read_data_out, B_read_data_out, sum) is
    begin
            case (state) is
                when Idle => 
                -- When Res has been populated with the outputs from the matrix multiply process,
                -- Done = '1' is asserted to go on to next state in myip
                if (RES_address_counter = 2**RES_depth_bits -1) then    
                    Done <= '1';
                    RES_write_en <= '0';
                    A_read_en <= '0';
                    B_read_en <= '0';  
                    P <= (others=>'0');
                    RES_write_data_in <= (others=>'0');
                else
                    Done <= '0';
                    RES_write_en <= '0';
                    A_read_en <= '0';
                    B_read_en <= '0';  
                    P <= (others=>'0');
                    RES_write_data_in <= (others=>'0');
                end if;
                
                when Buff => 
                    Done <= '0';
                    A_read_en <= '1';
                    B_read_en <= '1';
                    RES_write_en <= '0';
                    P <= (others=>'0');
                    RES_write_data_in <= (others=>'0');
                -- Add state: Product from values from matrix A and B done combinationally and summed by the next clock cycle  
                when Add => 
                    Done <= '0';
                    A_read_en <= '1';
                    B_read_en <= '1';
                    RES_write_en <= '0';
                    P <= std_logic_vector(unsigned(A_read_data_out) * unsigned(B_read_data_out));
                    RES_write_data_in <= (others=>'0');
                -- Reset state: Sum is written to RES ram
                when Reset => 
                    Done <= '0';
                    A_read_en <= '0';
                    B_read_en <= '0';
                    RES_write_en <= '1';   
                    P <= (others=>'0');
                    RES_write_data_in <= sum((width*2)-1 downto 8);
            end case;     
    end process;

    matrix_multiply: process (clk) is
    begin
        if rising_edge(clk) then
            if (Start = '0') then
                state <= Idle;
            else 
                case state is
                    when Idle =>
                        -- Init outputs to 0 -- 
                        A_address_counter <= 0;
                        B_address_counter <= 0;
                        RES_address_counter <= 0;
                        sum <= (others=>'0');
                        state <= Buff;
                    -- Buffer state: Allow for 1 extra clock cycle for values to be updated, sum = sum + 0
                    when Buff =>
                        sum <= std_logic_vector(unsigned(sum) + unsigned(P));
                        State <= Add;
                        
                    -- Add state: P would have been updated, Sum would then be sum = sum + P, 
                    -- Address counters incremented based on whether matrix B column has been fully multiplied
                    -- goes to reset if matrix B column completed, else goes to buff
                    when Add =>
                        sum <= std_logic_vector(unsigned(sum) + unsigned(P));
                        
                        if (B_address_counter = 2**B_depth_bits-1) then
                            A_address_counter <= A_address_counter + 1;
                            state <= Reset;
                        else                        
                            A_address_counter <= A_address_counter + 1;
                            B_address_counter <= B_address_counter + 1;
                            state <= Buff;
                        end if;
                   
                   -- Reset state: sum would be written to RES ram, check if number of outputs have been satisfied
                   -- if satisfied, -> idle, else process restarts for the next row of Matrix A
                    when Reset =>
                        if (RES_address_counter = 2**RES_depth_bits -1) then
                            sum <= (others=>'0');
                            state <= Idle;
                        else
                            RES_address_counter <= RES_address_counter + 1;
                            sum <= (others=>'0');
                            B_address_counter <= 0;
                            state <= Buff;
                        end if;
                end case;
            end if; 
        end if;
    end process;
                        
end arch_matrix_multiply;
--Final Ver

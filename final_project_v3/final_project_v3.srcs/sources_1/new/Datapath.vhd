library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity Datapath is
    
    -- Default values for generic M, H, N and data_size
    generic( M: natural := 3; -- the number of columns of A and rows of B
             H: natural := 4; -- the number of rows of A
             N: natural := 5; -- the number of columns of B
             data_size: natural := 5); -- width of data stored in ROM A
    
    -- Define ports in the datapath         
    Port ( clk             : in STD_LOGIC; -- time sequence
           RAM_write_en    : in STD_LOGIC; -- write enable for RAM
           MACC_enable     : in STD_LOGIC; -- enable for MACC
           MACC_rst        : in STD_LOGIC; -- reset for MACC
           
           -- In terms of address in ROM A and ROM B, width is defined by H, M and N, deduced by considering about the maximum locations needed in the matrix A and B
           ROM_A_address   : in UNSIGNED ((size(H*M-1)-1) downto 0); -- to tell the ROM A from which address to read contents 
           ROM_B_address   : in UNSIGNED ((size(N*M-1)-1) downto 0); -- to tell the ROM B from which address to read contents
           
           -- In terms of address in RAM C, width is defined by H and N, derived by considering about the maximum locations needed
           RAM_C_address   : in UNSIGNED ((size(H*N-1)-1) downto 0); -- to tell the RAM C which address to wrtie contents in and output contents from
           
           -- In terms of how many bits we use to represent output, use size function to calculate how many bits needed to represent maximum value from matrix multiplication
           -- The derivation takes advantage of assuming all products acquired by multiplying two negative values and then sum up
           output_datapath : out STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)) downto 0)); -- to tell the element in which address should be output
end Datapath;

architecture Behavioral of Datapath is

     -- Internal signals in datapath
     -- internal signals related to ROM A and ROM B
     signal data_A, data_B : STD_LOGIC_VECTOR ((data_size-1) downto 0); -- values at corresponding address for ROM A and ROM B
     
     -- internal signals related to single-port RAM
     signal Data_in_ram : STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)) downto 0); -- Output from MACC and input to RAM, which holds the coefficient of matrix C

begin
    
    -- ROM to store values in matrix A
    ROM_A: entity work.asynchronous_read_ROM
    generic map( M => M,
                 H => H,
                 data_size => data_size)
                 
    PORT MAP( address => ROM_A_address,
              Dataout => data_A);
    
    -- ROM to store values in matrix B
    ROM_B: entity work.asynchronous_read_ROMB
    generic map( M => M,
                 N => N,
                 data_size => data_size)
                 
    PORT MAP( address => ROM_B_address,
              Dataout => data_B);   
                 
    -- RAM to store results of matrix C and output from the system
    RAM_C: entity work.RAM
    generic map( M => M,
                 N => N,
                 H => H,
                 data_size => data_size)
                 
    PORT MAP( clk => clk,
              write_en => RAM_write_en,
              Address => RAM_C_address,
              Data_In => Data_in_ram,
              Data_out => output_datapath);
              
    -- MACC to calculate coefficients in matrix C
    MACC: entity work.MACC
    generic map( M => M,
                 data_size => data_size)
                 
    PORT MAP( clk => clk,
              rst => MACC_rst ,
              en => MACC_enable,
              A => data_A,
              B => data_B,
              macc_output => Data_in_ram);
              
end Behavioral;

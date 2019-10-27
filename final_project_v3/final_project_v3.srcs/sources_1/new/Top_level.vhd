library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity Top_level is
    
    ------------------set generic value for N,M,H,data_size-------------------- 
    -- Default values 2*3 matrix A and 3*2 matrix B to define the size of matrices
    generic( M: natural := 3; -- the number of columns of A and rows of B
             N: natural := 5; -- the number of columns of B
             H: natural := 4; -- the number of rows of A
             data_size: natural := 5); -- how many bits of binary number representing the data stored in ROM 
    
    ---------------set inputs and outputs for the matrix multiplication--------   
    -- Define ports in the circuits
    Port ( CLK    : in STD_LOGIC; -- time sequence
           RST    : in STD_LOGIC; -- global reset
           NXT    : in STD_LOGIC; -- enable for the whole circuits
           
           OUTPUT : out STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)) downto 0)); -- equation to calculate how many bits to represent coefficients in matrix C
end Top_level;

architecture Behavioral of Top_level is

    -- Internal signals in the circuits
    signal inv_rst : STD_LOGIC; -- inverted reset signal (compensates active low)
    
    -- internal signals related to debouncer
    signal deb_rst, deb_nxt : STD_LOGIC; -- debounced reset and "next" signals
    
    -- internal signals related to ROM address
    signal address_A: UNSIGNED ((size(H*M-1)-1) downto 0); -- to tell the ROM A from which address to read contents
    signal address_B: UNSIGNED ((size(N*M-1)-1) downto 0); -- to tell the ROM B from which address to read contents
    
    -- store H*M items in matrix A as well as N*M items in matrix B in two ROMs respectively, the loactions in ROM should be larger than N*M and H*M 
    
    -- internal signals related to single-port RAM
    signal address_C : UNSIGNED ((size(H*N-1)-1) downto 0); -- to tell the RAM C which address to wrtie contents in and output contents from
    signal ram_write_en : STD_LOGIC; -- to enable RAM to write value in the corresponding location
    
    -- internal signals related to MACC
    signal rst_macc, en_macc: STD_LOGIC; -- reset and enalbe to control MACC

begin

    -- Inversion of reset signal to compensate for active-low button
    inv_rst <= not RST;
    
    -- Debouncer for (inverted) reset signal)
    Rst_Debouncer: entity work.Debouncer 
    PORT MAP( clk => CLK,
              Sig => inv_rst,
              Deb_Sig => deb_rst);
              
    -- Debouncer for for "NXT" signal
    NXT_Debouncer: entity work.Debouncer
    PORT MAP( clk => CLK,
              Sig => NXT,
              Deb_Sig => deb_nxt);              
                            
    -- Datapath inside the circuits
    Datapath_tp: entity work.Datapath
    PORT MAP( clk => clk,
              RAM_write_en => ram_write_en,
              MACC_enable => en_macc,
              MACC_rst => rst_macc,
              ROM_A_address => address_A,
              ROM_B_address => address_B,
              RAM_C_address => address_C,
              output_datapath => OUTPUT);
              
    -- Control logic providing control signal to datapath
    Control: entity work.Control_logic
    PORT MAP( rst => deb_rst,
              nxt => deb_nxt,
              clk => CLK,
              rst_macc => rst_macc,
              en_macc => en_macc,
              address_romA => address_A,
              address_romB => address_B,
              address_ram => address_C,
              write_en_ram => ram_write_en);
        
end Behavioral;

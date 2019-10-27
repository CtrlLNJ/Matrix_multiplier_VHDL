library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

-- Synchronous write / asynchrounous read single-port RAM
entity RAM is

    -- Default values for generic M, H, N and data_size
    generic( M: natural := 3; -- the number of columns of A and rows of B
             H: natural := 4; -- the number of rows of A
             N: natural := 5; -- the number of columns of B
             data_size: natural := 5); -- width of data stored in ROM A
             
    Port ( clk     : in  STD_LOGIC;
           write_en: in  STD_LOGIC; -- Write enable which allows data written in this RAM
           Data_In : in  STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)) downto 0); -- use function discovered in report to define the width of coefficients in matrix C 
           Address : in  UNSIGNED ((size(H*N-1)-1) downto 0); -- width of the address bus is defined by this equation. details are in report
           
           Data_Out: out STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)) downto 0)); -- use function discovered in report to define the width of coefficients in matrix C
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to (2**log2(H*N)-1)) of STD_LOGIC_VECTOR((size(((2**(data_size - 1))**2)*M)) downto 0);
signal ram_inst: ram_type;

begin

    -- Synchronous write (write enable signal)
    process (clk)
    begin
        if (rising_edge(clk)) then 
            if (write_en='1') then
                ram_inst(to_integer(Address)) <= Data_In;
            end if;
        end if;
    end process;
    
    -- Asynchronous read
    Data_Out <= ram_inst(to_integer(Address)); 
    
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity asynchronous_read_ROM is

    -- Default values for generic M and H and data_size
    generic( M: natural := 3; -- the number of columns of A
             H: natural := 4; -- the number of rows of A
             data_size: natural := 5); -- width of data stored in ROM A
    
    -- Define ports in the circuits        
    Port ( address: in UNSIGNED ((size(H*M-1)-1) downto 0); -- width of the address bus is defined by this equation. details are in report
           
           DataOut: out STD_LOGIC_VECTOR ((data_size-1) downto 0)); -- width of data in ROM A is data_size
           
end asynchronous_read_ROM;

architecture Behavioral of asynchronous_read_ROM is

-- As matrix A is defined as 4*3, there should at least have 12 locations 
-- As calculated, to represent 12 loactions, we could use 5 bits
-- implement matrix in row-first order with the memory
type ROM_Array is array (0 to (2**log2(H*M)-1)) of STD_LOGIC_VECTOR((data_size-1) downto 0);
    constant Content: ROM_Array := ( -- implement values into ROM A in binary and only imlement calues in locations needed
        0 => B"10000", -- -16
        1 => B"10000", -- -16
        2 => B"10000", -- -16
        3 => B"01111", -- 15
        4 => B"01111", -- 15
        5 => B"01111", -- 15
        6 => B"11010", -- -6
        7 => B"01011", -- 11
        8 => B"01010", -- 10
        9 => B"11000", -- -8
        10 => B"00000", -- 0
        11 => B"00001", -- 1
        others => B"00000"); -- for other addresses which are redundant
    
begin
     DataOut <= Content(to_integer(address)); -- Asynchronous read

end Behavioral;

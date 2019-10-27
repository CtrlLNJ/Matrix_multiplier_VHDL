library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity asynchronous_read_ROMB is

    -- Default values for generic M and N and data_size
    generic( M: natural := 3; -- the number of rows of B
             N: natural := 5; -- the number of columns of B
             data_size: natural := 5); -- width of data stored in ROM B which must be the same as ROM A
             
    Port ( address     : in UNSIGNED ((size(N*M-1)-1) downto 0); -- width of the address bus is defined by this equation. details are in report
                        
           DataOut     : out STD_LOGIC_VECTOR ((data_size-1) downto 0)); -- width of data in ROM B is data_size
           
end asynchronous_read_ROMB;

architecture Behavioral of asynchronous_read_ROMB is

-- As matrix B is defined as 3*5, there should at least have 15 locations
-- As calculated, to represent 15 locations, we could use 5 bits
-- implement matrix in row-first order with the memory
type ROM_Array is array (0 to (2**log2(N*M)-1)) of STD_LOGIC_VECTOR((data_size-1) downto 0);
    constant Content: ROM_Array := ( -- implement values into ROM A in binary and only imlement calues in locations needed
        0 => B"10000", -- -16
        1 => B"01111", -- 15
        2 => B"11111", -- -1
        3 => B"11101", -- -3
        4 => B"11010", -- -6
        5 => B"10000", -- -16
        6 => B"01111", -- 15
        7 => B"11110", -- -2
        8 => B"00000", -- 0
        9 => B"01010", -- 10
        10 => B"10000", -- -16
        11 => B"01111", -- 15
        12 => B"00000", -- 0
        13 => B"01000", -- 8
        14 => B"11101", -- -3
        others => B"00000"); -- for other addresses which are redundant
    
begin
     DataOut <= Content(to_integer(address)); -- Asynchronous read

end Behavioral;

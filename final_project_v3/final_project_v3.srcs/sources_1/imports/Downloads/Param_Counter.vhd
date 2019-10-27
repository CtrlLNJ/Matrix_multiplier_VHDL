library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.DigEng.all; -- Library required for log2 function

-- See above for circuit description
entity Param_Counter is
generic (LIMIT : NATURAL := 17);  -- Limit for counter (default set to 17)
port ( clk : in  STD_LOGIC;
       rst : in  STD_LOGIC;  -- Synchronous reset
       en : in  STD_LOGIC;
       -- Counter output - bus size depends on limit (5 bits for default size)
	   --  Size is computed using the log2 function. 
	   --  Refer to library for full function description.
       count_out : out UNSIGNED (log2(LIMIT)-1 downto 0));
end Param_Counter;

architecture Behavioral of Param_Counter is

-- Internal bus for counter output
signal count_int : UNSIGNED (log2(LIMIT)-1 downto 0);

begin

-- Counter to LIMIT (0 to LIMIT-1) with synchronous reset and enable
counter: process (clk)
begin
  if rising_edge(CLK) then 
     if (rst = '1') then 
	     count_int <= (others => '0');
	  elsif (en = '1') then
	     if (count_int = LIMIT-1) then
           count_int <= (others => '0');
		  else
		     count_int <= count_int + 1;
        end if;
     end if;
  end if;
end process counter;

-- Map internal counter value to output
count_out <= count_int;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity MACC is
    
    -- Default values for data_size and M which are used to generate width of coefficient in C
    generic(data_size: natural := 5;
            M: natural := 3);
    
    -- Define ports in MACC
    Port ( clk         : in STD_LOGIC;
           rst         : in STD_LOGIC;
           en          : in STD_LOGIC;
           A           : in STD_LOGIC_VECTOR ((data_size-1) downto 0); -- output from one of the ROM, sending data at current address
           B           : in STD_LOGIC_VECTOR ((data_size-1) downto 0); -- output from another ROM, sending data at current address
           
           macc_output : out STD_LOGIC_VECTOR ((size(((2**(data_size - 1))**2)*M)+1)-1 downto 0)); -- use function discovered in report to define the width of coefficients in matrix C
end MACC;

architecture Behavioral of MACC is
    
    -- Define the internal signals in MACC
    signal result_multi: SIGNED (((data_size)*2)-1 downto 0); -- the result of the multiplication. 
                                                              -- The width to represent the maximum product is described as two times of width of multipliers
    signal result_add  : SIGNED (size(((2**(data_size - 1))**2)*M) downto 0); -- same maximum width as macc_output and acc_input and acc_output
    signal acc_add: STD_LOGIC_VECTOR (size(((2**(data_size - 1))**2)*M) downto 0); -- take the output from ACC as an addend of adder

begin

    -- Design port map and generic map to connect ACC with ports in MACC
    MACC: entity work.ACC -- generate MACC based on ACC
        generic map (data_size => data_size,
                     M => M)
        Port map (input_acc => STD_LOGIC_VECTOR(result_add),
                  en => en,
                  rst => rst,
                  clk => clk,
                  output_acc => acc_add);
                        
    -- Define formula of values for internal signals inside MACC
    -- result_multi is given by values from ROM multiplied by each other
    result_multi <= (signed(A) * signed(B)); 
    -- result_add is given by adding product of current values at current address of ROM A and B and value sent from ACC
    -- initial value sent from ACC is set as 0 by setting output_acc 0           
    result_add <= (result_multi + SIGNED(acc_add));
    -- set the result_add also output of macc
    macc_output <= STD_LOGIC_VECTOR(acc_add);

end Behavioral;

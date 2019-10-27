library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; -- contains size and log2 functions

entity top_level_tb is

end top_level_tb;

architecture Behavioral of top_level_tb is

    -- Set constant as values for changing M,N,H and data_size
    constant M_tb: natural := 3;
    constant N_tb: natural := 5;
    constant H_tb: natural := 4;
    constant data_size_tb: natural := 5;
    
    -- clock period definitions 
    constant clk_period: time := 10ns;
    
    -- Internal signals
    -- Input declaration
    signal CLK : STD_LOGIC;
    signal RST : STD_LOGIC;
    signal NXT : STD_LOGIC;
    
    -- Output declaration
    signal OUTPUT: STD_LOGIC_VECTOR ((size(((2**(data_size_tb - 1))**2)*M_tb)) downto 0);
    
    -- Self-checking testbench to record as a table of test vectors
    -- Self test vector type declaration
    -- Only check if coefficients are computed right
    type test_vector is record
        OUTPUT: STD_LOGIC_VECTOR ((size(((2**(data_size_tb - 1))**2)*M_tb)) downto 0);
    end record;
    
    -- Declare an array of records of the records type
    -- This array holds coefficients existing in matrix C, which are calculated manually
    -- These coefficients are saved as decimal instead of binary numbers
    -- size of this array is defined by calculating how many numbers are in matrix C, which is N_tb*H_tb
    type test_vector_array is array
        (0 to (N_tb*H_tb-1)) of integer;
        
    -- Declare a constant of the array of records type
    constant test_vectors : test_vector_array := (
        -- generate sample values for OUTPUT
        -- these values will be compared with the calculated values from circuits
        -- As follows, the array is matrix C and the sheet is shown in report in detail
        -- wrong numbers should be detected by self-checking testbench after test process in TCL console
        -- Right numbers will leave a note message in TCL console
        768, -720, 48, -80, -16,
        -720, 675, -45, 75, 15, 
        -240, 225, -16, 98, 116,
        112, -105, 8, 32, 45);
        
begin
    -- Instantiate UUT as a component in testbench
    UUT: entity work.Top_level
        -- generic map in order to access all files which use variables below to change their values
        generic map ( M => M_tb,
                      N => N_tb,
                      H => H_tb,
                      data_size => data_size_tb)
        Port map (CLK => CLK,
                  RST => RST,
                  NXT => NXT,
                  OUTPUT => OUTPUT);
                  
    -- Clock process
    -- This process generates a clock signal to control sequential elements
    clk_process: process
    begin
        CLK <= '0';
        wait for clk_period/2;
        CLK <= '1';
        wait for clk_period/2;
    end process;
    
    -- Test process used for testbench to test I/O ports in entity
    TEST : process
        begin
            -- wait 100ns for global reset to finish
            wait for 100 ns;
            
            -- Input values to change the falling edge of the clock
            wait until falling_edge(clk);
            
            -- Reset the circuits to define initial value not U
            RST <= '1';
            NXT <= '0';
            wait for clk_period*2;
            RST <= '0';
            wait for clk_period*3;
            
            -- Set reset back to 0
            rst <= '1';
            wait for clk_period*2;
            
            -- Start to calculate coefficients in matrix C
            -- generate a for loop to repeat 22 times to calculate and let circuits give the outputs
            -- Generate a for loop to assert values one by one following order in test_vectors array
            pulse_1x22: for i in test_vectors' range loop                           
                NXT <= '1';
                wait for clk_period*2; -- 2-period pulse
                NXT <= '0';
                wait for clk_period*5; -- 10-period pulse to wait for datapath finishes execution            
            
            -- Error message
            -- Insert values for OUTPUT to compare computation from circuits with manual computation
            -- Convert signed output to integer and compare it with value in test_vector array
            assert((to_integer(SIGNED(OUTPUT))) = test_vectors(i))
            
            -- The error message printing out what expected output is and what output from the circuits is
            report "TEST FAILED: " &
                   "The expected output value should be " & integer'image(test_vectors(i)) &
                   ". The real output value is " & integer'image(to_integer(SIGNED(OUTPUT)))
            severity error;
            
            -- Note message
            -- Insert values for not OUTPUT to compare computation form circuits with manual computation
            assert((to_integer(SIGNED(OUTPUT))) /= test_vectors(i))
            
            -- The note message printing out expected output corresponds to the real output
            report "TEST SUCCEED: " &
                   "The expected output value and the real output value are both " & integer'image(test_vectors(i))
            severity note;
            end loop pulse_1x22;
            
            -- test reset and restart after 20 clock periods
            rst <= '1';
            wait for clk_period*2;
            rst <= '0';
            wait for clk_period*2;
            
            pulse_1x10: for k in test_vectors' range loop
                 NXT <= '1';
                 wait for clk_period*2; -- 2-period pulse
                 NXT <= '0';
                 wait for clk_period*10; -- 10-period pulse to wait for datapath finishes execution            
           
                 wait for 50 ns; -- circuits needs time to execute
                       
                 -- Error message
                 -- Insert values for OUTPUT to compare computation from circuits with manual computation
                 -- Convert signed output to integer and compare it with value in test_vector array
                 assert((to_integer(SIGNED(OUTPUT))) = test_vectors(k))
                   
                 -- The error message printing out what expected output is and what output from the circuits is
                 report "TEST FAILED: " &
                        "The expected output value should be " & integer'image(test_vectors(k)) &
                        ". The real output value is " & integer'image(to_integer(SIGNED(OUTPUT)))
                 severity error;
                   
                 -- Note message
                 -- Insert values for not OUTPUT to compare computation form circuits with manual computation
                 assert((to_integer(SIGNED(OUTPUT))) /= test_vectors(k))
                 
                 -- The note message printing out expected output corresponds to the real output
                 report "TEST SUCCEED: " &
                        "The expected output value and the real output value are both " & integer'image(test_vectors(k))
                 severity note;
                 end loop pulse_1x10;
            
        wait; -- will wait forever
    end process;
                                             
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL;

entity Control_logic is

    -- Default values for generic M, H, N and data_size
    generic( M: natural := 3; -- the number of columns of A and rows of B
             H: natural := 4; -- the number of rows of A
             N: natural := 5); -- the number of columns of B
    
    -- Define ports in Control logic
    Port ( rst          : in STD_LOGIC;
           nxt          : in STD_LOGIC;
           clk          : in STD_LOGIC;
           
           rst_macc     : out STD_LOGIC; -- reset of macc
           en_macc      : out STD_LOGIC; -- enable of macc
           address_ram  : out UNSIGNED ((size(H*N-1)-1) downto 0); -- address to RAM to tell which number to output
           address_romA : out UNSIGNED ((size(H*M-1)-1) downto 0); -- address to ROM1 to tell which number should be sent to MACC A
           address_romB : out UNSIGNED ((size(N*M-1)-1) downto 0); -- address to ROM2 to tell which number should be sent to MACC B
           write_en_ram : out STD_LOGIC); -- wrting enable for RAM
           
end Control_logic;

architecture Behavioral of Control_logic is

    -- Declare the states as an enumerated type
    -- There are five states
    type fsm_states is (IDLE, CALCULATION, STORE, WAIT_ST);
    
    -- Internal signals
    signal state, next_state: fsm_states; -- of this type above
    signal data_out: STD_LOGIC; -- Define as 1 when N and H both reaches terminal values but in other cases, keep 0 to let the next coefficient caluculated
    signal en_M, en_N, en_H: STD_LOGIC; -- Define enable to let M N H counter count to update values out of ROM
    signal counter_m: UNSIGNED (log2(M)-1 downto 0); -- width of M counter
    signal counter_n: UNSIGNED (log2(N)-1 downto 0); -- width of N counter
    signal counter_h: UNSIGNED (log2(H)-1 downto 0); -- width of H counter
    signal ram: UNSIGNED ((size(H*N-1)-1) downto 0); -- as a signal to tell when data_out should be set to 1.
                                                     -- it also indicates current location of ram
       
begin

    -- Define M counter process
    M_counter: entity work.Param_Counter
    generic map (LIMIT => M)
    PORT MAP( clk => clk,
              rst => rst,
              en => en_M,
              count_out => counter_m);
    
    -- Define N counter process
    N_counter: entity work.Param_Counter
    generic map (LIMIT => N)
    PORT MAP( clk => clk,
              rst => rst,
              en => en_N,
              count_out => counter_n);
    
    -- Define H counter process
    H_counter: entity work.Param_Counter
    generic map (LIMIT => H)
    PORT MAP( clk => clk,
              rst => rst,
              en => en_H,
              count_out => counter_h);   
                              
    -- Define the state register
    state_assignment: process (clk) is -- synchronous process sensitive only to clock
        begin
            if (rising_edge(clk)) then
                if(rst = '1') then -- Define a reset state
                    state <= IDLE;
                else
                    state <= next_state;
                end if;
            end if;
        end process state_assignment;
        
    -- Define the fsm transition rules which is a mealy machine
    FSM_transitions: process (state, rst, nxt, data_out, counter_m) is
    begin
        case state is
            when IDLE => -- stage 1 is a reset state which all addresses in memeory are set to 0 and MACC is disabled, as well as counters are set to 0 
                if(nxt = '1') then
                    next_state <= CALCULATION;
                else
                    next_state <= IDLE;
                end if;
            when CALCULATION => -- stage 2 is to load values from ROM A and B and do multiplicaiton and addition of two numbers
                                -- It repeats until the last coefficient of C has been worked out 
                if(counter_m = M-1) then
                    next_state <= STORE;
                elsif(rst = '1') then -- When reset button is pressed, it goes back to initial state
                    next_state <= IDLE;
                else
                    next_state <= CALCULATION;
                end if;
            when STORE => -- stage 3 is to store coefficients calculated by datapath into RAM C and data_out as a signal to check which is the next state
                          -- The condition starting to calculate the next coefficient is when nxt button is pressed and there remains coefficients needed calculating (data_out = '0')
                          -- The condition waiting forever is the last coefficient has been computed (data_out = '1')
                if(data_out = '1') then 
                    next_state <= WAIT_ST;
                elsif(rst = '1') then -- When reset button is pressed, it goes back to initial state
                    next_state <= IDLE;
                elsif(data_out = '0' and nxt = '1') then
                    next_state <= CALCULATION;                
                else
                    next_state <= STORE;
                end if;
            when WAIT_ST => -- stage 4 is a freeze state, which will wait forever, ignoring nxt button pressed but wait for the reset button to make it go back to IDLE
                            -- It only happens all coefficients in matrix C has been computed
                if(rst = '1') then -- When reset button is pressed, it goes back to initial state
                    next_state <= IDLE;
                else
                    next_state <= WAIT_ST;
                end if;
        end case;
    end process FSM_transitions;

    -- By means of resize function, convert size of numbers counted by M,N,H counters to size of addresses required of ROM A and B as well as RAM C
    -- Because width in counter and width of memory are different, we convert width in counter to width in memory
    -- Because M is a non-negitive number, we use to_unsigned function to convert it to an unsigned vector with the specified size, which is log2(M)
    -- Because N is a non-negitive number, we use to_unsigned function to convert it to an unsigned vector with the specified size, which is log2(N)
    -- * performs the multiplication operation on two unsigned vectors which possibly be of different lengths
    -- + performs the addition on two unsigned vectors which possibly be of different lengths
    -- according to sheets written in report, we can find corresponding address as given values from counter_m and counter_h 
    -- resize function resizes an unsigned vector which is (counter_m + counter_h * to_unsigned(M, log2(M)) to the specified size size(M*H-1), whcih is recognized by ROM A
    address_romA <= resize(counter_m + counter_h * to_unsigned(M, log2(M)), size(M*H-1));
    
    -- resize function resizes an unsigned vector which is counter_n + counter_m * to_unsigned(N, log2(N)) to the specified size size(M*N-1), whcih is recognized by ROM B
    address_romB <= resize(counter_n + counter_m * to_unsigned(N, log2(N)), size(M*N-1));
    
    -- resize function resizes an unsigned vector which is (counter_n + counter_h * to_unsigned(N, log2(N)) to the specified size size(N*H-1), whcih is recognized by RAM C 
    ram <= resize(counter_n + counter_h * to_unsigned(N, log2(N)), size(N*H-1));
    address_ram <= ram;
    
    -- Define output from FSM
    -- reset of macc is at rising edge in reset and freeze state as well as store state where coefficients are stored in RAM
    rst_macc <= '1' when ((state = IDLE) or (state = STORE and NXT = '1') or (state = WAIT_ST)) else
                '0'; 
    
    -- enable of macc is at rising edge only where MACC is calculating coefficients of C
    en_macc <= '1' when (state = CALCULATION) else
               '0';
    
    -- M counter enable is set to high when MACC repeats multiplying two numbers because M counter needs to count column of matrix A and row of matrix B
    -- Only in Calculation state, MACC is working and column in A together with row in B of values going into multiplier needs changing
    en_M <= '1' when (state = CALCULATION) else
            '0';
    
    -- N counter enable is set to high only after working out one coefficient
    -- Because coefficients in matrix C are calculated row by row, every time, after working out one coefficient, address for column of B must be changed
    -- It is countrolled by N counter
    en_N <= '1' when (state = STORE and NXT = '1') else
            '0';
    
    -- H counter enable is set to high after workin gout one coefficient and when N counter counts to the maximum            
    -- Because at this point, matrix A should switched to the next row
    -- Current state should be store and also counter_n should be terminal values
    en_H <= '1' when (state = STORE and counter_n = (N-1) and NXT = '1') else
            '0';
             
    -- written enble of RAM C is set to high only when storing values into RAM C
    write_en_ram <= '1' when (state = STORE) else
                    '0';
    
    -- Define a signal called data_out to tell FSM if all coefficients of matrix C have been computed
    -- data_out is set to high when all coefficients of matrix C have been computed
    -- It happens when counter_h reaches maximum because coefficients of matrix C are computed row by row
    data_out <= '1' when (state = STORE and ram = H*N-1) else
                '0';
                
end Behavioral;

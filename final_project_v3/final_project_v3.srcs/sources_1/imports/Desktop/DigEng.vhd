----------------------------------------------------
-- PACKAGE FOR DIGITAL ENGINEERING LABS
--
-- To use:
--
-- - Download file
-- - Use "Add copy" to add to Xilinx project
-- - Add "use work.DigEng.all" on top of entity
--
----------------------------------------------------

package DigEng is

function log2 (x : natural ) return natural;
function size (x : natural ) return natural;

end DigEng;

package body DigEng is

----------------------------------------------------
-- LOG BASE 2 FUNCTION
-- returns the ceiling of log base 2 of a (non-zero) integer
-- (1->0; 2->1; 3->2; 4->2; 5->3 ...)
--
-- This function is NOT SYNTHESIZABLE 
-- should be used for indices, not circuit description
-- 
-- Examples:
-- - signal A : STD_LOGIC_VECTOR(log2(data_size)-1 downto 0);
-- 
----------------------------------------------------
function log2 ( x : natural ) return natural is
        variable temp : natural := x ;
        variable n : natural := 0 ;
    begin
        while temp > 1 loop
            temp := temp / 2 ;
            n := n + 1 ;
        end loop ;
	   if (x > 2**n) then
		n := n + 1;
	   end if;
        return n ;
end function log2;

----------------------------------------------------
-- SIZE FUNCTION
-- returns the size of a vector that can encode a (non-zero) integer
-- (1->1; 2->2; 3->2; 4->3; 5->3 ...)
--
-- This function is NOT SYNTHESIZABLE 
-- should be used for indices, not circuit description
-- 
-- Examples:
-- - signal A : STD_LOGIC_VECTOR(size(n)-1 downto 0);
-- 
----------------------------------------------------
function size ( x : natural ) return natural is
        variable temp : natural := x ;
        variable n : natural := 0 ;
    begin
        while temp >= 1 loop
            temp := temp / 2 ;
            n := n + 1 ;
        end loop ;
        return n ;
end function size;

function coeffic_C (x: natural; y:natural) return natural is
	variable temp: natural;
	variable n : natural := y;
	variable m: natural := x;
begin 
	temp := size(((2**(m-1))**2)*n)+1;
	return temp;
end function coeffic_C;


end DigEng;

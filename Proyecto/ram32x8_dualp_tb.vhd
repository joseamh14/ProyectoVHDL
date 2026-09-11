--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:55:02 05/27/2025
-- Design Name:   
-- Module Name:   C:/Users/ATC/Desktop/Trabajo2/trabajo2/ram32x8_dualp_tb.vhd
-- Project Name:  trabajo2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram32x8_dualp
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY ram32x8_dualp_tb IS
END ram32x8_dualp_tb;
 
ARCHITECTURE behavior OF ram32x8_dualp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram32x8_dualp
    PORT(
         addra : IN  std_logic_vector(4 downto 0);
         dia : IN  std_logic_vector(7 downto 0);
         ena : IN  std_logic;
         wea : IN  std_logic;
         addrb : IN  std_logic_vector(7 downto 0);
         dob : OUT  std_logic_vector(7 downto 0);
         enb : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal addra : std_logic_vector(4 downto 0) := (others => '0');
   signal dia : std_logic_vector(7 downto 0) := (others => '0');
   signal ena : std_logic := '0';
   signal wea : std_logic := '0';
   signal addrb : std_logic_vector(7 downto 0) := (others => '0');
   signal enb : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal dob : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram32x8_dualp PORT MAP (
          addra => addra,
          dia => dia,
          ena => ena,
          wea => wea,
          addrb => addrb,
          dob => dob,
          enb => enb,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
   dia <= X"68";
   
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      ena <= '1';
      wea <= '1';
      
      wait for clk_period*10;
      wait for 100 ns;
      ena <= '0';
      wea <= '0';
      enb <= '1';
      
      -- insert stimulus here 

      wait;
   end process;

END;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:52:37 05/27/2025 
-- Design Name: 
-- Module Name:    ram32x8_dualp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram32x8_dualp is
    Port ( 
           --Puerto A solo escritura
           addra : in  STD_LOGIC_vector (4 downto 0);  -- Como hay 32 direcciones, con 5 bits tenemos suficente ( 2^5 = 32 )
           dia : in  STD_LOGIC_vector (7 downto 0);  -- Puerto de entrada de 8 bits
           ena : in  STD_LOGIC;  -- Señal de habilitación del puerto A
           wea : in  STD_LOGIC;  -- Señal de escritura del puerto A
           
           --Puerto B solo lectura
           addrb : in  STD_LOGIC_vector (4 downto 0);
           dob : out  STD_LOGIC_vector (7 downto 0);  -- Puerto de salida de 8 bits
           enb : in  STD_LOGIC;  -- Señal de habilitación del puerto B
           
           --Señal de reloj
           clk : in  STD_LOGIC); 
end ram32x8_dualp;

architecture Behavioral of ram32x8_dualp is

type ram_type is array (31 downto 0) of std_logic_vector (7 downto 0);
signal RAM : ram_type;
signal SALIDA: std_logic_vector(7 downto 0);

begin

   P1: process(clk)
       begin
         if rising_edge(clk) then
            if wea = '1' and ena = '1' then
                  RAM(to_integer(unsigned(addra))) <= dia;
            end if;
            if enb = '1' then
                  SALIDA <= RAM(to_integer(unsigned(addrb)));
            end if;          
         end if;
       end process;
dob <= SALIDA;

end Behavioral;


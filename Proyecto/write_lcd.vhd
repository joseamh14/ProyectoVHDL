----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:54:32 03/30/2025 
-- Design Name: 
-- Module Name:    lcd1_JoseAntonio - Behavioral 
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

entity write_lcd is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC; --Asincrono activo en alta
           init : in  STD_LOGIC; --Señal de inicio de escritura
           e : out  STD_LOGIC; --Habilitacion lectura/escritura
           rs : out  STD_LOGIC; --Seleccion de registro
           rw : out  STD_LOGIC; --Señal de lectura escritura
           db : out  STD_LOGIC_VECTOR (7 downto 0);
           addrb : out  STD_LOGIC_vector (4 downto 0);
           dob : in  STD_LOGIC_vector (7 downto 0);  -- Puerto de salida de 8 bits
           enb : out  STD_LOGIC  -- Señal de habilitación del puerto B
           ); --Bus de datos
end write_lcd;

architecture Behavioral of write_lcd is
type tipo_matriz is array(0 to 31) of std_logic_vector(7 downto 0);
constant function_set : std_logic_vector (9 downto 0) := ("0000111000"); --Los dos ultimos bits no importa si son 1 o 0
constant display_on : std_logic_vector (9 downto 0) := ("0000001100");
constant clear_display : std_logic_vector (9 downto 0) := ("0000000001");
constant set_ddram_address: std_logic_vector (9 downto 0) := ("0011000000");
type tipo_estado is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16);
signal estado: tipo_estado;
signal thresh: std_logic;
signal control : std_logic_vector ( 9 downto 0);
signal contTHRESH : unsigned ( 6 downto 0); --Para que pueda llegar a 100
signal cont: unsigned (14 downto 0); 
signal recorrido: unsigned (4 downto 0); --Para recorrer la matriz

begin
 
 
 rs <= control(9);
 rw <= control (8);
 db <= control (7 downto 0);




PEstados: process(clk,reset)
   begin
      if reset = '1' then
         estado <= s16;
         control <= clear_display;
         enb <= '1';
         addrb <= (others => '0');
         cont <= (others => '0');
         recorrido <= (others => '0');
      elsif rising_edge(clk) then
         if thresh = '1' then
         case estado is
         
            when s0 =>
             
                     e <= '0' ;
                    
                  if init = '1' then
                  estado <= s1;
                  control <= function_set;
                  cont <= ( others => '0');
               end if;
               
               
            when s1 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                    
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s2;
                        end if;
               
            when s2 =>
                 cont <= cont +1;
                 if cont = 5900 then
                     cont <= ( others => '0');
                  estado <= s3;
                  control <= display_on;
                 end if; 
                  
             when s3 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s4;
                        end if;
                        
            when s4 =>
                 cont <= cont +1;
                 if cont = 5900 then
                     cont <= ( others => '0');
                  estado <= s5;
                  control <= clear_display;
                  end if;
                  
            when s5 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s6;
                        end if;
                  
            when s6 =>
            cont <= cont +1;
                 if cont = 25000 then
                     cont <= ( others => '0');
                     estado <= s7;
           
                     end if;
             
            when s7 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s8;
                           recorrido <= recorrido +1; -- incremento recorrido aqui para que se introduzca en addrb el caracter siguiente
                          
                          
                        end if;
                        
            when s8 =>
            cont <= cont +1;
            enb <= '1';
                  if cont = 6300 then
                     cont <= (others => '0');
                     
                     control <= ("10" & dob);
                     if recorrido = 15 then
                       
                        estado <= s9;
                        enb <= '0';
                        else
                           recorrido <= recorrido +1;
                           estado <= s14;
                           addrb <= std_logic_vector(recorrido);
                        end if;
                        end if;
                        
             when s14 =>
                  cont <= cont +1;
                  enb <= '0';
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s8;
                        end if;

                    
               when s9 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s10;
                        end if;
                        
            when s10 =>
            cont <= cont +1;
                  if cont = 6300 then
                  cont <= (others => '0');
                  control <= set_ddram_address;
                  estado <= s11;
                  end if;
                  
            when s11 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s12;
                           enb <= '1';
                        end if;
                  
            when s12 =>       
                 cont <= cont +1;
                 enb <= '1';
                 if cont = 5900 then
                     cont <= ( others => '0');
                     
                     control <= ("10" & dob);
                     if recorrido = 31 then
                        recorrido <= (others => '0');
                        estado <= s13;
                        enb <= '0';
                      else
                      recorrido <= recorrido +1;
                        estado <= s15;
                        addrb <= std_logic_vector(recorrido);
                        end if;
                        end if;
           
           when s15 =>
                  cont <= cont +1;
                  enb <= '0';
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s12;
                        end if;
           
              when s13 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s0;
                        end if;
                        
               when s16 =>
                  cont <= cont +1;
                  if cont = 1 then
                     e <= '1';
                  elsif cont = 2 then
                        e <= '0';
                           cont <= (others => '0');
                           estado <= s0;
                        end if;
         end case;
          end if;
      end if;
end process;



PReduccion: process(clk,reset)
         begin
         if reset = '1' then
         contTHRESH <= (others => '0');
         thresh <= '1';
         elsif rising_edge(clk) then
            contTHRESH <= contTHRESH + 1;
            if contTHRESH = 100 then
               thresh <= '1';
               contTHRESH <= (others => '0');
               else
               thresh <= '0';
         end if;
         end if;
         end process;
end Behavioral;


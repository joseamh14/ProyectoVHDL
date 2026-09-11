# ProyectoVHDL

Proyecto de VHDL desarrollado con Xilinx ISE, dirigido a una placa Nexys4 (ver restricciones de pines en `reception_uart_bt_lcd_nexys4.ucf`).

## Contenido

- `uart.vhd` — módulo UART.
- `Proyecto/reception_uart_bt.vhd` / `reception_uart_bt_lcd.vhd` — recepción UART (con variante que añade salida a LCD).
- `Proyecto/ram32x8_dualp.vhd` — memoria RAM dual-port 32x8.
- `Proyecto/write_lcd.vhd` — driver de escritura en LCD.
- `Proyecto/*_tb.vhd` — testbenches de los módulos anteriores.
- `Proyecto/trabajo2.xise` — proyecto de Xilinx ISE.
- `Trabajo2.ucf` — restricciones de pines.


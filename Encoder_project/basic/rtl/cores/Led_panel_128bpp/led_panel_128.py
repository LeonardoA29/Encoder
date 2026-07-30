from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

class LED_PANEL(Module,AutoCSR):
   def __init__(self, data):
   # Interfaz
    self.clk            = ClockSignal()
    self.rst            = ResetSignal()
    self.init           = CSRStorage()

    self.w_data0        = CSRStorage(48)
    self.w_data1        = CSRStorage(48)
    self.w_address      = CSRStorage(14)
    self.en_a           = CSRStorage()

    self.Led_clk        = data.Led_clk
    self.latch          = data.latch
    self.OE             = data.OE
    self.ROW            = data.ROW
    self.RGB0           = data.RGB0
    self.RGB1           = data.RGB1 

    self.specials +=Instance("led_panel_128", 
        i_clk            = self.clk,
        i_rst            = self.rst,
        i_init           = self.init.storage,
        i_w_data0        = self.w_data0.storage,
        i_w_data1        = self.w_data1.storage,
        i_w_address      = self.w_address.storage,
        i_en_a           = self.en_a.storage,
        o_Led_clk        = self.Led_clk,
        o_latch          = self.latch,
        o_OE             = self.OE,
        o_ROW            = self.ROW,
        o_RGB0           = self.RGB0,
        o_RGB1           = self.RGB1,
	)	   
    self.submodules.ev = EventManager()
    self.ev.ok = EventSourceProcess()
    self.ev.finalize()

# bram_tb.tcl
launch_simulation

set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
    if { [llength [get_objects]] > 0} {
        create_wave_config
        add_wave /
        set_property needs_save false [current_wave_config]
    } else {
        send_msg_id Add_Wave-1 WARNING "No top level signals found."
    }
}

add_wave /bram_tb/clk_10MHz
add_wave /bram_tb/clk_125MHz
add_wave /bram_tb/reset
add_wave /bram_tb/lfsr_out
add_wave /bram_tb/bram_out
add_wave /bram_tb/uut/write_addr
add_wave /bram_tb/lfsr_cycle_count
add_wave /bram_tb/uut/bram

run 2us

# Classic Frogger
Play an alternative version of the old arcade game Frogger!

# Features
- Awesome sound effects
- Death animation
- Display number of lives
- Frog moves with a log
- Keyboard input (A S D W)

# How to play
- Download [MARS v4.5](http://courses.missouristate.edu/kenvollmar/mars/download.htm)
- Download the [assembly source code](https://github.com/xingl213/classic-frogger/releases) or clone this repository
- Open `frogger.asm` in MARS
- Choose Tools -> Bitmap Display
- Set unit width in pixels to 8; set unit height in pixels to 8; set display width in pixels to 256; set display width in pixels to 256; set base address for display to 0x10008000 ($gp). Click Connect to MIPS
- Choose Tools -> Keyboard and Display MMIO Simulator
- Click Connect to MIPS
- Use keys A S D W to control the frog and play. Have fun playing!

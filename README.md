# PachisloAutostopChip
Autostop and credit add chip for older pachislo machines

Back in 2003-2004, I imported a lot of pachislo machines. And then I wrote code for an auto stop and credit add chip. It requires a pic 12c509a chip (< $2 in 2024), a bit of soldering on your reel stop board, and an eeprom burner - or a friend who has one.


The original code was written in picbasic and is included in the code directory. It's attached here for nostalgia, understanding, and in case someone wants to modify it.
The .hex file gets burned to your 12c509a chip. It's included in the code directory also.

Build and use instructions are included in the instructions directory. Simply click on one of the .htm files: autostop-instructions.htm, autostop-construction.htm, autostop-construction-page2.htm or autostop-supplement.htm to read build and use instructions.


Commands

Press left reel stop button for ~ 3 seconds to toggle autostop mode on / off

Hold left button for 3 secs, then tap middle button to shut down autostop mode

Hold left button for 3 secs, then tap right button to toggle random mode

Hold middle reel stop button for ~ 3 seconds to initialize calibrate mode.

Hold middle button for 3 seconds, then tap right button to subtract 100ms to autostop timer

Hold middle button for 3 seconds, then tap left button to add 100ms from autostop timer

Hold right reel stop button for ~ 3 seconds to add 50 credits 

Hold right button for 3 secs, then tap middle button to shut down credit add mode

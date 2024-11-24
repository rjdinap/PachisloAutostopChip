# PachisloAutostopChip
Autostop and credit add chip for older pachislo machines

Back in 2003-2004, I imported a few truckloads of pachislo machines. And then I wrote code for an auto stop and credit add chip. It requires a pic 12c509a chip (still < $2 in 2024), a bit of soldering on your reel stop board, and an eeprom burner - or a friend who has one.


The original code was written in picbasic and is included in the code directory. It's attached here for nostalgia, understanding, and in case someone wants to modify it.
The .hex file gets burned to your 12c509a chip. It's included in the code directory also.

Build and use instructions are included in the instructions directory. Simply click on one of the .htm files: autostop-instructions.htm, autostop-construction.htm, autostop-construction-page2.htm or autostop-supplement.htm to read build and use instructions. (You won't see the .htm pages pull up properly if browsing from github - you need to download the instructions directory to your local computer and then click the .htm files.)


Commands

Press left reel stop button for ~ 3 seconds to toggle autostop mode on / off

Hold left button for 3 secs, then tap middle button to shut down autostop mode

Hold left button for 3 secs, then tap right button to toggle random mode

Hold middle reel stop button for ~ 3 seconds to initialize calibrate mode.

Hold middle button for 3 seconds, then tap right button to subtract 100ms to autostop timer

Hold middle button for 3 seconds, then tap left button to add 100ms from autostop timer

Hold right reel stop button for ~ 3 seconds to add 50 credits 

Hold right button for 3 secs, then tap middle button to shut down credit add mode


If your reelstop board looks like one of these pictures, you can most likely use this code. Read the instrucions files for more details. Before trying to wire up the credit add functionality or pin 4, be sure to measure voltage with a multimeter! If you get more than 5v, don't do it!
![image](https://github.com/user-attachments/assets/7f819e09-fb61-4313-86b5-596806b77518)
![image](https://github.com/user-attachments/assets/37e9d32c-4cfe-4c70-99cf-8f47eda2602d)


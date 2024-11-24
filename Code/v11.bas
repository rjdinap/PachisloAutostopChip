; Super Autostop Chip - v1.1
; (c) 2004 Robert DiNapoli
; 2024 - rjgee@hotmail.com
; instructions for use
; press left reel stop button for ~ 3 seconds to toggle autostop mode on / off
; hold left button for 3 secs, then tap middle button to shut down autostop mode
; hold left button for 3 secs, then tap right button to toggle random mode
; hold middle reel stop button for ~ 3 seconds to initialize calibrate mode.
; hold middle button for 3 seconds, then tap right button to subtract 100ms to autostop timer
; hold middle button for 3 seconds, then tap left button to add 100ms from autostop timer
; hold right reel stop button for ~ 3 seconds to add 50 credits 
; hold right button for 3 secs, then tap middle button to shut down credit add mode

; When burning, use MCLRE OFF, WDT OFF, INT_RC ON
; Compile this code with Proton development suite -  www.picbasic.org

; v.99 fixes timing issues with wire 4
; add delay for startup stabilize
; add randommode function

; v1.0 - fix to work with IGT - reverse voltage coin mech sensors and start buttons

; v1.1 - fix to work with newer DAIDO - reverse voltage start lever
;if start lever is pressed for 3 seconds, disable autostop for current round

device = 12C509A
xtal = 4
dim x as byte
dim y as word
dim result as byte
dim mask as byte
dim counterahi as byte
dim counteralo as byte
dim counterbhi as byte
dim counterblo as byte
dim counterchi as byte
dim counterclo as byte
dim timerdelay as word
dim autostop as bit
dim creditcheck as bit
dim autocheck as bit
dim timerflag as bit
dim gamelever as bit
dim randommode as bit
dim bpressed as bit; most machines use 0 (lo) as pressed button state
dim breleased as bit; most machines use 1 (high) as released state
dim glreleased as byte; gamelever released state
dim gpioonstate as byte
dim r as word; reel stop order

config mclre_off,cp_off,wdt_off,intrc_osc
;option_reg.7 = 1; disable wake from sleep
;option_reg.6 = 0; weak pullups enabled
;option_reg.5 = 0; select timer mode - make gp2 an output
;option_reg.3 = 0; prescaler assigned to tmr0
;option_reg.2 = 0; prescaler value of 256 - tmr0 updated once every instruction cycle
;option_reg.1 = 0
;option_reg.0 = 0
delayms 1000; wait for pic to stabilize and machine to startup
option_reg = %10000000


counteralo = 15; 1ms increments
counterblo = 30
counterclo = 15
counterahi = 0; 64ms increments
counterbhi = 0
counterchi = 0
autostop = 0; autostop mode is off initially
creditcheck = 1; credit checking mode is on initially
autocheck = 1; autostop toggle checking is on initially
timerflag = 0; set to 1 when we change the autostop timer so we don't do a calibrate
gamelever = 1 ; game lever is not wired up; set to 0 when gamelever is detected
randommode = 0; reels stop in order; set to 1 to make reels stop in random order
timerdelay = 125; approx 4ms increments - (default value is 500ms)

trisio = 0x3f; 0011 1111 - gp0,1,2,3,4,5 to input
checkvoltage:
breleased = gpio.0 ; sample voltage
delayms 10
if gpio.0 <> breleased then goto checkvoltage ; resample voltage
if breleased = 1 then 
   bpressed = 0
   gpioonstate = 0x37; gp 0,1,2,4,5 on
else
   bpressed = 1
   gpioonstate = 0x00; gp0,1,2,4,5 off
endif	   
mask = gpioonstate & 0x0f;
glreleased = gpio.3 ; get state for game lever

trisio = 0x08; 0000 1000 ; gp0,1,2,4,5 to output gp3 input
gpio = gpioonstate ; turn 'on' all outputs



startloop:
trisio = 0x3f; 0011 1111 - gp 0,1,2,3,4,5 to input

if autocheck = 1 then
   if gpio.0 = bpressed then goto autotoggle
endif   
if gpio.1 = bpressed then goto calibrate
if creditcheck = 1 then
   if gpio.2 = bpressed then goto add_50_credits
endif  

if gpio.3 = 0 then gamelever = 0; start lever detected - this pin will normally be high, even if
;the lever isn't detected. If we see it go low, we know that the game lever has been wired up
;newer IGTs use reverse logic for everything but the start lever...
;newer Daidos use reverse logic for the start lever (0 -> 12v)

if autostop = 0 then goto startloop; if autostop is off, no reason to check gp3, just loop...

if gamelever = 1 then goto stopreels; jump if gamelever wire not attached (autostop = 1 at this point...)

; at this point, autostop = 1 (on) , gamelever = 0 (game lever detected)
;check if gp3 input has been pressed. If pressed, we delay, giving the reels time to come up to speed
if gpio.3 = glreleased then goto startloop; game lever has not been pressed. go to main input loop.
delayms 3000; wait for reels to spin up, then continue to the stopreels routine..


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stop the reels
; if the gamelever wire is not used, we enter this routine on every input loop. it eats up a lot of time,
; and constantly pulses the stop buttons
; if the gamelever wire is used, we only enter this routine only when gp3 goes low (game lever is pressed)
; buttons are normally high. Bring the pin low to enable reelstop
; on entry, will always be: trisio = 0x3f; 0011 1111 gp0,1,2,3,4,5 to input
stopreels:

;delay before stopping reels
y = 0
while y < timerdelay
result = gpio & mask
if result != mask then goto startloop
delayms 1
y = y + 1
wend

if gamelever = 0 then; if pin 4 is wired up and
   if gpio.3 != glreleased then 
   	  glwaitforrelease:
	  if gpio.3 = glreleased then goto startloop ; if the startlever is pressed at this point, don't do the autostop
	  goto glwaitforrelease
	  endif
endif	     
   

if randommode = 0 then
   result = 0
else
	result = tmr0 // 6 ; get psuedorandom number between 0 and 5
endif	

select result
case 0
r=0x0421
case 1
r=0x0241
case 2
r=0x0412
case 3
r=0x0142
case 4
r=0x0214
case 5
r=0x0124
endselect

;pulse signals to stop the reels
pulsestopsignal:
x = 0
while x < 3
trisio = 0x38; 0011 1000 gp0,1,2 to output gp 3,4,5 to input
;delayms 5; not needed?

result = r & 0x0f; get rightmost digit
r = r >> 4 ; shift right 1 place

if bpressed = 0 then
   gpio = gpio - result; turn bit 'off' to stop reel
else
   gpio = gpio | result
endif
delayms 20; 20ms is enough
if bpressed = 0 then
   gpio = gpio | result; turn bit back 'on'; 
else
   gpio = gpio - result
endif   


trisio = 0x3f; 0011 1111 gp0,1,2,3,4,5 to input
;delayms 3; not needed?

;delay inbetween reel stops
;this routine profiles out to ~4ms * timerdelay of 125 = 500ms total
y = 0
while y < timerdelay
result = gpio & mask
if result != mask then goto startloop
delayus 3976
y = y + 1
wend

x = x + 1
wend
goto startloop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
autotoggle:
; left button
; toggle autostop mode on and off
; check for autostop disable
; check for random mode toggle
; we will not enter this routine if autostop has been disabled (autocheck = 0)
x = 0
while x < 91
	delayms 10; 1 second total  
	if gpio.0 = breleased then goto startloop; user released button too early
	x = x + 1
wend	

waitforrelease:
if gpio.1 = bpressed then; middle button pushed; disable autostop
   delayms 20
   if gpio.1 = bpressed then
      autocheck = 0; disable autostop toggle checking
   	  autostop = 0; disable autostop mode
   	  goto startloop
	endif	  
endif
if gpio.2 = bpressed then; right button pushed; toggle random mode  
   delayms 20
   if gpio.2= bpressed then
   	  ; toggle randommode
	  toggle randommode; //this doesn't seem to work on 14bit core ?
      goto startloop
  endif	  
endif    
delayms 10
if gpio.0 = bpressed then goto waitforrelease; wait for button release
toggle autostop
goto startloop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calibrate:
; middle button
; wait for a coin insert. measure the timing between sensors, and use these times on the add_credit routines
; also check for autostop timer increase / decrease
; we must enter this function, even when creditcheck or autocheck is 0 because
; when autocheck is 0, this routine is still used for the calibrate function of creditcheck
; when creditcheck is 0, this routine is still used for the timing adjust function of autocheck

timerflag = 0; 
x = 0
while x < 91
	delayms 10; 1 second total
	if gpio.1 = breleased then goto startloop; user released button too early
x = x + 1
wend

waitforrelease2:
if gpio.2 = bpressed then ; decrease autostop timer if right button pressed
   delayms 5; slight delay for debounce timing
   timerdelay = timerdelay - 25; faster by 100ms 
   if timerdelay < 75  then timerdelay = 75; at least 300ms delay
   timerflag = 1; we set a timer, don't calibrate
   waitforrelease2_1:
   if gpio.2 = bpressed then goto waitforrelease2_1; wait for right button release
endif
if gpio.0 = bpressed then; increase autostop timer if left button pressed
   delayms 5; slight delay for debounce
   timerdelay = timerdelay + 25; slower by 100ms
   timerflag = 1; we set a timer, don't calibrate
   waitforrelease2_2:
   if gpio.0 = bpressed then goto waitforrelease2_2; wait for left button release
endif   
if gpio.1 = bpressed then goto waitforrelease2; wait for middle button release'

if timerflag = 1 then goto startloop; don't calibrate if we are only changing autostop timing
if creditcheck = 0 then goto startloop; no need to calibrate if add credit mode is off

trisio = 0x38 ; 0011 1000 - gp 0,1,2 to output mode  gp,3,4,5 to input mode
;delayms 3; might not need
option_reg = %10000111; set prescaler value 256; tmr 0 updates once every 256us
delayms 3

sensor1trigger:
if gpio.4 = breleased then goto sensor1trigger ;wait for 1st sensor to trigger
tmr0 = 0; zero out the counter, tmr0 increments once every 256us

sensor2trigger:
counteralo = tmr0; 256us increments (value of 4 = 1.024 ms)
if tmr0 < counteralo then
counterahi = counterahi +1; 256us * 255value byte = 65.280ms
endif
if gpio.5 = breleased then goto sensor2trigger; wait for 2nd sensor to trigger

tmr0 = 0
sensor1release:
counterblo = tmr0; 
if tmr0 < counterblo then
counterbhi = counterbhi +1
endif
if gpio.4 = bpressed then goto sensor1release; wait for 1st sensor to finish 

tmr0 = 0
sensor2release:
counterclo = tmr0;
if tmr0 < counterclo then
counterchi = counterchi +1
endif
if gpio.5 = bpressed then goto sensor2release; wait for 2nd sensor to finish

counteralo = counteralo / 4 ; convert to ms (approxiamate)
counterblo = counterblo / 4
counterclo = counterclo / 4
option_reg = %10000000; prescaler back to 0; timer updates every instruction cycle
;delayms 2 ; might not need
goto startloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add_50_credits:
; right button
; add credits
; also check for 50 credit disable
; we do not enter this routine if credit_add routine is disabled (creditcheck=0)
x = 0
while x < 91
	delayms 10; 1 second total
	if gpio.2 = breleased then goto startloop; user released button too early
x = x + 1
wend

waitforrelease3:
if gpio.1 = bpressed then
   delayms 10
   if gpio.1 = bpressed then
      creditcheck = 0; turn credit adding mode off
   	  goto startloop
	endif  
endif
delayms 5;
if gpio.2 = bpressed then goto waitforrelease3; wait for button release

gpio = gpioonstate; turn 'on' all outputs
trisio = 0x0f ; 0000 1111 gp 0,1,2,3 to input gp 4,5 to output
;delayms 5 ; not needed?
x = 0
while x < 54
gpio.4 = bpressed
delayms counterahi * 64; its really 65.280, but using 64 saves a lot of code space!
delayms counteralo     ; (and I really don't think any coinmechs take over 64ms anyway!!)     
gpio.5 = bpressed
delayms counterbhi * 64
delayms counterblo
gpio.4 = breleased
delayms counterchi * 64
delayms counterclo
gpio.5 = breleased
delayms 50;
x = x + 1
wend
goto startloop



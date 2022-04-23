# rpi-raise-desk-to-standing-height


Inspired by David Kong's article (How I Hacked My Standing Desk With a Raspberry Pi)[https://medium.com/@davidkongfilm/how-i-hacked-my-standing-desk-with-a-raspberry-pi-a50ed14c7f6f]

Future work: 
- use workstation lock/unlock detection: https://github.com/daoo/autodesk
    - also has limits on how long the desk can stay down
- decipher the control signal to/from the keypad

Hardware:

- Raspberry Pi 4
- Relay Board
- Duplicate keypress controller purchased from office desk supplier

Software

Balena
Python
GPIOZero

Environment Variables
- TIMEZONE
- PERIOD
- MIN_TIME
- GPIO_PIN

Relay Board Wiring

```
Channel No.	    RPi Pin No.	    wiringPi	BCM	    Descriptions
CH1	            37	            P25	        26	    Channel 1
CH2	            38	            P28	        20      Channel 2
CH3	            40	            P29	        21	    Channel 3
```
https://www.waveshare.com/wiki/RPi_Relay_Board

GPIOZero wiring
https://gpiozero.readthedocs.io/en/stable/recipes.html

```
>>> led = LED(17)
>>> led = LED("GPIO17")
>>> led = LED("BCM17")
>>> led = LED("BOARD11")
>>> led = LED("WPI0")
>>> led = LED("J8:11")
```
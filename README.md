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

Environment Variables
- TIMEZONE
- PERIOD
- MIN_TIME
- GPIO_PIN
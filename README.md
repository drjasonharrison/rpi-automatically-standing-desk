# rpi-raise-desk-to-standing-height

## Inspiration

After reading David Kong's article [How I Hacked My Standing Desk With a Raspberry Pi](https://medium.com/@davidkongfilm/how-i-hacked-my-standing-desk-with-a-raspberry-pi-a50ed14c7f6f)
I knew that I wanted to implement a similar solution but with with RPi supply shortages,
and having an Raspberry Pi 3 on hand, and a Relay Board, and experience with balena.io,
I knew I would be taking this in a slightly different direction.

The desks at work us a similar keypad to the one David Kong had, with a preset able to be recorded, and when you press and hold the button the desk rises or lowers to the level you set it to.

As in David's article I could solder wires on either side of the button electrical connections, and close the circuit using a relay.

I added a Balena.io Dockerfile.template based on the Raspberry Pi with Python 3.7

## Software

- [Balena.io](https://www.balena.io/)
- [Python 3.7](https://www.python.org/)
- [RPi.Gpio==0.7.1](https://pypi.org/project/RPi.GPIO/)
- [pytz](https://github.com/stub42/pytz)

## Environment Variables

These can be controlled through the Balena.io dashboard or left to their defaults

- DESK_MAX_PERIOD_MINUTES, default 60. Maximum amount of time before raising the desk.
- DESK_MIN_PERIOD_MINUTES, default 45. Minimum amount of time before raising the desk.
- DESK_PRESS_BUTTON_SECONDS, default 12. Number of seconds to keep the relay closed and the button pressed to raise the desk
- DESK_RAISE_WARNING_CYCLES, default 10. Number of clicks of the second relay to make as an audio warning that the desk is about to raise.
- DESK_TIME_ZONE, default America/Vancouver. Time zone to use for printing logs and next scheduled raise time.

## Hardware

- Raspberry Pi 3 (or 4)
- [Relay Board](https://www.waveshare.com/wiki/RPi_Relay_Board)
- Duplicate keypress controller purchased from office desk supplier

### Relay Board Wiring

```
Channel No.     RPi Pin No.     wiringPi BCM     Descriptions
CH1             37             P25         26     Channel 1
CH2             38             P28         20      Channel 2
CH3             40             P29         21     Channel 3
```

<https://www.waveshare.com/wiki/RPi_Relay_Board>

GPIOZero wiring
<https://gpiozero.readthedocs.io/en/stable/recipes.html>

```
>>> led = LED(17)
>>> led = LED("GPIO17")
>>> led = LED("BCM17")
>>> led = LED("BOARD11")
>>> led = LED("WPI0")
>>> led = LED("J8:11")
```

## Future work

- use workstation lock/unlock detection: <https://github.com/daoo/autodesk>
  - also has limits on how long the desk can stay down
- decipher the control signal to/from the keypad

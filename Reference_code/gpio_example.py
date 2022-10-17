#!/usr/bin/python
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

from time import sleep

# Get GPIO version and board version
print(f"GPIO.VERSION = {GPIO.VERSION}")
print(f"GPIO.RPI_INFO['P1_REVISION'] = {GPIO.RPI_INFO['P1_REVISION']}")

# Set GPIO mode: GPIO.BCM or GPIO.BOARD
GPIO.setmode(GPIO.BOARD)

# GPIO pins list based on GPIO.BOARD
gpioList1 = [3,5,7,8,10,11,12,13,15]
gpioList2 = [16,18,19,21,22,23,24,26]

# Set mode for each gpio pin
GPIO.setup(gpioList1, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(gpioList2, GPIO.OUT, initial=GPIO.LOW)

while True:
	# Change gpio pins in list 1 from low to high and list 2 from high to low
	GPIO.output(gpioList1, GPIO.HIGH)
	GPIO.output(gpioList2, GPIO.LOW)
	sleep(1)

	# Change gpio pin in list 1 from high to low and list 2 from low to high
	GPIO.output(gpioList1, GPIO.LOW)
	GPIO.output(gpioList2, GPIO.HIGH)
	sleep(1)

# Reset all gpio pin
GPIO.cleanup()

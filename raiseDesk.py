try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

from time import sleep
import random
import os
import logging
import itertools

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(name)s %(levelname)s %(message)s'
)
log = logging.getLogger("raiseDesk")

class RaiseDesk:
    def __init__(self):
        self.logger = logging.getLogger('RaiseDesk')

        self.Relay_Ch1 = 26
        self.Relay_Ch2 = 20
        self.Relay_Ch3 = 21

        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)

        GPIO.setup(self.Relay_Ch1, GPIO.OUT)
        GPIO.setup(self.Relay_Ch2, GPIO.OUT)
        GPIO.setup(self.Relay_Ch3, GPIO.OUT)

         # takes a long time for the desk to rise up
        self.pressRaiseDeskButtonSeconds = int(os.getenv("DESK_PRESS_BUTTON_SECONDS", 10))
        self.minMinutesBeforeRaisingDesk = int(os.getenv("DESK_MIN_PERIOD_MINUTES", 45))
        self.maxTimeBeforeRaisingDesk = int(os.getenv("DESK_MAX_PERIOD_MINUTES", 60))
        log.info("initialized")

    def chatterRelay(self):
        log.info("chattering relay")
        for _ in itertools.repeat(None, 100):
            GPIO.output(self.Relay_Ch2, GPIO.LOW)
            sleep(2)
            GPIO.output(self.Relay_Ch2, GPIO.HIGH)
            sleep(2)

    def pressButton(self):
        GPIO.output(self.Relay_Ch1, GPIO.LOW)

    def releaseButton(self):
        GPIO.output(self.Relay_Ch1, GPIO.HIGH)

    def raiseDeskAndSleepForever(self):
        while True:
            log.info("desk raising")
            self.chatterRelay()
            ## if during "work hours" on a "work day"
            self.pressButton()
            sleep(self.pressRaiseDeskButtonSeconds)
            self.releaseButton()
            log.info("desk raised")
            sleep(60 * random.randint(self.minMinutesBeforeRaisingDesk, self.maxTimeBeforeRaisingDesk) * self.maxTimeBeforeRaisingDesk)

    def toggleButtonTest(self):
        log.info("toggleButtonTest")
        while True:
            print("on")
            self.pressButton()
            sleep(2)
            print("off")
            self.releaseButton()
            sleep(2)


    def main(self):
        # self.toggleButtonTest()

        self.raiseDeskAndSleepForever()


if __name__ == "__main__":
    raiseDesk = RaiseDesk()
    raiseDesk.main()

        
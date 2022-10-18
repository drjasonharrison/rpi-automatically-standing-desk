try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print(
        "Error importing RPi.GPIO!  This is probably because you need superuser privileges.\n"
        "  You can achieve this by using 'sudo' to run your script"
    )

import itertools
import logging
import os
import random
from time import sleep
import datetime
import pytz

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s"
)
log = logging.getLogger("raiseDesk")


class RaiseDesk:
    def __init__(self):
        self.logger = logging.getLogger("RaiseDesk")

        self.Relay_Ch1 = 26
        self.Relay_Ch2 = 20
        self.Relay_Ch3 = 21

        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)

        GPIO.setup(self.Relay_Ch1, GPIO.OUT)
        GPIO.setup(self.Relay_Ch2, GPIO.OUT)
        GPIO.setup(self.Relay_Ch3, GPIO.OUT)

        GPIO.output(self.Relay_Ch1, GPIO.HIGH)
        GPIO.output(self.Relay_Ch2, GPIO.HIGH)
        GPIO.output(self.Relay_Ch3, GPIO.HIGH)

        # takes a long time for the desk to rise up
        self.pressRaiseDeskButtonSeconds = int(
            os.getenv("DESK_PRESS_BUTTON_SECONDS", 10)
        )
        self.minMinutesBeforeRaisingDesk = int(os.getenv("DESK_MIN_PERIOD_MINUTES", 45))
        self.maxMinutesBeforeRaisingDesk = int(os.getenv("DESK_MAX_PERIOD_MINUTES", 60))
        self.raiseWarningChatterCycles = int(os.getenv("DESK_RAISE_WARNING_CYCLES", 10))
        self.timezone = pytz.timezone(os.getenv("DESK_TIME_ZONE", "US/Pacific"))

        log.info("initialized")

    def chatterRelay(self):
        log.info("chattering relay")
        for _ in itertools.repeat(None, self.raiseWarningChatterCycles):
            GPIO.output(self.Relay_Ch2, GPIO.LOW)
            sleep(1)
            GPIO.output(self.Relay_Ch2, GPIO.HIGH)
            sleep(1)

    def pressButton(self):
        GPIO.output(self.Relay_Ch1, GPIO.LOW)

    def releaseButton(self):
        GPIO.output(self.Relay_Ch1, GPIO.HIGH)

    def raiseDeskAndSleepForever(self):
        while True:
            # TODO: if during "work hours" on a "work day"
            self.chatterRelay()
            log.info("desk raising")

            self.pressButton()
            sleep(self.pressRaiseDeskButtonSeconds)
            self.releaseButton()
            log.info("desk raised")

            sleep_minutes = random.randint(
                self.minMinutesBeforeRaisingDesk, self.maxMinutesBeforeRaisingDesk
            )
            log.info("sleeping for %d minutes", sleep_minutes)

            raise_datetime = datetime.datetime.now(self.timezone) + datetime.timedelta(minutes=sleep_minutes)
            raise_datetime_str = raise_datetime.strftime('%Y-%m-%d %H-%M-%S')
            log.info("desk will raise at %s", raise_datetime_str)
            sleep(sleep_minutes * 60)

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

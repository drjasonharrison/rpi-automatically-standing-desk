from gpiozero import LED # The LED library allows easy pin control
import pigpio
from time import sleep
import random
import os
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(name)s %(levelname)s %(message)s'
)

class RaiseDesk:
    def __init__(self):
        self.logger = logging.getLogger('RaiseDesk')

        Relay_Ch1 = 26
        Relay_Ch2 = 20
        Relay_Ch3 = 21

        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)

        GPIO.setup(Relay_Ch1,GPIO.OUT)
        GPIO.setup(Relay_Ch2,GPIO.OUT)
        GPIO.setup(Relay_Ch3,GPIO.OUT)

         # takes a long time for the desk to rise up
        self.pressRaiseDeskButtonSeconds = os.getenv("DESK_PRESS_BUTTON_SECONDS", 8)
        self.minMinutesBeforeRaisingDesk = os.getenv("DESK_MIN_PERIOD_MINUTES", 45)
        self.maxTimeBeforeRaisingDesk = os.getenv("DESK_MAX_PERIOD_MINUTES", 60)

    def raiseDeskAndSleepForever(self):
        while True:
            ## if during "work hours" on a "work day"
            self.relay.on()
            sleep(self.pressRaiseDeskButtonSeconds)
            self.relay.off()
            sleep(60 * random.randint(self.minMinutesBeforeRaisingDesk, self.maxTimeBeforeRaisingDesk) * self.maxTimeBeforeRaisingDesk)

    def toggleRelayTest(self):
        while True:
            print("on")
            self.relay.on()
            sleep(2)
            print("off")
            self.relay.off()
            sleep(2)


    def main(self):
        # self.init()
        self.toggleRelayTest()

        self.raiseDeskAndSleepForever()


if __name__ == "__main__":
    raiseDesk = RaiseDesk()
    raiseDesk.main()

        
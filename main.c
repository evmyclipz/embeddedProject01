/*! \file */
/******************************************************************************
 * File Name: ece230_2122s_project2MalipeddiR.c
 * Author:  Rohan Malipeddi
 * Last-modified:  03/22/24
 *
 * Description: code that toggle blinking of an LED and toggle of LED color
 *
 *                MSP432P4111
 *             ------------------
 *         /|\|                  |
 *          | |            P1.4  |<--- S2
 *          --|RST         P1.1  |<--- S1
 *            |                  |
 *            |            P2.0  |---> LED2 red
 *            |            P2.1  |---> LED2 green
 *            |            P2.2  |---> LED2 blue
 *            |                  |
*******************************************************************************/
#include "msp.h"

/* Standard Includes */
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

/* Own Libraries */
#include "rgbLED.h"
#include "switches.h"

int pin = 1;        //initial pin value
bool isOn = false;  //initial state of LED

/*!
 * \brief This function just delays for 5 milli seconds
 *
 * \return none
 */
void delay5(void) {
    int i;
    for(i = 1500; i >= 0; i--);
}

/*!
 * \brief This function toggles pin of specified port
 *
 * This function toggles a pin for the specified output port
 *
 * \param outRegister is reference to OUT register of desired port.
 *
 * \param pin is the pin to toggle (0 for lsb, 7 for msb).
 *
 * Modified bit \a pin of \b PxOUT register indicated by \a outRegister.
 *
 * \return None
 */
void toggleNextLED() {
    // toggle the bit specified by pin for the OUT register referenced by outRegister
    pin = 1 << pin;
    RGB_PORT->OUT ^= pin;
}

/*
 * \brief turns all the LEDs off
 *
 * \return none
 */
void toggleLEDoff() {
    RGB_PORT->OUT &= 0xFFFFFFF8;    // clear the last 3 bits
    isOn = false;
}

/*
 * \brief is checking if the LED is on after toggling
 *
 *  Used for feature 4
 *
 * \return none
 */
void setIsOn() {
    int temp = RGB_PORT->OUT;  // saves the value onto temp to not lose data
    temp = temp & 0x7;         // clears everything except the last 3 bits
    if(temp) {
        isOn = true;
    }
    else {
        isOn = false;
    }
}

/*
 * \brief toggle the current LED to on or off
 */
void toggleCurrentLED() {
    RGB_PORT->OUT ^= pin;
}

/**
 * main.c
 */
void main(void)
{
    /* Stop Watchdog  */
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // keep this at top of program

    // call init functions and sets initial LED2 outputs LOW
    RGBLED_init();
    SWITCHES_init();

    //initial values for pressed and state flags
    bool pressed = false;
    bool state = false;

    // infinite loop which program enters once setup is complete
    while(1) {

        // wait for S1 pressed
        //while(!pressed) {
            if(!(SWITCH_PORT->IN & SWITCH_1)) {
            pressed = true;
            }
        //}

        // delay 5 ms
        delay5();

        // wait for S1 released
        //while(!state) {
            if((SWITCH_PORT->IN & SWITCH_1) && pressed) {
            state = true;
            }
        //}

        // delay 5 ms
        delay5();

        // Loop to blink LED
        while(state) {   // loop while Blink LED STATE is active

            // load counter for 500 ms
            int counter = 44000; // 45453

            // toggle LED2
            toggleCurrentLED();
            setIsOn();

            // 500ms delay loop
            while(counter > 0) {   // loop while counter is > 0


                // check S1 state
                if (!(SWITCH_PORT->IN & SWITCH_1)) { // if S1 pressed

                    // turn off LED2
                    toggleLEDoff();

                    // delay 5 ms
                    delay5();

                    // wait for S1 released
                    if(SWITCH_PORT->IN & SWITCH_1) {
                        // delay 5 ms
                        delay5();

                        // set Blink LED STATE to inactive
                        state = false;

                        // set pressed state to inactive
                        pressed = false;

                        // 'break' from 500ms delay loop
                        break;
                    }

                }   // end if S1 pressed

                // check s2 state
                if(!(SWITCH_PORT->IN & SWITCH_2) && isOn) { //if s2 is pressed

                    //turns whatever is on to off
                    toggleLEDoff();

                    //switch to another LED
                    if(pin == 4) {
                        // reset pin back to red
                        pin = 2 >> pin;

                        //light up the next LED
                        toggleNextLED();
                    }
                    else{
                        //light up next LED
                        toggleNextLED();
                    }

                    // switch debounce that exit once the switch is release
                    // ensures the LED toggle once per press and release of switch2
                    while(!(SWITCH_PORT->IN & SWITCH_2)) {  // while s2 is not released
                        continue;
                    }

                }

                // decrement counter

                counter--;

            }   // end 500ms delay loop

        }   // end Loop to blink LED

    }   // end infinite loop

}


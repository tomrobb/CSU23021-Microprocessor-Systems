# CSU23021-Microprocessor-Systems
A collection of programs I wrote for CSU23021 Microprocessor Systems, during my second year at Trinity College Dublin.

Assignments:
1. Factorial Subroutine
2. Polling
3. Interrupt Handling

---------------------

## Assignment 1 - Factorial Subroutine
Write a complete Keil MDK project comprising a main program and a subroutine.

The subroutine must be called ````fact```` and should calculate the factorial of the number passed to it in R0. The subroutine must be recursive. Zero marks will be awarded for a non-recursive solution. Calculations  must be done in 64-bit unsigned arithmetic and the result must be returned in R0 & R1.

If any error occurs, the C bit of the CPSR must be set and a result of 0 returned in R0 & R1. If there are no errors, the C bit must be clear.

The main program uses the subroutine four times:
1. Calculate the factorial of 5.
2. Calculate the factorial of 14.
3. Calculate the factorial of 20.
4. Calculate the factorial of 30

Each result should be stored, by the main program, as a 64-bit result in RAM, starting at 0x40000000. Do this by reserving four 8-byte spaces at the start of the read-write area.

Please create a plain text file called “qanda.txt” ( for Questions AND Answers) and include it in your project folder. In it, please answer the following questions very briefly (one or two sentences each, max):
1. What does “well behaved” mean in the context of subroutines?
2. Explain how/why your subroutine is “well behaved”.
3. How would you test that your subroutine is well behaved?
4. Why is using repeated addition to implement multiplication such a bad idea?
5. What would happen to the program if a very large number of recursive calls were made, i.e. if there was very "deep" recursion?

------------------

## Assignment 2 - Polling
Write a complete program for the Keil Development System that can run and be demonstrated in the Emulator.

The program should allow you to do simulated input and output on the simulated GPIO Port 1. The program should monitor inputs on Pins 24 to 27 and should provide a response on Pins 23 to 16 as follows:
-  Pins 23 -- 16 should be treated as a 8-bit number "D" whose value is initially 0. Pin 23 is the MSB, Pin 16 the LSB.
-  Pins 27 -- 24 should be treated as individual inputs, where a pin's value going from 1 to 0 is to be interpreted as a corresponding [imaginary] push-button being pressed and the transition from 0 to 1 is is to be interpreted as the release of the button. For example, if Button 23 is pressed and released, Pin 23's value will go from 1 to 0; then, when Button 23 is released, the value of Pin 23 will return from 0 to 1. You can click theses values in the emulator.

The program should do the following:
1. Pressing Button 24 should add 1 to the value of D.
2. Pressing Button 25 should subtract 1 from the value of D.
3. Pressing Button 26 should shift the bits in D to the left by one bit position.
4. Pressing Button 27 should shift the bits in D to the right by one bit position.

Please create a plain text file called “qanda.txt” ( for Questions AND Answers) and include it in your project folder. In it, please answer the following questions very briefly (one or two sentences each, max):
1. What does the term "Memory Mapped" in "Memory Mapped I/O" mean?
2. What is the difference between a byte-sized memory-mapped interface register and a regular byte of RAM?
3. Why is polling considered to be inefficient?
4. How could you organise polling of two or more interfaces?
5. Why would polling be bad for a computer's energy consumption?

----------------

## Assignment 3 - Interrupt Handling

Write a complete program for the Keil Development System that can run and be demonstrated in the Emulator.


The main program should "display" the elapsed time, in hours, minutes and seconds, since the program started running, on the 32 bits of GPIO 1 using Binary Code Decimal (BCD) format. As the time goes by, the "display" should update appropriately. It must be exact.

For example, say the time to display is ```12:34:56```. Each character occupies four bits (a "nybble") and  use "1111" as a spacer instead of of the ":". This means that the above time would appear as:

00010010111100110100111101010110

in the GPIO (that is: "1 2 1111 3 4 1111 5 6" or, in hexadecimal: ````0x12F34F56````).

The time should be absolutely exact -- that is, it should be as accurate as the hardware of the computer will allow. The program should consist of a main program (and subroutines, if necessary) an an interrupt handler. Once initialised, your program should run in the user mode.

You interrupt handler should somehow make use of one of the timers in the LPC2138. It should be extremely simple and very fast. It should do the absolute minimum necessary at interrupt level. Everything else should run in the main program. In particular, the interrupt handler must not have anything to do with the displaying of the elapsed time on the GPIO -- that is the responsibility of the main program.

The main program will consist basically of two parts:
1. The "initialisation" part of the main program sets everything up for subsequent operation. So, it must set up any data necessary, configure the timer and the Vectored Interrupt Controller and finally enable interrupts.
Note: It is really important to ensure everything is absolutely ready before you enable interrupts, because as soon as interrupts are enabled, it is possible that an interrupt will immediately occur. If all your initialisation is incomplete, then it may cause the interrupt handler to misbehave.
2. The "application" part that actually implements the display. As you know, the system starts up in a privileged mode. When the initialisation part of your main program is finished, make the rest of the program run in the User Mode. (Obviously, the interrupt handler will run in Interrupt Mode.)

Please answer each question very briefly, preferably in one sentence.
1. What is the difference between "system" mode and "supervisor" mode on the ARM 7?
2. When the term "preemptive" is used in respect of a thread or process scheduler, what does it mean? 
3. Based on what we have discussed in class, why it is inadvisable to use a general-purpose operating system in a situation where real-time operation must be guaranteed?
4. What basic hardware facilities are provided to enable system builders to enforce privilege outside the CPU ("off-chip")? 
5. Overall, which is more efficient: interrupt-driven I/O or polled I/O? In your answer, explain why and roughly estimate the difference in efficiency.













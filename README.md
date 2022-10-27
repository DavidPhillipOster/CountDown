# CountDown
a macOS program displaying countdown timers, each in its own resizable window.

## To Build:

* Open the Xcode project and in the Info panel of the CountDown target change the `com.example` prefix of the bundle Identifier from `com.example.${PRODUCT_NAME:rfc1034identifier}`  to a domain you control.

* Adjust how the code is signed by selecting the project in Xcode's file navigator, then the target, then in Xcode's Signing&Capabilities panel.

## Sample screen shot

![Countdown](/Art/Screenshot.png)

## To Use:

* Press the Info button for the panel to set the duration of the timer, what the text below the timer should say, and what sound to play when the timer is done.

* If you wish, you can save that timer as a named document, so when you open that document it will already be set up the way you want.

## License
Apache 2.

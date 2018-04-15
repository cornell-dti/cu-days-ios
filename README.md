CU Days v1.0
======
An app for accepted Cornell students and their families to view Cornell Day events. The **Android** branch can be found [here](https://github.com/cornell-dti/cu-days-android).
Based on the O-Week app [here](https://github.com/cornell-dti/o-week-ios).

<img src="https://raw.githubusercontent.com/cornell-dti/cu-days-ios/master/Screenshots/1.png" width="250px">  <img src="https://raw.githubusercontent.com/cornell-dti/cu-days-ios/master/Screenshots/2.png" width="250px">  <img src="https://raw.githubusercontent.com/cornell-dti/cu-days-ios/master/Screenshots/3.png" width="250px">

Getting Started
------
You will need **Xcode 9.3** to run the latest version of this app, which uses Swift 4 compiled for iOS 11. Xcode can be downloaded from the Mac App Store. Make sure you are not running a beta version of macOS, as Apple will prevent you from publishing to the App Store if you do.

Design Choices
------
 * Document every function and at the start of every class/enum/protocol. [Here](http://nshipster.com/swift-documentation) are the guidelines for documentation.
 * Syntax:
   * Indent with tabs.
   * Put curly braces on a new line, like so:
   ```swift
   if (blah)
   {
      doSomething()
      doSomethingElse()
   }
   ```
   * If a statement fits in a single line, curly braces don't have to go on a new line, like so:
   ```swift
   if (blah) {
      doSomething();
   }
   ```
   This is especially true for <code>get</code> and <code>guard</code> statements, where the curly braces aren't allowed to be on a new line.
   * ClassesShouldBeNamedLikeThis, as should enums and protocols. (upper camel case)
   * functionsShouldBeNamedLikeThis, as should non-static variables or let constants. (lower camel case)
   * STATIC_VARS_SHOULD_BE_NAMED_LIKE_THIS, as should any let constants (or variables whose values shouldn't be changed).
 
Used Libraries
------
Unlike Android, which manages its dependencies through Gradle, iOS requires CocoaPods and the editing of the Podfile in the main project directory. If you don't have CocoaPods installed on your computer, follow the instructions [here](https://cocoapods.org/) under the tabs **Install** and **Get Started**.
 * [PureLayout](https://github.com/PureLayout/PureLayout) is a set of extensions added unto UIView to make setting programmatic constraints easy and readable.
 * [PKHUD](https://github.com/pkluz/PKHUD) is an implementation of **Heads Up Displays** in iOS, used like Toasts in Android to provide feedback for user actions.
 * [Google Maps](https://developers.google.com/maps/documentation/ios-sdk/) and [Google Places](https://developers.google.com/places/ios-api/) is used to display locations based on place id (as opposed to coordinates).

Contributors
------
2018
 * **Julia Kruk** - Product Manager
 * **David Chu** - Product Manager
 * **Amanda Ong** - Front-End Developer
 * **Jagger Brulato** - Front-End Developer
 * **Qichen (Ethan) Hu** - Front-End Developer
 * **Arnav Ghosh** - Back-End Developer
 * **Adit Gupta** - Back-End Developer
 * **Jessica Zhao** - Back-End Developer
 * **Cedric Castillo** - Designer
 * **Lisa LaBarbera** - Designer
 * **Justin Park** - Designer
 
2017
 * **Julia Kruk** - Product Manager
 * **David Chu** - Product Manager
 * **Amanda Ong** - Front-End Developer
 * **Jagger Brulato** - Front-End Developer
 * **Qichen (Ethan) Hu** - Front-End Developer
 * **Arnav Ghosh** - Back-End Developer
 * **Adit Gupta** - Back-End Developer
 * **Cedric Castillo** - Designer
 * **Lisa LaBarbera** - Designer
 * **Justin Park** - Designer
 
2016
 * **Julia Kruk** - Product Manager
 * **Juhwan Park** - Product Manager
 * **David Chu** - Front-End Developer
 * **Vicente Caycedo** - Front-End Developer
 * **Arnav Ghosh** - Back-End Developer
 
We are a team within **Cornell Design & Tech Initiative**. For more information, see its website [here](http://cornelldti.org/).
<img src="http://cornelldti.org/img/logos/cornelldti-dark.png">

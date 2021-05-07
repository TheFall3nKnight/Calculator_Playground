# Calculator_Playground

* Playground File 

This is my first project coding in Swift. It is a calculator that can take a string input that contains a mathematical expression and computes it

For example:

Input: "8-81/3^2" -> Output: -1.0

In order to use this file please call the calculate function and input a string value. You will have to store the return value as a Double

There are a couple of quirks with this calculator:

This calcultor can do the following operations
"+", "-", "*", "/", "^" and deal with parentheses
In order to input a negative use the "~" symbol. When wanting to input a minus sign use the ordinary "-" symbol. 
When ever you want to raise an expression to a power ie 6 to the 4-5 power, you need to wrap the expression in parentheses.
For example:
Correct: 6^(4-5)
Incorrect: 6^4-5. This will first do 6^4 and then subtract 5.
Some calculators when raising a negative to a power without parentheses may only raise the number and not the negative as well. Mine doesn't do this instead it it reaises the whole thing to the power
For example:
My Calculator: ~3^2 = 9
Other Calculators: -3^2 = -9
My Calculator: ~(3^2) = -9
Other Calculator: (-3)^2 = 9
Since this is my first project, it is very long and I know that there are probably easier and more efficient ways doing what I did. There also might be some bugs. If you find any please let me know ASAP. I want to imrove this as much as I can.

You may need XCODE in order to run this or you can run this in a online compiler.

Click on the content.swift file to check out the project 

# framework-zero
A lightweight RESTful web app and microservice framework for Lucee

Zero is inspired by the [Framework-one (fw/1)](https://github.com/framework-one/fw1). Zero, however seeks to provde a better experience for type checked, RESTful and domain driven applications. Zero is based on Fw/1 and requires it, however diverges by removing dependency injection, changing the way controllers are executed, providing a cleaner RESTful experience out of the box, test first design, and sane default. In the future, Zero may be standalone, but fw/1 is very well designed for a number of things that are useful. 

##Zero Opinions
(That is, the opinions of Zero...)
Zero was designed with these goals in mind:

1. MVC is the Application layer in a Domain Driven Design. This means that controllers should deal only with HTTP request and Response values. All business logic exists within the Domain Model. 
2. Controllers should be testable and rely on the Lucee type system.
3. Easy RESTful & API Applications

###MVC as the Appliation Layer

###Testable Controllers

..1. Disuade use of "global" scopes like the RC (request context). Controllers should receive certain value, and return certain values, for use by the views, thus:
..2. Use arguments of a controller function to check for existence of URL & FORM variables, and return specific variables for use by the views. Views should only have access to the values returned by the controller.

###Easy RESTfull & API Applications



 

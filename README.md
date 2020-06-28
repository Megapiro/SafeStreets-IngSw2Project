# SafeStreets - Software Engineering II Project - a.y. 2019-2020

## Structure of this Repository
This repository contains all the files that we created in order to realize the final documents for the project. In particular the folders that you can find are:
* __Delivery Folder__: contains the delivered documents, the latest versions have the highest index
* __Presentation__: contains all the Tex files used to realize the final pdf ([presentation.pdf](https://github.com/Megapiro/PaccianiPiro/blob/master/DeliveryFolder/presentation.pdf))
* __dd__: contains all the Tex files used to realize the final pdf ([DD2.pdf](https://github.com/Megapiro/PaccianiPiro/blob/master/DeliveryFolder/DD2.pdf))
* __rasd__:contains all the Tex files used to realize the final ([RASD3.pdf](https://github.com/Megapiro/PaccianiPiro/blob/master/DeliveryFolder/RASD3.pdf))

## Project goal and approach
The objective of this project is to apply in practice what we learnt during lectures with the purpose of becoming familiar with software engineering practices and able to address new software engineering issues in a rigorous way. The project issues two assignments:
1. The preparation of a __Requirement Analysis and Specification Document (RASD)__ for the problem provided
2. The definition of the __Design Document (DD)__ for the system considered in point 1 above

## The problem: SafeStreets
SafeStreets is a crowd-sourced application that intends to provide users with the possibility to notify authorities when traffic violations occur, and in particular parking violations. The application allows users to send pictures of violations, including their date, time, and position, to authorities. Examples of violations are vehicles parked in the middle of bike lanes or in places reserved for people with disabilities, double parking, and so on.
* __Basic Service__: SafeStreets stores the information provided by users, completing it with suitable metadata. In particular, when it receives a picture, it runs an algorithm to read the license plate (one can also think of mechanisms with which the user can help with the recognition), and stores the retrieved information with the violation, including also the type of the violation (input by the user) and the name of the street where the violation occurred (which can be retrieved from the geographical position of the violation). In addition, the application allows both end users and authorities to mine the information that has been received, for example by highlighting the streets (or the areas) with the highest frequency of violations, or the vehicles that commit the most violations. Of course, different levels of visibility could be offered to different roles.

* __Advanced function 1__: If the municipality offers a service that allows users to retrieve the information about the accidents that occur on the territory of the municipality, SafeStreets can cross this information with its own data to identify potentially unsafe areas, and suggest possible interventions (e.g., add a barrier between the bike lane and the part of the road for motorized vehicles to prevent unsafe parking).

* __Advanced function 2__: In addition, the municipality (and, in particular, the local police) could offer a service that takes the information about the violations coming from SafeStreets, and generates traffic tickets from it. In this case, mechanisms should be put in place to ensure that the chain of custody of the information coming from the users is never broken, and the information is never altered (e.g., if a manipulation occurs at any point of the image showing the violation, for example to alter the license plate, the application should discard the information). In addition, the information about issued tickets can be used by SafeStreets to build statistics, for example about the most egregious offenders, or the effectiveness of the SafeStreets initiative (e.g., by looking for trends in the issuing of tickets).

The documents realized are based on the __basic service__ and the __first advanced functionality__.

## Contributors
[__Matteo Pacciani__](https://github.com/teopac165)

[__Francesco Piro__](https://github.com/Megapiro)

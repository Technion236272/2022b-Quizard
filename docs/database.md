# Database:

* You will need access to our firebase project 
-----------------------------------------------------------------------------------------------------------


### UnderStanding the Stucture : 

* As asked we put the whole structure in a Versions folder which contains V1 folder which is our Sprint 1 work 
* We are going to make other Folder name V2 for the second sprint which will be the final result of our project
* The Database inside V1 is understandable and easy to use since we dont have a large DB, 
* We have Three Collections :
* custom_games
* official_questions
* users

## users:
* This collection is used to save the players profiles information and info , Each player has a unique uid and his info is in it , 
* Each user has 3 Arrays , Questions Answers Categories , which are used to save custom questions and its category
* Each user also has 3 strings which are Email username and wins 

## official_questions:
* This Collection is used to save the developer's official questions which are approved by the developing team 
* IT has 2 arrays , Questions and Answers 

## custom_games:
* This Collection is used to save the player's custom games so it could be used later
* Each saved game has its uid , admin , questions answers

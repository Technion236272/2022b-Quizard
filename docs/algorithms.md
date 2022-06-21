# Algorithms

## Lobby

When the admin creates a game (either as private or public), a new game document will be created on Firebase with 5 empty slots, as the game was designed for 5 players only. Each slot is a map which contains a needed data about the player for the game: 
- his username
- if the player is ready to play or not
- his current score
- his current round score
- the submitted false answer
- the selected answer

When the admin creates a game, it's document will be named by random generated 6 digits of mix letters and numbers, and then the game can be found by any player who wish to join. Furthermore, public games can be found with a "find me an open game" button that chooses a random game from all the custom game documents that are set the is_private field to false and is_locked to false.

The first slot will be reserved for the admin. With a StreamBuilder as admin, the admin will wait for other players to join and can see them any moment  as a ListView. When someone joins the lobby, the first empty slot will be taken by writing his username into the document. The player can view the lobby by a seperate StreamBuilder as follows:
- Only the admin can view a kick icon per player. If the admin decides to kick the player from the lobby, he can click the icon and then the username string in his slot will be empty. When the stream of the player idicates that, he will exit to the previous screen automatically.
- Only the admin can change the categories for the current game, and the player can see the selected categories by the admin.
- Only the admin can toggle the room from locked to unlocked, and the player onlt can see the current status without changing it (return null onPress).

The admin can start the game iff there are at least 2 players in the lobby, which means there are at least 2 taken slots, and when all the players set ready to true value. When enabled, the admin can click "Start Game",
and the document will be updated with random questions, answers and categories (each as a list of strings, and the index indicates as the current question in the game), according to the selected categories by the admin.

If the admin exits the lobby before starting the game, the lobby will be closed, all the players will be auto kicked and the document will be erased.

Edge-case: if any player crashes the app during waiting in the lobby, when the player rejoins it won't try to take another open slot but rather update locally the current slot.

## Quick Play

A game mode without lobby. We refer it as an official game that counts toward the leaderboard by wins. The game demands 5 players (max players) in the party slots and there are always 5 random questions from the official categories only (which are stored in Firebase by arrays). Because there is no admin here, we use two cloud functions on Firebase for that:

- findQuickGameForNewPlayer: This function triggered when a player creates a document by starting Quick Play (contains his username and empty pin code field). The documents sits in a collection called "waiting room" with all the other players, waiting to start the game. The function first checks if the player already joined to a party which didn't start the game (set to unlocked by boolean field) and if he did then the function updates the pin code's player with that party's pin code. Else, the function tries to find an already open game with empty slot to put the player in. If there is no empty slot, the game creates a new game document as unlocked game, with a pin code that is the document's id auto generated when created.
- initiateGameForFullParty: This function triggered when a game has a full party in it. Then 5 questions will be built randomly from the current database and each player will indicate that the game is ready with StreamBuilder when the game will be locked.

## Gameplay

There is a timer for each player in his own app that runs for 30 seconds for each screen. There are two main StreamBuilders for each game screen:

- First Screen: Everyone enters a false answer. If all the players entered a false answer before the time runs out (indicated with a streamer) then everyone navigating to the second screen. Else, the time runs out and then all the players are forced to navigate to the next screen without waiting anymore for false answers by entering an empty false answer (this string: " "), and then all the streamers will be triggered.
- Second Screen: Everyone are trying to select the correct answer. among all the options available. When everyone selected an answer before the time runs out (indicated with a streamer) then the results are shown simultaniously for all the players and after 3 seconds (by a Timer) all the players will be navigated to the first screen. Else, the time runs out and then all the players will be forced to navigate to the first screen by selecting an empty selected answer (this string: " "), and then all the streamers will be triggered. Each player holds the number of rounds per game, and accordingly will navigate to the final scoreboard instead for the first screen if needed.

Edge-case1: if a player pauses the game by moving the app to the backgournd this might delay his timer, and thus the game will indicate that with didChangeAppLifecycleState function that triggered if the state change to paused, and immediately will kick the player from the game by local logic (no a cloud function needed for that).

Edge-case2: if a player's app got crashed then the game will refer to him as a player that didn't enter any input. Because the game must go forward from screen to screen with inputs of all players (even empty inputs as mentioned above) then there is a "timer-exit-handler" which was implemented for this very specific case. This timer waits a little more than the game should exist and by any case will navigate to the next required screen. The exited player won't be able to come back as all games are getting locked at the beginning of the game to keep the integrity of the game.

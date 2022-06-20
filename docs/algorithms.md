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

## Gameplay

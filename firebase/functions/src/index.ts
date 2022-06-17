import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

export const findQuickGameForNewPlayer = functions.firestore
    .document("versions/{v2}/official_games/{waiting_room}/players/{playerId}")
    .onCreate(async (player, context) => {
      const db = admin.firestore();
      const maxPlayers = 2; // TODO: Change to 5
      const playerUsername = await player.get("username");
      const playerId = context.params.playerId;
      const gamesRef = db.collection("versions/v2/official_games");
      const playerRef = db
          .collection("versions/v2/official_games/waiting_room/players")
          .doc(playerId);

      let foundGame = false;

      // first check if already joined
      await gamesRef.get().then((games) => {
        games.forEach(async (game) => {
          // get index of duplicate username if exists
          let alreadyExistIndex = -1;
          for (let j = 0; j < maxPlayers; j++) {
            if (!foundGame && alreadyExistIndex == -1 &&
              await game.get(`player${j}.username`) == playerUsername) {
              alreadyExistIndex = j;
            }
            if (alreadyExistIndex != -1 &&
              await game.get("is_locked") == false) {
              // if found me in unlocked game then join
              await playerRef.update({"pin_code": game.id});
              foundGame = true;
            }
          }
        });
      });

      if (foundGame) {
        console.log("found myself in open game");
        return;
      }

      // then try to find an open slot
      await gamesRef.get().then(async (games) => {
        for (let j = 0; j < games.size; j++) {
          const game = games.docs[j];
          for (let i = 0; i < maxPlayers; i++) {
            if (await game.get(`player${i}.username`) == "" &&
            await game.get("is_locked") == false) {
              // and then catch the open slot with transaction
              try {
                foundGame = await db.runTransaction(async (transaction) => {
                  const doc = await transaction.get(game.ref);
                  const playerSlot = await doc.get(`player${i}`);
                  playerSlot["username"] = playerUsername;
                  if (i == 0) {
                    transaction.update(game.ref, {player0: playerSlot});
                  }
                  if (i == 1) {
                    transaction.update(game.ref, {player1: playerSlot});
                  }
                  if (i == 2) {
                    transaction.update(game.ref, {player2: playerSlot});
                  }
                  if (i == 3) {
                    transaction.update(game.ref, {player3: playerSlot});
                  }
                  if (i == 4) {
                    transaction.update(game.ref, {player4: playerSlot});
                  }
                }).then(async () => {
                  await playerRef.update({"pin_code": game.id});
                  return true;
                });
              } catch (e) {
                console.log("Transaction failed. ", e);
                return false;
              }
              if (foundGame) {
                console.log("found and catched open slot");
                return;
              }
            }
          }
        }

        // from here, not found so create a new game
        console.log("creating new game");

        const mapAdmin = {
          "username": "",
          "false_answer": "",
          "selected_answer": "",
          "score": 0,
          "round_score": 0,
        };
        mapAdmin["username"] = playerUsername;

        const mapPlayer = {
          "username": "",
          "false_answer": "",
          "selected_answer": "",
          "score": 0,
          "round_score": 0,
        };

        const game = {
          "player0": mapAdmin,
          "player1": mapPlayer,
          "player2": mapPlayer,
          "player3": mapPlayer,
          "player4": mapPlayer,
          "is_locked": false,
          "questions": [],
          "answers": [],
          "categories": [],
        };

        await playerRef.get().then(async (player) => {
          if (await player.get("pin_code") == "") {
            const newGame = gamesRef.doc();
            await newGame.set(game);
            await playerRef.update({"pin_code": newGame.id});
          }
        });

        return;
      });
    });

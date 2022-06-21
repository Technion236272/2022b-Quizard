/* eslint linebreak-style: ["error", "windows"] */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();
const maxPlayers = 5;

export const findQuickGameForNewPlayer = functions.firestore
    .document("versions/{v2}/official_games/{waiting_room}/players/{playerId}")
    .onWrite(async (player, context) => {
      if (!player.after.exists) {
      // Ignore delete operations
        console.log("ignoring delete operation");
        return;
      }

      const playerUsername = await player.after.get("username");
      const playerPinCode = await player.after.get("pin_code");
      const playerId = context.params.playerId;
      const gamesRef = db.collection("versions/v2/official_games");
      const playerRef = db
          .collection("versions/v2/official_games/waiting_room/players")
          .doc(playerId);

      let foundGame = false;

      if (playerPinCode != "") {
      // Ignore players that already found game
        console.log("player already found game. goodbye.");
        return;
      }

      // first check if already appears in unlocked game
      await gamesRef.get().then(async (games) => {
        for (let i = 0; i < games.size; i++) {
          const game = games.docs[i];
          // get index of duplicate username if exists
          for (let j = 0; j < maxPlayers; j++) {
            if (await game.get(`player${j}.username`) == playerUsername &&
            await game.get("is_locked") == false) {
              await playerRef.update({"pin_code": game.id});
              foundGame = true;
              break;
            }
          }
          if (foundGame) {
            break;
          }
        }
      });

      if (foundGame) {
        console.log("found player in unlocked game. goodbye.");
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
          "is_official": true,
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

/**
 * @param {number} min The first number.
 * @param {number} max The second number.
 * @return {number} Random number between min (inclusive) and max (inclusive).
 */
function getRandomBetween(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

const roundsPerGame = 5;

export const initiateGameForFullParty = functions.firestore
    .document("versions/{v2}/official_games/{changedGameId}")
    .onWrite(async (changedGame) => {
      if (!changedGame.after.exists) {
      // Ignore delete operations
        console.log("ignoring delete operation");
        return;
      }

      if (changedGame.after.id == "waiting_room") {
      // Ignore waiting room
        console.log("ignoring waiting room");
        return;
      }

      const isLocked = await changedGame.after.get("is_locked");
      if (isLocked) {
      // Ignore built games
        console.log("ignoring built game");
        return;
      }

      // check if party is full
      for (let i = 0; i < maxPlayers; i++) {
        const username = await changedGame.after.get(`player${i}.username`);
        if (username == "") {
          console.log("party is not full yet");
          return;
        }
      }

      // from here party is full and we can start game
      console.log("party is full. initiating game...");

      // gather all trivia data first
      const allQuestions: string[] = [];
      const allAnswers: string[] = [];
      const allCategories: string[] = [];
      const questionsRef = db.collection("versions/v1/official_questions");
      const triviaSnap = await questionsRef.get();
      const numOfCategories = triviaSnap.docs.length;
      console.log("number of categories on firestore: ", numOfCategories);
      for (let i = 0; i < numOfCategories; i++) {
        const categoryDoc = triviaSnap.docs[i];
        const categoryStr = categoryDoc.id;
        const questions: string[] = await categoryDoc.get("questions");
        const answers: string[] = await categoryDoc.get("answers");
        for (let j = 0; j < questions.length; j++) {
          allQuestions.push(questions[j]);
          allAnswers.push(answers[j]);
          allCategories.push(categoryStr);
        }
      }

      console.log("built trivia. size: ", allQuestions.length);
      console.log("choosing random indexes...");

      // generate unique random indexes
      const randomIndexes: number[] = [];
      while (randomIndexes.length < roundsPerGame) {
        const random = getRandomBetween(0, allQuestions.length - 1);
        if (!randomIndexes.includes(random)) {
          randomIndexes.push(random);
        }
      }

      console.log("generated indexes. building questions...");

      // build the trivia
      const builtQuestions = [];
      const builtAnswers = [];
      const builtCategories = [];
      for (let i = 0; i < roundsPerGame; i++) {
        builtQuestions.push(allQuestions[randomIndexes[i]]);
        builtAnswers.push(allAnswers[randomIndexes[i]]);
        builtCategories.push(allCategories[randomIndexes[i]]);
      }

      console.log("new game is ready. updating firestore...");

      await changedGame.after.ref.update(
          {
            "questions": builtQuestions,
            "answers": builtAnswers,
            "categories": builtCategories,
            "is_locked": true,
            "is_official": true,
          });

      console.log("done.");
      return;
    });

exports.resetDailyWinsForUsers = functions.pubsub
    .schedule("0 0 * * *")
    .onRun(async () => {
      const users = db.collection("versions/v2/users");
      const user = await users.get();
      user.forEach((snapshot) => {
        snapshot.ref.update({DailyWins: 0});
      });
      return null;
    });

exports.resetMonthlyWinsForUsers = functions.pubsub
    .schedule("0 0 1 * *")
    .onRun(async () => {
      const users = db.collection("versions/v2/users");
      const user = await users.get();
      user.forEach((snapshot) => {
        snapshot.ref.update({MonthlyWins: 0});
      });
      return null;
    });

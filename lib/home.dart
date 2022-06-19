import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import 'join_game.dart';
import 'quick_play.dart';
import 'ModelClasses/leader_board_model.dart';
import 'game/lobby/admin.dart';
import 'localization/classes/language_constants.dart';
import 'profile/profile.dart';
import 'consts.dart';
import 'providers.dart';

class Rules extends StatelessWidget {
  const Rules({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            child: const Icon(
                              Icons.arrow_back,
                              color: defaultColor,
                              size: appbarIconSize,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            })
                      ]),
                  const Padding(padding: EdgeInsets.all(20)),
                  const Image(image: AssetImage('images/titles/rules.png')),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(
                    decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(translation(context).players,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Padding(padding: EdgeInsets.all(2)),
                          const Text(
                            '2-5',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 16),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(translation(context).goal,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Padding(padding: EdgeInsets.all(2)),
                          Text(
                            translation(context).infoText1,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(translation(context).roundGameplay,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Padding(padding: EdgeInsets.all(3)),
                          Text(
                            translation(context).infoText2,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            translation(context).infoText3,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            translation(context).infoText4,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            translation(context).infoText5,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 150,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(translation(context).bonuses,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Padding(padding: EdgeInsets.all(3)),
                          Text(
                            translation(context).infoText6,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            translation(context).infoText7,
                            style: const TextStyle(
                                color: darkGreyColor, fontSize: 16),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                ]))));
  }
}

class QuizardAppBar extends StatelessWidget with PreferredSizeWidget {
  QuizardAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                        child: const Icon(
                          Icons.info_outline,
                          color: defaultColor,
                          size: appbarIconSize,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (context) => const Rules()));
                        })
                  ],
                ))));
  }

  @override
  Size get preferredSize => const Size(0, appbarSize);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final profileScreen = Profile();

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Hide navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    void _onOptionTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    Widget _chooseWidget() {
      if (_currentIndex == 1) {
        return const Play();
      }
      if (_currentIndex == 2) {
        return const Leaderboard();
      }
      return profileScreen;
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: QuizardAppBar(),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: translation(context).profile,
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.gamepad),
                label: translation(context).play,
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.crown),
                label: translation(context).leaderboard,
              ),
            ],
            currentIndex: _currentIndex,
            backgroundColor: defaultColor,
            selectedItemColor: backgroundColor,
            unselectedItemColor: secondaryColor,
            onTap: _onOptionTapped,
          ),
          body: _chooseWidget());
    });
  }
}

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  State<Play> createState() => _PlayState();
}

class _PlayState extends State<Play> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final loginModel = Provider.of<LoginModel>(context, listen: false);

    Future<void> _initializeGame() async {
      gameModel.setDataToPlayer("username", loginModel.username, 0);
      gameModel.pinCode = randomAlphaNumeric(6).toUpperCase();
      var games = FirebaseFirestore.instance
          .collection('$firestoreMainPath/${gameModel.gamePath}');
      Map<String, dynamic> mapAdmin = {
        "username": loginModel.username,
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      };
      final game = <String, dynamic>{
        "player0": mapAdmin, // Admin is always player0
        "is_private": gameModel.isPrivate,
        "is_locked": gameModel.isLocked,
        "is_official": false,
        "official_categories": gameModel.officialCategories,
        "custom_categories": gameModel.customCategories,
        "questions": [],
        "answers": [],
        "categories": []
      };
      Map<String, dynamic> mapPlayer = {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      };
      for (int i = 1; i < maxPlayers; i++) {
        game.addAll({"player$i": mapPlayer});
      }
      await games.doc(gameModel.pinCode).set(game);
    }

    InkWell _playOptionButton(String imgPath) {
      void _navigateToGame() async {
        setState(() {
          _navigated = true;
        });
        if (imgPath.contains('create')) {
          gameModel.resetData();
          gameModel.isPrivate = false;
          if (imgPath.contains('private')) {
            gameModel.isPrivate = true;
          }
          var lobby = LobbyAdmin(isPrivate: gameModel.isPrivate);
          _initializeGame();
          await Future.delayed(const Duration(milliseconds: 200));
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (context) => lobby));
        }
        if (imgPath.contains('join_existing')) {
          gameModel.resetData();
          await Future.delayed(const Duration(milliseconds: 200));
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const JoinGame(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
          // Show navigation buttons
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: [SystemUiOverlay.bottom]);
        }
        if (imgPath.contains('quick_play')) {
          gameModel.resetData();
          final playersRef = FirebaseFirestore.instance
              .collection("$firestoreMainPath/official_games/"
                  "waiting_room/players");
          Map<String, dynamic> data = {
            "username": loginModel.username,
            "pin_code": ""
          };
          final myPlayerDocRef = playersRef.doc(loginModel.userId);
          await myPlayerDocRef.set(data);
          await Future.delayed(const Duration(milliseconds: 200));
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const QuickPlay(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }

        setState(() {
          _navigated = false;
        });
      }

      return InkWell(
        splashColor: defaultColor,
        onTap: _navigated ? null : _navigateToGame,
        child: Padding(
            padding: const EdgeInsets.all(7),
            child: AspectRatio(
                aspectRatio: 1, // square
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: playOptionColor,
                      boxShadow: const [
                        BoxShadow(color: defaultColor, spreadRadius: 2),
                      ],
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image(image: AssetImage(imgPath)))))),
      );
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Image(image: AssetImage('images/titles/quizard.png')),
                Text(translation(context).goodLuck + ' ${loginModel.username}!',
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: _playOptionButton(
                                'images/titles/quick_play.png')),
                        Expanded(
                            child: _playOptionButton(
                                'images/titles/create_public.png')),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: _playOptionButton(
                                'images/titles/join_existing.png')),
                        Expanded(
                            child: _playOptionButton(
                                'images/titles/create_private.png')),
                      ],
                    ),
                  ],
                ),
                Container()
              ]));
    });
  }
}

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard>
    with TickerProviderStateMixin {
  List<LeaderBoardModel> dailyWinsList = [];
  List<LeaderBoardModel> monthlyWinsList = [];
  List<LeaderBoardModel> allTimeWinsList = [];
  int _lastTab = 0;
  int myRankDailyWins = 0;
  int myRankMonthlyWins = 0;
  int myRankAllTimeWins = 0;

  late TabController _tabController;

  void _onTapTab(int index) {
    setState(() {
      _lastTab = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 114;

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      if (allTimeWinsList.isEmpty) {
        getWinsData(loginModel.userId);
      }
      return Container(
          color: secondaryBackgroundColor,
          height: screenHeight,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                height: screenHeight * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      loginModel.username,
                      style: const TextStyle(fontSize: 24, color: defaultColor),
                    ),
                    Expanded(child: Container()),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      color: defaultColor.withOpacity(0.1),
                    ),
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${loginModel.wins}",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: defaultColor.withOpacity(.5)),
                            ),
                            Text(
                              translation(context).wins,
                              style: const TextStyle(
                                  fontSize: 18, color: defaultColor),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              myRankAllTimeWins.toString(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: defaultColor.withOpacity(.5)),
                            ),
                            Text(
                              translation(context).rank,
                              style: const TextStyle(
                                  fontSize: 18, color: defaultColor),
                            ),
                          ],
                        )
                      ],
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                decoration: const BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(boxRadiusConst)))),
            Expanded(
                child: DefaultTabController(
              initialIndex: _lastTab,
              length: 3,
              child: Scaffold(
                backgroundColor: secondaryColor,
                appBar: AppBar(
                  backgroundColor: secondaryBackgroundColor,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  elevation: 2,
                  bottom: TabBar(
                    controller: _tabController,
                    onTap: _onTapTab,
                    labelColor: defaultColor,
                    indicatorColor: defaultColor,
                    tabs: [
                      Tab(text: translation(context).daily),
                      Tab(
                        text: translation(context).monthly,
                      ),
                      Tab(
                        text: translation(context).allTime,
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                        color: secondaryBackgroundColor,
                        child: ListView.builder(
                            itemCount: dailyWinsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return leaderBoardListItemWidget(
                                  screenHeight,
                                  index + 1,
                                  dailyWinsList[index].name,
                                  dailyWinsList[index].profileImageLink,
                                  dailyWinsList[index].wins);
                            })),
                    Container(
                        color: secondaryBackgroundColor,
                        child: ListView.builder(
                            itemCount: monthlyWinsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return leaderBoardListItemWidget(
                                  screenHeight,
                                  index + 1,
                                  monthlyWinsList[index].name,
                                  monthlyWinsList[index].profileImageLink,
                                  monthlyWinsList[index].wins);
                            })),
                    Container(
                        color: secondaryBackgroundColor,
                        child: ListView.builder(
                            itemCount: allTimeWinsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return leaderBoardListItemWidget(
                                  screenHeight,
                                  index + 1,
                                  allTimeWinsList[index].name,
                                  allTimeWinsList[index].profileImageLink,
                                  allTimeWinsList[index].wins);
                            })),
                  ],
                ),
              ),
            )),
          ]));
    });
  }

  Widget leaderBoardListItemWidget(
      screenHeight, index, name, profileImageLink, wins) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "#$index",
                  style: const TextStyle(fontSize: 18, color: defaultColor),
                ),
              ),
              Expanded(
                flex: 9,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageLink),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 18, color: defaultColor.withOpacity(0.5)),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Text(
                    "$wins",
                    style: const TextStyle(fontSize: 18, color: defaultColor),
                  )),
            ],
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(0.5),
              width: MediaQuery.of(context).size.width,
            ))
      ],
    );
  }

  void getWinsData(userId) {
    FirebaseFirestore.instance
        .collection('versions/v2/users')
        .get()
        .then((users) async {
      dailyWinsList.clear();
      monthlyWinsList.clear();
      allTimeWinsList.clear();
      List<LeaderBoardModel> tempDailyWinsList = [];
      List<LeaderBoardModel> tempMonthlyWinsList = [];
      List<LeaderBoardModel> tempAllTimeWinsList = [];

      for (var user in users.docs) {
        var url = "";
        try {
          final ref =
              FirebaseStorage.instance.ref('images/profiles/${user.id}.jpg');
          url = await ref.getDownloadURL();
        } catch (e) {
          url = "";
          debugPrint("No image found");
        }

        if (url == "") {
          try {
            url = user["photoLink"];
          } catch (e) {
            debugPrint("PhotoLink not present");
          }
        }

        tempAllTimeWinsList.add(
            LeaderBoardModel(user.id, user["username"], url, user["wins"]));

        try {
          tempDailyWinsList.add(LeaderBoardModel(
              user.id, user["username"], url, user["DailyWins"]));
        } catch (e) {
          debugPrint(
              "ERROR in getting dailyWins for user id = ${user.id} = $e");
        }

        try {
          tempMonthlyWinsList.add(LeaderBoardModel(
              user.id, user["username"], url, user["MonthlyWins"]));
        } catch (e) {
          debugPrint(
              "ERROR in getting MonthlyWins for user id = ${user.id} = $e");
        }
      }

      setState(() {
        tempAllTimeWinsList.sort((a, b) => a.wins.compareTo(b.wins));
        tempDailyWinsList.sort((a, b) => a.wins.compareTo(b.wins));
        tempMonthlyWinsList.sort((a, b) => a.wins.compareTo(b.wins));

        allTimeWinsList.addAll(tempAllTimeWinsList.reversed.toList());
        dailyWinsList.addAll(tempDailyWinsList.reversed.toList());
        monthlyWinsList.addAll(tempMonthlyWinsList.reversed.toList());

        getMyRanks(userId);
        debugPrint("All Data Added");
      });
    });
  }

  void getMyRanks(myUserId) {
    for (LeaderBoardModel leaderBoardModel in dailyWinsList) {
      if (leaderBoardModel.userId == myUserId) {
        myRankDailyWins = dailyWinsList.indexOf(leaderBoardModel) + 1;
      }
    }

    for (LeaderBoardModel leaderBoardModel in monthlyWinsList) {
      if (leaderBoardModel.userId == myUserId) {
        myRankMonthlyWins = monthlyWinsList.indexOf(leaderBoardModel) + 1;
      }
    }

    for (LeaderBoardModel leaderBoardModel in allTimeWinsList) {
      if (leaderBoardModel.userId == myUserId) {
        myRankAllTimeWins = allTimeWinsList.indexOf(leaderBoardModel) + 1;
      }
    }
  }

  String getRank(tabIndex) {
    if (tabIndex == 0) {
      return myRankDailyWins.toString();
    } else if (tabIndex == 1) {
      return myRankMonthlyWins.toString();
    } else {
      return myRankAllTimeWins.toString();
    }
  }
}

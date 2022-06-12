import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizard/join_game.dart';
import 'package:random_string/random_string.dart';

import 'ModelClasses/leader_board_model.dart';
import 'lobby_admin.dart';
import 'profile.dart';
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
                child: Column(children: <Widget>[
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
                  const Padding(padding: EdgeInsets.all(18)),
                  const Image(image: AssetImage('images/titles/rules.png')),
                  const Padding(padding: EdgeInsets.all(15)),
                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 70,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Players',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                          Padding(padding: EdgeInsets.all(2)),
                          Text(
                            '2-5',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 70,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Goal',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                          Padding(padding: EdgeInsets.all(2)),
                          Text(
                            'The player with the highest score wins.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 260,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Round Gameplay\n',
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                          Text(
                            '-Each player enters a false answer.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Text(
                            '-All the false answers are shown with the right answer to all players.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Text(
                            '-Players are rewarded with points for choosing the right answer.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Text(
                            '-Players are rewarded with points for every player choosing their false answer.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                        ]),
                    padding: const EdgeInsets.all(10),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 150,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Bonuses',
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                          Padding(padding: EdgeInsets.all(10)),
                          Text(
                            '-Players are rewarded for choosing the right answer multiple times in a row.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Text(
                            '-Faster answer means more points.',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
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
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.gamepad),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.crown),
                label: 'Leaderboard',
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

class Play extends StatelessWidget {
  const Play({Key? key}) : super(key: key);

  Future<void> _initializeGame(
      GameModel gameModel, LoginModel loginModel) async {
    gameModel.setDataToPlayer("username", loginModel.username, 0);
    gameModel.pinCode = randomAlphaNumeric(6).toUpperCase();
    var games =
        FirebaseFirestore.instance.collection('$strVersion/custom_games');
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
      "official_categories": gameModel.officialCategories,
      "custom_categories": gameModel.customCategories,
      "questions": [],
      "answers": [],
      "categories": [],
    };
    Map<String, dynamic> mapPlayer = {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": "",
      "score": 0,
    };
    for (int i = 1; i < maxPlayers; i++) {
      game.addAll({"player$i": mapPlayer});
    }
    await games.doc(gameModel.pinCode).set(game);
  }

  @override
  Widget build(BuildContext context) {
    InkWell _playOptionButton(String imgPath) {
      return InkWell(
        splashColor: defaultColor,
        onTap: () async {
          // TODO: Support all games!
          final gameModel = Provider.of<GameModel>(context, listen: false);
          final loginModel = Provider.of<LoginModel>(context, listen: false);
          if (imgPath.contains('create_private')) {
            gameModel.resetData();
            gameModel.isPrivate = true;
            _initializeGame(gameModel, loginModel);
            await Future.delayed(const Duration(milliseconds: 200));
            Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => const LobbyAdmin()));
          }
          if (imgPath.contains('join_existing')) {
            gameModel.resetData();
            await Future.delayed(const Duration(milliseconds: 200));
            Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (context) => JoinGame()));
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(7),
            child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: playOptionColor,
                  boxShadow: const [
                    BoxShadow(color: defaultColor, spreadRadius: 2),
                  ],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image(image: AssetImage(imgPath))))),
      );
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Image(image: AssetImage('images/titles/quizard.png')),
              Text(
                'Good luck, ${loginModel.username}!',
                style: const TextStyle(fontSize: 18),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/quick_play.png'),
                      _playOptionButton('images/titles/create_public.png'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/join_existing.png'),
                      _playOptionButton('images/titles/create_private.png'),
                    ],
                  ),
                ],
              ),
              Container()
            ]),
      );
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
                            const Text(
                              "Wins",
                              style:
                                  TextStyle(fontSize: 18, color: defaultColor),
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
                            const Text(
                              "Rank",
                              style:
                                  TextStyle(fontSize: 18, color: defaultColor),
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
                    tabs: const [
                      Tab(text: "DAILY"),
                      Tab(
                        text: "MONTHLY",
                      ),
                      Tab(
                        text: "ALL TIME",
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
          print("No image found");
        }

        if (url == "") {
          try {
            url = user["photoLink"];
          } catch (e) {
            print("PhotoLink not present");
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

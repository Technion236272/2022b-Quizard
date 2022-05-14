import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'providers.dart';

class Questions extends StatefulWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  Future<String> _getStatus(String category, String question) async {
    String retVal = '';
    await FirebaseFirestore.instance
        .collection('trivia')
        .doc(category)
        .get()
        .then((value) {
      for (int i = 0; i < value["questions"].length; i++) {
        if (value["questions"][i] == question) {
          retVal = value["status"][i];
          break;
        }
      }
    });
    return retVal;
  }

  Future<bool> _isOfficialCategory(String category) async {
    bool retVal = false;
    await FirebaseFirestore.instance
        .collection('trivia')
        .doc(category)
        .get()
        .then((value) {
      retVal = value["is_official"];
    });
    return retVal;
  }

  Future<Row> _rowCategory(String category, String question) async {
    bool isOfficialCategory = await _isOfficialCategory(category);
    if (isOfficialCategory) {
      String status = await _getStatus(category, question);
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(category), Text(status)]);
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text(category)]);
    }
  }

  Future<List<Card>> _questionsListWidget(String username) async {
    List<Card> trivia = <Card>[];
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore.collection('users').doc(username).get().then((value) async {
      List questions = value["questions"];
      List answers = value["answers"];
      List categories = value["categories"];
      for (int i = 0; i < questions.length; i++) {
        Row currentRow = await _rowCategory(categories[i], questions[i]);
        trivia.add(Card(
          child: SizedBox(
              height: 150,
              child: Column(
                children: [
                  currentRow,
                  Center(child: Text(questions[i])),
                  Center(child: Text(answers[i]))
                ],
              )),
        ));
      }
    });
    return trivia;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          backgroundColor: secondaryBackgroundColor,
          body: FutureBuilder(
            future: _questionsListWidget(loginModel.username),
            builder:
                (BuildContext context, AsyncSnapshot<List<Card>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Add questions here for custom games."));
                } else {
                  return ListView(children: snapshot.data!);
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ));
    });
  }
}

class Profile extends StatelessWidget {
  int _lastTab = 0;

  void _onTapTab(int index) {
    _lastTab = index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(boxRadiusConst)),
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                      child: CircleAvatar(
                          backgroundImage: loginModel.getUserImage(),
                          backgroundColor: secondProfileColor,
                          radius: 35)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                        child: Text(
                          loginModel.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 26,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Text(
                          loginModel.email,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  )
                ]),
                Expanded(
                    child: DefaultTabController(
                  initialIndex: _lastTab,
                  length: 3,
                  child: Scaffold(
                    backgroundColor: secondaryColor,
                    appBar: AppBar(
                      backgroundColor: secondProfileColor,
                      automaticallyImplyLeading: false,
                      toolbarHeight: 0,
                      elevation: 0,
                      bottom: TabBar(
                        onTap: _onTapTab,
                        labelColor: defaultColor,
                        indicatorColor: defaultColor,
                        tabs: const [
                          Tab(
                              icon: Icon(Icons.question_mark),
                              text: "QUESTIONS"),
                          Tab(
                            icon: Icon(Icons.tag_faces),
                            text: "FRIENDS",
                          ),
                          Tab(
                            icon: Icon(Icons.settings),
                            text: "SETTINGS",
                          ),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Questions()),
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Icon(Icons.tag_faces)),
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Icon(Icons.settings)),
                      ],
                    ),
                  ),
                ))
              ])));
    });
  }
}

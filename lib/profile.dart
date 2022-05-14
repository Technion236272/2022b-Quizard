import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  Future<List<Dismissible>> _questionsListWidget(String username) async {
    List<Dismissible> trivia = <Dismissible>[];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get()
        .then((value) async {
      List questions = value["questions"];
      List answers = value["answers"];
      List categories = value["categories"];
      for (int i = 0; i < questions.length; i++) {
        trivia.add(Dismissible(
            key: UniqueKey(),
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Attention"),
                    content: const Text(
                        "Are you sure you wish to delete this question?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () async {
                            questions.removeAt(i);
                            answers.removeAt(i);
                            categories.removeAt(i);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(username)
                                .update({
                              "questions": questions,
                              "answers": answers,
                              "categories": categories,
                            }).then((_) {
                              Navigator.of(context).pop(true);
                            });
                          },
                          child: const Text("DELETE")),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.red,
              child: const Icon(Icons.delete),
              alignment: AlignmentDirectional.centerStart,
            ),
            direction: DismissDirection.startToEnd,
            child: ExpansionTile(
                childrenPadding: EdgeInsets.zero,
                title: Text(categories[i]),
                subtitle:
                    Text(questions[i], style: const TextStyle(fontSize: 20)),
                children: <Widget>[
                  ListTile(
                      title: Text(answers[i],
                          style: const TextStyle(fontSize: 18))),
                ])));
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
            builder: (BuildContext context,
                AsyncSnapshot<List<Dismissible>> snapshot) {
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

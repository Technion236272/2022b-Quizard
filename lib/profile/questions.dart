import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../consts.dart';
import '../localization/classes/language_constants.dart';
import '../providers.dart';

class AddQuestionForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  AddQuestionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  onTap: () {
                    // Show navigation buttons
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: [SystemUiOverlay.bottom]);
                  },
                  controller: _categoryController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translation(context).enterAnyCategory;
                    }
                    return null;
                  },
                  maxLength: 20,
                  minLines: 1,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: translation(context).category,
                  ),
                ),
                TextFormField(
                  onTap: () {
                    // Show navigation buttons
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: [SystemUiOverlay.bottom]);
                  },
                  controller: _questionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translation(context).enterAnyQuestion;
                    }
                    return null;
                  },
                  maxLength: 50,
                  minLines: 1,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: translation(context).question,
                  ),
                ),
                TextFormField(
                  onTap: () {
                    // Show navigation buttons
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: [SystemUiOverlay.bottom]);
                  },
                  controller: _answerController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translation(context).enterAnyAnswer;
                    }
                    return null;
                  },
                  maxLength: 25,
                  minLines: 1,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: translation(context).answer,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await FirebaseFirestore.instance
                              .collection('$firestoreMainPath/users')
                              .doc(loginModel.userId)
                              .get()
                              .then((value) {
                            List questions = value["questions"];
                            questions.add(_questionController.text);
                            List answers = value["answers"];
                            answers.add(_answerController.text);
                            List categories = value["categories"];
                            categories.add(_categoryController.text);
                            FirebaseFirestore.instance
                                .collection('$firestoreMainPath/users')
                                .doc(loginModel.userId)
                                .update({
                              "questions": questions,
                              "answers": answers,
                              "categories": categories
                            }).then((_) => Navigator.of(context).pop(true));
                            Provider.of<LoginModel>(context, listen: false)
                                .notifyAddedQuestion();
                          });
                        }
                      },
                      child: Text(translation(context).submit),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(translation(context).cancel2)),
                  ),
                ])
              ],
            ),
          ));
    });
  }
}

class Questions extends StatefulWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  Future<bool?> _editQuestionDialog(
      String userId, String question, String answer, String category) {
    final _categoryController = TextEditingController();
    final _questionController = TextEditingController();
    final _answerController = TextEditingController();

    _categoryController.text = category;
    _questionController.text = question;
    _answerController.text = answer;

    final _oldCategory = _categoryController.text;
    final _oldQuestion = _questionController.text;
    final _oldAnswer = _answerController.text;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(translation(context).editQuestion),
              content: Form(
                key: UniqueKey(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _categoryController,
                      minLines: 1,
                      decoration: InputDecoration(
                        labelText: translation(context).category,
                      ),
                    ),
                    TextFormField(
                      controller: _questionController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: translation(context).question,
                      ),
                    ),
                    TextFormField(
                      controller: _answerController,
                      minLines: 1,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: translation(context).answer,
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('$firestoreMainPath/users')
                                .doc(userId)
                                .get()
                                .then((value) {
                              List questions = value["questions"];
                              List answers = value["answers"];
                              List categories = value["categories"];
                              for (int i = 0; i < questions.length; i++) {
                                if (questions[i] == _oldQuestion &&
                                    answers[i] == _oldAnswer &&
                                    categories[i] == _oldCategory) {
                                  questions[i] = _questionController.text;
                                  answers[i] = _answerController.text;
                                  categories[i] = _categoryController.text;
                                  break;
                                }
                              }
                              FirebaseFirestore.instance
                                  .collection('$firestoreMainPath/users')
                                  .doc(userId)
                                  .update({
                                "questions": questions,
                                "answers": answers,
                                "categories": categories
                              }).then((_) => Navigator.of(context).pop(false));
                              Provider.of<LoginModel>(context, listen: false)
                                  .notifyAddedQuestion();
                            });
                          },
                          child: Text(translation(context).submit),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(translation(context).cancel2),
                        ),
                      ),
                    ])
                  ],
                ),
              ));
        });
  }

  Future<bool?> _removeQuestionDialog(
      String userId, String question, String answer, String category) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translation(context).deleteQuestion),
            content: Text(translation(context).confirmDeletion),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('$firestoreMainPath/users')
                        .doc(userId)
                        .get()
                        .then((value) {
                      List questions = value["questions"];
                      List answers = value["answers"];
                      List categories = value["categories"];
                      for (int i = 0; i < questions.length; i++) {
                        if (questions[i] == question &&
                            answers[i] == answer &&
                            categories[i] == category) {
                          questions.removeAt(i);
                          answers.removeAt(i);
                          categories.removeAt(i);
                          break;
                        }
                      }
                      FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(userId)
                          .update({
                        "questions": questions,
                        "answers": answers,
                        "categories": categories,
                      }).then((_) {
                        Navigator.of(context).pop(true);
                      });
                    });
                  },
                  child: Text(translation(context).delete)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(translation(context).cancel)),
            ],
          );
        });
  }

  Future<List<Dismissible>> _questionsListWidget(
      BuildContext context, String userId) async {
    List<Dismissible> trivia = <Dismissible>[];
    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(userId)
        .get()
        .then((value) {
      List questions = value["questions"];
      List answers = value["answers"];
      List categories = value["categories"];
      for (int i = 0; i < questions.length; i++) {
        trivia.add(Dismissible(
            key: UniqueKey(),
            confirmDismiss: (DismissDirection direction) {
              if (direction == DismissDirection.startToEnd) {
                return _removeQuestionDialog(
                    userId, questions[i], answers[i], categories[i]);
              } else {
                return _editQuestionDialog(
                    userId, questions[i], answers[i], categories[i]);
              }
            },
            background: Container(
              padding: const EdgeInsets.all(20),
              color: redColor,
              child: const Icon(Icons.delete),
              alignment: AlignmentDirectional.centerStart,
            ),
            secondaryBackground: Container(
              padding: const EdgeInsets.all(20),
              color: blueColor,
              child: const Icon(Icons.edit),
              alignment: AlignmentDirectional.centerEnd,
            ),
            //direction: DismissDirection.startToEnd,
            child: GestureDetector(
                onLongPress: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                        content: Text(translation(context).snackBar7),
                      ))
                      .closed
                      .then((value) =>
                          ScaffoldMessenger.of(context).clearSnackBars());
                },
                child: ExpansionTile(
                    childrenPadding: EdgeInsets.zero,
                    title: Text(categories[i]),
                    subtitle: Text(questions[i],
                        style: const TextStyle(fontSize: 22)),
                    children: <Widget>[
                      ListTile(
                          title: Text(answers[i],
                              style: const TextStyle(fontSize: 18))),
                    ]))));
      }
    });
    return trivia;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
              backgroundColor: blueColor,
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(translation(context).addYourQuestion),
                        content: AddQuestionForm());
                  },
                ).then((value) => SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: []));
              }),
          backgroundColor: secondaryBackgroundColor,
          body: FutureBuilder(
              future: _questionsListWidget(
                  context,
                  loginModel.userId.isEmpty
                      ? "${FirebaseAuth.instance.currentUser?.uid}"
                      : loginModel.userId),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  loginModel.cachedQuestionsList = snapshot.data;
                  if (snapshot.data.isNotEmpty) {
                    return ListView(children: loginModel.cachedQuestionsList);
                  } else {
                    return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                            child: Text(
                          translation(context).addQuestionsCustom,
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        )));
                  }
                } else {
                  if (loginModel.cachedQuestionsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView(children: loginModel.cachedQuestionsList);
                  }
                }
              }));
    });
  }
}

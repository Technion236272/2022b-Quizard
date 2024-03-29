import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'providers.dart';

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _categoryController,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            TextFormField(
              controller: _questionController,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Question',
              ),
            ),
            TextFormField(
              controller: _answerController,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Answer',
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('versions/v1/users')
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
                          .collection('versions/v1/users')
                          .doc(loginModel.userId)
                          .update({
                        "questions": questions,
                        "answers": answers,
                        "categories": categories
                      }).then((_) => Navigator.of(context).pop(true));
                      Provider.of<LoginModel>(context, listen: false)
                          .notifyAddedQuestion();
                    });
                  },
                  child: const Text('Submit'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ])
          ],
        ),
      );
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
              title: const Text("Edit Question"),
              content: Form(
                key: UniqueKey(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _categoryController,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    TextFormField(
                      controller: _questionController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                      ),
                    ),
                    TextFormField(
                      controller: _answerController,
                      minLines: 1,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Answer',
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('versions/v1/users')
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
                                  .collection('versions/v1/users')
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
                          child: const Text('Submit'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Cancel'),
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
            title: const Text("Delete Question"),
            content:
                const Text("Are you sure you wish to delete this question?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('versions/v1/users')
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
                          .collection('versions/v1/users')
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
                  child: const Text("DELETE")),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("CANCEL"),
              ),
            ],
          );
        });
  }

  Future<List<Dismissible>> _questionsListWidget(
      BuildContext context, String userId) async {
    List<Dismissible> trivia = <Dismissible>[];
    await FirebaseFirestore.instance
        .collection('versions/v1/users')
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
                      .showSnackBar(const SnackBar(
                        content: Text(
                            'Swipe left to edit, and swipe right to delete'),
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
          floatingActionButton: FloatingActionButton(
              backgroundColor: blueColor,
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text("Add Question"),
                        content: AddQuestionForm());
                  },
                );
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
                  if (snapshot.data.isNotEmpty) {
                    loginModel.cachedQuestionsList = snapshot.data;
                    return ListView(children: loginModel.cachedQuestionsList);
                  } else {
                    return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                            child: Text(
                          "Add questions here for custom games.",
                          style: TextStyle(fontSize: 22),
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

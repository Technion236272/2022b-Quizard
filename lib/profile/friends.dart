import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../consts.dart';
import '../localization/classes/language_constants.dart';
import '../providers.dart';

class FindFriendPage extends StatefulWidget {

  const FindFriendPage({Key? key}) : super(key: key);

  @override
  State<FindFriendPage> createState() => _FindFriendPageState();
}

class _FindFriendPageState extends State<FindFriendPage> {
  String email = '';
  bool isSearching = false;
  String friendId = '';
  String friendName = '';
  FutureBuilder<NetworkImage?>? friendImage;
  bool foundFriend = false;

  Future<void> addFriend() async {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(loginModel.userId)
        .get()
        .then((value) {
      List friends = value["friends"];
      friends.add(friendName);
      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .doc(loginModel.userId)
          .update({
        "friends": friends,
      });
      Provider.of<LoginModel>(context, listen: false)
          .notifyAddedFriend();
    });

    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(friendId)
        .get()
        .then((value) {
      List friends = value["friends"];
      friends.add(loginModel.username);
      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .doc(friendId)
          .update({
        "friends": friends,
      });
      Provider.of<LoginModel>(context, listen: false)
          .notifyAddedFriend();
      setState(() {
        foundFriend = false;
      });
    });


  }


  void showNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Not Found'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        );
      },
    );
  }

  void alreadyFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Already A Friend'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        );
      },
    );
  }

  void _friend(String username, String userId, int j) {
    Future<NetworkImage?> _getUserImage() async {
      final ref =
      FirebaseStorage.instance.ref('images/profiles/$userId.jpg');
      final url = await ref.getDownloadURL();
      return NetworkImage(url);
    }

    FutureBuilder<NetworkImage?> _getAvatarImage() {
      return FutureBuilder<NetworkImage?>(
          future: _getUserImage(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState != ConnectionState.waiting) {
              return CircleAvatar(
                  backgroundImage: snapshot.data,
                  backgroundColor: thirdColor,
                  radius: 25);
            }
            return const CircleAvatar(
                backgroundImage: AssetImage('images/avatar.png'),
                backgroundColor: thirdColor,
                radius: 25);
          });
    }

    friendName = username;
    friendImage = _getAvatarImage();
    friendId = userId;
  }

  Future<void> findUser() async {
    setState(() {
      foundFriend = false;
      isSearching = true;
    });
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    QuerySnapshot<Map<String, dynamic>> resultForEmail =
    await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('email', isEqualTo: email).get();
    QuerySnapshot<Map<String, dynamic>> resultForName =
    await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('username', isEqualTo: email).get();
    if (resultForEmail.docs.isEmpty && resultForName.docs.isEmpty) {
      showNotFoundDialog();
      setState(() => isSearching = false);
      return;
    } else {
      if (email == loginModel.email || email == loginModel.username) {
        showNotFoundDialog();
        setState(() => isSearching = false);
        return;
      }
    }
    String username = '';
    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .get()
        .then((users) async {
      for (var user in users.docs) {
        if (user['email'] == email || user['username'] == email) {
          username = user['username'];
          break;
        }
      }
    });
    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(loginModel.userId)
        .get()
        .then((value) {
      List friends = value["friends"];
      for(var name in friends)
        {
          if (username == name) {
            alreadyFriendDialog();
            setState(() => isSearching = false);
            return;
          }
        }
      setState(() {
        foundFriend = true;
        isSearching = false;
      });
      if(resultForEmail.docs.isEmpty) {
        _friend(username, resultForName.docs.first.id, 10);
      }
      else {
        _friend(username, resultForEmail.docs.first.id, 10);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(title: const Text('Find friend')),
        body: isSearching
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: TextField(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Friend's email or username"),
                onChanged: (val) => setState(() => email = val),
              ),
            ),
            ElevatedButton(
              onPressed: findUser,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Find'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 30.0, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: foundFriend == false ? null : friendImage,
                      subtitle: foundFriend == false ? null : Text(friendName),
                      title: foundFriend == false ? null :
                      Text(friendName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18)),
                    ),),
                  Expanded(
                    child: ListTile(
                      title: foundFriend == false ? null : ElevatedButton(
                        onPressed: addFriend,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(),
                          child: Text('Add Friend'),
                        ),),),),]
                ,),),],),);
    });
  }
}

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}


class _FriendsState extends State<Friends> {
  List friendsAvatars = [];
  List friendsWins = [];

  Future<NetworkImage?> _getImage(String id) async {
    final ref =
    FirebaseStorage.instance.ref('images/profiles/$id.jpg');
    final url = await ref.getDownloadURL();
    return NetworkImage(url);
  }
  Future<int> getWins(String id) async {
    int wins = 3;
    return wins;
  }

  FutureBuilder<NetworkImage?> _getAvatar(String id) {
    return FutureBuilder<NetworkImage?>(
        future: _getImage(id),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState != ConnectionState.waiting) {
            return CircleAvatar(
                backgroundImage: snapshot.data,
                backgroundColor: thirdColor,
                radius: 25);
          }
          return const CircleAvatar(
              backgroundImage: AssetImage('images/avatar.png'),
              backgroundColor: thirdColor,
              radius: 25);
        });
  }

  Future<void> getFriendsAvatars(List friends) async {
    for(int i=0; i<friends.length; i++) {
      String currentFriendName = friends[i];
      QuerySnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('username', isEqualTo: currentFriendName).get();
      friendsAvatars.add(_getAvatar(result.docs.first.id));
    }
  }
  Future<void> getFriendsWins(List friends) async {
    for(int i=0; i<friends.length; i++) {
      String currentFriendName = friends[i];
      QuerySnapshot<Map<String, dynamic>> result =
      await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('username', isEqualTo: currentFriendName).get();
      friendsWins.add(getWins(result.docs.first.id));
    }
  }

  Future<bool?> _removeFriendDialog(
      String userId, String username, String friend) {
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
                      List friends = value["friends"];
                      for (int i = 0; i < friends.length; i++) {
                        if (friends[i] == friend) {
                          friends.removeAt(i);
                          break;
                        }
                      }
                      FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(userId)
                          .update({
                        "friends": friends,
                      }).then((_) {
                        Navigator.of(context).pop(true);
                      });
                    });

                    QuerySnapshot<Map<String, dynamic>> result =
                    await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('username', isEqualTo: friend).get();

                    await FirebaseFirestore.instance
                        .collection('$firestoreMainPath/users')
                        .doc(result.docs.first.id)
                        .get()
                        .then((value) {
                      List friends = value["friends"];
                      friends.remove(username);
                      FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(result.docs.first.id)
                          .update({
                        "friends": friends,
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

  Future<List<Dismissible>> _friendsListWidget(
      BuildContext context, String userId, String username) async {
    List<Dismissible> trivia = <Dismissible>[];
    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(userId)
        .get()
        .then((value) async {
      List friends = value["friends"];
      await getFriendsAvatars(friends);
      await getFriendsWins(friends);
      for (int i = 0; i < friends.length; i++) {
        trivia.add(Dismissible(
            key: UniqueKey(),
            confirmDismiss: (DismissDirection direction) {
                return _removeFriendDialog(
                    userId, username, friends[i]);
            },
            background: Container(
              padding: const EdgeInsets.all(20),
              color: redColor,
              child: const Icon(Icons.delete),
              alignment: AlignmentDirectional.centerStart,
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
                child: Column(
            children: [
            Padding(
            padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                       friendsAvatars[i],
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      friends[i],
                      style: TextStyle(
                          fontSize: 18, color: defaultColor.withOpacity(0.5)),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Text(
                    "3",
                    style: TextStyle(fontSize: 18, color: defaultColor),
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
        ))));
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
              child: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const FindFriendPage();
                    }
                ).then((value) =>
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: []));
              }),
          backgroundColor: secondaryBackgroundColor,
          body: FutureBuilder(
              future: _friendsListWidget(
                  context,
                  loginModel.userId.isEmpty
                      ? "${FirebaseAuth.instance.currentUser?.uid}"
                      : loginModel.userId, loginModel.username),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  loginModel.cachedFriendsList = snapshot.data;

                  if (snapshot.data.isNotEmpty) {
                    return ListView(children: loginModel.cachedFriendsList);
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
                  if (loginModel.cachedFriendsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView(children: loginModel.cachedFriendsList);
                  }
                }
              }));
    });
  }
}
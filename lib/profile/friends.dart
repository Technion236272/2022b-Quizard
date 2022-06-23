import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../consts.dart';
import '../localization/classes/language_constants.dart';
import '../providers.dart';

class FriendsListModel {
  String id;
  String name;
  String profileImageLink;
  int wins;

  FriendsListModel(this.id, this.name, this.profileImageLink, this.wins);
}

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
      friends.add(friendId);

      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .doc(loginModel.userId)
          .update({
        "friends": friends,
      });

      Provider.of<LoginModel>(context, listen: false).notifyAddedFriend();
    });

    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(friendId)
        .get()
        .then((value) {
      List friends = value["friends"];
      friends.add(loginModel.userId);
      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .doc(friendId)
          .update({
        "friends": friends,
      });

      Provider.of<LoginModel>(context, listen: false).notifyAddedFriend();

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
          content: Text(translation(context).notFound),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translation(context).ok))
          ],
        );
      },
    );
  }

  void alreadyFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(translation(context).alreadyAFriend),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translation(context).ok))
          ],
        );
      },
    );
  }

  void _friend(String username, String userId) {
    Future<NetworkImage?> _getUserImage() async {
      final ref = FirebaseStorage.instance.ref('images/profiles/$userId.jpg');
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

    friendImage = _getAvatarImage();
  }

  Future<void> findUser() async {
    setState(() {
      foundFriend = false;
      isSearching = true;
    });
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    QuerySnapshot<Map<String, dynamic>> resultForEmail = await FirebaseFirestore
        .instance
        .collection('$firestoreMainPath/users')
        .where('email', isEqualTo: email)
        .get();
    QuerySnapshot<Map<String, dynamic>> resultForName = await FirebaseFirestore
        .instance
        .collection('$firestoreMainPath/users')
        .where('username', isEqualTo: email)
        .get();
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

    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .get()
        .then((users) async {
      for (var user in users.docs) {
        if (user['email'] == email || user['username'] == email) {
          friendName = user['username'];
          break;
        }
      }
    });

    if (resultForEmail.docs.isEmpty) {
      friendId = resultForName.docs.first.id;
    } else {
      friendId = resultForEmail.docs.first.id;
    }

    await FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(loginModel.userId)
        .get()
        .then((value) {
      List friends = value["friends"];
      for (var id in friends) {
        if (id == friendId) {
          alreadyFriendDialog();
          setState(() => isSearching = false);
          friendId = '';
          friendName = '';
          return;
        }
      }

      setState(() {
        foundFriend = true;
        isSearching = false;
      });

      _friend(friendName, friendId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(title: Text(translation(context).findFriend)),
        body: isSearching
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText:
                              translation(context).friendsEmailOrUsername),
                      onChanged: (val) => setState(() => email = val),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: findUser,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(translation(context).find),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 30.0, top: 30.0, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: foundFriend == false ? null : friendImage,
                            subtitle:
                                foundFriend == false ? null : Text(friendName),
                            title: foundFriend == false
                                ? null
                                : Text(friendName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: foundFriend == false
                                ? null
                                : ElevatedButton(
                                    onPressed: addFriend,
                                    child: Text(
                                      translation(context).addFriend,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool isDataLoading = false;
  List<FriendsListModel> friendsList = [];
  String userId = "null";
  String username = "null";

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 114;

    Future<bool?> _removeFriendDialog(
        String userId, String username, String friendId) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(translation(context).deleteFriend),
              content: Text(translation(context).confirmDeletion2),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      for (int i = 0; i < friendsList.length; i++) {
                        if (friendsList[i].id == friendId) {
                          friendsList.removeAt(i);
                        }
                      }
                      await FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(userId)
                          .get()
                          .then((value) {
                        List friends = value["friends"];
                        for (int i = 0; i < friends.length; i++) {
                          if (friends[i] == friendId) {
                            friends.removeAt(i);
                            break;
                          }
                        }
                        FirebaseFirestore.instance
                            .collection('$firestoreMainPath/users')
                            .doc(userId)
                            .update({
                          "friends": friends,
                        });
                      });

                      await FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(friendId)
                          .get()
                          .then((value) {
                        List friends = value["friends"];
                        friends.remove(userId);
                        FirebaseFirestore.instance
                            .collection('$firestoreMainPath/users')
                            .doc(friendId)
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

    Future<List<Dismissible>> _friendsListWidget(BuildContext context,
        loginModel, double screenHeight, String userId, String username) async {
      List<Dismissible> friends = <Dismissible>[];
      for (int i = 0; i < friendsList.length; i++) {
        friends.add(Dismissible(
            key: UniqueKey(),
            confirmDismiss: (DismissDirection direction) {
              return _removeFriendDialog(userId, username, friendsList[i].id);
            },
            background: Container(
              padding: const EdgeInsets.all(20),
              color: redColor,
              child: const Icon(Icons.delete),
              alignment: AlignmentDirectional.centerStart,
            ),
            direction: DismissDirection.startToEnd,
            child: GestureDetector(
                onLongPress: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                        content: Text(translation(context).snackBar28),
                      ))
                      .closed
                      .then((value) =>
                          ScaffoldMessenger.of(context).clearSnackBars());
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: friendsListItemWidget(
                        screenHeight,
                        friendsList[i].name,
                        friendsList[i].profileImageLink,
                        translation(context).wins1 +
                            "${friendsList[i].wins}")))));
      }
      return friends;
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      if (userId == "null") {
        userId = loginModel.userId;
        username = loginModel.username;
        getWinsData(userId, loginModel);
      }
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
                    }).then((value) {
                  getWinsData(userId, loginModel);
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: []);
                });
              }),
          backgroundColor: secondaryBackgroundColor,
          body: FutureBuilder(
              future: _friendsListWidget(
                  context,
                  loginModel,
                  screenHeight,
                  loginModel.userId.isEmpty
                      ? "${FirebaseAuth.instance.currentUser?.uid}"
                      : loginModel.userId,
                  username),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  loginModel.cachedFriendsList = snapshot.data;
                  if (snapshot.data.isNotEmpty) {
                    return ListView(children: loginModel.cachedFriendsList);
                  } else {
                    return Container();
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

  Widget friendsListItemWidget(screenHeight, name, profileImageLink, wins) {
    return Column(
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
                    Image.network(profileImageLink, fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            loadingProgress) {
                      if (loadingProgress == null) {
                        return CircleAvatar(
                            backgroundColor: thirdColor,
                            backgroundImage: NetworkImage(profileImageLink));
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Colors.grey,
                          ),
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black45),
                          ),
                        ],
                      );
                    }), // CircleAvatar(
                    //   backgroundImage: NetworkImage(profileImageLink),
                    // ),
                    const SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(right: 13.0),
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            color: defaultColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Text(
                    wins,
                    style: TextStyle(
                      fontSize: 18,
                      color: defaultColor.withOpacity(0.5),
                    ),
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

  void getWinsData(userId, loginModel) {
    FirebaseFirestore.instance
        .collection('$firestoreMainPath/users')
        .doc(loginModel.userId)
        .get()
        .then((value) async {
      List friends = value["friends"];

      FirebaseFirestore.instance
          .collection('versions/v2/users')
          .get()
          .then((users) async {
        setState(() {
          isDataLoading = true;
        });

        List<FriendsListModel> tempfriendsList = [];

        for (var user in users.docs) {
          for (var friendId in friends) {
            if (user.id == friendId) {
              var url = "";
              try {
                final ref = FirebaseStorage.instance
                    .ref('images/profiles/${user.id}.jpg');
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

              tempfriendsList.add(FriendsListModel(
                  user.id, user["username"], url, user["wins"]));
              break;
            }
          }
        }

        setState(() {
          tempfriendsList.sort((a, b) => a.wins.compareTo(b.wins));

          friendsList.clear();
          friendsList.addAll(tempfriendsList.reversed.toList());

          isDataLoading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          isDataLoading = false;
        });
      });
    });
  }
}

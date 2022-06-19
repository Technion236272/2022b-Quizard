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
          .notifyAddedQuestion();
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
      print(friends);
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
                    return const FindFriendPage();
                  }
              ).then((value) =>
                  SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: []));
            }),
        backgroundColor: secondaryBackgroundColor,
      );
    });
  }
}
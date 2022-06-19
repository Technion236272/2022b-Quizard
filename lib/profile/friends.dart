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

  void addFriend() {

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
  }

  Future<void> findUser() async {
    setState(() {
      foundFriend = false;
    });
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    setState(() => isSearching = true);
    QuerySnapshot<Map<String, dynamic>> result =
    await FirebaseFirestore.instance.collection('$firestoreMainPath/users').where('email', isEqualTo: email).get();
    if (result.docs.isEmpty) {
      showNotFoundDialog();
      setState(() => isSearching = false);
      return;
    } else {
      if (email == loginModel.email) {
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
        if (user['email'] == email) {
          username = user['username'];
          break;
        }
      }
    });
    setState(() {
      foundFriend = true;
      isSearching = false;
    });
    _friend(username, result.docs.first.id, 10);
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
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Friend's email"),
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
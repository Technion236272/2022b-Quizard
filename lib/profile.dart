import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'providers.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  int _lastTab = 0;

  void _onTapTab(int index) {
    _lastTab = index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      final screenHeight = MediaQuery.of(context).size.height - 114;

      return Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(boxRadiusConst)),
              ),
              child: SizedBox(
                  height: screenHeight,
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircleAvatar(
                                  backgroundImage: loginModel.getUserImage(),
                                  backgroundColor: secondProfileColor,
                                  radius: 35)),
                          Flexible(
                              child: Column(
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
                          ))
                        ]),
                    SizedBox(
                        height: screenHeight,
                        child: Column(children: [
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
                                      child: const Icon(Icons.question_mark)),
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
                        ]))
                  ])))));
    });
  }
}

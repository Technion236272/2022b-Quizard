import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts.dart';
import '../localization/classes/language_constants.dart';
import '../providers.dart';
import 'friends.dart';
import 'questions.dart';
import 'settings.dart';

//ignore: must_be_immutable
class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  int _lastTab = 0;

  void _onTapTab(int index) {
    _lastTab = index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
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
                          backgroundColor: thirdColor,
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
                      backgroundColor: thirdColor,
                      automaticallyImplyLeading: false,
                      toolbarHeight: 0,
                      elevation: 0,
                      bottom: TabBar(
                        onTap: _onTapTab,
                        labelColor: defaultColor,
                        indicatorColor: defaultColor,
                        tabs: [
                          Tab(
                              icon: const Icon(Icons.question_mark),
                              text: translation(context).questions),
                          Tab(
                            icon: const Icon(Icons.tag_faces),
                            text: translation(context).friends,
                          ),
                          Tab(
                            icon: const Icon(Icons.settings),
                            text: translation(context).settings,
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
                            child: const Friends()),
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Settings()),
                      ],
                    ),
                  ),
                ))
              ])));
    });
  }
}

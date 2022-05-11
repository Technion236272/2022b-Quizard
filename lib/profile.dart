import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'consts.dart';
import 'home.dart';
import 'login_model.dart';
import 'nav_model.dart';

class ProfileSnappingSheet extends StatelessWidget {
  ProfileSnappingSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Consumer<NavModel>(builder: (context, navModel, child) {
        Widget _chooseWidget() {
          if (navModel.currentIndex == 1) {
            return const Play();
          }
          if (navModel.currentIndex == 2) {
            return const Leaderboard();
          }
          if (navModel.previousIndex == 1) {
            return const Play();
          }
          if (navModel.previousIndex == 2) {
            return const Leaderboard();
          }
          return const Play();
        }

        return Scaffold(
          body: SnappingSheet(
            controller: loginModel.profileSheetController,
            lockOverflowDrag: true,
            snappingPositions: const [
              SnappingPosition.pixels(
                positionPixels: (-grabbingHeightConst),
                grabbingContentOffset: GrabbingContentOffset.top,
              ),
              SnappingPosition.factor(
                positionFactor: 1,
                grabbingContentOffset: GrabbingContentOffset.bottom,
              ),
            ],
            onSnapCompleted: (data, pos) {
              if (data.pixels < 0) {
                navModel.returnToPrev();
              }
            },
            grabbingHeight: grabbingHeightConst,
            grabbing: const GrabbingWidget(),
            sheetBelow: SnappingSheetContent(
              draggable: false,
              child: SingleChildScrollView(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height - 214,
                      child: Column(children: [
                        Expanded(
                            child: DefaultTabController(
                          length: 3,
                          child: Scaffold(
                            backgroundColor: secondaryColor,
                            appBar: AppBar(
                              backgroundColor: secondProfileColor,
                              automaticallyImplyLeading: false,
                              toolbarHeight: 0,
                              elevation: 0,
                              bottom: const TabBar(
                                //TODO: Fix OVERFLOW
                                labelColor: defaultColor,
                                indicatorColor: defaultColor,
                                tabs: [
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
                            body: const TabBarView(
                              children: [
                                Icon(Icons.question_mark),
                                Icon(Icons.tag_faces),
                                Icon(Icons.settings),
                              ],
                            ),
                          ),
                        ))
                      ]))),
            ),
            child: _chooseWidget(),
          ),
        );
      });
    });
  }
}

class GrabbingWidget extends StatelessWidget {
  const GrabbingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: secondaryColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(boxRadiusConst)),
        ),
        child: SingleChildScrollView(
            child: SizedBox(
          height: grabbingHeightConst,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                    //backgroundImage: loginModel.getUserImage(),
                    backgroundColor: secondProfileColor,
                    radius: 40)),
            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 15, 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Username", //TODO: Fix OVERFLOW
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            "17 WINS",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        ])),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 15, 0),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    color: firstProfileColor,
                    backgroundColor: secondProfileColor,
                    semanticsLabel: 'Linear progress indicator',
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Amateur",
                            style: TextStyle(
                              color: secondProfileColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Expert",
                            style: TextStyle(
                              color: secondProfileColor,
                              fontSize: 12,
                            ),
                          )
                        ])),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 15, 5),
                  child: Text(
                    "user@mail.com",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ))
          ]),
        )));
  }
}

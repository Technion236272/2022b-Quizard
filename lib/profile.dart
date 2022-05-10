import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'colors.dart';
import 'home.dart';
import 'login_model.dart';

class ProfileSnappingSheet extends StatelessWidget {
  ProfileSnappingSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
        body: SnappingSheet(
          controller: loginModel.profileSheetController,
          lockOverflowDrag: true,
          snappingPositions: const [
            SnappingPosition.pixels(
              positionPixels: -100,
              grabbingContentOffset: GrabbingContentOffset.top,
            ),
            SnappingPosition.factor(
              positionFactor: 1,
              grabbingContentOffset: GrabbingContentOffset.bottom,
            ),
          ],
          grabbingHeight: 100,
          grabbing: const GrabbingWidget(),
          sheetBelow: SnappingSheetContent(
              draggable: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: secondaryColor,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      )),
                    ]),
              )),
          child: const HomeContent(),
        ),
      );
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ));
  }
}

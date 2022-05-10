import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'home.dart';
import 'login_model.dart';

class ProfileSnappingSheet extends StatelessWidget {
  const ProfileSnappingSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
        body: SnappingSheet(
          controller: loginModel.profileSheetController,
          lockOverflowDrag: true,
          snappingPositions: const [
            SnappingPosition.factor(
              positionFactor: 0,
              grabbingContentOffset: GrabbingContentOffset.top,
            ),
            SnappingPosition.factor(
              positionFactor: 1,
              grabbingContentOffset: GrabbingContentOffset.bottom,
            ),
          ],
          grabbingHeight: 50,
          grabbing: const GrabbingWidget(),
          sheetBelow: SnappingSheetContent(
              draggable: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const []),
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
    return Consumer<LoginModel>(builder: (context, savesModel, child) {
      return Container();
    });
  }
}

import 'dart:async';
import 'package:fleet_management/screens/navigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../constants/color.dart';
import '../constants/spaces.dart';
import '../controller/transporterIdController.dart';
import '../functions/trasnporterApis/runTransporterApiPost.dart';

class SplashScreenToGetTransporterData extends StatefulWidget {
  final String mobileNum;
  SplashScreenToGetTransporterData({required this.mobileNum});

  @override
  _SplashScreenToGetTransporterDataState createState() =>
      _SplashScreenToGetTransporterDataState();
}

class _SplashScreenToGetTransporterDataState
    extends State<SplashScreenToGetTransporterData> {
  GetStorage tidstorage = GetStorage('TransporterIDStorage');
  TransporterIdController transporterIdController =
      Get.put(TransporterIdController(), permanent: true);
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    bool? transporterApproved;
    bool? companyApproved;
    String? mobileNum;
    bool? accountVerificationInProgress;
    String? transporterLocation;
    String? name;
    String? companyName;

    // String? transporterId =
        await runTransporterApiPost(mobileNum: widget.mobileNum);
    //old method commented
    String? transporterId = tidstorage.read("transporterId");

    // runTransporterApiPost(mobileNum: widget.mobileNum);
    if (transporterId != null) {
      Timer(Duration(milliseconds: 1200),
          () => Get.off(() => NavigationScreen()));
    } else {
      setState(() {
        transporterId = tidstorage.read("transporterId");
        transporterApproved = tidstorage.read("transporterApproved");
        companyApproved = tidstorage.read("companyApproved");
        mobileNum = tidstorage.read("mobileNum");
        accountVerificationInProgress =
            tidstorage.read("accountVerificationInProgress");
        transporterLocation = tidstorage.read("transporterLocation");
        name = tidstorage.read("name");
        companyName = tidstorage.read("companyName");
      });
      if (transporterId == null) {
        print("Transporter ID is null");
      } else {
        print("It is in else");
        transporterIdController.updateTransporterId(transporterId!);
        transporterIdController.updateTransporterApproved(transporterApproved!);
        transporterIdController.updateCompanyApproved(companyApproved!);
        transporterIdController.updateMobileNum(mobileNum!);
        transporterIdController.updateAccountVerificationInProgress(
            accountVerificationInProgress!);
        transporterIdController.updateTransporterLocation(transporterLocation!);
        transporterIdController.updateName(name!);
        transporterIdController.updateCompanyName(companyName!);
        print("transporterID is $transporterId");
      }
      Timer(Duration(milliseconds: 1), () => Get.off(() => NavigationScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: statusBarColor,
      body: SafeArea(
        child: Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [shadowGrey, white])),
            padding: EdgeInsets.only(right: space_2, top: space_30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage("assets/images/liveasyTruck.png")),
                SizedBox(
                  height: space_2,
                ),
                Container(
                  child: Column(
                    children: [
                      Image(
                        image: AssetImage("assets/images/logoSplashScreen.png"),
                        height: space_12,
                      ),
                      SizedBox(
                        height: space_3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
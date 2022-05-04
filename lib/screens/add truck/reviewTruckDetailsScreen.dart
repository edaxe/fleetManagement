import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/fontSize.dart';
import '../../constants/fontWeights.dart';
import '../../constants/spaces.dart';
import '../../controller/navigationIndexController.dart';
import '../../controller/truckIdController.dart';
import '../../functions/driverApiCalls.dart';
import '../../functions/truckApis/truckApiCalls.dart';
import '../../models/driverModel.dart';
import '../../providerClass/providerData.dart';
import '../../variables/truckFilterVariables.dart';
import '../../widgets/Header.dart';
import '../../widgets/buttons/mediumSizedButton.dart';
import '../../widgets/loadingWidget.dart';
import '../../widgets/truckReviewDetailsRow.dart';
import '../navigationScreen.dart';

class ReviewTruckDetails extends StatefulWidget {
  final String truckId;
  final String truckNumber;
  final String driverId;

  ReviewTruckDetails(
      {required this.truckId,
      required this.driverId,
      required this.truckNumber});

  @override
  _ReviewTruckDetailsState createState() => _ReviewTruckDetailsState();
}

class _ReviewTruckDetailsState extends State<ReviewTruckDetails> {
  TruckApiCalls truckApiCalls = TruckApiCalls();

  //
  DriverApiCalls driverApiCalls = DriverApiCalls();

  TruckIdController truckIdController = TruckIdController();

  String truckTypeText = '';

  TruckFilterVariables truckFilterVariables = TruckFilterVariables();

  DriverModel driverModel = DriverModel();

  String? truckIdForCrossVerification;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    getDriverDetails();
  }

  void getDriverDetails() async {
    if (widget.driverId != '') {
      var temp =
          await driverApiCalls.getDriverByDriverId(driverId: widget.driverId);
      setState(() {
        driverModel = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ProviderData providerData = Provider.of<ProviderData>(context);

    // providerData.updateIsAddNewDriver(false);
    if (providerData.truckTypeValue == '') {
      truckTypeText = '---';
    } else {
      truckTypeText = truckFilterVariables.truckTypeTextList[
          truckFilterVariables.truckTypeValueList
              .indexOf(providerData.truckTypeValue)];
    }

    // driverModel.driverName = driverModel.driverName!.length > 11 ? driverModel.driverName!.substring(0 , 9) + '..' : driverModel.driverName ;
    NavigationIndexController navigationIndexController =
        Get.find<NavigationIndexController>();

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(space_5),
          child: Column(
            children: [
              Header(
                backButton: true,
                text: 'addTruck'.tr,
                // AppLocalizations.of(context)!.addTruck,
                reset: false,
                // resetFunction: () {
                //   providerData.resetTruckFilters();
                //   Get.back();
                // }
              ),
              Container(
                margin: EdgeInsets.only(top: space_2),
                child: Row(
                  children: [
                    Text(
                      'Review Details For ',
                      style: TextStyle(
                          fontSize: size_9, fontWeight: mediumBoldWeight),
                    ),
                    Text(
                      '${widget.truckNumber}',
                      style: TextStyle(
                          fontSize: size_9,
                          color: Color(0xff152968),
                          fontWeight: mediumBoldWeight),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Stack(
                    children: [
                      Card(
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.all(space_2),
                          child: Column(
                            children: [
                              TruckReviewDetailsRow(
                                  value: truckTypeText, label: 'truckType'.tr
                                  // AppLocalizations.of(context)!.truckType
                                  ),
                              TruckReviewDetailsRow(
                                  value: providerData.totalTyresValue,
                                  label: 'totalTyres'.tr
                                  // AppLocalizations.of(context)!.totalTyres
                                  ),
                              TruckReviewDetailsRow(
                                  value: providerData.passingWeightValue,
                                  label: 'passingWeight'.tr
                                  // AppLocalizations.of(context)!.passingWeigthInTons
                                  ),
                              // Change here----------------------------
                              //  TruckReviewDetailsRow(
                              //      value: providerData.truckLengthValue,
                              //  //     label: AppLocalizations.of(context)!.truckLength),
                              //  TruckReviewDetailsRow(
                              //      value: widget.driverId != ''
                              //          ?
                              //      '${driverModel.driverName}-${driverModel.phoneNum}'
                              //          :
                              //      '---',
                              //      label: 'driverDetails'.tr
                              //      // AppLocalizations.of(context)!.driverDetails
                              //  ),
                            ],
                          ),
                        ),
                      ),
                      loading
                          ? Container(
                              margin: EdgeInsets.fromLTRB(
                                  space_3, space_20, space_3, 0),
                              child: LoadingWidget())
                          : Container(),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      space_2,
                      MediaQuery.of(context).size.height * 0.38,
                      space_2,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumSizedButton(
                            onPressedFunction: () {
                              Get.back();
                            },
                            optional: true,
                            text: 'edit'.tr
                            // AppLocalizations.of(context)!.edit
                            ),
                        MediumSizedButton(
                            onPressedFunction: () async {
                              setState(() {
                                loading = true;
                              });
                              truckIdForCrossVerification =
                                  await truckApiCalls.putTruckData(
                                truckType: providerData.truckTypeValue,
                                totalTyres: providerData.totalTyresValue,
                                // truckLength: providerData.truckLengthValue,
                                passingWeight: providerData.passingWeightValue,
                                driverID: widget.driverId,
                                truckID: widget.truckId,
                              );

                              if (truckIdForCrossVerification != null) {
                                setState(() {
                                  loading = false;
                                });

                                if (providerData.isAddTruckSrcDropDown) {
                                  navigationIndexController.updateIndex(3);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          NavigationScreen()));
                                } else {
                                  navigationIndexController.updateIndex(1);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          NavigationScreen()));
                                }
                                providerData.resetTruckFilters();
                              } else {
                                setState(() {
                                  loading = false;
                                });
                                Get.snackbar('Failed to update Details', '');
                              }
                            },
                            optional: true,
                            text: 'submit'.tr
                            // 'Submit'
                            )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:fleet_management/screens/add%20truck/reviewTruckDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/color.dart';
import '../../constants/spaces.dart';
import '../../controller/SelectedDriverController.dart';
import '../../functions/driverApiCalls.dart';
import '../../functions/truckApis/truckApiCalls.dart';
import '../../providerClass/providerData.dart';
import '../../variables/truckFilterVariables.dart';
import '../../widgets/Header.dart';
import '../../widgets/addTruckCircularButtonTemplate.dart';
import '../../widgets/addTruckRectangularButtontemplate.dart';
import '../../widgets/addTruckSubtitleText.dart';
import '../../widgets/buttons/mediumSizedButton.dart';

class TruckDescriptionScreen extends StatefulWidget {
  final String truckId;
  String truckNumber;

  // TruckDescriptionScreen(
  //      this.truckId,
  //     this.truckNumber,
  //     );

  TruckDescriptionScreen({required this.truckId, required this.truckNumber});

  @override
  _TruckDescriptionScreenState createState() => _TruckDescriptionScreenState();
}

class _TruckDescriptionScreenState extends State<TruckDescriptionScreen> {
  dynamic dropDownValue;

  TruckFilterVariables truckFilterVariables = TruckFilterVariables();

  DriverApiCalls driverApiCalls = DriverApiCalls();
  SelectedDriverController selectedDriverController =
      Get.put(SelectedDriverController());
  TruckApiCalls truckApiCalls = TruckApiCalls();

  late List driverList = [];

  List<DropdownMenuItem<String>> dropDownList = [];

  getDriverList() async {
    List temp;
    temp = await driverApiCalls.getDriversByTransporterId();
    setState(() {
      driverList = temp;
    });
    for (var instance in driverList) {
      bool instanceAlreadyAdded = false;
      for (var dropDown in dropDownList) {
        if (dropDown.value == instance.driverId) {
          instanceAlreadyAdded = true;
          break;
        }
      }
      if (!instanceAlreadyAdded) {
        dropDownList.insert(
            0,
            DropdownMenuItem<String>(
              value: instance.driverId,
              child: Text('${instance.driverName}-${instance.phoneNum}'),
            ));
      }
    }
    //
    // bool addNewDriverAlreadyAdded = false;
    // for (var dropDown in dropDownList) {
    //   if (dropDown.value == '') {
    //     addNewDriverAlreadyAdded = true;
    //     break;
    //   }
    // }
    // if (!addNewDriverAlreadyAdded) {
    //   dropDownList.add(DropdownMenuItem(
    //     value: '',
    //     child: Expanded(
    //       child: Container(
    //         width: 400,
    //         child: TextButton(
    //           onPressed: () {
    //             showDialog(
    //                 context: context,
    //                 builder: (context) => AddDriverAlertDialog());
    //           },
    //           child: Text('Add New Driver'),
    //         ),
    //       ),
    //     ),
    //   ));
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDriverList();
  }

  void autoAddDriver() async {
    await getDriverList();
    if (selectedDriverController.newDriverAddedTruck.value) {
      // print('dropDownValue: ${dropDownValue}');
      dropDownValue = selectedDriverController.selectedDriverTruck.value;
      selectedDriverController.updateNewDriverAddedTruckController(false);
    }
  }

  refresh() {
    setState(() {
      var page = ModalRoute.of(context)!.settings.name;
      Get.to(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    ProviderData providerData = Provider.of<ProviderData>(context);
    print('truck Id : ${widget.truckId}');
    selectedDriverController.updateFromBook(false);
    selectedDriverController.updateFromTruck(true);
    autoAddDriver();
    // print(
    //     "value of book true or not: ${selectedDriverController.fromBook.value}");
    // print(
    //     "value of truck true or not: ${selectedDriverController.fromTruck.value}");
    // print(
    //     'dropDownValueUpp: ${selectedDriverController.newDriverAddedTruck.value}');

    return WillPopScope(
      onWillPop: () {
        providerData.resetTruckFilters();
        return Future.value(true);
      },
      child: Scaffold(
          body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.fromLTRB(space_3, space_4, space_3, space_4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(
                    backButton: true,
                    text: 'addTruck'.tr,
                    // AppLocalizations.of(context)!.addTruck,
                    reset: true,
                    resetFunction: () {
                      providerData.resetTruckFilters();
                      dropDownValue = null;
                      providerData.updateResetActive(false);
                    }),
                AddTruckSubtitleText(text: 'truckType'.tr
                    // AppLocalizations.of(context)!.truckType
                    ),
                GridView.count(
                  shrinkWrap: true,
                  childAspectRatio: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: EdgeInsets.all(10.0),
                  crossAxisCount: 2,
                  children: truckFilterVariables.truckTypeValueList
                      .map((e) => AddTruckRectangularButtonTemplate(
                          value: e,
                          text: truckFilterVariables.truckTypeTextList[
                              truckFilterVariables.truckTypeValueList
                                  .indexOf(e)]))
                      .toList(),
                ),
                providerData.truckTypeValue == ''
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: space_3),
                        child: AddTruckSubtitleText(
                          text: 'passingWeight'.tr,
                          // 'Passing Weight (in tons.)'
                        )),
                providerData.truckTypeValue == ''
                    ? SizedBox()
                    : Container(
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisSpacing: space_6,
                          mainAxisSpacing: space_1,
                          crossAxisCount: 5,
                          children: truckFilterVariables
                              .passingWeightList[providerData.truckTypeValue]!
                              .map((e) => AddTruckCircularButtonTemplate(
                                    value: e,
                                    text: e != 0 ? e.toString() : "+",
                                    category: 'weight',
                                  ))
                              .toList(),
                        ),
                      ),
                providerData.truckTypeValue == ''
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: space_2),
                        child: AddTruckSubtitleText(text: 'totalTyres'.tr
                            // 'Total Tyres (front & rear)'
                            )),
                providerData.truckTypeValue == ''
                    ? SizedBox()
                    : Container(
                        child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisSpacing: space_6,
                            mainAxisSpacing: space_1,
                            crossAxisCount: 5,
                            children: truckFilterVariables
                                .totalTyresList[providerData.truckTypeValue]!
                                .map((e) => AddTruckCircularButtonTemplate(
                                      value: e,
                                      text: e != 0 ? e.toString() : "+",
                                      category: 'tyres',
                                    ))
                                .toList()),
                      ),
                // changed here-----------------------------------
                // providerData.truckTypeValue == ''
                //     ? SizedBox()
                //     : Container(
                //         margin: EdgeInsets.symmetric(vertical: space_2),
                //         child:
                //             AddTruckSubtitleText(text: 'Truck Length (in ft)')),
                // providerData.truckTypeValue == ''
                //     ? SizedBox()
                //     : Container(
                //         child: GridView.count(
                //           physics: NeverScrollableScrollPhysics(),
                //           shrinkWrap: true,
                //           crossAxisSpacing: space_6,
                //           mainAxisSpacing: space_1,
                //           crossAxisCount: 5,
                //           children: truckFilterVariables
                //               .truckLengthList[providerData.truckTypeValue]!
                //               .map((e) => AddTruckCircularButtonTemplate(
                //                     value: e,
                //                     text: e != 0 ? e.toString() : "+",
                //                     category: 'length',
                //                   ))
                //               .toList(),
                //         ),
                //       ),
                //till here----------------------------------------------------

                // change of select driver from here---------------------------
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Container(
                //       margin: EdgeInsets.only(top: space_2),
                //       child: AddTruckSubtitleText(text: 'Select A Driver'),
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         showDialog(
                //             context: context,
                //             builder: (context) =>
                //                 AddDriverAlertDialog(notifyParent: refresh));
                //       },
                //       child: Text('Add New Driver'),
                //     ),
                //   ],
                // ),
                // Align(
                //   alignment: Alignment.center,
                //   child: Container(
                //     margin: EdgeInsets.symmetric(vertical: space_1),
                //     width: 279,
                //     padding: EdgeInsets.all(space_2),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50),
                //       border: Border(
                //           top: BorderSide(width: 1, color: grey),
                //           right: BorderSide(width: 1, color: grey),
                //           left: BorderSide(width: 1, color: grey),
                //           bottom: BorderSide(width: 1, color: grey)),
                //     ),
                //     child: DropdownButton<String>(
                //       underline: SizedBox(),
                //       isDense: true,
                //       isExpanded: true,
                //       focusColor: Colors.blue,
                //       hint:
                //           Text('driverNameNumber'.tr
                //               // AppLocalizations.of(context)!.driverNameNumber
                //           ),
                //       value: dropDownValue,
                //       icon: Container(
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(100),
                //             color: darkBlueColor,
                //           ),
                //           child: const Icon(
                //             Icons.keyboard_arrow_down,
                //             color: white,
                //           )),
                //       onChanged: (String? newValue) {
                //         providerData.updateDriverDetailsValue(newValue);
                //         setState(() {
                //           dropDownValue = newValue!;
                //         });
                //       },
                //       items: dropDownList,
                //     ),
                //   ),
                // ),
                //till here-----------------------------------------
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: space_2),
                    child: MediumSizedButton(
                      optional: true,
                      onPressedFunction: () {
                        providerData.updateResetActive(true);
                        // truckApiCalls.updateDriverIdForTruck(
                        //     driverID: dropDownValue, truckID: widget.truckId);
                        Get.to(() => ReviewTruckDetails(
                              truckId: widget.truckId,
                              driverId: providerData.driverIdValue,
                              truckNumber: widget.truckNumber,
                            ));
                      },
                      text: 'save'.tr,
                      // 'Save',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

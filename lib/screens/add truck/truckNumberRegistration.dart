import 'package:fleet_management/screens/add%20truck/truckDescriptionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/color.dart';
import '../../constants/fontWeights.dart';
import '../../constants/spaces.dart';
import '../../functions/driverApiCalls.dart';
import '../../functions/truckApis/truckApiCalls.dart';
import '../../providerClass/providerData.dart';
import '../../widgets/Header.dart';
import '../../widgets/addTruckSubtitleText.dart';
import '../../widgets/buttons/mediumSizedButton.dart';
import '../../widgets/loadingWidget.dart';
import '../../widgets/sameTruckAlertDialogBox.dart';

//TODO: loading widget while post executes
class   AddNewTruck extends StatefulWidget {
  @override
  _AddNewTruckState createState() => _AddNewTruckState();
}

class _AddNewTruckState extends State<AddNewTruck> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _controller = TextEditingController();
  TruckApiCalls truckApiCalls = TruckApiCalls();
  DriverApiCalls driverApiCalls = DriverApiCalls();

  String? truckId;
  RegExp truckNoRegex = RegExp(
      r"^[A-Za-z]{2}[ -/]{0,1}[0-9]{1,2}[ -/]{0,1}(?:[A-Za-z]{0,1})[ -/]{0,1}[A-Za-z]{0,2}[ -/]{0,1}[0-9]{4}$");

  bool? loading = false;

  @override
  Widget build(BuildContext context) {
    ProviderData providerData = Provider.of<ProviderData>(context);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(space_4, space_4, space_4, space_10),
        color: backgroundColor,
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(
                  backButton: true,
                  text: 'addTruck'.tr,
                  // AppLocalizations.of(context)!.addTruck,
                  reset: true,
                  resetFunction: () {
                    _controller.text = '';
                    providerData.resetTruckNumber();
                    providerData.updateResetActive(false);
                  },
                ),
                SizedBox(
                  height: space_2,
                ),
                AddTruckSubtitleText(text: 'truckNumber'.tr
                    // AppLocalizations.of(context)!.truckNumber
                    ),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: space_6),
                    margin: EdgeInsets.symmetric(vertical: space_4),
                    height: space_8,
                    child: TextFormField(
                      onChanged: (value) {
                        if (_controller.text != value.toUpperCase())
                          _controller.value = _controller.value
                              .copyWith(text: value.toUpperCase());
                        if (truckNoRegex.hasMatch(value) && value.length >= 9) {
                          providerData.updateResetActive(true);
                        } else {
                          providerData.updateResetActive(false);
                        }
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9]")),
                      ],
                      textCapitalization: TextCapitalization.characters,
                      controller: _controller,
                      // textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: space_2),
                        filled: true,
                        fillColor: whiteBackgroundColor,
                        hintText: 'Eg: UP 22 GK 2222',
                        hintStyle: TextStyle(
                          fontWeight: boldWeight,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: unselectedGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: unselectedGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                loading!
                    ? Container(
                        margin: EdgeInsets.all(space_3),
                        child: LoadingWidget(),
                      )
                    : Container(),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MediumSizedButton(
                        text: 'next'.tr,
                        // AppLocalizations.of(context)!.next,
                        optional: false,
                        onPressedFunction: providerData.resetActive
                            ? () async {
                                setState(() {
                                  loading = true;
                                });
                                providerData
                                    .updateTruckNumberValue(_controller.text);
                                truckId = await truckApiCalls.postTruckData(
                                    truckNo: _controller.text);

                                if (truckId != null) {
                                  setState(() {
                                    loading = false;
                                  });
                                  providerData.updateResetActive(false);
                                  Get.to(() => TruckDescriptionScreen(
                                        truckId: truckId!,
                                        truckNumber: _controller.text,
                                      ));
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) {
                                        return SameTruckAlertDialogBox();
                                      });
                                }
                              }
                            : null),
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

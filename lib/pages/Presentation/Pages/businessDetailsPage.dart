import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_dimensions.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/Utils/utils.dart';
import 'package:raithan_serviceapp/Widgets/textField.dart';
import 'package:raithan_serviceapp/constants/enums/business_type.dart';
import 'package:raithan_serviceapp/constants/regex_constant.dart';

import '../../../Widgets/dropDownTextFeild.dart';

class Businessdetailspage extends StatefulWidget {
  final TextEditingController businessNameController;
  final TextEditingController pincodeController;
  final TextEditingController blockNumberController;
  final TextEditingController streetController;
  final TextEditingController areaController;
  final TextEditingController landmarkController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController businessTypeController;
  final TextEditingController mobileNumberController; // NEW

  final Map<String, bool> workingDays;
  final GlobalKey<FormState> formKey;

  Businessdetailspage({
    super.key,
    required this.businessNameController,
    required this.pincodeController,
    required this.blockNumberController,
    required this.streetController,
    required this.areaController,
    required this.landmarkController,
    required this.cityController,
    required this.stateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.workingDays,
    required this.formKey,
    required this.businessTypeController,
    required this.mobileNumberController, // NEW
  });

  @override
  State<Businessdetailspage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<Businessdetailspage> {
  late FocusNode businessNameFocusNode;
  late FocusNode businessTypeFocusNode;
  late FocusNode mobileNumberFocusNode; // NEW
  late FocusNode pincodeFocusNode;
  late FocusNode blockNumberFocusNode;
  late FocusNode streetFocusNode;
  late FocusNode areaFocusNode;
  late FocusNode landmarkFocusNode;
  late FocusNode cityFocusNode;
  late FocusNode stateFocusNode;
  late FocusNode workingTimeFocusNode;

  @override
  void initState() {
    super.initState();
    businessNameFocusNode  = FocusNode();
    businessTypeFocusNode  = FocusNode();
    mobileNumberFocusNode  = FocusNode(); // NEW
    pincodeFocusNode       = FocusNode();
    blockNumberFocusNode   = FocusNode();
    streetFocusNode        = FocusNode();
    areaFocusNode          = FocusNode();
    landmarkFocusNode      = FocusNode();
    cityFocusNode          = FocusNode();
    stateFocusNode         = FocusNode();
    workingTimeFocusNode   = FocusNode();
  }

  @override
  void dispose() {
    businessNameFocusNode.dispose();
    businessTypeFocusNode.dispose();
    mobileNumberFocusNode.dispose(); // NEW
    pincodeFocusNode.dispose();
    blockNumberFocusNode.dispose();
    streetFocusNode.dispose();
    areaFocusNode.dispose();
    landmarkFocusNode.dispose();
    cityFocusNode.dispose();
    stateFocusNode.dispose();
    workingTimeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (selectedTime != null) {
      controller.text =
          Utils.convertTo12HourFormat(selectedTime.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(alwaysUse24HourFormat: false),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.formFieldPadding),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Business Information".tr,
                    style: robotoBold.copyWith(color: black, fontSize: 20),
                  ),
                ],
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.businessNameController,
                type: TextInputType.name,
                focusNode: businessNameFocusNode,
                label: "Business Name ( Optional )".tr,
                onFieldSubmitted: (_) => businessNameFocusNode.unfocus(),
                onChanged: (_) => widget.formKey.currentState?.validate(),
              ),
              sizedBox(),
              DropdownTextField(
                controller: widget.businessTypeController,
                label: "Select a Business Type".tr,
                focusNode: businessTypeFocusNode,
                onFieldSubmitted: (_) => businessTypeFocusNode.unfocus(),
                options: BusinessType.values
                    .map((t) => t.toString())
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option'.tr;
                  }
                  return null;
                },
              ),
              sizedBox(),
              // ── Mobile number ───────────────────────────────────────────
              CustomTextfield(
                controller: widget.mobileNumberController,
                type: TextInputType.phone,
                focusNode: mobileNumberFocusNode,
                label: "Business Contact Number".tr,
                maxLength: 10,
                isBuildCounterRequired: true,
                onFieldSubmitted: (_) => Utils.changeNodeFocus(
                    context, mobileNumberFocusNode, blockNumberFocusNode),
                onChanged: (_) => widget.formKey.currentState?.validate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number'.tr;
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit number'.tr;
                  }
                  return null;
                },
              ),
              // ───────────────────────────────────────────────────────────
              sizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Business Address".tr,
                    style: robotoBold.copyWith(color: black, fontSize: 20),
                  ),
                ],
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.blockNumberController,
                type: TextInputType.text,
                label: "House Number".tr,
                focusNode: blockNumberFocusNode,
                onFieldSubmitted: (_) => Utils.changeNodeFocus(
                    context, blockNumberFocusNode, streetFocusNode),
                onChanged: (_) => widget.formKey.currentState?.validate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write your house number'.tr;
                  }
                  return null;
                },
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.streetController,
                type: TextInputType.text,
                label: "Street".tr,
                focusNode: streetFocusNode,
                onFieldSubmitted: (_) => Utils.changeNodeFocus(
                    context, streetFocusNode, areaFocusNode),
                onChanged: (_) => widget.formKey.currentState?.validate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write your street'.tr;
                  }
                  return null;
                },
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.areaController,
                type: TextInputType.text,
                label: "Area".tr,
                focusNode: areaFocusNode,
                onFieldSubmitted: (_) => Utils.changeNodeFocus(
                    context, areaFocusNode, landmarkFocusNode),
                onChanged: (_) => widget.formKey.currentState?.validate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write your area'.tr;
                  }
                  return null;
                },
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.landmarkController,
                type: TextInputType.text,
                label: "Landmark".tr,
                focusNode: landmarkFocusNode,
                onFieldSubmitted: (_) => Utils.changeNodeFocus(
                    context, landmarkFocusNode, cityFocusNode),
                onChanged: (_) => widget.formKey.currentState?.validate(),
              ),
              sizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppDimensions.width * 0.43,
                    child: CustomTextfield(
                      controller: widget.cityController,
                      type: TextInputType.text,
                      label: "City".tr,
                      focusNode: cityFocusNode,
                      onFieldSubmitted: (_) => Utils.changeNodeFocus(
                          context, cityFocusNode, stateFocusNode),
                      onChanged: (_) =>
                          widget.formKey.currentState?.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please write your city'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: AppDimensions.width * 0.43,
                    child: CustomTextfield(
                      controller: widget.stateController,
                      type: TextInputType.text,
                      label: "State".tr,
                      focusNode: stateFocusNode,
                      onFieldSubmitted: (_) => Utils.changeNodeFocus(
                          context, stateFocusNode, pincodeFocusNode),
                      onChanged: (_) =>
                          widget.formKey.currentState?.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please write your state'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              sizedBox(),
              CustomTextfield(
                controller: widget.pincodeController,
                type: TextInputType.number,
                label: "Pincode".tr,
                focusNode: pincodeFocusNode,
                maxLength: 6,
                onFieldSubmitted: (_) => pincodeFocusNode.unfocus(),
                onChanged: (_) => widget.formKey.currentState?.validate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write your pincode'.tr;
                  }
                  if (!RegExp(RegexConstant.otpOrPincodeValidationRegex)
                      .hasMatch(value)) {
                    return 'Pincode must be 6 digits only'.tr;
                  }
                  return null;
                },
              ),
              sizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Working Time".tr,
                    style: robotoBold.copyWith(color: black, fontSize: 20),
                  ),
                ],
              ),
              sizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppDimensions.width * 0.43,
                    child: CustomTextfield(
                      controller: widget.startTimeController,
                      type: TextInputType.number,
                      readOnly: true,
                      onTap: () =>
                          _selectTime(context, widget.startTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                      label: "Start Time".tr,
                      onChanged: (_) =>
                          widget.formKey.currentState?.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select start time'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    width: AppDimensions.width * 0.43,
                    child: CustomTextfield(
                      controller: widget.endTimeController,
                      type: TextInputType.number,
                      readOnly: true,
                      onTap: () =>
                          _selectTime(context, widget.endTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                      label: "End Time".tr,
                      onChanged: (_) =>
                          widget.formKey.currentState?.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select end time'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              sizedBox(),
              Container(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 10.0, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    onExpansionChanged: (expanding) {
                      if (expanding) {
                        FocusScope.of(context)
                            .requestFocus(workingTimeFocusNode);
                      }
                    },
                    tilePadding: EdgeInsets.zero,
                    collapsedBackgroundColor: Colors.transparent,
                    title: Text(
                      "Select Working Days".tr,
                      style: const TextStyle(
                        fontSize: AppDimensions.regularFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: widget.workingDays.keys.map((day) {
                      return CheckboxListTile(
                        title: Text(day.tr),
                        value: widget.workingDays[day],
                        onChanged: (bool? value) {
                          setState(() {
                            widget.workingDays[day] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              sizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget sizedBox() => const SizedBox(height: 15);
}
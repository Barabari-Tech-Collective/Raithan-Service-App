import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_colors.dart';
import 'package:raithan_serviceapp/Utils/app_dimensions.dart';
import 'package:raithan_serviceapp/Utils/utils.dart';
import 'package:raithan_serviceapp/common/custom_appbar.dart';
import 'package:raithan_serviceapp/common/custom_button.dart';
import 'package:raithan_serviceapp/constants/routes/route_name.dart';
import 'package:raithan_serviceapp/controller/business_controller.dart';

import 'businessDetailsPage.dart';

class Business extends GetView<BusinessController> {
  Business({super.key}) {
    Get.lazyPut(() => BusinessController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Business".tr, context, options: false),
      body: Obx(
        () => controller.isLoading.value
            ? Utils.getLoadingWidget()
            : controller.isCreateMode.value
                ? _buildCreateMode(context)
                : _buildViewMode(context),
      ),
    );
  }

  // ── Create mode: shown when provider has no business yet ─────────────────

  Widget _buildCreateMode(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.scrollController,
      child: Column(
        children: [
          Businessdetailspage(
            businessNameController: controller.businessNameController,
            pincodeController: controller.pincodeController,
            blockNumberController: controller.blockNumberController,
            streetController: controller.streetController,
            areaController: controller.areaController,
            landmarkController: controller.landmarkController,
            cityController: controller.cityController,
            stateController: controller.stateController,
            startTimeController: controller.startTimeController,
            endTimeController: controller.endTimeController,
            workingDays: controller.workingDays,
            businessTypeController: controller.businessTypeController,
            mobileNumberController: controller.mobileNumberController,
            formKey: controller.businessDetailFormKey,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.formFieldPadding,
              right: AppDimensions.formFieldPadding,
              bottom: AppDimensions.formFieldPadding,
            ),
            child: Obx(
              () => CustomButton(
                isPrimary: true,
                width: double.infinity,
                onPressed: () =>
                    controller.saveBusinessDetails(context),
                isLoading: controller.savingBusinessDetails.value,
                child: Text("Submit & Apply For Verification".tr),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── View mode: shown when business already exists ─────────────────────────

  Widget _buildViewMode(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppDimensions.formFieldPadding * 0.05),
          Padding(
            padding: EdgeInsets.all(AppDimensions.formFieldPadding),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: [
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Business Information".tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))
                    ],
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.businessDetails.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.formFieldPadding),
                      child: const Divider(),
                    ),
                    itemBuilder: (_, index) {
                      String label =
                          controller.businessDetails.keys.elementAt(index);
                      String value = controller.businessDetails[label]!;
                      return BusinessInfoTile(
                        label: label,
                        value: value.tr,
                        isFirst: index == 0,
                        isLast: index ==
                            controller.businessDetails.length - 1,
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.formFieldPadding),
                    child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Colors.grey))),
                  ),
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                  Text("Categories".tr,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                      height: AppDimensions.formFieldPadding * 0.25),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.formFieldPadding),
                    child: Wrap(
                      spacing: AppDimensions.formFieldPadding,
                      runSpacing: AppDimensions.formFieldPadding * 0.5,
                      alignment: WrapAlignment.center,
                      children: controller.categories
                          .map((c) => Text(c.tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                ],
              ),
            ),
          ),
          _infoCard(
              context, "Business Address".tr, controller.businessAddress),
          _infoCard(
              context, "Working Time".tr, controller.businessTime),
          Padding(
            padding: EdgeInsets.only(
                left: AppDimensions.formFieldPadding,
                right: AppDimensions.formFieldPadding,
                bottom: AppDimensions.formFieldPadding),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: [
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Working Days".tr,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))
                  ]),
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.formFieldPadding),
                    child: Wrap(
                      spacing: AppDimensions.formFieldPadding,
                      runSpacing: AppDimensions.formFieldPadding * 0.5,
                      alignment: WrapAlignment.center,
                      children: controller.businessDays
                          .map((d) => Text(d.tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: AppDimensions.formFieldPadding * 0.5),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                style: _buttonStyle(),
                onPressed: () =>
                    controller.askUpdateLocationConfirmation(context),
                child: Row(children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.whiteColor),
                  const SizedBox(width: 5),
                  Text("Update Location".tr,
                      style:
                          const TextStyle(color: AppColors.whiteColor)),
                ]),
              ),
              SizedBox(width: AppDimensions.formFieldPadding),
              FilledButton(
                style: _buttonStyle(),
                onPressed: () => Get.toNamed(
                    RouteName.businessEdit,
                    arguments: controller.businessInfo),
                child: Row(children: [
                  const Icon(Icons.edit, color: AppColors.whiteColor),
                  const SizedBox(width: 5),
                  Text("Edit".tr,
                      style:
                          const TextStyle(color: AppColors.whiteColor)),
                ]),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.formFieldPadding),
        ],
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, String title, dynamic dataMap) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppDimensions.formFieldPadding,
          right: AppDimensions.formFieldPadding,
          bottom: AppDimensions.formFieldPadding),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0)),
        child: Column(
          children: [
            SizedBox(height: AppDimensions.formFieldPadding * 0.5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))
            ]),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dataMap.length,
              separatorBuilder: (_, __) => Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.formFieldPadding),
                child: const Divider(),
              ),
              itemBuilder: (_, index) {
                String label = dataMap.keys.elementAt(index);
                String value = dataMap[label]!;
                return BusinessInfoTile(
                  label: label,
                  value: value,
                  isFirst: index == 0,
                  isLast: index == dataMap.length - 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>(AppColors.appBarColor),
        padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      );
}

class BusinessInfoTile extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isLast;
  final String value;

  const BusinessInfoTile({
    required this.label,
    required this.value,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppDimensions.formFieldPadding,
          right: AppDimensions.formFieldPadding,
          top: isFirst ? AppDimensions.formFieldPadding * 0.5 : 0.0,
          bottom: isLast ? AppDimensions.formFieldPadding * 0.5 : 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
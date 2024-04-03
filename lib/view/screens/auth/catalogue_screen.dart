import 'package:country_code_picker/country_code.dart';
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/utill/routes.dart';
import 'package:emarket_user/view/base/footer_web_view.dart';
import 'package:emarket_user/view/base/web_header/web_app_bar.dart';
import 'package:emarket_user/view/screens/auth/widget/code_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/helper/email_checker.dart';
import 'package:emarket_user/localization/language_constrants.dart';
import 'package:emarket_user/provider/auth_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/view/base/custom_button.dart';
import 'package:emarket_user/view/base/custom_snackbar.dart';
import 'package:emarket_user/view/base/custom_text_field.dart';
import 'package:provider/provider.dart';

class CatalogueScreen extends StatefulWidget {
  @override
  _CatalogueScreenState createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar:  ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120)) : null,
      body: SafeArea(
        child: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all( ResponsiveHelper.isDesktop(context)? 0 : Dimensions.PADDING_SIZE_LARGE),
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context)? size.height - 400 : size.height),
                    child: Center(
                      child: Container(
                        width: size.width > 700 ? 700 : size.width,
                        margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.isDesktop(context)? Dimensions.PADDING_SIZE_LARGE : 0),
                        padding: size.width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT) : null,
                        decoration: size.width > 700 ? BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 5, spreadRadius: 1)],
                        ) : null,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 30),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Image.asset(Images.logo, matchTextDirection: true,height: MediaQuery.of(context).size.height / 4.5),
                                ),
                              ),
                              SizedBox(height: 20),
                              Center(
                                  child: Text(
                                    getTranslated('reseller_pdf', context),
                                    style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 24, color: ColorResources.getGreyBunkerColor(context)),
                                  )),

                              SizedBox(height: 35),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  authProvider.verificationMessage.length > 0
                                      ? CircleAvatar(backgroundColor: Colors.red, radius: 5)
                                      : SizedBox.shrink(),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.verificationMessage ?? "",
                                      style: Theme.of(context).textTheme.headline2.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE),
                                child: InkWell(
                                  onTap: () {
                                    try {
                                      String baseUrl = Provider.of<SplashProvider>(context, listen: false).configModel.baseUrls.resellerPdfUrl;
                                      String fileName = Provider.of<SplashProvider>(context, listen: false).configModel.resellerPDF;
                                      String pdfUrl = baseUrl + "/" + fileName;
                                      if(pdfUrl != null) {
                                        Provider.of<SplashProvider>(context, listen: false).downloadFile(context, pdfUrl);
                                      } else {
                                        showCustomSnackBar(getTranslated('error_download', context), context, isError: false);
                                      }
                                    } catch(e) {
                                      showCustomSnackBar(getTranslated('error_download', context), context, isError: false);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                    ),
                                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          getTranslated('click_download', context),
                                          style: Theme.of(context).textTheme.headline2.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: ColorResources.COLOR_WHITE),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ResponsiveHelper.isDesktop(context) ? FooterView() : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

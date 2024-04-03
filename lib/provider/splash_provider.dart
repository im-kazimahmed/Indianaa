import 'dart:io';

import 'package:emarket_user/data/model/response/base/api_response.dart';
import 'package:emarket_user/data/model/response/config_model.dart';
import 'package:emarket_user/data/model/response/policy_model.dart';
import 'package:emarket_user/data/repository/splash_repo.dart';
import 'package:emarket_user/helper/api_checker.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../localization/language_constrants.dart';
import '../view/base/custom_snackbar.dart';

class SplashProvider extends ChangeNotifier {
  final SplashRepo splashRepo;
  final SharedPreferences sharedPreferences;
  SplashProvider({@required this.splashRepo, this.sharedPreferences});

  ConfigModel _configModel;
  PolicyModel _policyModel;

  BaseUrls _baseUrls;
  DateTime _currentTime = DateTime.now();


  ConfigModel get configModel => _configModel;
  PolicyModel get policyModel => _policyModel;

  BaseUrls get baseUrls => _baseUrls;
  DateTime get currentTime => _currentTime;

  Future<bool> initConfig(GlobalKey<ScaffoldMessengerState> globalKey) async {
    ApiResponse apiResponse = await splashRepo.getConfig();
    bool isSuccess;
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response.data).baseUrls;
      print("base urls ${_baseUrls.toJson()}");
      isSuccess = true;
      notifyListeners();
    } else {
      isSuccess = false;
      String _error;
      if(apiResponse.error is String) {
        _error = apiResponse.error;
      }else {
        _error = apiResponse.error.errors[0].message;
      }
      print(_error);
      globalKey.currentState.showSnackBar(SnackBar(content: Text(_error), backgroundColor: Colors.red));
    }
    return isSuccess;
  }

  Future<void> downloadFile(BuildContext context, String fileUrl) async {
    final response = await http.get(Uri.parse(fileUrl));
    print(fileUrl);
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'reseller.pdf';
      final filePath = '${tempDir.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('File downloaded to: $filePath');
      showCustomSnackBar('File downloaded to: $filePath', context, isError: false);
      OpenAppFile.open(filePath);
      // final downloadsDirectory = await getDownloadsDirectory();
      // // Generate a unique filename
      // final fileName = 'reseller.pdf';
      // final filePath = '${downloadsDirectory.path}/$fileName';
      // // Write the file
      // File file = File(filePath);
      // await file.writeAsBytes(response.bodyBytes);
      // print('File downloaded to: $filePath');
      // // Open the file with the default app
      // OpenFile.open(filePath);

      print('File downloaded to: $filePath');
    } else {
      showCustomSnackBar(getTranslated('error_download', context), context, isError: true);
      print('Failed to download file. Status code: ${response.statusCode}');
    }
  }

  Future<bool> getPolicyPage(BuildContext context) async {

    ApiResponse apiResponse = await splashRepo.getPolicyPage();
    bool isSuccess;
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {

      _policyModel = PolicyModel.fromJson(apiResponse.response.data);

      isSuccess = true;
      notifyListeners();
    } else {
      isSuccess = false;
      String _error;
      if(apiResponse.error is String) {
        _error = apiResponse.error;
      }else {
        _error = apiResponse.error.errors[0].message;
      }
      print(_error);
      ApiChecker.checkApi(context, apiResponse);
    }
    return isSuccess;
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashRepo.removeSharedData();
  }

  bool showLang() {
    return splashRepo.showLang()??true;
  }

  void disableLang() {
    splashRepo.disableLang();
  }


}
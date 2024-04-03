import 'dart:convert';
import 'package:emarket_user/provider/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/base/api_response.dart';
import 'package:emarket_user/data/model/response/response_model.dart';
import 'package:emarket_user/data/model/response/userinfo_model.dart';
import 'package:emarket_user/data/repository/profile_repo.dart';
import 'package:emarket_user/helper/api_checker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utill/app_constants.dart';
import 'localization_provider.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepo profileRepo;

  ProfileProvider({@required this.profileRepo});

  UserInfoModel _userInfoModel;
  static String userType ="";

  String get getUserType => userType;

  UserInfoModel get userInfoModel => _userInfoModel;

  Future<ResponseModel> getUserInfo(BuildContext context) async {
    ResponseModel _responseModel;
    ApiResponse apiResponse = await profileRepo.getUserInfo();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _userInfoModel = UserInfoModel.fromJson(apiResponse.response.data);
      profileRepo.clearUserId().then((value) {
        saveUserId('${_userInfoModel.id}');
      });
      if(_userInfoModel.userType!="" || _userInfoModel.userType!=null)
        userType  =_userInfoModel.userType;

      await Provider.of<WishListProvider>(context, listen: false).initWishList(
        context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );

      _responseModel = ResponseModel(true, 'successful');
    } else {
      String _errorMessage;
      if (apiResponse.error is String) {
        _errorMessage = apiResponse.error.toString();
      } else {
        _errorMessage = apiResponse.error.errors[0].message;
      }
      print(_errorMessage);
      _responseModel = ResponseModel(false, _errorMessage);
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
    return _responseModel;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String password, XFile  file, String token) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel _responseModel;
    http.StreamedResponse response = await profileRepo.updateProfile(updateUserModel, password, file, token);
    _isLoading = false;
    if (response.statusCode == 200) {
      Map map = jsonDecode(await response.stream.bytesToString());
      String message = map["message"];
      _userInfoModel = updateUserModel;
      _responseModel = ResponseModel(true, message);
      print(message);
    } else {
      _responseModel = ResponseModel(false, '${response.statusCode} ${response.reasonPhrase}');
      print('${response.statusCode} ${response.reasonPhrase}');
    }
    notifyListeners();
    return _responseModel;
  }

  void saveUserId(String userId) {
    profileRepo.saveUserID(userId);
  }
  String getUserId() {
    return profileRepo.getUserId() ?? '0';
  }




}

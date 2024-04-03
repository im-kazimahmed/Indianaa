import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/banner_model.dart';
import 'package:emarket_user/data/model/response/base/api_response.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/data/repository/banner_repo.dart';
import 'package:emarket_user/helper/api_checker.dart';

class BannerProvider extends ChangeNotifier {
  final BannerRepo bannerRepo;
  BannerProvider({@required this.bannerRepo});

  List<BannerModel> _bannerList;
  List<Product> _productList = [];

  List<BannerModel> get bannerList => _bannerList;
  List<Product> get productList => _productList;

  Future<void> getBannerList(BuildContext context, bool reload) async {
    if (bannerList == null || reload) {
      ApiResponse apiResponse = await bannerRepo.getBannerList();
      if (apiResponse.response != null &&
          apiResponse.response.statusCode == 200) {
        _bannerList = [];
        apiResponse.response.data.forEach((category) {
          BannerModel bannerModel = BannerModel.fromJson(category);
          if (bannerModel.productId != null) {
            getProductDetails(context, bannerModel.productId.toString());
          }
          _bannerList.add(bannerModel);
        });
        notifyListeners();
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }
    }
  }

  void getProductDetails(BuildContext context, String productID) async {
    ApiResponse apiResponse = await bannerRepo.getProductDetails(productID);
    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _productList.add(Product.fromJson(apiResponse.response.data));
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
  }

  List<BannerModel> getCategoryBanners(String categoryId) {
    List<BannerModel> banners = [];
    for (int i = 0; i < _bannerList.length; i++) {
      if (_bannerList[i].categoryId == int.parse(categoryId)) {
        banners.add(_bannerList[i]);
      }
    }
    return banners;
  }
}

import 'dart:developer';

import 'package:emarket_user/data/model/response/base/api_response.dart';
import 'package:emarket_user/data/model/response/category_model.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/data/repository/category_repo.dart';
import 'package:emarket_user/helper/api_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization_provider.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepo categoryRepo;

  CategoryProvider({@required this.categoryRepo});

  List<CategoryModel> _categoryList;
  List<CategoryModel> _subCategoryList;
  List<Product> _categoryProductList;
  List<Product> _filteredProductsList;
  Map<String, List<Product>> _categoryProductListById = {};
  Map<String, List<Product>> currentCategoryProductListById = {};
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;
  String filterDropDownValue = 'Select filter';
  double _upperValue = 0;
  double _lowerValue = 0;
  double get lowerValue => _lowerValue;
  double get upperValue => _upperValue;

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    notifyListeners();
  }

  Future<List<Product>> getCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedDataString = prefs.getString('cached_category_product_list');
    if (cachedDataString != null) {
      // Parse the cached data and check if it's not expired
      List<Product> cachedData = parseCachedData(cachedDataString);
      DateTime cachedTime = DateTime.parse(prefs.getString('cached_category_product_list_time'));
      if (cachedTime != null && DateTime.now().difference(cachedTime).inMinutes <= 5) {
        return cachedData;
      }
    }
    return null;
  }

  void saveDataToCache(List<Product> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_category_product_list', data.toString());
    prefs.setString('cached_category_product_list_time', DateTime.now().toString());
  }

  List<Product> parseCachedData(String cachedDataString) {
    // Parse the cached data and return the List<Product>
    // You need to implement this based on your data structure
    // For example, you might use json.decode(cachedDataString) for JSON data
  }

  ValueNotifier<List<CategoryModel>> categoryListNotifier =
      ValueNotifier<List<CategoryModel>>([]);
  List<CategoryModel> get categoryList => _categoryList;
  List<CategoryModel> get subCategoryList => _subCategoryList;
  List<Product> get categoryProductList => _categoryProductList;
  List<Product> get filteredProductsList => _filteredProductsList;
  Map<String, List<Product>> get categoryProductListById =>
      _categoryProductListById;
  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;
  Map<String, int> currentIndexes = {};
  int categoriesLength = 0;
  bool isLoading = false;

  void applyFilter(String value) {
    filterDropDownValue = value;

    switch (value) {
      case 'Below 1000':
        _filteredProductsList = _categoryProductList
            .where((product) => product.price < 1000)
            .toList();
        break;
      case '1000-3000':
        _filteredProductsList = _categoryProductList
            .where((product) => product.price >= 1000 && product.price <= 3000)
            .toList();
        break;
      case '3001-5000':
        _filteredProductsList = _categoryProductList
            .where((product) => product.price >= 3001 && product.price <= 5000)
            .toList();
        break;
      case '5001-10000':
        _filteredProductsList = _categoryProductList
            .where((product) => product.price >= 5001 && product.price <= 10000)
            .toList();
        break;
      case 'Above 100000':
        _filteredProductsList =
            _categoryProductList.where((product) => product.price > 100000).toList();
        break;
      default:
        _filteredProductsList = _categoryProductList;
        break;
    }

    notifyListeners();
  }

  // Future<void> getCategoryList(
  //     BuildContext context, bool reload, String languageCode) async {
  //   _subCategoryList = null;
  //   if (_categoryList == null || reload) {
  //     ApiResponse apiResponse =
  //         await categoryRepo.getCategoryList(languageCode);
  //     if (apiResponse.response != null &&
  //         apiResponse.response.statusCode == 200) {
  //       categoryListNotifier.value = [];
  //       _categoryList = [];
  //       apiResponse.response.data.forEach((category) {
  //         _categoryList.add(CategoryModel.fromJson(category));
  //       });
  //       categoryListNotifier.value = _categoryList;
  //     } else {
  //       ApiChecker.checkApi(context, apiResponse);
  //     }
  //     notifyListeners();
  //   }
  // }

  Future<void> getCategoryList(
      BuildContext context, bool reload, String languageCode) async {
    _subCategoryList = null;

    if (_categoryList == null || reload) {
      // Check if data is present in cache and not expired
      List<CategoryModel> cachedData = await getCachedCategoryList();
      if (cachedData != null) {
        _categoryList = cachedData;
        categoryListNotifier.value = _categoryList;
        print("Category list loaded from cache");
        notifyListeners();
        return;
      }

      ApiResponse apiResponse =
      await categoryRepo.getCategoryList(languageCode);
      if (apiResponse.response != null &&
          apiResponse.response.statusCode == 200) {
        categoryListNotifier.value = [];
        _categoryList = [];
        apiResponse.response.data.forEach((category) {
          _categoryList.add(CategoryModel.fromJson(category));
        });

        // Save category list data to cache
        saveCategoryListToCache(_categoryList);

        categoryListNotifier.value = _categoryList;
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }

      notifyListeners();
    }
  }

  Future<List<CategoryModel>> getCachedCategoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedDataString = prefs.getString('cached_category_list');
    if (cachedDataString != null) {
      // Parse the cached data and check if it's not expired
      List<CategoryModel> cachedData = parseCachedCategoryData(cachedDataString);
      DateTime cachedTime =
      DateTime.parse(prefs.getString('cached_category_list_time') ?? ''); // Use a consistent key for time
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime).inMinutes <= 5) {
        return cachedData;
      }
    }
    return null;
  }

  void saveCategoryListToCache(List<CategoryModel> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_category_list', data.toString());
    prefs.setString('cached_category_list_time', DateTime.now().toString());
  }

  List<CategoryModel> parseCachedCategoryData(String cachedDataString) {
    // Parse the cached data and return the List<CategoryModel>
    // You need to implement this based on your data structure
    // For example, you might use json.decode(cachedDataString) for JSON data
  }

  // void getSubCategoryList(
  //     BuildContext context, String categoryID, String languageCode) async {
  //   _subCategoryList = null;
  //   ApiResponse apiResponse =
  //       await categoryRepo.getSubCategoryList(categoryID, languageCode);
  //   if (apiResponse.response != null &&
  //       apiResponse.response.statusCode == 200) {
  //     _subCategoryList = [];
  //     apiResponse.response.data.forEach(
  //         (category) => _subCategoryList.add(CategoryModel.fromJson(category)));
  //     getCategoryProductList(context, categoryID, languageCode);
  //   } else {
  //     ApiChecker.checkApi(context, apiResponse);
  //   }
  //   notifyListeners();
  // }

  void getSubCategoryList(
      BuildContext context, String categoryID, String languageCode) async {
    _subCategoryList = null;
    notifyListeners();

    // Check if data is present in cache and not expired
    List<CategoryModel> cachedData =
    await getCachedSubCategoryList(categoryID);
    if (cachedData != null) {
      _subCategoryList = cachedData;
      getCategoryProductList(context, categoryID, languageCode);
      print("Subcategory list loaded from cache");
      notifyListeners();
      return;
    }

    ApiResponse apiResponse =
    await categoryRepo.getSubCategoryList(categoryID, languageCode);

    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _subCategoryList = [];
      apiResponse.response.data.forEach((category) =>
          _subCategoryList.add(CategoryModel.fromJson(category)));
      log("calling api");
      // Save subcategory data to cache
      saveSubCategoryListToCache(categoryID, _subCategoryList);
      getCategoryProductList(context, categoryID, languageCode);
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }

    notifyListeners();
  }

  Future<List<CategoryModel>> getCachedSubCategoryList(String categoryID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cacheKey = 'cached_subcategory_list_$categoryID';
    String cachedDataString = prefs.getString(cacheKey);
    if (cachedDataString != null) {
      // Parse the cached data and check if it's not expired
      List<CategoryModel> cachedData =
      parseCachedSubCategoryData(cachedDataString);
      DateTime cachedTime =
      DateTime.parse(prefs.getString('cached_data_time') ?? ''); // Use a consistent key for time
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime).inMinutes <= 5) {
        return cachedData;
      }
    }
    return null;
  }

  void saveSubCategoryListToCache(
      String categoryID, List<CategoryModel> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cacheKey = 'cached_subcategory_list_$categoryID';
    prefs.setString(cacheKey, data.toString());
    prefs.setString('cached_data_time', DateTime.now().toString());
  }

  List<CategoryModel> parseCachedSubCategoryData(String cachedDataString) {
    // Parse the cached data and return the List<CategoryModel>
    // You need to implement this based on your data structure
    // For example, you might use json.decode(cachedDataString) for JSON data
  }

  void getCategoryProductList(
      BuildContext context, String categoryID, String languageCode) async {
    filterDropDownValue = "Select filter";
    _categoryProductList = null;
    notifyListeners();

    // Check if data is present in cache and not expired
    List<Product> cachedData = await getCachedData();
    if (cachedData != null) {
      _categoryProductList = cachedData;
      notifyListeners();
      print("Data loaded from cache");
      return;
    }

    ApiResponse apiResponse = await categoryRepo.getCategoryProductList(
      categoryID,
      languageCode,
    );

    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _categoryProductList = [];
      apiResponse.response.data.forEach((category) =>
          _categoryProductList.add(Product.fromJson(category)));

      // Save data to cache
      saveDataToCache(_categoryProductList);

      notifyListeners();
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
  }
  // void getCategoryProductList(
  //     BuildContext context, String categoryID, String languageCode) async {
  //   filterDropDownValue = "Select filter";
  //   _categoryProductList = null;
  //   notifyListeners();
  //   ApiResponse apiResponse =
  //       await categoryRepo.getCategoryProductList(categoryID, languageCode);
  //   if (apiResponse.response != null &&
  //       apiResponse.response.statusCode == 200) {
  //     _categoryProductList = [];
  //     apiResponse.response.data.forEach(
  //         (category) => _categoryProductList.add(Product.fromJson(category)));
  //     notifyListeners();
  //   } else {
  //     ApiChecker.checkApi(context, apiResponse);
  //   }
  // }

  Future<bool> getCategoryProductListById(
      BuildContext context, String categoryID, String languageCode) async {
    _categoryProductListById[categoryID] = null;
    notifyListeners();
    ApiResponse apiResponse =
        await categoryRepo.getCategoryProductList(categoryID, languageCode);
    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _categoryProductListById[categoryID] = [];
      apiResponse.response.data.forEach((category) =>
          _categoryProductListById[categoryID].add(Product.fromJson(category)));

      currentCategoryProductListById[categoryID] =
          _categoryProductListById[categoryID].sublist(
              0, 4 >= _categoryProductListById[categoryID].length ? null : 4);
      currentIndexes[categoryID] = 3;
      notifyListeners();
      return true;
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    return false;
  }

  void setNextCurrentCategoryProductListById(String categoryId) {
    int currentIndex = currentIndexes[categoryId];
    print(categoryId);
    List<Product> products = _categoryProductListById[categoryId];
    if (currentIndex < products.length) {
      currentCategoryProductListById[categoryId] = null;
      notifyListeners();
      currentCategoryProductListById[categoryId] = products.sublist(
          currentIndex,
          currentIndex + 4 >= products.length ? null : currentIndex + 4);
      currentIndexes[categoryId] = currentIndexes[categoryId] + 4;
      print(currentIndex);
      notifyListeners();
    }
  }

  void setPreviousCurrentCategoryProductListById(String categoryId) {
    int currentIndex = currentIndexes[categoryId] - 4;
    print(categoryId);
    List<Product> products = _categoryProductListById[categoryId];
    print(currentIndex);
    if (currentIndex >= 0) {
      currentCategoryProductListById[categoryId] = null;
      notifyListeners();

      currentCategoryProductListById[categoryId] = products.sublist(
          currentIndex - 4 >= 0 ? currentIndex - 4 : 0,
          currentIndex + 1 >= products.length ? null : currentIndex + 1);
      currentIndexes[categoryId] = currentIndexes[categoryId] - 4;
      print(currentIndex);
      notifyListeners();
    }
  }

  int _selectCategory = -1;

  int get selectCategory => _selectCategory;

  updateSelectCategory(int index) {
    _selectCategory = index;
    notifyListeners();
  }

  updateProductCurrentIndex(int index, int totalLength) {
    if (index > 0) {
      _pageFirstIndex = false;
      notifyListeners();
    } else {
      _pageFirstIndex = true;
      notifyListeners();
    }
    if (index + 1 == totalLength) {
      _pageLastIndex = true;
      notifyListeners();
    } else {
      _pageLastIndex = false;
      notifyListeners();
    }
  }
}

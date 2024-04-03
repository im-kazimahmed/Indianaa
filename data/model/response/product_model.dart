import 'package:emarket_user/provider/profile_provider.dart';

class ProductModel {
  int _totalSize;
  String _limit;
  String _offset;
  List<Product> _products;

  ProductModel(
      {int totalSize, String limit, String offset, List<Product> products}) {
    this._totalSize = totalSize;
    this._limit = limit;
    this._offset = offset;
    this._products = products;
  }

  int get totalSize => _totalSize;
  String get limit => _limit;
  String get offset => _offset;
  List<Product> get products => _products;

  ProductModel.fromJson(Map<String, dynamic> json) {
    _totalSize = json['total_size'];
    _limit = json['limit'];
    _offset = json['offset'];
    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products.add(new Product.fromJson(v));
      });
    }
  }

  factory ProductModel.fromJson2(Map<String, dynamic> json) {
    print("on json $json");
    return ProductModel(
      totalSize: json['total_size'],
      limit: json['limit'],
      offset: json['offset'],
      products: (json['products'] as List<dynamic>)
          ?.map((productJson) => Product.fromJson(productJson))
          ?.toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_size'] = this._totalSize;
    data['limit'] = this._limit;
    data['offset'] = this._offset;
    if (this._products != null) {
      data['products'] = this._products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int _id;
  String _name;
  String _description;
  List<String> _image;
  double _price;
  List<Variation> _variations;
  double _tax;
  int _status;
  String _createdAt;
  String _updatedAt;
  List<String> _attributes;
  List<CategoryId> _categoryIds;
  List<ChoiceOption> _choiceOptions;
  double _discount;
  double _rdiscount;
  String _discountType;
  String _taxType;
  int _wishlistCount;
  String _unit;
  int _totalStock;
  List<Rating> _rating;

  Product(
      {int id,
        String name,
        String description,
        List<String> image,
        double price,
        double rprice,
        List<Variation> variations,
        double tax,
        int status,
        String createdAt,
        String updatedAt,
        List<String> attributes,
        List<CategoryId> categoryIds,
        List<ChoiceOption> choiceOptions,
        double discount,
        double rdiscount,
        String discountType,
        String taxType,
        int wishlistCount,
        String unit,
        int totalStock,
        List<Rating> rating}) {
    this._id = id;
    this._name = name;
    this._description = description;
    this._image = image;
    this._price = price;
    this._variations = variations;
    this._tax = tax;
    this._status = status;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    this._attributes = attributes;
    this._categoryIds = categoryIds;
    this._choiceOptions = choiceOptions;
    this._discount = discount;
    this._rdiscount = rdiscount;
    this._discountType = discountType;
    this._taxType = taxType;
    this._wishlistCount = wishlistCount;
    this._unit = unit;
    this._totalStock = totalStock;
    this._rating = rating;
  }

  int get id => _id;
  String get name => _name;
  String get description => _description;
  List<String> get image => _image;
  double get price => _price;
  List<Variation> get variations => _variations;
  double get tax => _tax;
  int get status => _status;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  List<String> get attributes => _attributes;
  List<CategoryId> get categoryIds => _categoryIds;
  List<ChoiceOption> get choiceOptions => _choiceOptions;
  double get discount => _discount;
  double get resellerDiscount => _rdiscount;
  String get discountType => _discountType;
  String get taxType => _taxType;
  int get wishlistCount => _wishlistCount;
  String get unit => _unit;
  int get totalStock => _totalStock;
  List<Rating> get rating => _rating;

  Product.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
    _image = json['image'].cast<String>();
    if(ProfileProvider.userType !="" && ProfileProvider.userType =="Reseller" && (json['rprice']!=""|| json['rprice']!=null))
      _price = json['rprice'].toDouble();
    else
      _price = json['price'].toDouble();

    if (json['variations'] != null) {
      _variations = [];
      json['variations'].forEach((v) {
        _variations.add(new Variation.fromJson(v));
      });
    }
    _tax = json['tax'].toDouble();
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _attributes = json['attributes'].cast<String>();
    if (json['category_ids'] != null) {
      _categoryIds = [];
      json['category_ids'].forEach((v) {
        _categoryIds.add(new CategoryId.fromJson(v));
      });
    }
    if (json['choice_options'] != null) {
      _choiceOptions = [];
      json['choice_options'].forEach((v) {
        _choiceOptions.add(new ChoiceOption.fromJson(v));
      });
    }
    _discount = json['discount'].toDouble();
    if(json['rdiscount'] != null) {
      _rdiscount = double.parse(json['rdiscount'].toString());
    }
    _discountType = json['discount_type'];
    _taxType = json['tax_type'];
    _wishlistCount = json['wishlist_count'];
    _unit = json['unit'];
    _totalStock = json['total_stock'];
    if (json['rating'] != null) {
      _rating = [];
      json['rating'].forEach((v) {
        _rating.add(new Rating.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['description'] = this._description;
    data['image'] = this._image;
    data['price'] = this._price;
    if (this._variations != null) {
      data['variations'] = this._variations.map((v) => v.toJson()).toList();
    }
    data['tax'] = this._tax;
    data['status'] = this._status;
    data['created_at'] = this._createdAt;
    data['updated_at'] = this._updatedAt;
    data['attributes'] = this._attributes;
    if (this._categoryIds != null) {
      data['category_ids'] = this._categoryIds.map((v) => v.toJson()).toList();
    }
    if (this._choiceOptions != null) {
      data['choice_options'] =
          this._choiceOptions.map((v) => v.toJson()).toList();
    }
    data['discount'] = this._discount;
    data['rdiscount'] = this._rdiscount;
    data['discount_type'] = this._discountType;
    data['tax_type'] = this._taxType;
    data['wishlist_count'] = this._wishlistCount;
    data['unit'] = this._unit;
    data['total_stock'] = this._totalStock;
    if (this._rating != null) {
      data['rating'] = this._rating.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variation {
  String _type;
  double _price;
  int _stock;

  Variation({String type, double price, int stock}) {
    this._type = type;
    this._price = price;
    this._stock = stock;
  }

  String get type => _type;
  double get price => _price;
  int get stock => _stock;

  Variation.fromJson(Map<String, dynamic> json) {
    _type = json['type'];
    if(json['price'] != null) {
      _price = json['price'].toDouble();
    }
    _stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this._type;
    data['price'] = this._price;
    data['stock'] = this._stock;
    return data;
  }
}

class CategoryId {
  String _id;

  CategoryId({String id}) {
    this._id = id;
  }

  String get id => _id;

  CategoryId.fromJson(Map<String, dynamic> json) {
    _id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    return data;
  }
}

class ChoiceOption {
  String _name;
  String _title;
  List<String> _options;

  ChoiceOption({String name, String title, List<String> options}) {
    this._name = name;
    this._title = title;
    this._options = options;
  }

  String get name => _name;
  String get title => _title;
  List<String> get options => _options;

  ChoiceOption.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _title = json['title'];
    _options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this._name;
    data['title'] = this._title;
    data['options'] = this._options;
    return data;
  }
}

class Rating {
  String _average;
  int _productId;

  Rating({String average, int productId}) {
    this._average = average;
    this._productId = productId;
  }

  String get average => _average;
  int get productId => _productId;

  Rating.fromJson(Map<String, dynamic> json) {
    _average = json['average'];
    _productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['average'] = this._average;
    data['product_id'] = this._productId;
    return data;
  }
}
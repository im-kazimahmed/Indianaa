import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/helper/price_converter.dart';
import 'package:emarket_user/provider/product_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/routes.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/base/rating_bar.dart';
import 'package:emarket_user/view/screens/product/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../data/model/response/userinfo_model.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/profile_provider.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({@required this.product, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
    double _startingPrice;
    double _endingPrice;
    if (product.variations.length != 0) {
      List<double> _priceList = [];
      product.variations
          .forEach((variation) => _priceList.add(variation.price));
      _priceList.sort((a, b) => a.compareTo(b));
      _startingPrice = _priceList[0];
      if (_priceList[0] < _priceList[_priceList.length - 1]) {
        _endingPrice = _priceList[_priceList.length - 1];
      }
    } else {
      _startingPrice = product.price;
    }

    double _discount;
    String _userType = Provider.of<ProfileProvider>(context, listen: false).getUserType;
    log("message: $_userType");
    if(_userType == "Reseller") {
      log("product ${product.name}");
      log("user is reseller ${product.price}");
      log("reseller discount ${product.resellerDiscount}");
      _discount = product.price -
          PriceConverter.convertWithDiscount(
            context,
            product.price,
            product.resellerDiscount,
            product.discountType,
          );
    } else {
      log("user is normal user ${product.price}");
      _discount = product.price -
          PriceConverter.convertWithDiscount(
            context,
            product.price,
            product.discount,
            product.discountType,
          );
    }

    return Padding(
      padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, bottom: 5),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
              Routes.getProductDetailsRoute(product.id),
              arguments: ProductDetailsScreen(product: product));
        },
        child: Container(
          height: 300,
          width: 170,
          decoration: BoxDecoration(
            image: DecorationImage(
                image:
                    NetworkImage("https://ccadmultiservices.com/jewelry.jpg"),
                fit: BoxFit.cover),
            // color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            // boxShadow: [
            //   Provider.of<ThemeProvider>(context).darkTheme
            //       ? BoxShadow()
            //       : BoxShadow(
            //           color: Colors.grey[300],
            //           blurRadius: 5,
            //           spreadRadius: 1,
            //         )
            // ]
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                          bottom: Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                          height: 120,
                          // width: 170,
                          fit: BoxFit.cover,
                          imageUrl: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}'
                              '/${product.image[0]}',
                          errorWidget: (c, o, s) => Image.asset(Images.placeholder(context),
                              height: 120,
                              // width: 170,
                              fit: BoxFit.cover),
                        ),
                        // child: FadeInImage.assetNetwork(
                        //   placeholder: Images.placeholder(context),
                        //   image:
                        //       '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}'
                        //       '/${product.image[0]}',
                        //   height: 120,
                        //   // width: 170,
                        //   fit: BoxFit.cover,
                        //   imageErrorBuilder: (c, o, t) =>
                        //       Image.asset(Images.placeholder(context),
                        //           height: 120,
                        //           // width: 170,
                        //           fit: BoxFit.cover),
                        // ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_SMALL),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            style: rubikMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if(_userType == "Reseller")
                                Flexible(
                                  child: Text(
                                    '${PriceConverter.convertPrice(context, _startingPrice, discount: product.resellerDiscount, discountType: product.discountType, asFixed: 1)}'
                                    '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, discount: product.resellerDiscount, discountType: product.discountType, asFixed: 1)}' : ''}',
                                    style: rubikBold.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_LARGE),
                                  ),
                                )
                              else
                                Flexible(
                                  child: Text(
                                    '${PriceConverter.convertPrice(context, _startingPrice, discount: product.discount, discountType: product.discountType, asFixed: 1)}'
                                        '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, discount: product.discount, discountType: product.discountType, asFixed: 1)}' : ''}',
                                    style: rubikBold.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_LARGE),
                                  ),
                                ),
                              _discount > 0
                                  ? SizedBox()
                                  : Icon(Icons.add,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color),
                            ],
                          ),
                          _discount > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                      Flexible(
                                        child: Text(
                                          '${PriceConverter.convertPrice(context, _startingPrice, asFixed: 1)}'
                                          '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, asFixed: 1)}' : ''}',
                                          style: rubikBold.copyWith(
                                            fontSize: Dimensions
                                                .FONT_SIZE_EXTRA_SMALL,
                                            color: ColorResources.COLOR_GREY,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      SizedBox(),
                                    ])
                              : SizedBox(),
                          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          /*RatingBar(
                            rating: product.rating.length > 0
                                ? double.parse(product.rating[0].average)
                                : 10,
                            size: 25,
                          ),*/
                        ]),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class ProductsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: 4,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          height: 300,
          width: 170,
          margin:
              EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300], blurRadius: 10, spreadRadius: 1)
              ]),
          child: Shimmer(
            duration: Duration(seconds: 2),
            enabled:
                Provider.of<ProductProvider>(context).offerProductList == null,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 110,
                width: 170,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    color: Colors.grey[300]),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 15, width: 130, color: Colors.grey[300]),
                        Align(
                            alignment: Alignment.centerRight,
                            child: RatingBar(rating: 0.0, size: 12)),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: 10,
                                  width: 50,
                                  color: Colors.grey[300]),
                              Icon(Icons.add,
                                  color: ColorResources.COLOR_BLACK),
                            ]),
                      ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

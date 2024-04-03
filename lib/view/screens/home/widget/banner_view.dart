import 'package:cached_network_image/cached_network_image.dart';
import 'package:emarket_user/utill/routes.dart';
import 'package:emarket_user/view/screens/category/category_screen.dart';
import 'package:emarket_user/view/screens/product/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/category_model.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/localization/language_constrants.dart';
import 'package:emarket_user/provider/banner_provider.dart';
import 'package:emarket_user/provider/category_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/provider/theme_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/view/base/title_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerView extends StatelessWidget {
  String categoryId;
  BannerView({this.categoryId});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Padding(
        //   padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        //   child: TitleWidget(title: getTranslated('banner', context)),
        // ),
        Consumer<BannerProvider>(
          builder: (context, banner, child) {
            return banner.bannerList != null
                ? banner.bannerList.length > 0
                    ? (categoryId != null &&
                                banner
                                    .getCategoryBanners(categoryId)
                                    .isNotEmpty) ||
                            categoryId == null
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                              itemCount: banner.bannerList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(
                                  left: Dimensions.PADDING_SIZE_SMALL),
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    if (banner.bannerList[index].productId !=
                                        null) {
                                      Product product;
                                      for (Product prod in banner.productList) {
                                        if (prod.id ==
                                            banner
                                                .bannerList[index].productId) {
                                          product = prod;
                                          break;
                                        }
                                      }
                                      if (product != null) {
                                        Navigator.of(context).pushNamed(
                                            Routes.getProductDetailsRoute(
                                                product.id),
                                            arguments: ProductDetailsScreen(
                                                product: product));
                                      }
                                    } else if (banner
                                            .bannerList[index].categoryId !=
                                        null) {
                                      CategoryModel category;
                                      for (CategoryModel categoryModel
                                          in Provider.of<CategoryProvider>(
                                                  context,
                                                  listen: false)
                                              .categoryList) {
                                        if (categoryModel.id ==
                                            banner
                                                .bannerList[index].categoryId) {
                                          category = categoryModel;
                                          break;
                                        }
                                      }
                                      if (category != null) {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.getCategoryRoute(category.id),
                                          arguments: CategoryScreen(
                                              categoryModel: category),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.only(
                                        right: Dimensions.PADDING_SIZE_SMALL),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        Provider.of<ThemeProvider>(context)
                                                .darkTheme
                                            ? BoxShadow()
                                            : BoxShadow(
                                                color: Colors.grey[
                                                    Provider.of<ThemeProvider>(
                                                                context)
                                                            .darkTheme
                                                        ? 700
                                                        : 300],
                                                spreadRadius: 1,
                                                blurRadius: 5),
                                      ],
                                      color: ColorResources.COLOR_WHITE,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                                        imageUrl: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.bannerImageUrl}/${banner.bannerList[index].image}',
                                        width: MediaQuery.of(context).size.width - 30,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorWidget: (c, o, s) => Image.asset(
                                          Images.placeholder(context),
                                          width: MediaQuery.of(context).size.width - 30,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // child: FadeInImage.assetNetwork(
                                      //   placeholder:
                                      //       Images.placeholder(context),
                                      //   image:
                                      //       '${Provider.of<SplashProvider>(context, listen: false).baseUrls.bannerImageUrl}/${banner.bannerList[index].image}',
                                      //   width:
                                      //       MediaQuery.of(context).size.width -
                                      //           30,
                                      //   height: 150,
                                      //   fit: BoxFit.cover,
                                      //   imageErrorBuilder: (context, a, b) =>
                                      //       Image.asset(
                                      //     Images.placeholder(context),
                                      //     width: MediaQuery.of(context)
                                      //             .size
                                      //             .width -
                                      //         30,
                                      //     height: 150,
                                      //     fit: BoxFit.cover,
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width - 30,
                            child: Center(
                              child: Image.asset(Images.logo,
                                  width: 40, height: 40),
                            ),
                          )
                    : SizedBox(
                        height: 150,
                        child: Center(
                            child: Text(
                                getTranslated('no_banner_available', context))),
                      )
                : SizedBox(height: 150, child: BannerShimmer());
          },
        ),
      ],
    );
  }
}

class BannerShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Shimmer(
          duration: Duration(seconds: 2),
          enabled: Provider.of<BannerProvider>(context).bannerList == null,
          child: Container(
            width: MediaQuery.of(context).size.width - 30,
            height: 150,
            margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[200], spreadRadius: 1, blurRadius: 5)
              ],
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}

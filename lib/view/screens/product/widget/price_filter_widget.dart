// import 'package:flutter/material.dart';
// import 'package:emarket_user/localization/language_constrants.dart';
// import 'package:emarket_user/provider/category_provider.dart';
// import 'package:emarket_user/provider/search_provider.dart';
// import 'package:emarket_user/utill/color_resources.dart';
// import 'package:emarket_user/utill/dimensions.dart';
// import 'package:emarket_user/utill/styles.dart';
// import 'package:emarket_user/view/base/custom_button.dart';
// import 'package:emarket_user/view/screens/home/widget/category_view.dart';
// import 'package:provider/provider.dart';
//
// class PriceFilterWidget extends StatelessWidget {
//   final double maxValue;
//   PriceFilterWidget({@required this.maxValue});
//
//   @override
//   Widget build(BuildContext context) {
//     final lowerValue = context.watch<CategoryProvider>().lowerValue;
//     final upperValue = context.watch<CategoryProvider>().upperValue;
//     return Padding(
//       padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 icon: Icon(Icons.close, size: 18, color: ColorResources.getGreyBunkerColor(context)),
//               ),
//               Align(
//                 alignment: Alignment.center,
//                 child: Text(
//                   getTranslated('filter', context),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headline3.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_LARGE,
//                     color: ColorResources.getGreyBunkerColor(context),
//                   ),
//                 ),
//               ),
//               // TextButton(
//               //   onPressed: () {
//               //     searchProvider.setRating(-1);
//               //     Provider.of<CategoryProvider>(context, listen: false).updateSelectCategory(-1);
//               //     searchProvider.setLowerAndUpperValue(0, 0);
//               //   },
//               //   child: Text(
//               //     getTranslated('reset', context),
//               //     style: Theme.of(context).textTheme.headline2.copyWith(color: Theme.of(context).primaryColor),
//               //   ),
//               // )
//             ],
//           ),
//
//           Text(
//             getTranslated('price', context),
//             style: Theme.of(context).textTheme.headline3,
//           ),
//
//           SizedBox(height: 15),
//           RangeSlider(
//             values: RangeValues(lowerValue, upperValue),
//             max: maxValue,
//             min: 0,
//             activeColor: Theme.of(context).primaryColor,
//             labels: RangeLabels(lowerValue.toString(), upperValue.toString()),
//             onChanged: (RangeValues rangeValues) {
//               context.read<CategoryProvider>().setLowerAndUpperValue(rangeValues.start, rangeValues.end);
//               // category.setLowerAndUpperValue(rangeValues.start, rangeValues.end);
//             },
//           ),
//           SizedBox(height: 30),
//
//           // CustomButton(
//           //   btnTxt: getTranslated('apply', context),
//           //   onTap: () {
//           //     searchProvider.sortSearchList(Provider.of<CategoryProvider>(context, listen: false).selectCategory,
//           //       Provider.of<CategoryProvider>(context, listen: false).categoryList,
//           //     );
//           //
//           //     Navigator.pop(context);
//           //   },
//           // )
//         ],
//       ),
//     );
//   }
// }

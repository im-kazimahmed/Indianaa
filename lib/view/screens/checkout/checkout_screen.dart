import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'dart:developer';
import 'package:emarket_user/helper/functions.dart';
import 'package:http/http.dart' as http;
import 'package:emarket_user/data/model/response/address_model.dart';
import 'package:emarket_user/helper/price_converter.dart';
import 'package:emarket_user/provider/localization_provider.dart';
import 'package:emarket_user/utill/payment_utils.dart';
import 'package:emarket_user/view/base/custom_divider.dart';
import 'package:emarket_user/view/base/custom_snackbar.dart';
import 'package:emarket_user/view/base/footer_web_view.dart';
import 'package:emarket_user/view/base/web_header/web_app_bar.dart';
import 'package:emarket_user/view/screens/checkout/webview_payment.dart';
import 'package:emarket_user/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/product_provider.dart';
import 'package:emarket_user/utill/app_constants.dart';
import 'package:emarket_user/utill/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emarket_user/data/model/body/place_order_body.dart';
import 'package:emarket_user/data/model/response/cart_model.dart';
import 'package:emarket_user/data/model/response/config_model.dart';
import 'package:emarket_user/localization/language_constrants.dart';
import 'package:emarket_user/provider/auth_provider.dart';
import 'package:emarket_user/provider/cart_provider.dart';
import 'package:emarket_user/provider/coupon_provider.dart';
import 'package:emarket_user/provider/location_provider.dart';
import 'package:emarket_user/provider/order_provider.dart';
import 'package:emarket_user/provider/profile_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/base/custom_app_bar.dart';
import 'package:emarket_user/view/base/custom_button.dart';
import 'package:emarket_user/view/base/custom_text_field.dart';
import 'package:emarket_user/view/base/not_logged_in_screen.dart';
import 'package:emarket_user/view/screens/checkout/widget/custom_check_box.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final double amount;
  final String orderType;
  final bool fromCart;
  final double discount;
  CheckoutScreen({ @required this.amount, @required this.orderType, @required this.fromCart, @required this.cartList, @required this.discount});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  GoogleMapController _mapController;
  bool _isCashOnDeliveryActive;
  bool _isDigitalPaymentActive;
  List<Branches> _branches = [];
  bool _loading = true;
  bool buttonLoading = false;
  Set<Marker> _markers = HashSet<Marker>();
  bool _isLoggedIn;
  List<CartModel> _cartList;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn) {
      _branches = Provider.of<SplashProvider>(context, listen: false).configModel.branches;
      Provider.of<LocationProvider>(context, listen: false).initAddressList(context);
      Provider.of<OrderProvider>(context, listen: false).clearPrevData();
      _isCashOnDeliveryActive = Provider.of<SplashProvider>(context, listen: false).configModel.cashOnDelivery == 'true';
      _isDigitalPaymentActive = Provider.of<SplashProvider>(context, listen: false).configModel.digitalPayment == 'true';
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList) : _cartList.addAll(widget.cartList);
      if(Provider.of<ProfileProvider>(context, listen: false).userInfoModel != null) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
      }
    }

    debugPrint("===${_cartList[0].price}");



  }

  @override
  Widget build(BuildContext context) {
    bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;
    bool _selfPickup = widget.orderType == 'self_pickup';

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120)) :  CustomAppBar(title: getTranslated('checkout', context)),
      body: _isLoggedIn ? Consumer<OrderProvider>(
        builder: (context, order, child) {
          double _deliveryCharge = order.distance
              * Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.shippingPerKm;
          if(_deliveryCharge < Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.minShippingCharge) {
            _deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.minShippingCharge;
          }
          if(!_kmWiseCharge || order.distance == -1) {
            _deliveryCharge = 0;
          }

          return Consumer<LocationProvider>(
            builder: (context, address, child) {
              final _height = MediaQuery.of(context).size.height;
              return Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                                width: 1170,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  if(!ResponsiveHelper.isDesktop(context)) mapView(context, order, _selfPickup, address, _kmWiseCharge),

                                  if(!ResponsiveHelper.isDesktop(context)) detailsView(context, _kmWiseCharge, _selfPickup, order, _deliveryCharge, address),
                                  if(ResponsiveHelper.isDesktop(context)) Padding(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                                    blurRadius: 10,
                                                  )
                                                ]
                                            ),
                                            child: mapView(
                                                context, order, _selfPickup, address, _kmWiseCharge),
                                          ),
                                        ),

                                        SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                                    blurRadius: 10,
                                                  )
                                                ]
                                            ),
                                            child: detailsView(
                                                context, _kmWiseCharge, _selfPickup, order, _deliveryCharge, address),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),



                                ]),
                              ),
                            ),
                            if(ResponsiveHelper.isDesktop(context)) FooterView(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if(!ResponsiveHelper.isDesktop(context)) buttonView(order, _selfPickup, address, _kmWiseCharge, _deliveryCharge, context),

                ],
              );
            },
          );
        },
      ) : NotLoggedInScreen(),
    );
  }

  Container buttonView(OrderProvider order, bool _selfPickup, LocationProvider address, bool _kmWiseCharge, double _deliveryCharge, BuildContext context) {
    return Container(
      width: 1170,
      alignment: Alignment.center,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child: buttonLoading == false ? Builder(
        builder: (context) => CustomButton(btnTxt: getTranslated('confirm_order', context), onTap: () async {
          print('address id : ${_branches[order.branchIndex].id}');
          if(widget.amount < Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue) {
            showCustomSnackBar('Minimum order amount is ${Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue}', context);
          }else if(!_selfPickup && (address.addressList == null || address.addressList.length == 0 || order.addressIndex < 0)) {
            showCustomSnackBar(getTranslated('select_an_address', context), context);
          }else if (!_selfPickup && _kmWiseCharge && order.distance == -1) {
            showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context), context);
          }else if (!_isCashOnDeliveryActive && !_isDigitalPaymentActive) {
            showCustomSnackBar(getTranslated('payment_method_is_not_activated_please_order_later', context), context,isError: true);
          }
          else {
            List<dynamic> carts = [];

            for (int index = 0; index < _cartList.length; index++) {
              carts.add({
                "product_id":_cartList[index].product.id,
                "quantity":_cartList[index].quantity
              }
              );
            }



            double _discount = 0;
            var cartProvider = Provider.of<CartProvider>(context, listen: false);
            cartProvider.cartList.forEach((cartModel) {
              _discount = _discount + (cartModel.discountAmount * cartModel.quantity);
            });

            if(order.paymentMethodIndex == 0){
              // order.placeOrder(
              //   PlaceOrderBody(
              //     cart: carts,
              //     couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount, couponDiscountTitle: '',
              //     deliveryAddressId: !_selfPickup ? Provider.of<LocationProvider>(context, listen: false)
              //         .addressList[order.addressIndex].id : 0,
              //     orderAmount: widget.amount+_deliveryCharge, orderNote: _noteController.text ?? '', orderType: widget.orderType,
              //     paymentMethod: _isCashOnDeliveryActive ? order.paymentMethodIndex == 0 ? 'cash_on_delivery' : null : null,
              //     // couponCode: Provider.of<CouponProvider>(context, listen: false).coupon != null
              //     //     ? Provider.of<CouponProvider>(context, listen: false).coupon.code : null,
              //     branchId: _branches[order.branchIndex].id, distance: _selfPickup ? 0 : order.distance,
              //   ), _callback,
              // );
              // placeOrderApi({"order_amount":50,"order_type":"delivery","branch_id":_branches[order.branchIndex].id,"cart":carts});
              setState(() {
                buttonLoading = true;
                placeOrderApi(
                    orderAmount: widget.amount,
                    deleveryId: !_selfPickup ? Provider.of<LocationProvider>(context, listen: false)
                        .addressList[order.addressIndex].id : 0,
                    orderType: "delivery",
                    branchId: _branches[order.branchIndex].id,
                    cart: carts,
                    from: "Cash",
                    paymentMethod: "COD",
                    discount: _discount
                );

              });

            }else {
              // String id = generateRandomTransactionId(1000);
              // bool result = await _callbackOnline(true,"Payment",id, 0);
              // if(result) {
              setState(() {
                buttonLoading = true;
                placeOrderApi(
                  orderAmount: widget.amount,
                  deleveryId: !_selfPickup ? Provider.of<LocationProvider>(context, listen: false)
                      .addressList[order.addressIndex].id : 0,
                  orderType: "delivery",
                  branchId: _branches[order.branchIndex].id,
                  cart: carts,
                  from: "Online",
                  paymentMethod: "Digital_Payment",
                  discount: _discount,
                );
              });
              // }

              // fetchMerchantEncryptedData("100071");
              //
              // //
              //  String data =
              //      "merchant_id=2571703&order_id=009&redirect_url=https://india-naa.in.php&cancel_url=https://india-naa.in.php&amount=50.00&currency=INR";
              //  //
              //  // String key = "E62DC9E51412A129987A3E17430C0713";
              //
              // Encrypted result = PaymentUtils.encryptDataS(data);
              //
              // print("Result ${result.bytes}");
              //  print("Result ${result.base16}");
              //  print("Result ${result.base64}");
              //
              //  String result2 =   PaymentUtils.decrypterData(result);
              //
              //  print("Result2 ${result2}");
// PaymentUtils.fetchMerchantEncryptedData();




              // CcAvenue.cCAvenueInit(
              //     transUrl: 'https://secure.ccavenue.com/transaction/initTrans',
              //     accessCode: 'AVEO78KF76BH82OEHB',
              //     amount: '10',
              //     cancelUrl: 'https://admin.india-naa.in',
              //     currencyType: 'INR',
              //     merchantId: '2571703',
              //     orderId: '519',
              //     redirectUrl: 'https://admin.india-naa.in',
              //     rsaKeyUrl: 'https://secure.ccavenue.com/transaction/jsp/GetRSA.jsp'
              //
              //     // transUrl: 'https://secure.ccavenue.com/transaction/initTrans',
              //     // accessCode: 'AVEO78KF76BH82OEHB',
              //     // amount: '1',
              //     // cancelUrl: 'https://india-naa.in',
              //     // currencyType: 'INR',
              //     // merchantId: '2571703',
              //     // orderId: '520',
              //     // redirectUrl: 'https://india-naa.in/',
              //     // rsaKeyUrl: 'https://secure.ccavenue.com/transaction/jsp/GetRSA.jsp'
              // ).whenComplete(() {
              //   print("DONEPAYMENT");
              //   order.placeOrder(
              //     PlaceOrderBody(
              //       cart: carts, couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount, couponDiscountTitle: '',
              //       deliveryAddressId: !_selfPickup ? Provider.of<LocationProvider>(context, listen: false)
              //           .addressList[order.addressIndex].id : 0,
              //       orderAmount: widget.amount+_deliveryCharge, orderNote: _noteController.text ?? '', orderType: widget.orderType,
              //       paymentMethod: _isCashOnDeliveryActive ? order.paymentMethodIndex == 0 ? 'cash_on_delivery' : null : null,
              //       couponCode: Provider.of<CouponProvider>(context, listen: false).coupon != null
              //           ? Provider.of<CouponProvider>(context, listen: false).coupon.code : null,
              //       branchId: _branches[order.branchIndex].id, distance: _selfPickup ? 0 : order.distance,
              //     ), _callback,
              //   );
              // })..then((value) {
              //   debugPrint("=======");
              // })..onError((error, stackTrace) {
              //   print("======${error.toString()}");
              // });
              // fetchMerchantEncryptedData();

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) =>  WebViewPage(fromDetails: "99F716ABE521A85E04D2F4BB11F5F9DAC52610A768376EAB0A352E2F47673D22C21B63FB43161E95C7EC88100F782BFF0859558B98411E1FFF1BBFCCB2DA34AC047250A98447E7705C0B9B0A98467A66CAF33F61503FBB9AFCF52525F7D8A7B4C521D6CE51BED52EFFCB6EA61B9953BFC0A655D083AD08A02B0FF90AC567E512F6D7916583A2B68F51A5E73E492F4D6A",)));

            }


          }
        }),
      ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
    );
  }

  Future<bool> fetchMerchantEncryptedData(String orderId) async {
    try {
      final amount = "50";
      // var rng = Random();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var  token = await prefs.getString(AppConstants.TOKEN);
      debugPrint("");
      final response = await http
          .post(Uri.parse("https://india-naa.in/api/v1/customer/payment/transaction"),
          body: {"order_id":orderId}, headers: { "authorization" : "Bearer ${token}",
          });
      print("bearer: $token");
      print("response is ${response.statusCode}");

      print("Second response is ${response.body}");
      if(response.statusCode == 200){
        setState(() {
          buttonLoading = false;
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  WebViewPage(fromDetails: response.body,orderId: orderId,)));
          //http.post(Uri.parse("https://india-naa.in/api/v1/customer/order/update_ccavenue"), body: {"orderId": orderId});
          return true;
        });

      }
    } catch (e) {
      print(e.toString());
      return false;
    }
    return false;
  }

  placeOrderApi({double orderAmount,int deleveryId,String orderType,int branchId,List cart,String from, String paymentMethod, double discount}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var  token = await prefs.getString(AppConstants.TOKEN);
    log("place order api called");
    var requestBody = {
      'order_amount':orderAmount,
      'delivery_address_id':deleveryId.toString(),
      'order_type':orderType.toString(),
      'branch_id':branchId.toString(),
      'cart':json.encode(cart),
      'payment_method': paymentMethod,
      'order_status': 'confirmed',
      'discount_on_product': discount
    };

    try {
      debugPrint(json.encode(requestBody));

      final response = await http
          .post(Uri.parse("https://india-naa.in/api/v1/customer/order/place"),
          headers: {
            "authorization" : "Bearer ${token}",
            'Content-Type': 'application/json'
          },body: json.encode(requestBody));

      debugPrint("============${response.body}");

      if(response.statusCode == 200){
        var data = json.decode(response.body);
        log("status code 200 response $data");
        if(from == "Online"){
          _callbackOnline(true,data["message"],data["order_id"].toString(),deleveryId);
        }else{
          _callback(true,data["message"],data["order_id"].toString(),deleveryId);
        }


      }else if(response.statusCode == 403) {
        log("status code 403");
        setState(() {
          buttonLoading = false;
        });

        var data = json.decode(response.body);
        showCustomSnackBar(data["errors"][0]["message"], context, isError: true);
        debugPrint("============${data["errors"][0]["message"]}");

      }




      // Map<String, String> headers= <String,String>{
      //   'Authorization':'Bearer ${token}'
      // };
      //
      // var uri = Uri.parse('https://india-naa.in/api/v1/customer/order/place');
      // var request = http.MultipartRequest('POST', uri)
      //   ..headers.addAll(headers) //if u have headers, basic auth, token bearer... Else remove line
      //   ..fields.addAll(requestBody);
      // var response = await request.send();
      // final respStr = await response.stream.bytesToString();
      // return jsonDecode(respStr);





      // if(response.statusCode == 200){
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) =>  WebViewPage(fromDetails: response.body,)));
      // }


    } catch (e) {
      print(e.toString());

    }
  }


  Column mapView(BuildContext context, OrderProvider order, bool _selfPickup, LocationProvider address, bool _kmWiseCharge)  {
    return Column(
      children: [
        _branches.length > 1 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(getTranslated('select_branch', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              physics: BouncingScrollPhysics(),
              itemCount: _branches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                  child: InkWell(
                    onTap: () {
                      order.setBranchIndex(index);
                      _setMarkers(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == order.branchIndex ? Theme.of(context).primaryColor : ColorResources.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(_branches[index].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: rubikMedium.copyWith(
                        color: index == order.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyText1.color,
                      )),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            height: 200,
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Stack(children: [
              GoogleMap(
                minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(target: LatLng(
                  double.parse(_branches[0].latitude),
                  double.parse(_branches[0].longitude),
                ), zoom: 16),
                zoomControlsEnabled: true,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) async {
                  await Geolocator.requestPermission();
                  _mapController = controller;
                  _loading = false;
                  _setMarkers(0);
                },
              ),
              _loading ? Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              )) : SizedBox(),
            ]),
          ),
        ]) : SizedBox(),


        !_selfPickup ? Column(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
            child: Row(children: [
              Text(getTranslated('delivery_address', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
              Expanded(child: SizedBox()),
              TextButton.icon(
                onPressed: () =>  Navigator.pushNamed(context, Routes.getAddAddressRoute('checkout', 'add', AddressModel())),
                icon: Icon(Icons.add),
                label: Text(getTranslated('add', context), style: rubikRegular),
              ),
            ]),
          ),

          SizedBox(
            height: 60,
            child: address.addressList != null ? address.addressList.length > 0 ? ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
              itemCount: address.addressList.length,
              itemBuilder: (context, index) {
                bool _isAvailable = _branches.length == 1 && (_branches[0].latitude == null || _branches[0].latitude.isEmpty);
                if(!_isAvailable) {
                  double _distance = Geolocator.distanceBetween(
                    double.parse(_branches[order.branchIndex].latitude), double.parse(_branches[order.branchIndex].longitude),
                    double.parse(address.addressList[index].latitude), double.parse(address.addressList[index].longitude),
                  ) / 1000;
                  _isAvailable = _distance < _branches[order.branchIndex].coverage;
                }
                return Padding(
                  padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                  child: InkWell(
                    onTap: () async {
                      if(_isAvailable) {
                        order.setAddressIndex(index);
                        if(_kmWiseCharge) {
                          showDialog(context: context, builder: (context) => Center(child: Container(
                            height: 100, width: 100, decoration: BoxDecoration(
                            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                          ),
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                          )), barrierDismissible: false);
                          bool _isSuccess = await order.getDistanceInMeter(
                            LatLng(
                              double.parse(_branches[order.branchIndex].latitude),
                              double.parse(_branches[order.branchIndex].longitude),
                            ),
                            LatLng(
                              double.parse(address.addressList[index].latitude),
                              double.parse(address.addressList[index].longitude),
                            ),
                          );
                          Navigator.pop(context);
                          if(_isSuccess) {
                            showDialog(context: context, builder: (context) => DeliveryFeeDialog(
                              amount: widget.amount, distance: order.distance,
                            ));
                          }else {
                            showCustomSnackBar(getTranslated('failed_to_fetch_distance', context), context);
                          }
                        }
                      }
                    },
                    child: Stack(children: [
                      Container(
                        height: 60,
                        width: 200,
                        decoration: BoxDecoration(
                          color: index == order.addressIndex ? Theme.of(context).cardColor : ColorResources.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: index == order.addressIndex ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                        ),
                        child: Row(children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(
                              address.addressList[index].addressType == 'Home' ? Icons.home_outlined
                                  : address.addressList[index].addressType == 'Workplace' ? Icons.work_outline : Icons.list_alt_outlined,
                              color: index == order.addressIndex ? Theme.of(context).primaryColor
                                  : Theme.of(context).textTheme.bodyText1.color,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(address.addressList[index].addressType, style: rubikRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyBunkerColor(context),
                              )),
                              Text(address.addressList[index].address, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ]),
                          ),
                          index == order.addressIndex ? Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                          ) : SizedBox(),
                        ]),
                      ),
                      !_isAvailable ? Positioned(
                        top: 0, left: 0, bottom: 0, right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                          child: Text(
                            getTranslated('out_of_coverage_for_this_branch', context),
                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ) : SizedBox(),
                    ]),
                  ),
                );
              },
            ) : Center(child: Text(getTranslated('no_address_available', context)))
                : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
          ),
          SizedBox(height: 20),
        ]) : SizedBox(),
      ],
    );
  }

  Column detailsView(BuildContext context, bool _kmWiseCharge, bool _selfPickup, OrderProvider order, double _deliveryCharge, LocationProvider address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
          child: Text(getTranslated('payment_method', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
        ),
        _isCashOnDeliveryActive ? CustomCheckBox(title: getTranslated('cash_on_delivery', context), index: 0) : SizedBox(),
        _isCashOnDeliveryActive ? InkWell(
          onTap: () => order.setPaymentMethod(1),
          child: Row(children: [
            Checkbox(
              value: order.paymentMethodIndex == 1,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool isChecked) => order.setPaymentMethod(1),
            ),

            Image.asset("assets/image/ic_ccAvenue.png",width: 80,),SizedBox(width: 30,)
          ]),
        )
            :SizedBox.shrink(),

        _isCashOnDeliveryActive || _isDigitalPaymentActive ? SizedBox.shrink() :  Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL,vertical: Dimensions.PADDING_SIZE_SMALL),
          child: Text('No Payment Method is Active',style: rubikRegular),
        ),

        Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: CustomTextField(
            controller: _noteController,
            hintText: getTranslated('additional_note', context),
            maxLines: 5,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ),

        _kmWiseCharge ? Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
          child: Column(children: [
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(getTranslated('subtotal', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
              Text(PriceConverter.convertPrice(context, widget.amount), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            ]),
            SizedBox(height: 10),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                getTranslated('delivery_fee', context),
                style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              ),
              Text(
                (_selfPickup || order.distance != -1) ? '(+) ${PriceConverter.convertPrice(context, _selfPickup ? 0 : _deliveryCharge)}'
                    : getTranslated('not_found', context),
                style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              ),
            ]),

            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
              child: CustomDivider(),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(getTranslated('total_amount', context), style: rubikMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor,
              )),
              Text(
                PriceConverter.convertPrice(context, widget.amount+_deliveryCharge),
                style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
              ),
            ]),
          ]),
        ) : SizedBox(),
        SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

        if(ResponsiveHelper.isDesktop(context)) buttonView(order, _selfPickup, address, _kmWiseCharge, _deliveryCharge, context),

      ],
    );
  }

  Future<bool> _callbackOnline(bool isSuccess, String message, String orderID, int addressID) async {
    debugPrint("=====MESSAGE${message.toString()}");
    if(isSuccess){
      return fetchMerchantEncryptedData(orderID);
    }else {
      setState(() {
        buttonLoading = false;
      });

      showCustomSnackBar(message, context, isError: true);
    }
    return false;
  }

  void _callback(bool isSuccess, String message, String orderID, int addressID) async {
    debugPrint("=====MESSAGE${message.toString()}");
    if(isSuccess) {
      if(widget.fromCart) {
        Provider.of<CartProvider>(context, listen: false).clearCartList();
      }
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
      Provider.of<ProductProvider>(context, listen: false).getPopularProductList(
        context, '1', true, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      );
      if(_isCashOnDeliveryActive && Provider.of<OrderProvider>(context, listen: false).paymentMethodIndex == 0) {
        setState(() {
          buttonLoading = false;
          Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_SCREEN}/$orderID/success');
        });

      }else {
        if (ResponsiveHelper.isWeb()) {
          String hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.BASE_URL}/payment-mobile?order_id=$orderID&&customer_id=${Provider.of<ProfileProvider>(context, listen: false).getUserId()
          }'
              '&&callback=$protocol//$hostname${Routes.ORDER_SUCCESS_SCREEN}/$orderID';
          html.window.open(selectedUrl, "_self");

        } else {
          Navigator.pushReplacementNamed(context, Routes.getPaymentRoute('checkout', orderID, Provider.of<ProfileProvider>(context, listen: false).userInfoModel.id));
        }
      }
    }else {
      setState(() {
        buttonLoading = false;
      });
      showCustomSnackBar(message, context, isError: true);
    }
  }

  void _setMarkers(int selectedIndex) async {
    BitmapDescriptor _bitmapDescriptor;
    BitmapDescriptor _bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30, 50)), Images.restaurant_marker).then((_marker) {
      _bitmapDescriptor = _marker;
    });
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(20, 20)), Images.unselected_restaurant_marker).then((_marker) {
      _bitmapDescriptorUnSelect = _marker;
    });

    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index<_branches.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.parse(_branches[index].latitude), double.parse(_branches[index].longitude)),
        infoWindow: InfoWindow(title: _branches[index].name, snippet: _branches[index].address),
        icon: selectedIndex == index ? _bitmapDescriptor : _bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      double.parse(_branches[selectedIndex].latitude),
      double.parse(_branches[selectedIndex].longitude),
    ), zoom: ResponsiveHelper.isMobile(context) ? 12 : 16)));

    setState(() {});
  }


//
// Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
//   ByteData data = await rootBundle.load(imagePath);
//   Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
//   FrameInfo fi = await codec.getNextFrame();
//   return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
// }

// void _checkPermission(BuildContext context, String navigateTo) async {
//   LocationPermission permission = await Geolocator.checkPermission();
//   if(permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//   }
//   if(permission == LocationPermission.denied) {
//     showCustomSnackBar(getTranslated('you_have_to_allow', context), context);
//   }else if(permission == LocationPermission.deniedForever) {
//     showDialog(context: context, barrierDismissible: false, builder: (context) => PermissionDialog());
//   }else {
//     Navigator.pushNamed(context, navigateTo);
//   }
// }

}

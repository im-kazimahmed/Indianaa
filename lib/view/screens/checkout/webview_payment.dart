import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../provider/cart_provider.dart';
import '../../../utill/routes.dart';

class WebViewPage extends StatefulWidget {

  final String fromDetails;
  final String orderId;

  WebViewPage({this.fromDetails,this.orderId});
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebViewPage> {
  bool loading = true;

  @override
  void initState() {

    print("======"+widget.fromDetails);
    super.initState();

    // _loadHTML();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        //title: new Text('Are you sure?'),
        content: new Text('Do you want to cancel this transaction ?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (_) => HomePage()));
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        // appBar: AppBar(
        //   title: Text('Payment'),
        // ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        javaScriptEnabled: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useWideViewPort: false,
                        useHybridComposition: true,
                        loadWithOverviewMode: true,
                        domStorageEnabled: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          enableViewportScale: true,
                          ignoresViewportScaleLimits: true)),
                  initialData: InAppWebViewInitialData(

                      data: widget.fromDetails),
                  onWebViewCreated: (InAppWebViewController controller) {
                  },
                  onLoadError: (controller, url, code, message) {
                    print(message);
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri pageUri) async {
                    if(pageUri.path == "/public/ccavenue/ccavResponseHandler.php"){
                      Provider.of<CartProvider>(context, listen: false).clearCartList();
                      //http.post(Uri.parse("https://india-naa.in/ccavenue/v1/customer/order/updateca"), body: {"orderId": '1234'});
                      //var response = await http.post(Uri.parse("https://india-naa.in/update.php"));
                      var response = await http.post(Uri.parse("https://india-naa.in/update.php?orderId=${widget.orderId}"));
                      if (response.statusCode == 201) {
                        Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESS_SCREEN}/${widget.orderId}/success');
                      } else {
                        Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESSPG_SCREEN}/${widget.orderId}/success');
                      }
                      //Navigator.pushReplacementNamed(context, '${Routes.ORDER_SUCCESSPG_SCREEN}/${widget.orderId}/success');
                      //Navigator.pushReplacementNamed(context, '${Routes.ORDER_SCREEN}');
                    }

                  },iosOnNavigationResponse:  (controller, navigationResponse) {
                  debugPrint("====URL${navigationResponse.response.url.path}");
                },
                ),
              ),
              // (loading)
              //     ? Center(
              //   child: CircularProgressIndicator(),
              // )
              //     : Center(),
            ],
          ),
        ),
      ),
    );
  }

  String _loadHTML() {
    final url = "https://qasecure.ccavenue.com/transaction.do";
    final command = "initiateTransaction";
    final encRequest = widget.fromDetails.toString();
    final accessCode = "AVEO78KF76BH82OEHB";
    //final accessCode = "AVFC27FH13AB03CFBA";

    String html =
        "<html> <head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head> <body onload='document.f.submit();'> <form id='f' name='f' method='post' action='$url'>" +
            "<input type='hidden' name='command' value='$command'/>" +
            "<input type='hidden' name='encRequest' value='$encRequest' />" +
            "<input  type='hidden' name='access_code' value='$accessCode' />";
    print(html);
    return html + "</form> </body> </html>";
  }


}

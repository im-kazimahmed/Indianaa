import 'package:cached_network_image/cached_network_image.dart';
import 'package:emarket_user/data/model/response/chat_model.dart';
import 'package:emarket_user/helper/date_converter.dart';
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/profile_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/screens/chat/widget/image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  final Messages messages;
  final bool isAdmin;
  const MessageBubble({Key key, this.messages, this.isAdmin}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    final _profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    return !isAdmin ? messages.deliverymanId != null ?
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
      ),

      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(messages.deliverymanId.name??'',style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT))
                    ),
                    child: ClipRRect(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Image.asset(Images.profile),
                        imageUrl: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.deliveryManImageUrl}/${messages.deliverymanId.image??''}',
                        width: 40, height: 40,
                        errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                      ),
                      // child: FadeInImage.assetNetwork(
                      //   placeholder: Images.profile, fit: BoxFit.cover, width: 40, height: 40,
                      //   image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.deliveryManImageUrl}/${messages.deliverymanId.image??''}',
                      //   imageErrorBuilder: (c, o, s) => Image.asset(Images.profile, fit: BoxFit.cover),
                      // ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     if(messages.message != null) Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(child: Padding(
                            padding: EdgeInsets.all(messages.message != null?Dimensions.PADDING_SIZE_DEFAULT:0),
                            child: Text(messages.message??''),
                          ),),
                        ),
                      ),
                     if( messages.attachment !=null) SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      messages.attachment !=null? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                            crossAxisSpacing: 5, mainAxisSpacing: 5,
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: messages.attachment.length,
                        itemBuilder: (BuildContext context, index){
                          return  messages.attachment.length > 0?
                          InkWell(
                            onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages.attachment[index]), ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                imageUrl: '${messages.attachment[index] ?? ''}',
                                errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                              ),
                              // child:FadeInImage.assetNetwork(
                              //   placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                              //   image: '${messages.attachment[index] ?? ''}',
                              //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                              // ),
                            ),
                          ):SizedBox();

                        },):SizedBox(),
                    ],
                  ),
                ),

              ],
            ),





            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            SizedBox(),
            Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages.createdAt)), style: rubikRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_SMALL),),
          ],
        ),
      ),
    ):
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.PADDING_SIZE_DEFAULT),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
          //color: Colors.red
        ),

        child: Padding(
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_profileProvider.userInfoModel.fName} ${_profileProvider.userInfoModel.lName}',style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                       if(messages.message != null) Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorResources.getChatAdminColor(context),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(messages.message != null ? Dimensions.PADDING_SIZE_DEFAULT:0),
                              child: Text(messages.message??''),
                            ),
                          ),
                        ),
                        messages.attachment != null ? SizedBox(height: Dimensions.PADDING_SIZE_SMALL) : SizedBox(),
                        messages.attachment !=null? Directionality(
                          textDirection: TextDirection.rtl,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8: 3,
                                crossAxisSpacing: 5, mainAxisSpacing: 5,
                            ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: messages.attachment.length,
                            itemBuilder: (BuildContext context, index){
                              return  (messages.attachment.length !=null  &&  messages.attachment.length > 0) ?
                              InkWell(
                                onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages.attachment[index]), ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                    imageUrl: '${messages.attachment[index] ?? ''}',
                                    errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                  ),
                                  // child: FadeInImage.assetNetwork(
                                  //   placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                  //   image: '${messages.attachment[index] ?? ''}',
                                  //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                  // ),
                                ),
                              ):SizedBox();

                            },),
                        ):SizedBox(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                    child: Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT))
                      ),
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Image.asset(Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40),
                          imageUrl: Provider.of<ProfileProvider>(context, listen: false).userInfoModel != null?
                            '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.image}':'',
                          errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                        ),
                        // child: FadeInImage.assetNetwork(
                        //   placeholder: Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,
                        //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                        //   image: Provider.of<ProfileProvider>(context, listen: false).userInfoModel != null?
                        //   '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.image}':'',
                        // ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),




              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages.createdAt)), style: rubikRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_SMALL),),

            ],
          ),
        ),
      ),
    )
    //customer to admin
        :Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      child: (messages.isReply != null && messages.isReply) ?
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),

        ),

        child: Padding(
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Provider.of<SplashProvider>(context,listen: false).configModel.ecommerceName}',style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Image.asset(Images.logo, fit: BoxFit.cover, width: 40, height: 40),
                      imageUrl: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.ecommerceImageUrl}/${Provider.of<SplashProvider>(context,listen: false).configModel.ecommerceLogo}',
                      errorWidget: (c, o, s) => Image.asset(Images.logo, fit: BoxFit.contain, width: 40, height: 40),
                    ),
                    // child: FadeInImage.assetNetwork(
                    //   placeholder: Images.logo, fit: BoxFit.cover, width: 40, height: 40,
                    //   image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.ecommerceImageUrl}/${Provider.of<SplashProvider>(context,listen: false).configModel.ecommerceLogo}',
                    //   imageErrorBuilder: (c, o, s) => Image.asset(Images.logo, fit: BoxFit.contain, width: 40, height: 40),
                    // ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),


                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      if(messages.reply != null && messages.reply.isNotEmpty)  Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Container(child: Padding(
                              padding: EdgeInsets.all(messages.reply != null?Dimensions.PADDING_SIZE_DEFAULT:0),
                              child: Text(messages.reply??''),
                            ),),
                          ),
                        ),
                        if(messages.reply != null && messages.reply.isNotEmpty) SizedBox(height: 8.0),

                        messages.attachment != null ?
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1,
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                              crossAxisSpacing: 5, mainAxisSpacing: 5,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: messages.attachment.length,
                          itemBuilder: (BuildContext context, index){
                            return  messages.attachment.length > 0?
                            InkWell(
                              hoverColor: Colors.transparent,
                              onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.chatImageUrl}/${messages.attachment[index]}'), ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: (messages.message != null && messages.message.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0,),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                                        height: 100, width: 100, fit: BoxFit.cover,
                                        imageUrl: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.chatImageUrl}/${messages.attachment[index] ?? ''}',
                                        errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                      ),
                                    // child: FadeInImage.assetNetwork(
                                    //   placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                    //   image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.chatImageUrl}/${messages.attachment[index] ?? ''}',
                                    //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                    // ),
                                ),

                              ),
                            ):SizedBox();

                          },):SizedBox(),


                      ],
                    ),
                  ),

                ],
              ),





              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages.createdAt)), style: rubikRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_SMALL),),
            ],
          ),
        ),
      ):

      Padding(
        padding: const EdgeInsets.symmetric(horizontal:Dimensions.PADDING_SIZE_DEFAULT),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),

          ),

          child: Consumer<ProfileProvider>(
              builder: (context, profileController,_) {
                return Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${profileController.userInfoModel != null?profileController.userInfoModel.fName??'':''} ${profileController.userInfoModel != null?profileController.userInfoModel.lName??'':''}', style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              (messages.message != null && messages.message.isNotEmpty) ? Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorResources.getChatAdminColor(context),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(child: Padding(
                                    padding: EdgeInsets.all(messages.message != null?Dimensions.PADDING_SIZE_DEFAULT:0),
                                    child: Text(messages.message??''),
                                  ),),
                                ),
                              ) : SizedBox(),
                              messages.attachment != null ?
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: GridView.builder(
                                  reverse: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 1,
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                                      crossAxisSpacing: 5, mainAxisSpacing: 5
                                  ),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: messages.attachment.length,
                                  itemBuilder: (BuildContext context, index){
                                    return  messages.attachment.length > 0?
                                    InkWell(
                                      onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages.attachment[index])),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: (messages.message != null && messages.message.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0,                                       ),
                                        child:ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                                            height: 100, width: 100, fit: BoxFit.cover,
                                            imageUrl: '${messages.attachment[index] ?? ''}',
                                            errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                          ),
                                          // child: FadeInImage.assetNetwork(
                                          //   placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                          //   image: '${messages.attachment[index] ?? ''}',
                                          //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                          // ),
                                        ),
                                      ),
                                    ):SizedBox();

                                  },),
                              ):SizedBox(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                          child: Container(width: 40, height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT))
                            ),
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                                imageUrl: profileController.userInfoModel != null? '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/${profileController.userInfoModel.image}':'',
                                fit: BoxFit.cover, width: 40, height: 40,
                                errorWidget: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,),
                              ),
                              // child: FadeInImage.assetNetwork(
                              //   placeholder: Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,
                              //   image: profileController.userInfoModel != null? '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/${profileController.userInfoModel.image}':'',
                              //   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,),
                              // ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),


                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages.createdAt)), style: rubikRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_SMALL),),
                    SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}

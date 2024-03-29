import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/constant/route_paths.dart';
import 'package:flutterbuyandsell/ui/common/ps_ui_widget.dart';
import 'package:flutterbuyandsell/ui/common/smooth_star_rating_widget.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/viewobject/user.dart';

class UserVerticalListItem extends StatelessWidget {
  const UserVerticalListItem(
      {Key? key,
      required this.user,
      this.onTap,
      this.animationController,
      this.animation})
      : super(key: key);

  final User user;
  final VoidCallback? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();

    return AnimatedBuilder(
        animation: animationController!,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: PsDimens.space120,
            margin: const EdgeInsets.only(bottom: PsDimens.space4),
            child: Ink(
              color: PsColors.backgroundColor,
              child: Padding(
                  padding: const EdgeInsets.all(PsDimens.space16),
                  child: UserWidget(user: user, onTap: onTap!)
                  //  Card(
                  //   elevation: 0.0,
                  //   child: ClipPath(
                  //     child: Container(
                  //         height: PsDimens.space120,
                  //         margin: const EdgeInsets.all(PsDimens.space8),
                  //         child: UserWidget(user: user, onTap: onTap)),
                  //     clipper: ShapeBorderClipper(
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(4))),
                  //   ),
                  // )
                  ),
            ),
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
              opacity: animation!,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation!.value), 0.0),
                  child: child));
        });
  }
}

class UserWidget extends StatelessWidget {
  const UserWidget({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space8,
    );

    // final Widget _imageWidget = PsNetworkCircleImageForUser(
    //   photoKey: '',
    //   imagePath: user.userProfilePhoto,
    //   width: PsDimens.space76,
    //   height: PsDimens.space80,
    //   boxfit: BoxFit.cover,
    //   onTap: () {
    //     onTap();
    //   },
    // );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // _imageWidget,
            Container(
              width: PsDimens.space76,
              height: PsDimens.space80,
              child: PsNetworkCircleImageForUser(
                photoKey: '',
                imagePath: user.userProfilePhoto,
                // width: PsDimens.space76,
                // height: PsDimens.space80,
                boxfit: BoxFit.cover,
                onTap: () {
                  onTap();
                },
              ),
            ),
            const SizedBox(
              width: PsDimens.space12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                      user.userName == ''
                          ? Utils.getString(context, 'default__user_name')
                          : user.userName!,
                      style: Theme.of(context).textTheme.subtitle1),
                  _spacingWidget,
                  _RatingWidget(
                    data: user,
                  ),
                  _spacingWidget,
                  Text(
                    '${Utils.getString(context, 'user_detail__joined')} - ${Utils.getDateFormat(user.addedDate!)}',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class _RatingWidget extends StatelessWidget {
  const _RatingWidget({
    Key? key,
    @required this.data,
  }) : super(key: key);

  final User? data;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          data!.overallRating!,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(
          width: PsDimens.space8,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, RoutePaths.ratingList,
                arguments: data!.userId);
          },
          child: SmoothStarRating(
              key: Key(data!.ratingDetail!.totalRatingValue!),
              rating: double.parse(data!.ratingDetail!.totalRatingValue!),
              allowHalfRating: false,
              isReadOnly: true,
              starCount: 5,
              size: PsDimens.space16,
              color: Colors.yellow,
              borderColor: Colors.blueGrey[200],
              onRated: (double v) {},
              spacing: 0.0),
        ),
        const SizedBox(
          width: PsDimens.space8,
        ),
        Text(
          '( ${data!.ratingCount} )',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}

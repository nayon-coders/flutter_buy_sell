import 'package:flutterbuyandsell/api/common/ps_admob_banner_widget.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/config/ps_config.dart';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/provider/product/search_product_provider.dart';
import 'package:flutterbuyandsell/repository/product_repository.dart';
import 'package:flutterbuyandsell/ui/item/item/product_vertical_list_item.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/product_parameter_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterbuyandsell/viewobject/product.dart';
import 'package:provider/provider.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/constant/route_paths.dart';
import 'package:flutterbuyandsell/ui/common/ps_ui_widget.dart';

class ProductListWithFilterView extends StatefulWidget {
  const ProductListWithFilterView(
      {Key? key,
      required this.productParameterHolder,
      required this.animationController,
      this.changeAppBarTitle})
      : super(key: key);

  final ProductParameterHolder productParameterHolder;
  final AnimationController animationController;
  final Function? changeAppBarTitle;

  @override
  _ProductListWithFilterViewState createState() =>
      _ProductListWithFilterViewState();
}

class _ProductListWithFilterViewState extends State<ProductListWithFilterView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  SearchProductProvider? _searchProductProvider;
  bool isVisible = true;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _offset = 0;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final String loginUserId =
                      Utils.checkUserLoginId(valueHolder!);
        _searchProductProvider!.nextProductListByKey(
            loginUserId,
            _searchProductProvider!.productParameterHolder);
      }
      setState(() {
        final double offset = _scrollController.offset;
        _delta = offset - _oldOffset!;
        if (_delta! > _containerMaxHeight)
          _delta = _containerMaxHeight;
        else if (_delta! < 0) {
          _delta = 0;
        }
        _oldOffset = offset;
        _offset = -_delta!;
      });

      print(' Offset $_offset');
    });
  }

  final double _containerMaxHeight = 60;
  double? _offset, _delta = 0, _oldOffset = 0;
  ProductRepository? repo1;
  dynamic data;
  PsValueHolder? valueHolder;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    repo1 = Provider.of<ProductRepository>(context);
    // data = EasyLocalizationProvider.of(context).data;
    valueHolder = Provider.of<PsValueHolder>(context);

    print(
        '............................Build UI Again ............................');
    return
        // EasyLocalizationProvider(
        //     data: data,
        //     child:
        ChangeNotifierProvider<SearchProductProvider>(
            lazy: false,
            create: (BuildContext context) {
              final SearchProductProvider provider = SearchProductProvider(
                  repo: repo1!, psValueHolder: valueHolder);
              widget.productParameterHolder.itemLocationId =
                  provider.psValueHolder!.locationId;
              final String loginUserId =
                      Utils.checkUserLoginId(valueHolder!);
              provider.loadProductListByKey(loginUserId, widget.productParameterHolder );
              _searchProductProvider = provider;
              _searchProductProvider!.productParameterHolder =
                  widget.productParameterHolder;

              return _searchProductProvider!;
            },
            child: Consumer<SearchProductProvider>(builder:
                (BuildContext context, SearchProductProvider provider,
                    Widget? child) {
              // print(provider.productList.data.isEmpty);
              // if (provider.productList.data.isNotEmpty) {
              return Column(
                children: <Widget>[
                  const PsAdMobBannerWidget(),
                  Expanded(
                    child: Container(
                      color: PsColors.coreBackgroundColor,
                      child: Stack(children: <Widget>[
                        if (provider.productList.data!.isNotEmpty &&
                            provider.productList.data != null)
                          Container(
                              color: PsColors.coreBackgroundColor,
                              margin: const EdgeInsets.only(
                                  left: PsDimens.space4,
                                  right: PsDimens.space4,
                                  top: PsDimens.space4,
                                  bottom: PsDimens.space4),
                              child: RefreshIndicator(
                                child: CustomScrollView(
                                    controller: _scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    slivers: <Widget>[
                                      SliverGrid(
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 280.0,
                                                childAspectRatio: 0.55),
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                            if (provider.productList.data !=
                                                    null ||
                                                provider.productList.data!
                                                    .isNotEmpty) {
                                              final int count = provider
                                                  .productList.data!.length;
                                              return ProductVeticalListItem(
                                                coreTagKey: provider.hashCode
                                                        .toString() +
                                                    provider.productList
                                                        .data![index].id!,
                                                animationController:
                                                    widget.animationController,
                                                animation: Tween<double>(
                                                        begin: 0.0, end: 1.0)
                                                    .animate(
                                                  CurvedAnimation(
                                                    parent: widget
                                                        .animationController,
                                                    curve: Interval(
                                                        (1 / count) * index,
                                                        1.0,
                                                        curve: Curves
                                                            .fastOutSlowIn),
                                                  ),
                                                ),
                                                product: provider
                                                    .productList.data![index],
                                                onTap: () {
                                                  final Product product =
                                                      provider.productList.data!
                                                          .reversed
                                                          .toList()[index];
                                                  final ProductDetailIntentHolder
                                                      holder =
                                                      ProductDetailIntentHolder(
                                                          productId: provider
                                                              .productList
                                                              .data![index].id,
                                                          heroTagImage: provider
                                                                  .hashCode
                                                                  .toString() +
                                                              product.id! +
                                                              PsConst
                                                                  .HERO_TAG__IMAGE,
                                                          heroTagTitle: provider
                                                                  .hashCode
                                                                  .toString() +
                                                              product.id! +
                                                              PsConst
                                                                  .HERO_TAG__TITLE);
                                                  Navigator.pushNamed(context,
                                                      RoutePaths.productDetail,
                                                      arguments: holder);
                                                },
                                              );
                                            } else {
                                              return null;
                                            }
                                          },
                                          childCount:
                                              provider.productList.data!.length,
                                        ),
                                      ),
                                    ]),
                                onRefresh: () {
                                  final String loginUserId =
                                  Utils.checkUserLoginId(valueHolder!);
                                  return provider.resetLatestProductList(
                                      loginUserId,
                                      _searchProductProvider!
                                          .productParameterHolder);
                                },
                              ))
                        else if (provider.productList.status !=
                                PsStatus.PROGRESS_LOADING &&
                            provider.productList.status !=
                                PsStatus.BLOCK_LOADING &&
                            provider.productList.status != PsStatus.NOACTION)
                          Align(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/baseline_empty_item_grey_24.png',
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    height: PsDimens.space32,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space20,
                                        right: PsDimens.space20),
                                    child: Text(
                                      Utils.getString(context,
                                          'procuct_list__no_result_data'),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: PsDimens.space20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: _offset,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: PsDimens.space12,
                                top: PsDimens.space8,
                                right: PsDimens.space12,
                                bottom: PsDimens.space16),
                            child: Container(
                                width: double.infinity,
                                height: _containerMaxHeight,
                                child: BottomNavigationImageAndText(
                                    changeAppBarTitle: widget.changeAppBarTitle!,
                                    searchProductProvider:
                                        _searchProductProvider!)),
                          ),
                        ),
                        PSProgressIndicator(provider.productList.status),
                      ]),
                    ),
                  )
                ],
              );
            }));
  }
}

class BottomNavigationImageAndText extends StatefulWidget {
  const BottomNavigationImageAndText(
      {this.searchProductProvider, this.changeAppBarTitle});
  final SearchProductProvider? searchProductProvider;
  final Function? changeAppBarTitle;

  @override
  _BottomNavigationImageAndTextState createState() =>
      _BottomNavigationImageAndTextState();
}

class _BottomNavigationImageAndTextState
    extends State<BottomNavigationImageAndText> {
  bool isClickBaseLineList = false;
  bool isClickBaseLineTune = false;
  PsValueHolder? valueHolder;

  @override
  Widget build(BuildContext context) {

    valueHolder = Provider.of<PsValueHolder>(context);

    if (widget.searchProductProvider!.productParameterHolder.isFiltered()) {
      isClickBaseLineTune = true;
    
    }

    if (widget.searchProductProvider!.productParameterHolder
        .isCatAndSubCatFiltered()) {
      isClickBaseLineList = true;
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: PsColors.mainLightShadowColor!),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: PsColors.mainShadowColor!,
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
          color: PsColors.backgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PsIconWithCheck(
                  icon: MaterialCommunityIcons.format_list_bulleted_type,
                  color: isClickBaseLineList
                      ? PsColors.mainColor!
                      : PsColors.iconColor!,
                ),
                Text(Utils.getString(context, 'search__category'),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: isClickBaseLineList
                            ? PsColors.mainColor
                            : PsColors.textPrimaryColor)),
              ],
            ),
            onTap: () async {
              final Map<String, String> dataHolder = <String, String>{};
              dataHolder[PsConst.CATEGORY_ID] =
                  widget.searchProductProvider!.productParameterHolder.catId;
              dataHolder[PsConst.SUB_CATEGORY_ID] =
                  widget.searchProductProvider!.productParameterHolder.subCatId;
              // dataHolder[PsConst.CATEGORY_NAME] = widget.searchProd
              final dynamic result = await Navigator.pushNamed(
                  context, RoutePaths.filterExpantion,
                  arguments: dataHolder);

              if (result != null && result is Map<String, String>) {
                widget.searchProductProvider!.productParameterHolder.catId =
                    result[PsConst.CATEGORY_ID]!;

                widget.searchProductProvider!.productParameterHolder.subCatId =
                    result[PsConst.SUB_CATEGORY_ID]!;
                final String loginUserId =
                      Utils.checkUserLoginId(valueHolder!);
                widget.searchProductProvider!.resetLatestProductList(
                    loginUserId,
                    widget.searchProductProvider!.productParameterHolder);

                if (result[PsConst.CATEGORY_ID] == '' &&
                    result[PsConst.SUB_CATEGORY_ID] == '') {
                  isClickBaseLineList = false;
                } else {
                  widget.changeAppBarTitle!(result[PsConst.CATEGORY_NAME]);
                  isClickBaseLineList = true;
                }
              }
            },
          ),
          InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PsIconWithCheck(
                  icon: Icons.filter_list,
                  color: isClickBaseLineTune
                      ? PsColors.mainColor!
                      : PsColors.textPrimaryColor!,
                ),
                Text(Utils.getString(context, 'search__filter'),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: isClickBaseLineTune
                            ? PsColors.mainColor
                            : PsColors.textPrimaryColor))
              ],
            ),
            onTap: () async {
              final dynamic result = await Navigator.pushNamed(
                  context, RoutePaths.itemSearch,
                  arguments:
                      widget.searchProductProvider!.productParameterHolder);
              if (result != null && result is ProductParameterHolder) {
                widget.searchProductProvider!.productParameterHolder = result;
                final String loginUserId =
                      Utils.checkUserLoginId(valueHolder!);
                widget.searchProductProvider!.resetLatestProductList(
                    loginUserId,
                    widget.searchProductProvider!.productParameterHolder);

                if (widget.searchProductProvider!.productParameterHolder
                    .isFiltered()) {
                  isClickBaseLineTune = true;
                } else {
                  isClickBaseLineTune = false;
                }
              }
            },
          ),
          InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PsIconWithCheck(
                  icon: Icons.sort,
                  color: PsColors.mainColor!,
                ),
                Text(Utils.getString(context, 'search__map'),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: isClickBaseLineTune
                            ? PsColors.mainColor
                            : PsColors.textPrimaryColor))
              ],
            ),
            onTap: () async {
              if (widget.searchProductProvider!.productParameterHolder.lat ==
                      '' &&
                  widget.searchProductProvider!.productParameterHolder.lng ==
                      '') {
                widget.searchProductProvider!.productParameterHolder.lat =
                    widget.searchProductProvider!.psValueHolder!.locationLat;
                widget.searchProductProvider!.productParameterHolder.lng =
                    widget.searchProductProvider!.psValueHolder!.locationLng;
              }
              final dynamic result = await Navigator.pushNamed(
                  context, RoutePaths.mapFilter,
                  arguments:
                      widget.searchProductProvider!.productParameterHolder);
              if (result != null && result is ProductParameterHolder) {
                widget.searchProductProvider!.productParameterHolder = result;
                if (widget.searchProductProvider!.productParameterHolder.mile !=
                        null &&
                    widget.searchProductProvider!.productParameterHolder.mile !=
                        '' &&
                    double.parse(widget.searchProductProvider!
                            .productParameterHolder.mile) <
                        1) {
                  widget.searchProductProvider!.productParameterHolder.mile =
                      '1';
                } 
                final String loginUserId =
                      Utils.checkUserLoginId(valueHolder!);
                //for 0.5 km, it is less than 1 miles and error
                widget.searchProductProvider!.resetLatestProductList(
                    loginUserId,
                    widget.searchProductProvider!.productParameterHolder);
              }
            },
          ),
        ],
      ),
    );
  }
}

class PsIconWithCheck extends StatelessWidget {
  const PsIconWithCheck({Key? key, this.icon, this.color}) : super(key: key);
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color ?? PsColors.grey);
  }
}

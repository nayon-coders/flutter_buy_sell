import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/provider/common/ps_provider.dart';
import 'package:flutterbuyandsell/repository/product_repository.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_value_holder.dart';
import 'package:flutterbuyandsell/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterbuyandsell/viewobject/product.dart';

class DisabledProductProvider extends PsProvider {
  DisabledProductProvider(
      {required ProductRepository repo, this.psValueHolder, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('DisabledProductProvider : $hashCode');
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    itemListStream = StreamController<PsResource<List<Product>>>.broadcast();
    subscription =
        itemListStream!.stream.listen((PsResource<List<Product>> resource) {
      updateOffset(resource.data!.length);

      _itemList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  ProductRepository? _repo;
  PsValueHolder? psValueHolder;
  ProductParameterHolder addedUserParameterHolder =
      ProductParameterHolder().getDisabledProductParameterHolder();
  PsResource<List<Product>> _itemList =
      PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);

  PsResource<List<Product>> get itemList => _itemList;
  StreamSubscription<PsResource<List<Product>>>? subscription;
  StreamController<PsResource<List<Product>>>? itemListStream;
  @override
  void dispose() {
    subscription!.cancel();
    isDispose = true;
    print('Added Product Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadProductList(
      String loginUserId, ProductParameterHolder holder) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo!.getItemListByUserId(
        itemListStream!,
        loginUserId,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder);
  }

  Future<dynamic> nextProductList(
      String loginUserId, ProductParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo!.getNextPageItemListByUserId(
          itemListStream!,
          loginUserId,
          isConnectedToInternet,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          holder);
    }
  }

  Future<void> resetProductList(
      String loginUserId, ProductParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo!.getItemListByUserId(
        itemListStream!,
        loginUserId,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder);

    isLoading = false;
  }

}

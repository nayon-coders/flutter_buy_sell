import 'dart:async';
import 'package:flutterbuyandsell/repository/item_paid_history_repository.dart';
import 'package:flutterbuyandsell/utils/utils.dart';

import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/provider/common/ps_provider.dart';
import 'package:flutterbuyandsell/viewobject/item_paid_history.dart';

class ItemPromotionProvider extends PsProvider {
  ItemPromotionProvider({required ItemPaidHistoryRepository itemPaidHistoryRepository,int limit = 0}) : super(itemPaidHistoryRepository, limit) {

    String selectedDate;
    DateTime selectedDateTime;
    StreamSubscription<PsResource<ItemPaidHistory>>? subscription;
    StreamController<PsResource<ItemPaidHistory>> itemPaidHistoryStream;
    ItemPaidHistoryRepository _repo;

    _repo = itemPaidHistoryRepository;
    isDispose = false;
    print('Item Paid History Provider: $hashCode');

    itemPaidHistoryStream =
        StreamController<PsResource<ItemPaidHistory>>.broadcast();
    subscription = itemPaidHistoryStream.stream
        .listen((PsResource<ItemPaidHistory> resource) {
      if (resource != null && resource.data != null) {
        _itemPaidHistoryEntry = resource;
      }

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }


  PsResource<ItemPaidHistory> _itemPaidHistoryEntry =
      PsResource<ItemPaidHistory>(PsStatus.NOACTION, '', null);
  PsResource<ItemPaidHistory> get item => _itemPaidHistoryEntry;


  @override
  void dispose() {
    isDispose = true;
    print('Item Paid History Provider Dispose: $hashCode');
    super.dispose();
  }
  ItemPaidHistoryRepository? repo;
  Future<dynamic> postItemHistoryEntry(
    Map<dynamic, dynamic> jsonMap,
  ) async {

    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _itemPaidHistoryEntry = await repo!.postItemPaidHistory(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _itemPaidHistoryEntry;
  }
}

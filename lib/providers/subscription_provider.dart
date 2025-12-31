import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final subscriptionServiceProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionState {
  final bool isSubscribed;
  final bool isLoading;

  SubscriptionState({this.isSubscribed = false, this.isLoading = false});

  SubscriptionState copyWith({bool? isSubscribed, bool? isLoading}) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static const String subscriptionProductId = 'ad_free_monthly';
  static const String subscriptionKey = 'is_subscribed';

  SubscriptionNotifier() : super(SubscriptionState()) {
    _loadSubscriptionStatus();
    _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSubscribed = prefs.getBool(subscriptionKey) ?? false;
    state = state.copyWith(isSubscribed: isSubscribed);
  }

  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.productID == subscriptionProductId) {
        if (purchase.status == PurchaseStatus.purchased) {
          await _setSubscriptionStatus(true);
        } else if (purchase.status == PurchaseStatus.error) {
          // Handle error
        }
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _setSubscriptionStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(subscriptionKey, status);
    state = state.copyWith(isSubscribed: status);
  }

  Future<void> purchaseSubscription() async {
    state = state.copyWith(isLoading: true);

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(
        {subscriptionProductId},
      );

      if (response.error != null || response.productDetails.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Handle error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      // Handle error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

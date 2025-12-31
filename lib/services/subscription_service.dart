import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static const String subscriptionProductId = 'ad_free_monthly';
  static const String subscriptionKey = 'is_subscribed';

  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionService() {
    _loadSubscriptionStatus();
    _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = prefs.getBool(subscriptionKey) ?? false;
    notifyListeners();
  }

  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.productID == subscriptionProductId) {
        if (purchase.status == PurchaseStatus.purchased) {
          await _setSubscriptionStatus(true);
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchase.error}');
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
    _isSubscribed = status;
    notifyListeners();
  }

  Future<void> purchaseSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('In-app purchase not available');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(
        {subscriptionProductId},
      );

      if (response.error != null) {
        debugPrint('Error querying products: ${response.error}');
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('No products found');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

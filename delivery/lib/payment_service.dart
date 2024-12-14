import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutter/material.dart';

class PaymentService {
  Future<String?> startBraintreePayment(
      BuildContext context, double totalPrice) async {
    var request = BraintreeDropInRequest(
      tokenizationKey: 'sandbox_2438xwxw_rq8zs4nkvb48x775',
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: totalPrice.toStringAsFixed(2),
        currencyCode: 'EUR',
        billingAddressRequired: false,
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: totalPrice.toStringAsFixed(2),
        displayName: 'APP',
      ),
      cardEnabled: true,
    );

    BraintreeDropInResult? result = await BraintreeDropIn.start(request);
    if (result != null) {
      print('Payment method result: ${result.paymentMethodNonce.nonce}');
      // Return nonce to be used for processing
      return result.paymentMethodNonce.nonce;
    } else {
      print('Payment cancelled');
      return null;
    }
  }
}

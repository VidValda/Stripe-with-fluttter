import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stripe_google_apple_pay/models/payment_intent_response.dart';
import 'package:stripe_google_apple_pay/models/stripe_custom_response.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService {
  StripeService._private();
  static final StripeService _instance = StripeService._private();
  factory StripeService() => _instance;

  String _paymentApiUrl = "https://api.stripe.com/v1/payment_intents";
  static String _secretKey =
      "sk_test_51IGxnXFoF4AZGiBeEXPX6BRtw2zOi6W7ByBD4UuHoBHZ2clIaVD8MLT7cjWoIaDHrpYsa3dmOEMUVDYRF6pOPliz00wKTwNEdG";
  String _apiKey =
      "pk_test_51IGxnXFoF4AZGiBelJ8DnPbAwp32f1YZ0WqyYgJL5fIkdvKQhI5W4nm3iyVxBxEQDAWA5y14uKlf492IrlYHSEO70042gMf4jA";

  final headerOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      "Authorization": "Bearer ${StripeService._secretKey}",
    },
  );

  void init() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: _apiKey,
        androidPayMode: "test",
        merchantId: "test",
      ),
    );
  }

  Future<StripeCustomResponse> payWithExistingCard({
    @required String amount,
    @required String currency,
    @required CreditCard card,
  }) async {
    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(card: card),
      );
      return await this
          ._realizarPago(amount: amount, currency: currency, paymentMethod: paymentMethod);
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payWithNewCard({
    @required String amount,
    @required String currency,
  }) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );
      return await this
          ._realizarPago(amount: amount, currency: currency, paymentMethod: paymentMethod);
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payWithAppleGooglePay({
    @required String amount,
    @required String currency,
  }) async {
    try {
      final token = await StripePayment.paymentRequestWithNativePay(
        androidPayOptions: AndroidPayPaymentRequest(
          currencyCode: currency,
          totalPrice: amount,
        ),
        applePayOptions: ApplePayPaymentOptions(
          countryCode: "US",
          currencyCode: currency,
          items: [
            ApplePayItem(
              label: "producto 1",
              amount: (double.parse(amount) / 100).toString(),
            )
          ],
        ),
      );
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          token: token,
          card: CreditCard(token: token.tokenId),
        ),
      );
      final resp = await this._realizarPago(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
      );
      StripePayment.completeNativePayRequest();
      return resp;
    } catch (e) {
      print("Error en el intento: ${e.toString()}");
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future<PaymentIntentReponse> _createPaymentIntent({
    @required String amount,
    @required String currency,
  }) async {
    try {
      final dio = Dio();
      final data = {
        "amount": amount,
        "currency": currency,
      };
      final resp = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions,
      );
      return PaymentIntentReponse.fromJson(resp.data);
    } catch (e) {
      print("Error en el intento: ${e.toString()}");
      return PaymentIntentReponse(status: "400");
    }
  }

  Future<StripeCustomResponse> _realizarPago({
    @required String amount,
    @required String currency,
    @required PaymentMethod paymentMethod,
  }) async {
    try {
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );
      final paymentResult = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent.clientSecret,
          paymentMethodId: paymentMethod.id,
        ),
      );
      if (paymentResult.status == "succeeded") {
        return StripeCustomResponse(ok: true);
      } else {
        return StripeCustomResponse(ok: false, msg: "Fail: ${paymentResult.status}");
      }
    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }
}

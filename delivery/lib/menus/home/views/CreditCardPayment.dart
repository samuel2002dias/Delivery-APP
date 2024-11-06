// ignore_for_file: unnecessary_import

import 'package:delivery/menus/home/bloc/Firebase_BuyNow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreditCardPayment extends StatefulWidget {
  final double totalAmount;
  final List<String> productIds;
  final List<Map<String, dynamic>> productDataList;
  final List<int> productQuantities;
  final TextEditingController numberController;
  final TextEditingController observationsController;
  final TextEditingController addressController;
  final LatLng selectedLocation;
  final dynamic Function(String) showDialog;
  final double totalPrice;

  const CreditCardPayment({
    Key? key,
    required this.totalAmount,
    required this.productIds,
    required this.productDataList,
    required this.productQuantities,
    required this.numberController,
    required this.observationsController,
    required this.addressController,
    required this.selectedLocation,
    required this.showDialog,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _CreditCardPaymentState createState() => _CreditCardPaymentState();
}

class _CreditCardPaymentState extends State<CreditCardPayment> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void _simulatePayment() {
    if (formKey.currentState!.validate()) {
      Future.delayed(const Duration(seconds: 4), () {
        sendLocationToFirebase(
          context: context,
          productIds: widget.productIds,
          productDataList: widget.productDataList,
          productQuantities: widget.productQuantities,
          numberController: widget.numberController,
          observationsController: widget.observationsController,
          addressController: widget.addressController,
          selectedLocation: widget.selectedLocation,
          showDialog: widget.showDialog,
          paymentMethod: 'Credit Card',
          price: widget.totalPrice,
        );

        // Show a SnackBar instead of an AlertDialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Stripe has proceeded with the payment successfully'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                // Dismiss the SnackBar
              },
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceed the payment'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {
                // Handle credit card brand change if needed
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text(
                      'You are paying \$${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CreditCardForm(
                      formKey: formKey,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      onCreditCardModelChange: _onCreditCardModelChange,
                      themeColor: Colors.blue,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumberDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Holder',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: _simulatePayment,
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor:
                              const Color.fromRGBO(252, 185, 19, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

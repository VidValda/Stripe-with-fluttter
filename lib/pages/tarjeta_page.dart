import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_google_apple_pay/bloc/pay/pay_bloc.dart';
import 'package:stripe_google_apple_pay/widgets/total_pay_button.dart';

class TarjetaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final payBloc = BlocProvider.of<PayBloc>(context);
    final tarjeta = payBloc.state.tarjeta;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text("Pagar"),
      ),
      body: Stack(
        children: [
          Container(),
          Hero(
            tag: tarjeta.cardNumberHidden,
            child: CreditCardWidget(
              cardNumber: tarjeta.cardNumber,
              expiryDate: tarjeta.expiracyDate,
              cardHolderName: tarjeta.cardHolderName,
              cvvCode: tarjeta.cvv,
              showBackView: false,
            ),
          ),
          Positioned(
            child: TotalPayButton(),
            bottom: 0,
          ),
        ],
      ),
    );
  }
}

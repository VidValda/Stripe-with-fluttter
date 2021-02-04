import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_google_apple_pay/bloc/pay/pay_bloc.dart';
import 'package:stripe_google_apple_pay/helpers/helpers.dart';
import 'package:stripe_google_apple_pay/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

class TotalPayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final payBloc = BlocProvider.of<PayBloc>(context).state;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("${payBloc.monto} ${payBloc.moneda}", style: TextStyle(fontSize: 20)),
            ],
          ),
          BlocBuilder<PayBloc, PayState>(
            builder: (context, state) {
              return _BtnPay(state);
            },
          ),
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  final PayState state;
  _BtnPay(this.state);

  @override
  Widget build(BuildContext context) {
    return state.tarjetaActiva ? buildBotonTarjeta(context) : buildAppleAndGooglePay(context);
  }

  Widget buildBotonTarjeta(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 170,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      textColor: Colors.white,
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.solidCreditCard,
            color: Colors.white,
          ),
          SizedBox(width: 15),
          Text("Pay", style: TextStyle(fontSize: 22)),
        ],
      ),
      onPressed: () async {
        final tarjeta = state.tarjeta;
        final mesAnExp = tarjeta.expiracyDate.split("/");
        mostrarLoading(context);
        final response = await StripeService().payWithExistingCard(
          amount: state.montoPagarString,
          currency: state.moneda,
          card: CreditCard(
            number: tarjeta.cardNumber,
            expMonth: int.parse(mesAnExp[0]),
            expYear: int.parse(mesAnExp[1]),
          ),
        );

        Navigator.pop(context);
        if (response.ok) {
          mostrarAlerta(context, "Tarjeta OK", "Todo correcto");
        } else {
          mostrarAlerta(context, "Algo fue mal", response.msg);
        }
      },
    );
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 150,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      textColor: Colors.white,
      child: Row(
        children: [
          FaIcon(
            Platform.isAndroid ? FontAwesomeIcons.google : FontAwesomeIcons.apple,
            color: Colors.white,
          ),
          SizedBox(width: 15),
          Text("Pay", style: TextStyle(fontSize: 22)),
        ],
      ),
      onPressed: () async {
        final response = await StripeService().payWithAppleGooglePay(
          amount: state.montoPagarString,
          currency: state.moneda,
        );
      },
    );
  }
}

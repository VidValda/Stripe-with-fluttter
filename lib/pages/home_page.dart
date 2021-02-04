import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:stripe_google_apple_pay/bloc/pay/pay_bloc.dart';
import 'package:stripe_google_apple_pay/data/tarjetas.dart';
import 'package:stripe_google_apple_pay/helpers/helpers.dart';
import 'package:stripe_google_apple_pay/pages/tarjeta_page.dart';
import 'package:stripe_google_apple_pay/services/stripe_service.dart';
import 'package:stripe_google_apple_pay/widgets/total_pay_button.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stripeService = StripeService();
    final payBloc = BlocProvider.of<PayBloc>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pagar"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              mostrarLoading(context);
              final response = await stripeService.payWithNewCard(
                amount: payBloc.state.montoPagarString,
                currency: payBloc.state.moneda,
              );
              Navigator.pop(context);
              if (response.ok) {
                mostrarAlerta(context, "Tarjeta OK", "Todo correcto");
              } else {
                mostrarAlerta(context, "Algo fue mal", response.msg);
              }
              // mostrarLoading(context);
              // await Future.delayed(Duration(seconds: 1));
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            height: size.height,
            width: size.width,
            top: 150,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.85,
              ),
              physics: BouncingScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: (context, i) {
                final tarjeta = tarjetas[i];
                return GestureDetector(
                  onTap: () {
                    BlocProvider.of<PayBloc>(context).add(OnSeleccionarTarjeta(tarjeta));
                    Navigator.push(
                      context,
                      navegarFadeIn(context, TarjetaPage()),
                    ).then(
                      (value) {
                        BlocProvider.of<PayBloc>(context).add(OnDesactivarTarjeta());
                      },
                    );
                  },
                  child: Hero(
                    tag: tarjeta.cardNumberHidden,
                    child: CreditCardWidget(
                      cardNumber: tarjeta.cardNumber,
                      expiryDate: tarjeta.expiracyDate,
                      cardHolderName: tarjeta.cardHolderName,
                      cvvCode: tarjeta.cvv,
                      showBackView: false,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: TotalPayButton(),
          ),
        ],
      ),
    );
  }
}

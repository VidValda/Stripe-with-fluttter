import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_google_apple_pay/bloc/pay/pay_bloc.dart';
import 'package:stripe_google_apple_pay/pages/home_page.dart';
import 'package:stripe_google_apple_pay/pages/pago_completo_page.dart';
import 'package:stripe_google_apple_pay/pages/tarjeta_page.dart';
import 'package:stripe_google_apple_pay/services/stripe_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StripeService().init();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PayBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stripe App',
        initialRoute: "home",
        routes: {
          "home": (_) => HomePage(),
          "pago_completo": (_) => PagoPage(),
        },
        theme: ThemeData.light().copyWith(
          primaryColor: Color(0xFF284879),
          scaffoldBackgroundColor: Color(0xFF21232A),
        ),
      ),
    );
  }
}

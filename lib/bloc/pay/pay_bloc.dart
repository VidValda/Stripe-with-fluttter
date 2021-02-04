import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stripe_google_apple_pay/models/tarjeta_credito.dart';

part 'pay_event.dart';
part 'pay_state.dart';

class PayBloc extends Bloc<PayEvent, PayState> {
  PayBloc() : super(PayState());

  @override
  Stream<PayState> mapEventToState(PayEvent event) async* {
    if (event is OnSeleccionarTarjeta) {
      yield state.copyWith(tarjeta: event.tarjeta, tarjetaActiva: true);
    } else if (event is OnDesactivarTarjeta) {
      yield state.copyWith(tarjetaActiva: false);
    }
  }
}

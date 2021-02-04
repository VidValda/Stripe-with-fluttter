part of 'pay_bloc.dart';

@immutable
abstract class PayEvent {}

class OnSeleccionarTarjeta extends PayEvent {
  final TarjetaCredito tarjeta;

  OnSeleccionarTarjeta(this.tarjeta);
}

class OnDesactivarTarjeta extends PayEvent {}

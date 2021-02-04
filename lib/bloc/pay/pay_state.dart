part of 'pay_bloc.dart';

@immutable
class PayState {
  final double monto;
  final String moneda;
  final bool tarjetaActiva;
  final TarjetaCredito tarjeta;

  String get montoPagarString => "${(monto * 100).floor()}";

  PayState({
    this.monto = 375.55,
    this.moneda = "USD",
    this.tarjetaActiva = false,
    this.tarjeta,
  });

  PayState copyWith({
    double monto,
    String moneda,
    bool tarjetaActiva,
    TarjetaCredito tarjeta,
  }) =>
      PayState(
        monto: monto ?? this.monto,
        moneda: moneda ?? this.moneda,
        tarjetaActiva: tarjetaActiva ?? this.tarjetaActiva,
        tarjeta: tarjeta ?? this.tarjeta,
      );
}

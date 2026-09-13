import 'package:flutter_test/flutter_test.dart';

/// Schema.md 14.1 "Ledger dan agregasi" (Akun/Transaksi, M4):
///
///   saldo(A) = saldo_awal + income(A) - expense(A) - outbound_transfer(A)
///            + inbound_transfer(A) + adjustment_increase(A) - adjustment_decrease(A)
///
/// plus `total_balance` (sum of non-archived Akun), category chart
/// (expense-only, zero-value categories dropped, sorted amount desc then
/// category id), and trend (income+expense per month, transfer/adjustment
/// excluded) — all keyed off Transaksi's Local `tanggal`, not `created_at`.
///
/// No worked numeric example exists yet in schema.md/API-SPEC.md to lock in
/// as a golden fixture; add one here (matching whatever M4's design lands
/// with) instead of inventing untraceable numbers now. Kept as a named,
/// skipped placeholder so this contract obligation isn't forgotten before
/// Akun/CategoryKeuangan/Transaksi exist.
void main() {
  test('ledger saldo/aggregation formulas match schema 14.1', () {},
      skip: 'M4: Akun/CategoryKeuangan/Transaksi do not exist yet');
}

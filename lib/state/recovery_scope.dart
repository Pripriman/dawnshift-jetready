import 'package:flutter/widgets.dart';
import '../domain/recovery_vault.dart';

class RecoveryScope extends InheritedNotifier<RecoveryVault> {
  const RecoveryScope({
    super.key,
    required RecoveryVault vault,
    required super.child,
  }) : super(notifier: vault);

  static RecoveryVault of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecoveryScope>();
    assert(scope != null, 'RecoveryScope not found in context');
    return scope!.notifier!;
  }

  static RecoveryVault read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<RecoveryScope>()
        ?.widget as RecoveryScope?;
    return scope!.notifier!;
  }
}

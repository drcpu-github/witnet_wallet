import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildSigningTxModal(ThemeData theme, BuildContext context) {
  return buildAlertDialog(
      context: context,
      actions: [],
      title: 'Signing transaction',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: 'signing-transaction', height: 100),
        SizedBox(height: 16),
        Text('The transaction is being signed',
            style: theme.textTheme.bodyLarge)
      ]));
}

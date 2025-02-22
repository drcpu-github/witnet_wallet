import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/widgets/ordered_list_item.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';

typedef void VoidCallback(NavAction? value);

class ReEstablishWalletDisclaimer extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;

  ReEstablishWalletDisclaimer({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ReEstablishWalletDisclaimerState();
}

class ReEstablishWalletDisclaimerState
    extends State<ReEstablishWalletDisclaimer> with TickerProviderStateMixin {
  List<AnimationController> _providerControllerList = <AnimationController>[];
  bool isNextAllow = false;
  bool isCheckBoxFocus = false;
  FocusNode _checkBoxFocusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    _checkBoxFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    _checkBoxFocusNode.removeListener(_handleFocus);
    super.dispose();
    _providerControllerList.forEach((controller) {
      controller.dispose();
    });
  }

  _handleFocus() {
    setState(() {
      this.isCheckBoxFocus = _checkBoxFocusNode.hasFocus;
    });
  }

  void prevAction() {
    Navigator.pushNamed(context, '/');
  }

  void nextAction() async {
    showDeleteStorageAlert();
  }

  void closeModal() {
    Navigator.pop(context);
    toggleCheckBox(false);
  }

  void continueToNextStep() {
    Navigator.pop(context);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.unset));
  }

  void deleteStorageAndContinue() async {
    final theme = Theme.of(context);
    ApiDatabase db = Locator.instance.get<ApiDatabase>();
    final storageDeleted = await db.deleteAllWallets();
    if (storageDeleted) {
      final isdbOpen = await db.openDatabase();
      if (isdbOpen) {
        // Close current modal
        Navigator.pop(context);
        // Show next modal
        showStorageDeletedMessage();
      } else {
        closeModal();
        showErrorSnackBar(context, theme,
            'There was an error re-establishing myWitWallet, please try again!');
      }
    } else {
      closeModal();
      showErrorSnackBar(context, theme,
          'There was an error re-establishing myWitWallet, please try again!');
    }
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  void showDeleteStorageAlert() {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return buildAlertDialog(
        color: extendedTheme.errorColor,
        context: context,
        actions: [
          PaddedButton(
              color: theme.textTheme.bodyLarge!.color,
              padding: EdgeInsets.all(8),
              text: 'Cancel',
              type: ButtonType.text,
              enabled: true,
              onPressed: () => {setState(() => closeModal())}),
          PaddedButton(
              color: extendedTheme.errorColor,
              padding: EdgeInsets.all(8),
              text: 'Re-establish',
              type: ButtonType.text,
              enabled: true,
              onPressed: deleteStorageAndContinue)
        ],
        icon: FontAwesomeIcons.circleExclamation,
        title: 'Your storage is about to be permanently deleted!',
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          svgThemeImage(theme, name: 'general-warning', height: 100),
        ]));
  }

  void showStorageDeletedMessage() {
    final theme = Theme.of(context);
    return buildAlertDialog(
        context: context,
        actions: [
          PaddedButton(
              padding: EdgeInsets.all(8),
              text: 'Continue',
              type: ButtonType.text,
              enabled: true,
              onPressed: continueToNextStep)
        ],
        title: 'myWitWallet has been successfully re-established!',
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          svgThemeImage(theme, name: 'transaction-success', height: 100),
        ]));
  }

  void toggleCheckBox(bool? value) {
    setState(() {
      isNextAllow = value ?? false;
    });
    if (isNextAllow) {
      widget.nextAction(next);
    } else {
      widget.nextAction(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('Re-establish your wallet', style: theme.textTheme.titleLarge!),
        SizedBox(
          height: 16,
        ),
        Text(
          'Please, read carefully before continuing. Your attention is crucial! ',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
            'Clicking \"Continue\" will result in the permanent deletion of your current wallet data. If you proceed, you\'ll need to import an existing wallet or create a new one to access your funds.',
            style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text('What to do?',
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )),
        SizedBox(
          height: 10,
        ),
        buildOrderedListItem(
            '1. ',
            'Make sure you have stored your recovery seed phrase or Xprv.',
            context),
        SizedBox(
          height: 10,
        ),
        buildOrderedListItem(
            '2. ',
            'Click \"Continue\" to delete your storage and import your wallet again.',
            context),
        LabeledCheckbox(
            focusNode: _checkBoxFocusNode,
            isFocus: isCheckBoxFocus,
            checked: isNextAllow,
            label: 'I will be careful, I promise!',
            onChanged: toggleCheckBox),
      ],
    );
  }
}

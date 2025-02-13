import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/fcm_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/notification_setting.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_show_qr.dart';
import 'package:nautilus_wallet_flutter/ui/receive/split_bill_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/request/request_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';
import 'package:quiver/strings.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:ndef/ndef.dart' as ndef;
// import 'package:flutter_nearby_messages_api/flutter_nearby_messages_api.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({this.min, this.max});

  final double? min;
  final double? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min!) {
      return TextEditingValue.empty.copyWith(text: min!.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max! ? oldValue : newValue;
    }
  }
}

class ReceiveSheet extends StatefulWidget {
  const ReceiveSheet({required this.localCurrency, this.address, this.qrWidget}) : super();
  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;

  @override
  // ignore: library_private_types_in_public_api
  _ReceiveSheetState createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<ReceiveSheet> {
  GlobalKey? shareCardKey;
  ByteData? shareImageData;
  // Address copied items
  // Current state references
  bool _showShareCard = false;
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  String? _rawAmount;

  // states:
  FocusNode? _addressFocusNode;
  FocusNode? _amountFocusNode;
  FocusNode? _memoFocusNode;
  TextEditingController? _addressController;
  TextEditingController? _amountController;
  TextEditingController? _memoController;

  // States
  AddressStyle? _addressStyle;
  String? _amountHint;
  String? _addressHint;
  String? _memoHint;
  String _amountValidationText = "";
  String _addressValidationText = "";
  String _memoValidationText = "";
  String? quickSendAmount;
  late List<User> _users;
  bool? animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  bool _isFavorite = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _clearButton = false;
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  late NumberFormat _localCurrencyFormat;

  final int _REQUIRED_CONFIRMATION_HEIGHT = 10;

  Widget? qrWidget;

  Future<Uint8List?> _capturePng() async {
    if (shareCardKey != null && shareCardKey!.currentContext != null) {
      final RenderRepaintBoundary boundary = shareCardKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      final ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;

    _amountFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _memoFocusNode = FocusNode();
    _amountController = TextEditingController();
    _addressController = TextEditingController();
    _memoController = TextEditingController();
    _addressStyle = AddressStyle.TEXT60;
    _users = [];

    // _amountHint = AppLocalization.of(context).enterAmount;
    // _addressHint = AppLocalization.of(context).enterUserOrAddress;
    // _memoHint = AppLocalization.of(context).enterMemo;

    // On amount focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _amountController!.text = getRawAsThemeAwareAmount(context, _rawAmount);
            _rawAmount = null;
          });
        }
        setState(() {
          _amountHint = "";
        });
      } else {
        setState(() {
          _amountHint = AppLocalization.of(context).enterAmount;
        });
      }
    });
    // On address focus change
    _addressFocusNode!.addListener(() async {
      if (_addressFocusNode!.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidationText = "";
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          if (_addressController!.text.isNotEmpty) {
            _clearButton = true;
          } else {
            _clearButton = false;
          }
          _addressStyle = AddressStyle.TEXT60;
        });
        _addressController!.selection = TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        if (_addressController!.text.isNotEmpty && _addressController!.text.length > 1 && !_addressController!.text.startsWith("nano_")) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
          if (_addressController!.text != formattedAddress) {
            setState(() {
              _addressController!.text = formattedAddress;
            });
          }
          final List<User> userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
          setState(() {
            _users = userList;
          });
        }

        if (_addressController!.text.isEmpty) {
          setState(() {
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = AppLocalization.of(context).enterUserOrAddress;
          _users = <User>[];
          if (Address(_addressController!.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController!.text.isEmpty) {
            _pasteButtonVisible = true;
            _clearButton = false;
          }
        });

        if (SendSheetHelpers.stripPrefixes(_addressController!.text).isEmpty) {
          setState(() {
            _addressController!.text = "";
          });
          return;
        }
        if (_addressController!.text.isNotEmpty) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
          // check if in the username db:
          String? address;
          String? type;
          final User? user = await sl.get<DBHelper>().getUserOrContactWithName(formattedAddress);
          if (user != null) {
            type = user.type;
            if (_addressController!.text != user.getDisplayName()) {
              setState(() {
                _addressController!.text = user.getDisplayName()!;
              });
            }
          } else {
            // check if UD / ENS / opencap address
            if (_addressController!.text.contains(r"$")) {
              // check if opencap address:
              address = await sl.get<AccountService>().checkOpencapDomain(formattedAddress);
              if (address != null) {
                type = UserTypes.OPENCAP;
              }
            } else if (_addressController!.text.contains(".")) {
              // check if UD domain:
              address = await sl.get<AccountService>().checkUnstoppableDomain(formattedAddress);
              if (address != null) {
                type = UserTypes.UD;
              } else {
                // check if ENS domain:
                address = await sl.get<AccountService>().checkENSDomain(formattedAddress);
                if (address != null) {
                  type = UserTypes.ENS;
                }
              }
            }
          }

          if (type != null) {
            setState(() {
              _pasteButtonVisible = false;
              _addressStyle = AddressStyle.PRIMARY;
            });

            if (address != null && user == null) {
              // add to the db if missing:
              final User user = User(username: formattedAddress, address: address, type: type, is_blocked: false);
              await sl.get<DBHelper>().addUser(user);
            }
          } else {
            setState(() {
              _addressStyle = AddressStyle.TEXT60;
            });
          }
        }
      }
    });
    // On memo focus change
    _memoFocusNode!.addListener(() {
      if (_memoFocusNode!.hasFocus) {
        setState(() {
          _memoHint = "";
          _memoValidationText = "";
        });
      } else {
        setState(() {
          _memoHint = AppLocalization.of(context).enterMemo;
        });
      }
    });

    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());

    qrWidget = widget.qrWidget;
  }

  @override
  Widget build(BuildContext context) {
    // The main column that holds everything
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the header of the sheet, balance text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),

                // Container for the header, address and balance text
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            CaseChange.toUpperCase(AppLocalization.of(context).requestFrom, context),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.only(top: 25, right: 20),
                  child: AppDialogs.infoButton(
                    context,
                    () {
                      AppDialogs.showInfoDialog(context, AppLocalization.of(context).requestSheetInfoHeader, AppLocalization.of(context).requestSheetInfo);
                    },
                  ),
                ),
              ],
            ),

            // account / wallet name:
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: StateContainer.of(context).selectedAccount!.name,
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.text60,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("|", textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: StateContainer.of(context).wallet?.username ?? Address(StateContainer.of(context).wallet!.address).getShortFirstPart(),
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.text60,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Balance Text
            FutureBuilder(
              future: sl.get<SharedPrefsUtil>().getPriceConversion(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null && snapshot.data != PriceConversion.HIDDEN) {
                  return RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: "(",
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                        if (!_localCurrencyMode)
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, StateContainer.of(context).wallet!.accountBalance.toString()),
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.primary60,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: "NunitoSans",
                            ),
                          ),
                        if (!_localCurrencyMode)
                          displayCurrencySymbol(
                            context,
                            TextStyle(
                              color: StateContainer.of(context).curTheme.primary60,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: "NunitoSans",
                            ),
                          ),
                        TextSpan(
                          text: _localCurrencyMode
                              ? StateContainer.of(context)
                                  .wallet!
                                  .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale)
                              : getRawAsThemeAwareFormattedAmount(context, StateContainer.of(context).wallet!.accountBalance.toString()),
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                        TextSpan(
                          text: ")",
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Text(
                  "*******",
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w100,
                    fontFamily: "NunitoSans",
                  ),
                );
              },
            ),
            // A main container that holds everything
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                child: GestureDetector(
                  onTap: () {
                    // Clear focus of our fields when tapped in this empty space
                    _addressFocusNode!.unfocus();
                    _amountFocusNode!.unfocus();
                    _memoFocusNode!.unfocus();
                  },
                  child: KeyboardAvoider(
                    duration: Duration.zero,
                    autoScroll: true,
                    focusPadding: 40,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            // Enter Amount container + Enter Amount Error container
                            Column(
                              children: <Widget>[
                                // ******* Enter Amount Container ******* //
                                getEnterAmountContainer(),
                                // ******* Enter Amount Container End ******* //

                                // ******* Enter Amount Error Container ******* //
                                Container(
                                  alignment: const AlignmentDirectional(0, 0),
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_amountValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Amount Error Container End ******* //
                              ],
                            ),

                            // Column for Enter Address container + Enter Address Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                                        alignment: Alignment.bottomCenter,
                                        constraints: const BoxConstraints(maxHeight: 160, minHeight: 0),
                                        // ********************************************* //
                                        // ********* The pop-up Contacts List ********* //
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(25),
                                              color: StateContainer.of(context).curTheme.backgroundDarkest,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              margin: const EdgeInsets.only(bottom: 50),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                // padding: const EdgeInsets.only(bottom: 0, top: 0),
                                                itemCount: _users.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return _buildUserItem(_users[index]);
                                                },
                                              ), // ********* The pop-up Contacts List End ********* //
                                              // ************************************************** //
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ******* Enter Address Container ******* //
                                      getEnterAddressContainer(),
                                      // ******* Enter Address Container End ******* //
                                    ],
                                  ),
                                ),

                                // ******* Enter Address Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_addressValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Address Error Container End ******* //
                              ],
                            ),

                            // Column for Enter Memo container + Enter Memo Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                                        alignment: Alignment.bottomCenter,
                                        constraints: const BoxConstraints(maxHeight: 174, minHeight: 0),
                                      ),

                                      // ******* Enter Memo Container ******* //
                                      getEnterMemoContainer(),
                                      // ******* Enter Memo Container End ******* //
                                    ],
                                  ),
                                ),

                                // ******* Enter Memo Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_memoValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Memo Error Container End ******* //
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // A column for Enter Amount, Enter Address, Error containers and the pop up list
              ),
            ),

            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     AppButton.buildAppButton(
                //       context,
                //       // Share Address Button
                //       AppButtonType.PRIMARY_OUTLINE,
                //       AppLocalization.of(context).shareViaNFC,
                //       Dimens.BUTTON_BOTTOM_DIMENS,
                //       onPressed: () async {
                //         // final availability = await FlutterNfcKit.nfcAvailability;
                //         // print("ok");
                //         // if (availability != NFCAvailability.available) {
                //         //   // oh-no
                //         //   print("NFC is not available");
                //         // }

                //         // // timeout only works on Android, while the latter two messages are only for iOS
                //         // var tag = await FlutterNfcKit.poll(
                //         //     timeout: Duration(seconds: 10), iosMultipleTagMessage: "Multiple tags found!", iosAlertMessage: "Scan your tag");
                //         // print(jsonEncode(tag));
                //         // // if (tag.type == NFCTagType.iso7816) {
                //         // //   var result = await FlutterNfcKit.transceive("00B0950000",
                //         // //       timeout: Duration(seconds: 5)); // timeout is still Android-only, persist until next change
                //         // //   print(result);
                //         // // }
                //         // // // read NDEF records if available
                //         // if (tag.ndefAvailable!) {
                //         //   /// decoded NDEF records (see [ndef.NDEFRecord] for details)
                //         //   /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
                //         //   for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
                //         //     print(record.toString());
                //         //   }

                //         // //   /// raw NDEF records (data in hex string)
                //         // //   /// `{identifier: "", payload: "00010203", type: "0001", typeNameFormat: "nfcWellKnown"}`
                //         // //   for (var record in await FlutterNfcKit.readNDEFRawRecords(cached: false)) {
                //         // //     print(jsonEncode(record).toString());
                //         // //   }
                //         // }

                //         // write NDEF record:
                //         // decoded NDEF records
                //         // await FlutterNfcKit.writeNDEFRecords([new ndef.UriRecord.fromUriString("https://github.com/nfcim/flutter_nfc_kit")]);
                //         // raw NDEF records
                //         // await FlutterNfcKit.writeNDEFRawRecords([new NDEFRawRecord("0001", "0002", "0003", ndef.TypeNameFormat.unknown)]);
                //       },
                //     ),
                //   ],
                // ),
                // Row(
                //   children: <Widget>[
                //     AppButton.buildAppButton(
                //       context,
                //       // Share Address Button
                //       AppButtonType.PRIMARY_OUTLINE,
                //       AppLocalization.of(context).nearby,
                //       Dimens.BUTTON_BOTTOM_DIMENS,
                //       onPressed: () async {
                //         Sheets.showAppHeightNineSheet(
                //           context: context,
                //           widget: const NearbyDevicesSheet(),
                //         );
                //       },
                //     ),
                //   ],
                // ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).request, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      final bool validRequest = await _validateRequest();
                      if (!mounted) return;

                      if (!validRequest) {
                        return;
                      }
                      final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);

                      final String formattedAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);

                      String amountRaw;
                      if (_amountController!.text.isEmpty || _amountController!.text == "0") {
                        amountRaw = "0";
                      } else {
                        if (_localCurrencyMode) {
                          amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                              _localCurrencyFormat, convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text)));
                        } else {
                          if (!mounted) return;
                          amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                        }
                      }

                      if (_isMaxSend()) {
                        if (!mounted) return;
                        amountRaw = StateContainer.of(context).wallet!.accountBalance.toString();
                      }

                      // verifies the input is a user in the db
                      if (_addressController!.text.startsWith("@") ||
                          _addressController!.text.startsWith("★") ||
                          _addressController!.text.contains(".") ||
                          _addressController!.text.contains(r"$")) {
                        // Need to make sure its a valid contact or user
                        final User? user = await sl.get<DBHelper>().getUserOrContactWithName(formattedAddress);
                        if (user == null) {
                          setState(() {
                            if (_addressController!.text.startsWith("★")) {
                              _addressValidationText = AppLocalization.of(context).contactInvalid;
                            } else if (_addressController!.text.startsWith("@")) {
                              _addressValidationText = AppLocalization.of(context).usernameInvalid;
                            } else if (_addressController!.text.contains(".") || _addressController!.text.contains(r"$")) {
                              _addressValidationText = AppLocalization.of(context).domainInvalid;
                            }
                          });
                        } else {
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: RequestConfirmSheet(
                                amountRaw: amountRaw,
                                destination: user.address!,
                                contactName: user.getDisplayName(),
                                localCurrency: _localCurrencyMode ? _amountController!.text : null,
                                memo: _memoController!.text,
                              ));
                        }
                      } else if (_addressController!.text.contains(".") || _addressController!.text.contains(r"$")) {
                        String? address;

                        // check if UD domain:
                        address = await sl.get<AccountService>().checkUnstoppableDomain(_addressController!.text);
                        address ??= await sl.get<AccountService>().checkENSDomain(_addressController!.text);
                        address ??= await sl.get<AccountService>().checkOpencapDomain(_addressController!.text);

                        if (!mounted) return;

                        if (address == null) {
                          _addressValidationText = AppLocalization.of(context).domainInvalid;
                        }
                      } else {
                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: RequestConfirmSheet(
                                amountRaw: amountRaw,
                                destination: _addressController!.text,
                                localCurrency: _localCurrencyMode ? _amountController!.text : null,
                                memo: _memoController!.text));
                      }
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).showAccountInfo, Dimens.BUTTON_COMPACT_LEFT_DIMENS,
                        onPressed: () async {
                      Sheets.showAppHeightEightSheet(
                          context: context,
                          widget: ReceiveShowQRSheet(
                            localCurrency: widget.localCurrency,
                            address: widget.address,
                            qrWidget: widget.qrWidget,
                          ));
                    }),
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).splitBill, Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                        onPressed: () async {
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: SplitBillSheet(
                            localCurrencyFormat: _localCurrencyFormat,
                          ));
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend() {
    // Sanitize commas
    if (_amountController!.text.isEmpty) {
      return false;
    }
    try {
      String textField = _amountController!.text;
      String balance;
      if (_localCurrencyMode) {
        balance = StateContainer.of(context)
            .wallet!
            .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = getRawAsThemeAwareAmount(context, StateContainer.of(context).wallet!.accountBalance.toString());
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        final String sanitizedTextField = sanitizedAmount(_localCurrencyFormat, textField);
        final String sanitizedBalance = sanitizedAmount(_localCurrencyFormat, balance);
        textFieldInt = (Decimal.parse(sanitizedTextField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      } else {
        textField = sanitizedAmount(_localCurrencyFormat, textField);
        textFieldInt = (Decimal.parse(textField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
        balanceInt = (Decimal.parse(balance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      }
      return textFieldInt == balanceInt;
    } catch (e) {
      return false;
    }
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (_amountController!.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _amountController!.text;
        _lastCryptoAmount = convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text);
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = cryptoAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_amountController!.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
        if (!_lastLocalCurrencyAmount.startsWith(_localCurrencyFormat.currencySymbol)) {
          _lastLocalCurrencyAmount = _localCurrencyFormat.currencySymbol + _lastLocalCurrencyAmount;
        }
      } else {
        _lastCryptoAmount = _amountController!.text;
        _lastLocalCurrencyAmount = convertCryptoToLocalCurrency(context, _localCurrencyFormat, _amountController!.text);
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = localAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  void redrawQrCode() {
    String? raw;
    if (_localCurrencyMode) {
      _lastLocalCurrencyAmount = _amountController!.text;
      _lastCryptoAmount = sanitizedAmount(_localCurrencyFormat, convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text));
      if (_lastCryptoAmount.isNotEmpty) {
        raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
      }
    } else {
      raw = _amountController!.text.isNotEmpty
          ? NumberUtil.getAmountAsRaw(
              _amountController!.text.trim().replaceAll(_localCurrencyFormat.currencySymbol, "").replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, ""))
          : "";
    }
    paintQrCode(address: widget.address, amount: raw);
  }

  Future<void> paintQrCode({String? address, String? amount}) async {
    late String data;
    if (isNotEmpty(amount)) {
      data = "nano:${address!}?amount:${amount!}";
    } else {
      data = "nano:${address!}";
    }

    final Widget qr = SizedBox(width: MediaQuery.of(context).size.width / 2.675, child: await UIUtil.getQRImage(context, data));
    setState(() {
      qrWidget = qr;
    });
  }

  Future<bool> showNotificationDialog() async {
    final NotificationOptions? option = await showDialog<NotificationOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text("${AppLocalization.of(context).notificationInfo}\n", style: AppStyles.textStyleParagraph(context)),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (option == null) {
      return false;
    }

    if (option == NotificationOptions.ON) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: true));
        FirebaseMessaging.instance.requestPermission();
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return true;
    } else {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: false));
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return false;
    }
  }

  Future<bool> showNeedVerificationAlert() async {
    switch (await showDialog<int>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              AppLocalization.of(context).needVerificationAlertHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${AppLocalization.of(context).needVerificationAlert}\n\n", style: AppStyles.textStyleParagraph(context)),
              ],
            ),
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).ok,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      // case 1:

      //   // go to qr code
      //   if (receive == null) {
      //     return false;
      //   }
      //   Navigator.of(context).pop();
      //   // TODO: BACKLOG: this is a roundabout solution to get the qr code to show up
      //   // probably better to do with an event bus
      //   Sheets.showAppHeightNineSheet(context: context, widget: receive!);
      //   return true;
      default:
        return false;
    }
  }

  // Build contact items for the list
  Widget _buildUserItem(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 42,
          width: double.infinity - 5,
          child: TextButton(
            onPressed: () {
              _addressController!.text = user.getDisplayName()!;
              _addressFocusNode!.unfocus();
              setState(() {
                _isUser = true;
                _showContactButton = false;
                _pasteButtonVisible = false;
                _addressStyle = AddressStyle.PRIMARY;
                _addressValidationText = "";
              });
            },
            child: Text(user.getDisplayName()!, textAlign: TextAlign.center, style: AppStyles.textStyleAddressPrimary(context)),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: StateContainer.of(context).curTheme.text03,
        ),
      ],
    );
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  Future<bool> _validateRequest() async {
    bool isValid = true;
    _amountFocusNode!.unfocus();
    _addressFocusNode!.unfocus();
    _memoFocusNode!.unfocus();
    // Validate amount
    if (_amountController!.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = AppLocalization.of(context).amountMissing;
      });
    } else {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = sanitizedAmount(_localCurrencyFormat, convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text));
      } else {
        if (_rawAmount == null) {
          bananoAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);
        } else {
          bananoAmount = getRawAsThemeAwareAmount(context, _rawAmount);
        }
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
      final BigInt? sendAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        if (_memoController!.text.trim().isEmpty) {
          isValid = false;
          setState(() {
            _amountValidationText = AppLocalization.of(context).amountMissing;
          });
        } else {
          setState(() {
            _amountValidationText = "";
          });
        }
      } else {
        setState(() {
          _amountValidationText = "";
        });
      }
    }
    // Validate address
    final bool isUser = _addressController!.text.startsWith("@");
    final bool isFavorite = _addressController!.text.startsWith("★");
    final bool isDomain = _addressController!.text.contains(".") || _addressController!.text.contains(r"$");
    final bool isNano = _addressController!.text.startsWith("nano_");
    // final bool isPhoneNumber = _isPhoneNumber(_addressController!.text);
    if (_addressController!.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).addressMissing;
        _pasteButtonVisible = true;
      });
    } else if (_addressController!.text.isNotEmpty && !isFavorite && !isUser && !isDomain && !Address(_addressController!.text).isValid()) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).invalidAddress;
        _pasteButtonVisible = true;
      });
    } else if (!isUser && !isFavorite) {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
      _addressFocusNode!.unfocus();
    }
    if (isValid) {
      // notifications must be turned on if sending a request or memo:
      final bool notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();

      if ((_memoController!.text.isNotEmpty && _addressController!.text.isNotEmpty) && !notificationsEnabled) {
        final bool notificationTurnedOn = await showNotificationDialog();
        if (!notificationTurnedOn) {
          isValid = false;
        } else {
          // not sure why this is needed to get it to update:
          // probably event bus related:
          await sl.get<SharedPrefsUtil>().setNotificationsOn(true);
        }
      }

      if (isValid) {
        // still valid && you have to have a nautilus username to send requests:
        if (StateContainer.of(context).wallet!.user == null && StateContainer.of(context).wallet!.confirmationHeight < _REQUIRED_CONFIRMATION_HEIGHT) {
          isValid = false;
          await showNeedVerificationAlert();
        }
      }

      // if (isValid && sl.get<AccountService>().fallbackConnected) {
      //   if (_memoController!.text.trim().isNotEmpty) {
      //     isValid = false;
      //     // await showFallbackConnectedAlert();
      //   }
      // }
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
    return AppTextField(
      focusNode: _amountFocusNode,
      controller: _amountController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: "NunitoSans",
      ),
      inputFormatters: [
        CurrencyFormatter2(
          active: _localCurrencyMode,
          currencyFormat: _localCurrencyFormat,
          maxDecimalDigits: _localCurrencyMode ? _localCurrencyFormat.decimalDigits ?? 2 : NumberUtil.maxDecimalDigits,
        ),
      ],
      onChanged: (String text) {
        if (_localCurrencyMode == false && !text.contains(".") && text.isNotEmpty && text.length > 1) {
          // if the amount is larger than 133248297 set it to that number:
          if (BigInt.parse(text.replaceAll(_localCurrencyFormat.currencySymbol, "").replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "")) >
              BigInt.parse("133248297")) {
            setState(() {
              // _amountController.text = "133248297";
              // prevent the user from entering more than 13324829
              _amountController!.text = _amountController!.text.substring(0, _amountController!.text.length - 1);
              _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: _amountController!.text.length));
            });
          }
        }
        // Always reset the error message to be less annoying
        setState(() {
          _amountValidationText = "";
          // Reset the raw amount
          _rawAmount = null;
        });

        redrawQrCode();
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _amountHint ?? AppLocalization.of(context).enterAmount,
      prefixButton: _rawAmount == null
          ? TextFieldButton(
              padding: EdgeInsets.zero,
              widget: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: displayCurrencySymbol(
                      context,
                      TextStyle(
                        color: StateContainer.of(context).curTheme.primary,
                        fontSize: _localCurrencyMode ? 12 : 20,
                        fontWeight: _localCurrencyMode ? FontWeight.w400 : FontWeight.w800,
                        fontFamily: "NunitoSans",
                      ),
                    ),
                  ),
                  const Text("/"),
                  Text(_localCurrencyFormat.currencySymbol.trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _localCurrencyMode ? 20 : 12,
                        fontWeight: _localCurrencyMode ? FontWeight.w800 : FontWeight.w400,
                        color: StateContainer.of(context).curTheme.primary,
                        fontFamily: "NunitoSans",
                      )),
                ],
              ),
              onPressed: () {
                toggleLocalCurrency();
              },
            )
          : null,
      fadeSuffixOnCondition: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Amount Container Method End ************//
  //*************************************************************//

  //************ Enter Address Container Method ************//
  //*******************************************************//
  Widget getEnterAddressContainer() {
    return AppTextField(
        topMargin: 115,
        padding: _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
        // padding: EdgeInsets.zero,
        textAlign: TextAlign.center,
        // textAlign: (_isUser || _addressController.text.length == 0) ? TextAlign.center : TextAlign.start,
        focusNode: _addressFocusNode,
        controller: _addressController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [
          if (_isUser) LengthLimitingTextInputFormatter(20) else LengthLimitingTextInputFormatter(65),
        ],
        textInputAction: _memoController!.text.isEmpty ? TextInputAction.next : TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _addressHint ?? AppLocalization.of(context).enterUserOrAddress,
        prefixButton: TextFieldButton(
            icon: AppIcons.scan,
            onPressed: () async {
              UIUtil.cancelLockEvent();
              final String? scanResult = await UserDataUtil.getQRData(DataType.ADDRESS, context) as String?;
              if (!mounted) return;
              if (scanResult == null) {
                UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidAddress, context);
              } else if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
                if (mounted) {
                  setState(() {
                    _addressController!.text = scanResult;
                    _addressValidationText = "";
                    _addressValidAndUnfocused = true;
                  });
                  _addressFocusNode!.unfocus();
                }
              }
            }),
        fadePrefixOnCondition: true,
        prefixShowFirstCondition: _showContactButton && _users.isEmpty,
        suffixButton: TextFieldButton(
          icon: _clearButton ? AppIcons.clear : AppIcons.paste,
          onPressed: () {
            if (_clearButton) {
              setState(() {
                _isUser = false;
                _addressValidationText = "";
                _pasteButtonVisible = true;
                _clearButton = false;
                _showContactButton = true;
                _addressController!.text = "";
                _users = <User>[];
              });
              return;
            }
            Clipboard.getData("text/plain").then((ClipboardData? data) {
              if (data == null || data.text == null) {
                return;
              }
              final Address address = Address(data.text);
              if (address.isValid()) {
                sl.get<DBHelper>().getUserOrContactWithAddress(address.address!).then((User? user) {
                  if (user == null) {
                    setState(() {
                      _isUser = false;
                      _addressValidationText = "";
                      _addressStyle = AddressStyle.TEXT90;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _addressController!.text = address.address!;
                    _addressFocusNode!.unfocus();
                    setState(() {
                      _addressValidAndUnfocused = true;
                    });
                  } else {
                    // Is a user
                    setState(() {
                      _addressController!.text = user.getDisplayName()!;
                      _addressFocusNode!.unfocus();
                      _users = [];
                      _isUser = true;
                      _addressValidationText = "";
                      _addressStyle = AddressStyle.PRIMARY;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                  }
                });
              }
            });
          },
        ),
        fadeSuffixOnCondition: true,
        suffixShowFirstCondition: _pasteButtonVisible,
        style: _addressStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _addressStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressPrimary(context),
        onChanged: (String text) async {
          bool isUser = false;
          final bool isDomain = text.contains(".") || text.contains(r"$");
          final bool isFavorite = text.startsWith("★");
          final bool isNano = text.startsWith("nano_");

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _addressController!.text = text;
            _addressController!.selection = TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
          }

          if (text.isNotEmpty) {
            setState(() {
              _showContactButton = false;
              _pasteButtonVisible = true;
              _clearButton = true;
            });
          } else {
            setState(() {
              _showContactButton = true;
              _pasteButtonVisible = true;
              _clearButton = false;
            });
          }

          if (text.isNotEmpty && !isUser && !isNano) {
            isUser = true;
          }

          if (text.isNotEmpty && text.startsWith("nano_")) {
            isUser = false;
          }

          if (text.isNotEmpty && text.contains(".")) {
            isUser = false;
          }

          // check if it's a real nano address:
          // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
          if (text.isEmpty) {
            setState(() {
              _isUser = false;
              _users = [];
            });
          } else if (isFavorite) {
            final List<User> matchedList = await sl.get<DBHelper>().getContactsWithNameLike(SendSheetHelpers.stripPrefixes(text));
            final Set<String?> nicknames = {};
            matchedList.retainWhere((User x) => nicknames.add(x.nickname));
            setState(() {
              _isFavorite = true;
              _users = matchedList;
            });
          } else if (isUser || isDomain) {
            final List<User> matchedList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(SendSheetHelpers.stripPrefixes(text));
            setState(() {
              _isFavorite = false;
              _users = matchedList;
            });
          } else {
            setState(() {
              _isUser = false;
              _users = [];
            });
          }
          // Always reset the error message to be less annoying
          if (_addressValidationText.isNotEmpty) {
            setState(() {
              _addressValidationText = "";
            });
          }
          if (isNano && Address(text).isValid()) {
            _addressFocusNode!.unfocus();
            setState(() {
              _addressStyle = AddressStyle.TEXT90;
              _addressValidationText = "";
              _pasteButtonVisible = false;
            });
          } else {
            setState(() {
              _addressStyle = AddressStyle.TEXT60;
            });
          }

          if ((isUser || isFavorite) != _isUser) {
            setState(() {
              _isUser = isUser || isFavorite;
            });
          }
        },
        onSubmitted: (String text) {
          if (_memoController!.text.isEmpty) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        overrideTextFieldWidget: _addressValidAndUnfocused
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _addressValidAndUnfocused = false;
                  });
                  Future.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_addressFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _addressController!.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer() {
    double margin = 200;
    if (_addressController!.text.startsWith("nano_")) {
      if (_addressController!.text.length > 24) {
        margin = 217;
      }
      if (_addressController!.text.length > 48) {
        margin = 238;
      }
    }
    return AppTextField(
      topMargin: margin,
      focusNode: _memoFocusNode,
      controller: _memoController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(255),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _memoHint ?? AppLocalization.of(context).enterMemo,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.5,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
      onChanged: (String text) {
        setState(() {}); // forces address container to respect the memo's status (empty or not empty)
        // nothing for now
      },
    );
  } //************ Enter Memo Container Method End ************//
  //*************************************************************//
}

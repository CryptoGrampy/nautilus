import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

class IntroImportSeedPage extends StatefulWidget {
  @override
  IntroImportSeedState createState() => IntroImportSeedState();
}

class IntroImportSeedState extends State<IntroImportSeedPage> {
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  // Plaintext seed
  FocusNode _seedInputFocusNode = FocusNode();
  TextEditingController _seedInputController = TextEditingController();
  // Mnemonic Phrase
  FocusNode _mnemonicFocusNode = FocusNode();
  TextEditingController _mnemonicController = TextEditingController();

  bool _seedMode = false; // False if restoring phrase, true if restoring seed

  bool _seedIsValid = false;
  bool _showSeedError = false;
  bool _mnemonicIsValid = false;
  String? _mnemonicError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        body: TapOutsideUnfocus(
            child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
            minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Back Button
                          Container(
                            margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                            height: 50,
                            width: 50,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: StateContainer.of(context).curTheme.text15,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                  padding: EdgeInsets.zero,
                                  // highlightColor: StateContainer.of(context).curTheme.text15,
                                  // splashColor: StateContainer.of(context).curTheme.text15,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                          ),
                          // Switch between Secret Phrase and Seed
                          Container(
                            margin: EdgeInsetsDirectional.only(end: smallScreen(context) ? 15 : 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                padding: const EdgeInsetsDirectional.only(top: 6, bottom: 6, start: 12, end: 12),
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                                // splashColor: StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () {
                                setState(() {
                                  _seedMode = !_seedMode;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(end: 8),
                                    child: Text(
                                      _seedMode
                                          ? AppLocalization.of(context).secretPhrase
                                          : AppLocalization.of(context).seed,
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.text,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ),
                                  Icon(_seedMode ? Icons.vpn_key : AppIcons.seed,
                                      color: StateContainer.of(context).curTheme.text, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The header
                      Container(
                        margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 10,
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        child: AutoSizeText(
                          _seedMode
                              ? AppLocalization.of(context).importSeed
                              : AppLocalization.of(context).importSecretPhrase,
                          style: AppStyles.textStyleHeaderColored(context),
                          maxLines: 1,
                          minFontSize: 12,
                          stepGranularity: 0.1,
                        ),
                      ),
                      // The paragraph
                      Container(
                        margin: EdgeInsets.only(
                            left: smallScreen(context) ? 30 : 40, right: smallScreen(context) ? 30 : 40, top: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _seedMode
                              ? AppLocalization.of(context).importSeedHint
                              : AppLocalization.of(context).importSecretPhraseHint,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                          child: KeyboardAvoider(
                              duration: Duration.zero,
                              autoScroll: true,
                              focusPadding: 40,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                // The text field for the seed
                                if (_seedMode)
                                  AppTextField(
                                      leftMargin: smallScreen(context) ? 30 : 40,
                                      rightMargin: smallScreen(context) ? 30 : 40,
                                      topMargin: 20,
                                      focusNode: _seedInputFocusNode,
                                      controller: _seedInputController,
                                      inputFormatters: [LengthLimitingTextInputFormatter(64), UpperCaseTextFormatter()],
                                      textInputAction: TextInputAction.done,
                                      maxLines: null,
                                      autocorrect: false,
                                      prefixButton: TextFieldButton(
                                        icon: AppIcons.scan,
                                        onPressed: () {
                                          if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                            return;
                                          }
                                          // Scan QR for seed
                                          UIUtil.cancelLockEvent();
                                          BarcodeScanner.scan(/*StateContainer.of(context).curTheme.qrScanTheme TODO:*/)
                                              .then((ScanResult res) {
                                            final String result = res.rawContent;
                                            if (NanoSeeds.isValidSeed(result)) {
                                              _seedInputController.text = result;
                                              setState(() {
                                                _seedIsValid = true;
                                              });
                                            } else if (NanoMnemomics.validateMnemonic(result.split(' '))) {
                                              _mnemonicController.text = result;
                                              _mnemonicFocusNode.unfocus();
                                              _seedInputFocusNode.unfocus();
                                              setState(() {
                                                _seedMode = false;
                                                _mnemonicError = null;
                                                _mnemonicIsValid = true;
                                              });
                                            } else {
                                              UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidSeed, context);
                                            }
                                          });
                                        },
                                      ),
                                      fadePrefixOnCondition: true,
                                      prefixShowFirstCondition: !NanoSeeds.isValidSeed(_seedInputController.text),
                                      suffixButton: TextFieldButton(
                                        icon: AppIcons.paste,
                                        onPressed: () {
                                          if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                            return;
                                          }
                                          Clipboard.getData("text/plain").then((ClipboardData? data) {
                                            if (data == null || data.text == null) {
                                              return;
                                            } else if (NanoSeeds.isValidSeed(data.text!)) {
                                              _seedInputController.text = data.text!;
                                              setState(() {
                                                _seedIsValid = true;
                                              });
                                            } else if (NanoMnemomics.validateMnemonic(data.text!.split(' '))) {
                                              _mnemonicController.text = data.text!;
                                              _mnemonicFocusNode.unfocus();
                                              _seedInputFocusNode.unfocus();
                                              setState(() {
                                                _seedMode = false;
                                                _mnemonicError = null;
                                                _mnemonicIsValid = true;
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      fadeSuffixOnCondition: true,
                                      suffixShowFirstCondition: !NanoSeeds.isValidSeed(_seedInputController.text),
                                      keyboardType: TextInputType.text,
                                      style: _seedIsValid
                                          ? AppStyles.textStyleSeed(context)
                                          : AppStyles.textStyleSeedGray(context),
                                      onChanged: (String text) {
                                        // Always reset the error message to be less annoying
                                        setState(() {
                                          _showSeedError = false;
                                        });
                                        // If valid seed, clear focus/close keyboard
                                        if (NanoSeeds.isValidSeed(text)) {
                                          _seedInputFocusNode.unfocus();
                                          setState(() {
                                            _seedIsValid = true;
                                          });
                                        } else {
                                          setState(() {
                                            _seedIsValid = false;
                                          });
                                        }
                                      })
                                else
                                  AppTextField(
                                    leftMargin: smallScreen(context) ? 30 : 40,
                                    rightMargin: smallScreen(context) ? 30 : 40,
                                    topMargin: 20,
                                    focusNode: _mnemonicFocusNode,
                                    controller: _mnemonicController,
                                    inputFormatters: [
                                      SingleSpaceInputFormatter(),
                                      LowerCaseTextFormatter(),
                                      FilteringTextInputFormatter(RegExp("[a-zA-Z ]"),
                                          allow: true), // bug fix for debug mode when importing a seed
                                    ],
                                    textInputAction: TextInputAction.done,
                                    maxLines: null,
                                    autocorrect: false,
                                    prefixButton: TextFieldButton(
                                      icon: AppIcons.scan,
                                      onPressed: () {
                                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                          return;
                                        }
                                        // Scan QR for mnemonic
                                        UIUtil.cancelLockEvent();
                                        BarcodeScanner.scan(/*StateContainer.of(context).curTheme.qrScanTheme*/)
                                            .then((ScanResult res) {
                                          final String result = res.rawContent;
                                          if (NanoMnemomics.validateMnemonic(result.split(' '))) {
                                            _mnemonicController.text = result;
                                            setState(() {
                                              _mnemonicIsValid = true;
                                            });
                                          } else if (NanoSeeds.isValidSeed(result)) {
                                            _seedInputController.text = result;
                                            _mnemonicFocusNode.unfocus();
                                            _seedInputFocusNode.unfocus();
                                            setState(() {
                                              _seedMode = true;
                                              _seedIsValid = true;
                                              _showSeedError = false;
                                            });
                                          } else {
                                            UIUtil.showSnackbar(AppLocalization.of(context).qrMnemonicError, context);
                                          }
                                        });
                                      },
                                    ),
                                    fadePrefixOnCondition: true,
                                    prefixShowFirstCondition:
                                        !NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' ')),
                                    suffixButton: TextFieldButton(
                                      icon: AppIcons.paste,
                                      onPressed: () {
                                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                          return;
                                        }
                                        Clipboard.getData("text/plain").then((ClipboardData? data) {
                                          if (data == null || data.text == null) {
                                            return;
                                          } else if (NanoMnemomics.validateMnemonic(data.text!.split(' '))) {
                                            _mnemonicController.text = data.text!;
                                            setState(() {
                                              _mnemonicIsValid = true;
                                            });
                                          } else if (NanoSeeds.isValidSeed(data.text!)) {
                                            _seedInputController.text = data.text!;
                                            _mnemonicFocusNode.unfocus();
                                            _seedInputFocusNode.unfocus();
                                            setState(() {
                                              _seedMode = true;
                                              _seedIsValid = true;
                                              _showSeedError = false;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    fadeSuffixOnCondition: true,
                                    suffixShowFirstCondition:
                                        !NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' ')),
                                    keyboardType: TextInputType.text,
                                    style: _mnemonicIsValid
                                        ? AppStyles.textStyleParagraphPrimary(context)
                                        : AppStyles.textStyleParagraph(context),
                                    onChanged: (String text) {
                                      if (text.length < 3) {
                                        setState(() {
                                          _mnemonicError = null;
                                        });
                                      } else if (_mnemonicError != null) {
                                        if (!text.contains(_mnemonicError!.split(' ')[0])) {
                                          setState(() {
                                            _mnemonicError = null;
                                          });
                                        }
                                      }
                                      // If valid mnemonic, clear focus/close keyboard
                                      if (NanoMnemomics.validateMnemonic(text.split(' '))) {
                                        _mnemonicFocusNode.unfocus();
                                        setState(() {
                                          _mnemonicIsValid = true;
                                          _mnemonicError = null;
                                        });
                                      } else {
                                        setState(() {
                                          _mnemonicIsValid = false;
                                        });
                                        // Validate each mnemonic word
                                        if (text.endsWith(" ") && text.length > 1) {
                                          int? lastSpaceIndex = text.substring(0, text.length - 1).lastIndexOf(" ");
                                          if (lastSpaceIndex == -1) {
                                            lastSpaceIndex = 0;
                                          } else {
                                            lastSpaceIndex = lastSpaceIndex + 1;
                                          }
                                          final String lastWord = text.substring(lastSpaceIndex, text.length - 1);
                                          if (!NanoMnemomics.isValidWord(lastWord)) {
                                            setState(() {
                                              _mnemonicIsValid = false;
                                              setState(() {
                                                _mnemonicError = AppLocalization.of(context)
                                                    .mnemonicInvalidWord
                                                    .replaceAll("%1", lastWord);
                                              });
                                            });
                                          }
                                        }
                                      }
                                    },
                                  ),
                                // "Invalid Seed" text that appears if the input is invalid
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      !_seedMode
                                          ? _mnemonicError == null
                                              ? ""
                                              : _mnemonicError!
                                          : _showSeedError
                                              ? AppLocalization.of(context).seedInvalid
                                              : "",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: _seedMode
                                            ? _showSeedError
                                                ? StateContainer.of(context).curTheme.primary
                                                : Colors.transparent
                                            : _mnemonicError != null
                                                ? StateContainer.of(context).curTheme.primary
                                                : Colors.transparent,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ])))
                    ],
                  ),
                ),
                // Next Screen Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsetsDirectional.only(end: 30),
                      height: 50,
                      width: 50,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: StateContainer.of(context).curTheme.primary30,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.zero,
                            // highlightColor: StateContainer.of(context).curTheme.primary15,
                            // splashColor: StateContainer.of(context).curTheme.primary30,
                          ),
                          onPressed: () {
                            if (_seedMode) {
                              _seedInputFocusNode.unfocus();
                              // If seed valid, log them in
                              if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                                sl.get<SharedPrefsUtil>().setSeedBackedUp(true).then((result) async {
                                  // Navigator.pushNamed(context, '/intro_password_on_launch', arguments: _seedInputController.text);
                                  await sl.get<Vault>().setSeed(_seedInputController.text);
                                  await sl.get<DBHelper>().dropAccounts();
                                  if (!mounted) return;
                                  await NanoUtil().loginAccount(_seedInputController.text, context);
                                  if (!mounted) return;
                                  final String? pin = await Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (BuildContext context) {
                                    return PinScreen(
                                      PinOverlayType.NEW_PIN,
                                    );
                                  }));
                                  if (pin != null && pin.length > 5) {
                                    _pinEnteredCallback(pin);
                                  }
                                });
                              } else {
                                // Display error
                                setState(() {
                                  _showSeedError = true;
                                });
                              }
                            } else {
                              // mnemonic mode
                              _mnemonicFocusNode.unfocus();
                              if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                sl.get<SharedPrefsUtil>().setSeedBackedUp(true).then((result) async {
                                  // Navigator.pushNamed(context, '/intro_password_on_launch',
                                  //     arguments: NanoMnemomics.mnemonicListToSeed(_mnemonicController.text.split(' ')));
                                  final String seed =
                                      NanoMnemomics.mnemonicListToSeed(_mnemonicController.text.split(' '));
                                  await sl.get<Vault>().setSeed(seed);
                                  await sl.get<DBHelper>().dropAccounts();
                                  if (!mounted) return;
                                  await NanoUtil().loginAccount(seed, context);
                                  if (!mounted) return;
                                  final String? pin = await Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (BuildContext context) {
                                    return PinScreen(
                                      PinOverlayType.NEW_PIN,
                                    );
                                  }));
                                  if (pin != null && pin.length > 5) {
                                    _pinEnteredCallback(pin);
                                  }
                                });
                              } else {
                                // Show mnemonic error
                                if (_mnemonicController.text.split(' ').length != 24) {
                                  setState(() {
                                    _mnemonicIsValid = false;
                                    _mnemonicError = AppLocalization.of(context).mnemonicSizeError;
                                  });
                                } else {
                                  _mnemonicController.text.split(' ').forEach((String word) {
                                    if (!NanoMnemomics.isValidWord(word)) {
                                      setState(() {
                                        _mnemonicIsValid = false;
                                        _mnemonicError =
                                            AppLocalization.of(context).mnemonicInvalidWord.replaceAll("%1", word);
                                      });
                                    }
                                  });
                                }
                              }
                            }
                          },
                          child: Icon(AppIcons.forward, color: StateContainer.of(context).curTheme.primary, size: 50)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }

  Future<void> _pinEnteredCallback(String pin) async {
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(pin);
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }
}

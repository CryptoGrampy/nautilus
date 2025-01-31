import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/localize.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  IntroWelcomePageState createState() => IntroWelcomePageState();
}

class IntroWelcomePageState extends State<IntroWelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // post frame callback:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool openedDialog = false;

      // If the system can show an authorization request dialog
      if (Platform.isIOS) {
        if (await sl.get<SharedPrefsUtil>().getTrackingEnabled() == false ||
            await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.notDetermined) {
          // Show a custom explainer dialog before the system dialog
          await AppDialogs.showInfoDialog(
            context,
            AppLocalization.of(context).trackingHeader,
            AppLocalization.of(context).askTracking,
            closeText: AppLocalization.of(context).ok,
            barrierDismissible: false,
            onPressed: () async {
              bool trackingEnabled = false;
              if (Platform.isIOS) {
                trackingEnabled =
                    await AppTrackingTransparency.requestTrackingAuthorization() == TrackingStatus.authorized;
              } else {
                trackingEnabled = (await AppDialogs.showTrackingDialog(context))!;
              }
              await sl.get<SharedPrefsUtil>().setTrackingEnabled(trackingEnabled);
              FlutterBranchSdk.disableTracking(!trackingEnabled);
            },
          );
        }
      }

      // check every 500ms if there's a giftcard:
      timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
        if (!mounted) return;
        if (!openedDialog && StateContainer.of(context).gift != null) {
          openedDialog = true;
          timer?.cancel();

          AppDialogs.showConfirmDialog(
            context,
            AppLocalization.of(context).giftAlert,
            AppLocalization.of(context).askSkipSetup,
            AppLocalization.of(context).ok,
            () async {
              setState(() {
                StateContainer.of(context).introSkiped = true;
              });

              await skipIntro();
            },
            cancelText: AppLocalization.of(context).noThanks,
            cancelAction: () {
              // do nothing:
            },
            barrierDismissible: false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: MediaQuery.of(context).size.height * 0.10,
          ),
          child: Column(
            children: <Widget>[
              // A widget that holds welcome animation + paragraph
              Expanded(
                child: Flex(
                  direction: landscape ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: landscape ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: <Widget>[
                    //Container for the animation
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      // Width/Height ratio for the animation is needed because BoxFit is not working as expected
                      // width: double.infinity,
                      // width: MediaQuery.of(context).size.width / 2,
                      // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
                      // height: MediaQuery.of(context).size.width * 4 / 8,
                      // width: MediaQuery.of(context).size.width,

                      child: Image.asset("assets/logo.png"),
                    ),

                    SizedBox(
                      width: landscape ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                // margin: const EdgeInsets.only(top: 0),
                                color: Colors.white,
                                // padding: EdgeInsets.zero,
                                // width: double.infinity,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                height: 90,
                              ),
                              Container(
                                // margin:
                                padding: EdgeInsets.zero,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                child: TextLiquidFill(
                                  text: CaseChange.toUpperCase(NonTranslatable.nautilus, context),
                                  waveColor: NautilusTheme.nautilusBlue,
                                  boxBackgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
                                  textStyle:
                                      const TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold, color: Colors.white),
                                  boxHeight: 100.0,
                                  boxWidth: double.infinity,
                                  loadDuration: const Duration(seconds: 3),
                                  waveDuration: const Duration(seconds: 3),
                                  loadUntil: 0.5,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 90),
                                color: StateContainer.of(context).curTheme.backgroundDark,
                                // color: Colors.green,
                                // padding: EdgeInsets.zero,
                                // width: double.infinity,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                height: 15,
                              ),
                            ],
                          ),

                          // Container for the paragraph
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 30 : 40, vertical: 20),
                            child: AutoSizeText(
                              AppLocalization.of(context).welcomeTextUpdated,
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 4,
                              stepGranularity: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //A column with "New Wallet" and "Import Wallet" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // New Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).newWallet,
                          Dimens.BUTTON_TOP_DIMENS,
                          instanceKey: const Key("new_wallet_button"), onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Import Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).importWallet, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pushNamed('/intro_import');
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> skipIntro() async {
    // set random representative as the default:
    // TODO: disabled because mynano.ninja is down:
    // final List<NinjaNode>? nodes = await NinjaAPI.getVerifiedNodes();
    // if (nodes != null && nodes.isNotEmpty) {
    //   final Random random = Random();
    //   final NinjaNode randomNode = nodes[random.nextInt(nodes.length)];
    //   sl.get<SharedPrefsUtil>().setRepresentative(randomNode.account);
    //   AppWallet.defaultRepresentative = randomNode.account!;
    // }
    await sl.get<DBHelper>().dropAccounts();
    await sl.get<Vault>().setSeed(NanoSeeds.generateSeed());
    if (!mounted) return;
    // Update wallet
    final String seed = await StateContainer.of(context).getSeed();
    if (!mounted) return;
    await NanoUtil().loginAccount(seed, context);

    const String DEFAULT_PIN = "000000";

    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(DEFAULT_PIN);
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }

  Future<void> handleBranchGift() async {
    await showDialog<int>(
        barrierDismissible: false,
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              AppLocalization.of(context).giftAlert,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${AppLocalization.of(context).importGiftIntro}\n\n",
                    style: AppStyles.textStyleParagraph(context)),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).close,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              )
            ],
          );
        });
  }
}

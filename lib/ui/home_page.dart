// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_modified_event.dart';
import 'package:nautilus_wallet_flutter/bus/deep_link_event.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/tx_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/unified_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/xmr_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/localize.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/list_model.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/fcm_message_event.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/auth_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/handoff_item.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/auth/auth_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/gift/gift_qr_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/handoff/handoff_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/popup_button.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_xmr_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/users/add_blocked.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/custom_monero.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/hcaptcha.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/top_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:nautilus_wallet_flutter/util/box.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/giftcards.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiver/strings.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AppHomePage extends StatefulWidget {
  AppHomePage({this.priceConversion}) : super();
  PriceConversion? priceConversion;

  @override
  AppHomePageState createState() => AppHomePageState();
}

class AppHomePageState extends State<AppHomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  late AnimationController _placeholderCardAnimationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _emptyAnimation;
  late bool _animationDisposed;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, List<AccountHistoryResponseItem>> _historyListMap = <String, List<AccountHistoryResponseItem>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, List<TXData>> _solidsListMap = <String, List<TXData>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = <String, GlobalKey<AnimatedListState>>{};
  final Map<String, ListModel<dynamic>> _unifiedListMap = <String, ListModel<dynamic>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  List<dynamic> _moneroHistoryList = <dynamic>[];
  // final Map<String, GlobalKey<AnimatedListState>> _moneroListKeyMap = <String, GlobalKey<AnimatedListState>>{};
  // final Map<String, ListModel<dynamic>> _moneroListMap = <String, ListModel<dynamic>>{};
  GlobalKey<AnimatedListState>? _moneroListKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState>? _moneroListKeyAlert;
  late ListModel<dynamic>? _moneroList;

  // used to associate memos with blocks so we don't have search on every re-render:
  final Map<String, TXData> _txDetailsMap = {};

  // search bar text controller:
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;
  bool _noSearchResults = false;

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  // List<User> _contacts = [];
  // List<User> _blocked = [];
  List<User> _users = [];
  // List<TXData> _txData = [];
  List<TXData> _txRecords = [];

  // "infinite scroll":
  late ScrollController _scrollController;
  int _maxHistItems = 10;
  bool _listExtended = false;
  double _lastExtentPixels = 0;
  int _trueMaxHistItems = 10000;
  late ScrollController _xmrScrollController;
  late TabController _tabController;

  bool _isRefreshing = false;
  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
    googlePlayIdentifier: 'co.perish.nautiluswallet',
    appStoreIdentifier: '1615775960',
  );

  // confetti:
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  // receive disabled?:
  bool _receiveDisabled = false;

  Future<void> _switchToAccount(String account) async {
    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(await StateContainer.of(context).getSeed());
    if (!mounted) return;
    for (final Account acc in accounts) {
      if (acc.address == account && acc.address != StateContainer.of(context).wallet!.address) {
        await sl.get<DBHelper>().changeAccount(acc);
        EventTaxiImpl.singleton().fire(AccountChangedEvent(account: acc, delayPop: true));
      }
    }
  }

  /// Notification includes which account its for, automatically switch to it if they're entering app from notification
  Future<void> _chooseCorrectAccountFromNotification(dynamic message) async {
    if (message.containsKey("account") as bool) {
      final String? account = message['account'] as String?;
      if (account != null) {
        await _switchToAccount(account);
      }
    }
  }

  Future<void> getNotificationPermissions() async {
    bool notificationsAllowed = false;
    try {
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.badge == AppleNotificationSetting.enabled ||
          settings.sound == AppleNotificationSetting.enabled ||
          settings.authorizationStatus == AuthorizationStatus.authorized) {
        sl.get<SharedPrefsUtil>().getNotificationsSet().then((bool beenSet) {
          if (!beenSet) {
            notificationsAllowed = true;
            sl.get<SharedPrefsUtil>().setNotificationsOn(true);
          }
        });
        _firebaseMessaging.getToken().then((String? token) {
          if (token != null) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          }
        });
      } else {
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
          _firebaseMessaging.getToken().then((String? token) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          });
        });
      }
      final String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
      }
    } catch (e) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false);
    }
    if (!await sl.get<SharedPrefsUtil>().getNotificationsOn() && !notificationsAllowed) {
      showNotificationWarning();
    }
  }

  Future<void> getTrackingPermissions() async {
    // check if we have tracking permissions on iOS:
    if (Platform.isIOS) {
      final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined || status == TrackingStatus.denied) {
        await showTrackingWarning();

        // update the setting if there's a mismatch:
        if (await sl.get<SharedPrefsUtil>().getTrackingEnabled()) {
          await sl.get<SharedPrefsUtil>().setTrackingEnabled(false);
        }
      }
    } else {
      // the setting is just a user preference on android:
      if (!await sl.get<SharedPrefsUtil>().getTrackingEnabled()) {
        await showTrackingWarning();
      }
    }
  }

  Future<void> _introSkippedMessage() async {
    StateContainer.of(context).introSkiped = false;
    AppDialogs.showInfoDialog(
      context,
      AppLocalization.of(context).introSkippedWarningHeader,
      AppLocalization.of(context).introSkippedWarningContent,
      barrierDismissible: false,
    );
  }

  Future<void> handleBranchGift(dynamic gift) async {
    if (gift == null || !mounted) {
      return;
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

    final String seed = gift["seed"] as String;
    final String memo = gift["memo"] as String;
    String amountRaw = gift["amount_raw"] as String;
    final String fromAddress = gift["from_address"] as String;
    final String giftUUID = gift["uuid"] as String;
    final bool requireCaptcha = gift["require_captcha"] as bool;

    if (amountRaw.isEmpty) {
      amountRaw = "0";
    }

    final String supposedAmount = getRawAsThemeAwareAmount(context, amountRaw);

    String? userOrFromAddress;

    // change address to username if it exists:
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(fromAddress);
    if (!mounted) return;
    if (user != null) {
      userOrFromAddress = user.getDisplayName();
    } else {
      userOrFromAddress = fromAddress;
    }

    bool shouldShowEmptyDialog = false;

    // try {
    BigInt balance = BigInt.parse(amountRaw);

    if (giftUUID.isEmpty) {
      // check if there's actually any nano to claim:
      if (seed.isNotEmpty) {
        balance = await AppTransferOverviewSheet().getGiftCardBalance(context, seed);
      }
      if (!mounted) return;

      if (balance != BigInt.zero) {
        final String actualAmount = getRawAsThemeAwareFormattedAmount(context, balance.toString());
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
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
                    Text("${AppLocalization.of(context).importGift}\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrFromAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context).giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftAmount}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: <InlineSpan>[
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, balance.toString()),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: actualAmount,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: <Widget>[
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context).refund,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context).receive,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
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
            })) {
          case 2:
            break;
          case 1:
            // transfer to this wallet:
            String? hcaptchaToken;
            if (requireCaptcha) {
              await AppDialogs.showInfoDialog(
                context,
                AppLocalization.of(context).captchaWarning,
                AppLocalization.of(context).captchaWarningBody,
                barrierDismissible: false,
                closeText: CaseChange.toUpperCase(AppLocalization.of(context).ok, context),
              );
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<dynamic>(builder: (BuildContext context) {
                  return HCaptcha((String code) => hcaptchaToken = code);
                }),
              );
            }
            if (!mounted) return;

            // not really worth actually checking the captcha, just send the gift anyway:

            // await AppTransferConfirmSheet().createState().autoProcessWallets(privKeyBalanceMap, StateContainer.of(context).wallet);
            await AppTransferOverviewSheet().startAutoTransfer(context, seed, StateContainer.of(context).wallet);
            break;
          case 0:
            // refund the gift:
            await AppTransferOverviewSheet().startAutoRefund(
              context,
              seed,
              fromAddress,
            );
            break;
        }
        if (!mounted) return;
        if (StateContainer.of(context).introSkiped) {
          // sleep for a few seconds so it doesn't feel too jarring:
          await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
          _introSkippedMessage();
        }
        return;
      } else {
        shouldShowEmptyDialog = true;
      }
    } else {
      // GIFT UUID is not empty, so we're dealing with gift card v2:
      // check if there's actually any nano to claim:
      final String requestingAccount = StateContainer.of(context).wallet!.address!;
      final dynamic res =
          await sl.get<GiftCards>().giftCardInfo(giftUUID: giftUUID, requestingAccount: requestingAccount);
      if (!mounted) return;
      final String actualAmount = getRawAsThemeAwareFormattedAmount(context, balance.toString());
      if (!mounted) return;
      if (res["error"] != null) {
        shouldShowEmptyDialog = true;
      } else if (res["success"] != null) {
        // show alert:
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
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
                    Text("${AppLocalization.of(context).importGiftv2}\n\n",
                        style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrFromAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context).giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftAmount}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, balance.toString()),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: actualAmount,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: <Widget>[
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context).receive,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
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
            })) {
          case 0:
            // transfer to this wallet:

            String? hcaptchaToken;

            if (requireCaptcha) {
              await AppDialogs.showInfoDialog(
                context,
                AppLocalization.of(context).captchaWarning,
                AppLocalization.of(context).captchaWarningBody,
                barrierDismissible: false,
                closeText: CaseChange.toUpperCase(AppLocalization.of(context).ok, context),
              );
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<dynamic>(builder: (BuildContext context) {
                  return HCaptcha((String code) => hcaptchaToken = code);
                }),
              );
            }
            if (!mounted) return;

            // show loading animation for ~5 seconds:
            // push animation to prevent early exit:
            bool animationOpen = true;
            AppAnimation.animationLauncher(context, AnimationType.GENERIC,
                onPoppedCallback: () => animationOpen = false);
            // sleep to flex the animation a bit:
            await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

            final dynamic res = await sl
                .get<GiftCards>()
                .giftCardClaim(giftUUID: giftUUID, requestingAccount: requestingAccount, hcaptchaToken: hcaptchaToken);
            if (!mounted) return;

            if (res["error"] != null) {
              log.d(res);
              // something went wrong, show error:
              UIUtil.showSnackbar(AppLocalization.of(context).errorProcessingGiftCard, context, durationMs: 4000);
            } else if (res["success"] != null) {
              // show success:
              UIUtil.showSnackbar(AppLocalization.of(context).giftProcessSuccess, context, durationMs: 4000);
            }

            if (animationOpen) {
              // animation is still open, so we need to close it:
              if (!mounted) return;
              Navigator.pop(context);
            }

            break;
          case 1:
            // close
            break;
        }
        if (!mounted) return;
        if (StateContainer.of(context).introSkiped) {
          // sleep for a few seconds so it doesn't feel too jarring:
          await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
          _introSkippedMessage();
        }
        return;
      }
    }

    if (!mounted) return;

    // show alert that the gift is empty:
    if (shouldShowEmptyDialog) {
      await showDialog<bool>(
          context: context,
          barrierColor: StateContainer.of(context).curTheme.barrier,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                AppLocalization.of(context).giftAlertEmpty,
                style: AppStyles.textStyleDialogHeader(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text("${AppLocalization.of(context).importGiftEmpty}\n\n",
                      style: AppStyles.textStyleParagraph(context)),
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "${AppLocalization.of(context).giftFrom}: ",
                      style: AppStyles.textStyleParagraph(context),
                      children: [
                        TextSpan(
                          text: "${userOrFromAddress!}\n",
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                      ],
                    ),
                  ),
                  if (memo.isNotEmpty)
                    Text(
                      "${AppLocalization.of(context).giftMessage}: $memo\n",
                      style: AppStyles.textStyleParagraph(context),
                    ),
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "${AppLocalization.of(context).giftAmount}: ",
                      style: AppStyles.textStyleParagraph(context),
                      children: [
                        TextSpan(
                          text: getThemeAwareRawAccuracy(context, amountRaw),
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                        displayCurrencySymbol(
                          context,
                          AppStyles.textStyleParagraphPrimary(context),
                        ),
                        TextSpan(
                          text: supposedAmount,
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                AppSimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppLocalization.of(context).ok,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  ),
                )
              ],
            );
          });
    }
    if (!mounted) return;
    if (StateContainer.of(context).introSkiped) {
      // sleep for a few seconds so it doesn't feel too jarring:
      await Future<dynamic>.delayed(const Duration(milliseconds: 4000));
      _introSkippedMessage();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    WidgetsBinding.instance.addObserver(this);
    // _addSampleContact();
    _updateUsers();
    // _updateTXData();
    // infinite scroll:
    _scrollController = ScrollController()..addListener(_scrollListener);
    _xmrScrollController = ScrollController() /*..addListener(_scrollListener)*/;
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      final String mode = _tabController.index == 0 ? "nano" : "monero";
      EventTaxiImpl.singleton().fire(XMREvent(type: "mode_change", message: mode));
      if (_tabController.index == 0) {
        if (!_receiveDisabled) {
          if (StateContainer.of(context).wallet?.address == null ||
              StateContainer.of(context).wallet!.address!.isEmpty) {
            setState(() {
              _receiveDisabled = true;
            });
          }
        } else {
          if (StateContainer.of(context).wallet?.address != null &&
              StateContainer.of(context).wallet!.address!.isNotEmpty) {
            setState(() {
              _receiveDisabled = false;
            });
          }
        }
      } else if (_tabController.index == 1) {
        if (!_receiveDisabled) {
          if (StateContainer.of(context).xmrAddress.isEmpty) {
            setState(() {
              _receiveDisabled = true;
            });
          }
        } else {
          if (StateContainer.of(context).xmrAddress.isNotEmpty) {
            setState(() {
              _receiveDisabled = false;
            });
          }
        }
      }
    });
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController.addListener(_animationControllerListener);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    // setup blank animation controller:
    _emptyAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();

    _moneroListKey = GlobalKey<AnimatedListState>();
    _moneroList = ListModel<dynamic>(listKey: _moneroListKey!);
    // Register handling of push notifications
    // *only triggers when tapped!*:
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        await _chooseCorrectAccountFromNotification(message.data);
        // await _processPaymentRequestNotification(message.data);
      } catch (error) {
        log.e("Error processing push notification: $error");
      }
    });

    // ask to rate the app:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (!mounted) return;
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: AppLocalization.of(context).rateTheApp,
          message: AppLocalization.of(context).rateTheAppDescription,
          rateButton: AppLocalization.of(context).rate,
          noButton: AppLocalization.of(context).noThanks,
          laterButton: AppLocalization.of(context).maybeLater,
          listener: (RateMyAppDialogButton button) {
            // The button click listener (useful if you want to cancel the click event).
            switch (button) {
              case RateMyAppDialogButton.rate:
                break;
              case RateMyAppDialogButton.later:
                break;
              case RateMyAppDialogButton.no:
                break;
            }
            return true; // Return false if you want to cancel the click event.
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(
            dialogShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          ), // Custom dialog styles.
          // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
          // This one allows you to change the default dialog content.
          // contentBuilder: (context, defaultContent) => content,
          // This one allows you to use your own buttons.
          // actionsBuilder: (context) => [],
        );
      }

      // first launch:
      final bool isFirstLaunch = !(await sl.get<SharedPrefsUtil>().getFirstContactAdded());
      if (!mounted) return;

      // Setup notifications
      // skip if we just opened a gift card:
      if (!StateContainer.of(context).introSkiped) {
        await getNotificationPermissions();
      }

      await getTrackingPermissions();

      if (!mounted) return;

      // show changelog?

      // don't show the changelog on first launch:
      if (!StateContainer.of(context).introSkiped && !isFirstLaunch) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String runningVersion = packageInfo.version;
        final String lastVersion = await sl.get<SharedPrefsUtil>().getAppVersion();
        if (runningVersion != lastVersion) {
          await sl.get<SharedPrefsUtil>().setAppVersion(runningVersion);
          if (!mounted) return;
          await AppDialogs.showChangeLog(context);
          if (!mounted) return;

          // also force a username update:
          StateContainer.of(context).checkAndUpdateNanoToUsernames(true);
        }
      }

      // are we not connected after ~5 seconds?
      Future<dynamic>.delayed(const Duration(seconds: 5), () async {
        final bool connected = await sl.get<AccountService>().isConnected();
        if (!connected) {
          showConnectionWarning();
        }
      });

      // listen for nfc tag events:
      listenForNFC();

      // add donations contact:
      _addSampleContact();
    });
    // confetti:
    _confettiControllerLeft = ConfettiController(duration: const Duration(milliseconds: 150));
    _confettiControllerRight = ConfettiController(duration: const Duration(milliseconds: 150));
  }

  Future<void> showConnectionWarning() async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4041,
      active: true,
      title: AppLocalization.of(context).connectionWarning,
      shortDescription: AppLocalization.of(context).connectionWarningBodyShort,
      longDescription: AppLocalization.of(context).connectionWarningBodyLong,
      dismissable: false,
    );
    // ignore the dismissal of the alert, since it's the highest priority:
    StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
    if (StateContainer.of(context).wallet!.loading) {
      setState(() {
        StateContainer.of(context).wallet!.loading = false;
      });
    }
    return;
  }

  Future<void> showNotificationWarning() async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4042,
      active: true,
      title: AppLocalization.of(context).notificationWarning,
      shortDescription: AppLocalization.of(context).notificationWarningBodyShort,
      longDescription: AppLocalization.of(context).notificationWarningBodyLong,
    );
    // don't show if already dismissed:
    // if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
    StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
    // }
    return;
  }

  Future<void> showTrackingWarning() async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4043,
      active: true,
      title: AppLocalization.of(context).trackingWarning,
      shortDescription: AppLocalization.of(context).trackingWarningBodyShort,
      longDescription: AppLocalization.of(context).trackingWarningBodyLong,
      dismissable: true,
    );
    // don't show if already dismissed:
    if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
      StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
    }
    return;
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController.reverse();
        break;
      default:
        return;
    }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _startAnimation() {
    if (_animationDisposed) {
      _animationDisposed = false;
      _placeholderCardAnimationController.addListener(_animationControllerListener);
      _opacityAnimation.addStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.forward();
    }
  }

  void _disposeAnimation() {
    if (!_animationDisposed) {
      _animationDisposed = true;
      _opacityAnimation.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.removeListener(_animationControllerListener);
      _placeholderCardAnimationController.stop();
    }
  }

  Future<void> listenForNFC() async {
    final bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable || Platform.isIOS) {
      return;
    }

    // Start Session
    NfcManager.instance.startSession(
      // alertMessage: "Scan",
      onError: (NfcError error) async {
        log.d("onError: ${error.message}");
      },
      pollingOptions: Set()..add(NfcPollingOption.iso14443),
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
        final Ndef? ndef = Ndef.from(tag);
        if (ndef?.cachedMessage != null && ndef!.cachedMessage!.records.isNotEmpty) {
          Uint8List payload = ndef.cachedMessage!.records[0].payload;

          if (payload.length < 3) {
            return;
          }

          if (payload[0] == 0x00) {
            payload = payload.sublist(1);
            handleDeepLink(utf8.decode(payload));
          } else {
            // try anyways?
            handleDeepLink(utf8.decode(payload));
          }
        }
      },
    );
  }

  // Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    final bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      const String nautilusDonationsNickname = "NautilusDonations";
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      final User donationsContact = User(
          nickname: nautilusDonationsNickname,
          address: "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579",
          // username: "nautilus",
          type: UserTypes.CONTACT);
      await sl.get<DBHelper>().saveContact(donationsContact);
    }
  }

  void _updateUsers() {
    sl.get<DBHelper>().getUsers().then((List<User> users) {
      setState(() {
        _users = users;
      });
    });
  }

  // void _updateTXData() {
  //   sl.get<DBHelper>().getTXData().then((List<TXData> txData) {
  //     setState(() {
  //       _txData = txData;
  //     });
  //   });
  // }

  Future<void> _updateTXDetailsMap(String? account) async {
    final List<TXData> data = await sl.get<DBHelper>().getAccountSpecificTXData(account);
    if (!mounted) return;
    setState(() {
      _txRecords = data;
      _txDetailsMap.clear();
    });
    for (final TXData tx in _txRecords) {
      if (tx.isSolid() && (isEmpty(tx.block) || isEmpty(tx.link))) {
        // set to the last block:
        final String? lastBlockHash = StateContainer.of(context).wallet!.history.isNotEmpty
            ? StateContainer.of(context).wallet!.history[0].hash
            : null;
        if (isEmpty(tx.block) && StateContainer.of(context).wallet!.address == tx.from_address) {
          tx.block = lastBlockHash;
        }
        if (isEmpty(tx.link) && StateContainer.of(context).wallet!.address == tx.to_address) {
          tx.link = lastBlockHash;
        }
        // save to db:
        sl.get<DBHelper>().replaceTXDataByUUID(tx);
      }
      // if unacknowledged, we're the recipient, and not local, ACK it:
      if (tx.is_acknowledged == false &&
          tx.to_address == StateContainer.of(context).wallet!.address &&
          !tx.uuid!.contains("LOCAL")) {
        log.v("ACKNOWLEDGING TX_DATA: ${tx.uuid}");
        tx.is_acknowledged = true;
        sl.get<DBHelper>().replaceTXDataByUUID(tx);
        sl.get<AccountService>().requestACK(tx.uuid, tx.from_address, tx.to_address);
      }
      if (tx.is_memo && isEmpty(tx.link) && isNotEmpty(tx.block)) {
        if (_historyListMap[StateContainer.of(context).wallet!.address] != null) {
          // find if there's a matching link:
          // for (var histItem in StateContainer.of(context).wallet.history) {
          for (final AccountHistoryResponseItem histItem
              in _historyListMap[StateContainer.of(context).wallet!.address]!) {
            if (histItem.link == tx.block) {
              tx.link = histItem.hash;
              // save to db:
              sl.get<DBHelper>().replaceTXDataByUUID(tx);
              break;
            }
          }
        }
      }

      if (tx.record_type == RecordTypes.GIFT_LOAD) {
        if (isNotEmpty(tx.metadata)) {
          bool shouldUpdate = false;
          if (tx.request_time == null) {
            shouldUpdate = true;
          } else if (DateTime.fromMillisecondsSinceEpoch(tx.request_time! * 1000)
              .isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
            shouldUpdate = true;
          }
          if (shouldUpdate) {
            tx.request_time = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
            final String balanceRaw = await getGiftBalance(tx.to_address);

            if (balanceRaw.isNotEmpty) {
              final List<String> metadata = tx.metadata!.split(RecordTypes.SEPARATOR);
              if (metadata.length > 2) {
                metadata[2] = balanceRaw;
              } else if (metadata.length == 2) {
                metadata.add(balanceRaw);
              }
              tx.metadata = metadata.join(RecordTypes.SEPARATOR);
              // save to db:
              sl.get<DBHelper>().replaceTXDataByUUID(tx);
            }
          }
        }
      }

      // only applies to non-solids (i.e. memos / gifts):
      if (!tx.isSolid()) {
        setState(() {
          if (isNotEmpty(tx.block) && tx.from_address == account) {
            _txDetailsMap[tx.block!] = tx;
          } else if (isNotEmpty(tx.link) && tx.to_address == account) {
            _txDetailsMap[tx.link!] = tx;
          }
        });
      }
    }
  }

  StreamSubscription<ConfirmationHeightChangedEvent>? _confirmEventSub;
  StreamSubscription<HistoryHomeEvent>? _historySub;
  StreamSubscription<TXUpdateEvent>? _txUpdatesSub;
  StreamSubscription<PaymentsHomeEvent>? _solidsSub;
  StreamSubscription<UnifiedHomeEvent>? _unifiedSub;
  StreamSubscription<ContactModifiedEvent>? _contactModifiedSub;
  StreamSubscription<BlockedModifiedEvent>? _blockedModifiedSub;
  StreamSubscription<DisableLockTimeoutEvent>? _disableLockSub;
  StreamSubscription<AccountChangedEvent>? _switchAccountSub;
  StreamSubscription<DeepLinkEvent>? _deepLinkEventSub;
  StreamSubscription<XMREvent>? _xmrSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton().registerTo<HistoryHomeEvent>().listen((HistoryHomeEvent event) {
      updateHistoryList(event.items);
      // // update tx memo's
      // if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.address != null) {
      //   _updateTXDetailsMap(StateContainer.of(context).wallet.address);
      // }
      // handle deep links:
      if (StateContainer.of(context).initialDeepLink != null) {
        handleDeepLink(StateContainer.of(context).initialDeepLink);
        StateContainer.of(context).initialDeepLink = null;
      }
    });
    _txUpdatesSub = EventTaxiImpl.singleton().registerTo<TXUpdateEvent>().listen((TXUpdateEvent event) {
      if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.address != null) {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
      }
    });
    _solidsSub = EventTaxiImpl.singleton().registerTo<PaymentsHomeEvent>().listen((PaymentsHomeEvent event) {
      final List<TXData>? newSolids = event.items;
      if (newSolids == null || _solidsListMap[StateContainer.of(context).wallet!.address] == null) {
        return;
      }
      setState(() {
        _solidsListMap[StateContainer.of(context).wallet!.address!] = newSolids;
      });
    });
    _unifiedSub = EventTaxiImpl.singleton().registerTo<UnifiedHomeEvent>().listen((UnifiedHomeEvent event) {
      if (_isRefreshing) {
        setState(() {
          _isRefreshing = false;
        });
      }
      generateUnifiedList(fastUpdate: event.fastUpdate);
    });
    _contactModifiedSub =
        EventTaxiImpl.singleton().registerTo<ContactModifiedEvent>().listen((ContactModifiedEvent event) {
      setState(() {
        _updateUsers();
      });
    });
    // _blockedModifiedSub = EventTaxiImpl.singleton().registerTo<BlockedModifiedEvent>().listen((BlockedModifiedEvent event) {
    //   _updateBlocked();
    // });
    // Hackish event to block auto-lock functionality
    _disableLockSub =
        EventTaxiImpl.singleton().registerTo<DisableLockTimeoutEvent>().listen((DisableLockTimeoutEvent event) {
      if (event.disable!) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable!;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton().registerTo<AccountChangedEvent>().listen((AccountChangedEvent event) {
      setState(() {
        _maxHistItems = 20; // reset max history items
        _startAnimation();
        StateContainer.of(context).wallet!.loading = true;
        StateContainer.of(context).updateWallet(account: event.account!);
        currentConfHeight = -1;
      });
      if (event.delayPop) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
    // Handle subscribe
    _confirmEventSub = EventTaxiImpl.singleton()
        .registerTo<ConfirmationHeightChangedEvent>()
        .listen((ConfirmationHeightChangedEvent event) {
      updateConfirmationHeights(event.confirmationHeight);
    });
    // deep link scan:
    _deepLinkEventSub = EventTaxiImpl.singleton().registerTo<DeepLinkEvent>().listen((DeepLinkEvent event) {
      handleDeepLink(event.link);
    });
    // xmr:
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "update_transfers") {
        final List<dynamic> transfers = jsonDecode(event.message) as List<dynamic>;
        _moneroHistoryList = transfers;
      }
      // if (event.type == "update_txs") {
      //   final List<dynamic> txs = jsonDecode(event.message) as List<dynamic>;
      //   for (var tx in txs) {
      //     print(tx);
      //   }
      //   _moneroHistoryList = txs;
      // }
      if (event.type == "update_status") {
        if (event.message == "ready") {
          setState(() {
            StateContainer.of(context).wallet!.xmrLoading = false;
          });
        }
      } else if (event.type == "update_progress") {
        if (event.message == "1") {
          setState(() {
            StateContainer.of(context).wallet!.xmrLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _xmrScrollController.dispose();
    _tabController.dispose();
    _placeholderCardAnimationController.dispose();
    // confetti:
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();

    NfcManager.instance.stopSession();

    super.dispose();
  }

  void _destroyBus() {
    if (_historySub != null) {
      _historySub!.cancel();
    }
    if (_contactModifiedSub != null) {
      _contactModifiedSub!.cancel();
    }
    if (_blockedModifiedSub != null) {
      _blockedModifiedSub!.cancel();
    }
    if (_disableLockSub != null) {
      _disableLockSub!.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub!.cancel();
    }
    if (_confirmEventSub != null) {
      _confirmEventSub!.cancel();
    }
    if (_txUpdatesSub != null) {
      _txUpdatesSub!.cancel();
    }
    if (_solidsSub != null) {
      _solidsSub!.cancel();
    }
    if (_unifiedSub != null) {
      _unifiedSub!.cancel();
    }
    if (_xmrSub != null) {
      _xmrSub!.cancel();
    }
  }

  // TODO: this is honestly a terrible system, but it works really well:
  void _scrollListener() {
    // print("aaaa");
    if ((_historyListMap[StateContainer.of(context).wallet!.address]?.isEmpty ?? true) ||
        (StateContainer.of(context).wallet?.loading ?? true)) {
      return;
    }
    if (!_listExtended && _scrollController.position.extentAfter < 5) {
      if (_trueMaxHistItems >= _maxHistItems) {
        setState(() {
          _listExtended = true;
          _lastExtentPixels = _scrollController.position.pixels;
          _maxHistItems += 2;
          generateUnifiedList(fastUpdate: true);
        });
      }
    }
    if (_listExtended && (_scrollController.position.extentAfter > 10 || _scrollController.position.extentAfter < 2)) {
      setState(() {
        _listExtended = false;
        _lastExtentPixels = _scrollController.position.pixels;
      });
    }
  }

  int currentConfHeight = -1;

  void updateConfirmationHeights(int? confirmationHeight) {
    setState(() {
      currentConfHeight = confirmationHeight! + 1;
    });
    if (!_historyListMap.containsKey(StateContainer.of(context).wallet!.address)) {
      return;
    }
    final List<int> unconfirmedUpdate = [];
    final List<int> confirmedUpdate = [];
    for (int i = 0; i < _historyListMap[StateContainer.of(context).wallet!.address]!.length; i++) {
      if ((_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed == null ||
              _historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed!) &&
          _historyListMap[StateContainer.of(context).wallet!.address]![i].height != null &&
          confirmationHeight! < _historyListMap[StateContainer.of(context).wallet!.address]![i].height!) {
        unconfirmedUpdate.add(i);
      } else if ((_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed == null ||
              !_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed!) &&
          _historyListMap[StateContainer.of(context).wallet!.address]![i].height != null &&
          confirmationHeight! >= _historyListMap[StateContainer.of(context).wallet!.address]![i].height!) {
        confirmedUpdate.add(i);
      }
    }
    setState(() {
      for (final int index in unconfirmedUpdate) {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = false;
      }
      for (final int index in confirmedUpdate) {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = true;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        setAppLockEvent();
        StateContainer.of(context).disconnect();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        cancelLockEvent();
        StateContainer.of(context).reconnect();
        // handle deep links:
        if (/*!StateContainer.of(context).wallet!.loading && */ StateContainer.of(context).initialDeepLink != null &&
            !_lockTriggered) {
          handleDeepLink(StateContainer.of(context).initialDeepLink);
          StateContainer.of(context).initialDeepLink = null;
        }
        // branch gift:
        if (StateContainer.of(context).gift != null && !_lockTriggered) {
          handleBranchGift(StateContainer.of(context).gift);
          StateContainer.of(context).resetGift();
        }
        // handle pending background events:
        if (!StateContainer.of(context).wallet!.loading && !_lockTriggered) {
          handleReceivableBackgroundMessages();
        }

        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  StreamSubscription<dynamic>? lockStreamListener;

  Future<void> setAppLockEvent() async {
    if (((await sl.get<SharedPrefsUtil>().getLock()) || StateContainer.of(context).encryptedSecret != null) &&
        !_lockDisabled) {
      if (lockStreamListener != null) {
        lockStreamListener!.cancel();
      }
      final Future<dynamic> delayed = Future.delayed((await sl.get<SharedPrefsUtil>().getLockTimeout()).getDuration());
      delayed.then((_) {
        return true;
      });
      lockStreamListener = delayed.asStream().listen((_) {
        try {
          StateContainer.of(context).resetEncryptedSecret();
        } catch (e) {
          log.w("Failed to reset encrypted secret when locking ${e.toString()}");
        } finally {
          _lockTriggered = true;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      });
    }
  }

  Future<void> cancelLockEvent() async {
    if (lockStreamListener != null) {
      lockStreamListener!.cancel();
    }
  }

  Future<void> _refresh() async {
    // start refresh
    setState(() {
      _isRefreshing = true;
    });
    sl.get<HapticUtil>().success();
    // Hide refresh indicator after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
    if (_tabController.index == 0) {
      await StateContainer.of(context).requestUpdate();
      if (!mounted) return;
      // queries the db for account specific solids:
      await StateContainer.of(context).updateSolids();
      // _updateTXData();

      if (!mounted) return;
      // for memos:
      await _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
    } else {
      EventTaxiImpl.singleton().fire(XMREvent(type: "xmr_reload"));
      EventTaxiImpl.singleton().fire(XMREvent(type: "update_status", message: "loading"));
      setState(() {
        StateContainer.of(context).wallet!.xmrLoading = true;
      });
    }

    // are we not connected after ~5 seconds?
    await Future<dynamic>.delayed(const Duration(seconds: 8));
    final bool connected = await sl.get<AccountService>().isConnected();
    if (!connected) {
      showConnectionWarning();
    }
    // await generateUnifiedList(fastUpdate: false);
    // setState(() {});
  }

  ///
  /// Because there's nothing convenient like DiffUtil, some manual logic
  /// to determine the differences between two lists and to add new items.
  ///
  /// Depends on == being overriden in the AccountHistoryResponseItem class
  ///
  /// Required to do it this way for the animation
  ///
  void updateHistoryList(List<AccountHistoryResponseItem>? newList) {
    if (newList == null || newList.isEmpty || _historyListMap[StateContainer.of(context).wallet!.address] == null) {
      return;
    }

    _historyListMap[StateContainer.of(context).wallet!.address!] = newList;

    // Re-subscribe if missing data
    if (StateContainer.of(context).wallet!.loading) {
      StateContainer.of(context).requestSubscribe();
    } else {
      updateConfirmationHeights(StateContainer.of(context).wallet!.confirmationHeight);
    }
  }

  /// Desired relation | Result
  /// -------------------------------------------
  ///           a < b  | Returns a negative value.
  ///           a == b | Returns 0.
  ///           a > b  | Returns a positive value.
  ///
  int defaultSortComparison(dynamic a, dynamic b) {
    final int propertyA = a.height as int? ?? 0;
    final int propertyB = b.height as int? ?? 0;

    // both are AccountHistoryResponseItems:
    if (a is AccountHistoryResponseItem && b is AccountHistoryResponseItem) {
      if (propertyA < propertyB) {
        return 1;
      } else if (propertyA > propertyB) {
        return -1;
      } else {
        return 0;
      }
      // if both are TXData, sort by request time:
    } else if (a is TXData && b is TXData) {
      int aTime;
      int bTime;
      try {
        aTime = a.request_time!;
      } catch (e) {
        aTime = 0;
      }
      try {
        bTime = b.request_time!;
      } catch (e) {
        bTime = 0;
      }

      if (aTime < bTime) {
        return 1;
      } else if (aTime > bTime) {
        return -1;
      } else {
        return 0;
      }
    }

    if (propertyA < propertyB) {
      return 1;
    } else if (propertyA > propertyB) {
      return -1;
    } else if (propertyA == propertyB) {
      // ensure the request shows up lower in the list?:
      if (a is TXData && b is AccountHistoryResponseItem) {
        return 1;
      } else if (a is AccountHistoryResponseItem && b is TXData) {
        return -1;
      } else {
        return 0;
      }
    }
    return 0;
  }

  int amountSortComparison(dynamic a, dynamic b) {
    final String propertyA = a?.amount as String? ?? a?.amount_raw as String? ?? "";
    final String propertyB = b?.amount as String? ?? b?.amount_raw as String? ?? "";
    if (propertyA == "" || propertyB == "") {
      // messages don't have amounts:
      return 0;
    }

    final BigInt numA = BigInt.parse(propertyA);
    final BigInt numB = BigInt.parse(propertyB);
    if (numA < numB) {
      return 1;
    } else if (numA > numB) {
      return -1;
    } else if (numA == numB) {
      return 0;
    }

    return 0;
  }

  // void renderQueueOld() {
  // if (!overrideRenderQueue) {
  //   // check the render queue:
  //   if (_renderQueue.length > 0) {
  //     // push to the renderQueue and return:
  //     setState(() {
  //       _renderQueue.add(fastUpdate);
  //     });
  //     return;
  //   }
  //   // push to the render queue, we're the first to render:
  //   setState(() {
  //     _renderQueue.add(fastUpdate);
  //   });
  // }

  //     // done with this render, see if there's another in the queue:
  // if (_renderQueue.length > 0) {
  //   // if this was a slow render then the next must be after at least 2.5 seconds:
  //   // if this was a fast render then the next must be after at least 0.5 seconds
  //   Duration timeBetweenRenders = fastUpdate ? RENDER_QUEUE_SHORT : RENDER_QUEUE_LONG;
  //   print("START");
  //   Timer(const Duration(seconds: 10), () async {
  //     print("END");
  //     if (mounted) {
  //       // we just rendered so pop the last element of the list:
  //       setState(() {
  //         _renderQueue.removeLast();
  //       });
  //       if (_renderQueue.isNotEmpty) {
  //         generateUnifiedList(fastUpdate: _renderQueue.last, overrideRenderQueue: true);
  //       }
  //     }
  //   });
  // }
  // }

  Future<void> generateMoneroList({bool fastUpdate = false}) async {
    ListModel<dynamic>? ULM = _moneroList;
    // if (StateContainer.of(context).activeAlert != null) {
    //   ULM = _unifiedListMap["${StateContainer.of(context).wallet!.address}alert"];
    // }
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ULM = _moneroList; // todo: use the alert list
    }

    if (_moneroHistoryList == null || ULM == null) {
      return;
    }

    if (ULM.length > 0) {
      log.d("generating unified list! fastUpdate: $fastUpdate");
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];
    List<int> removeIndices = [];

    // combine history and payments:
    // List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet!.history!;
    // List<TXData> solidsList = StateContainer.of(context).wallet!.solids!;
    // final List<AccountHistoryResponseItem> historyList = _historyListMap[StateContainer.of(context).wallet!.address]!;
    // final List<TXData> solidsList = _solidsListMap[StateContainer.of(context).wallet!.address]!;

    // for (var tx in solidsList) {
    //   print("memo: ${tx.memo} is_request: ${tx.is_request}");
    // }

    // add tx's to the unified list:
    // unifiedList.addAll(historyList);
    // unifiedList.addAll(solidsList);
    // don't process change or openblocks:
    // unifiedList =
    //     List<dynamic>.from(historyList.where((AccountHistoryResponseItem element) => ![BlockTypes.CHANGE, BlockTypes.OPEN].contains(element.subtype)).toList());

    unifiedList = _moneroHistoryList;

    if (!mounted) return;

    bool overrideSort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      final String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search is numeric:
      overrideSort = double.tryParse(lowerCaseSearch) != null;

      for (final dynamic dynamicItem in unifiedList) {
        bool shouldRemove = true;

        if (dynamicItem is SizedBox) continue;

        final TXData txDetails = dynamicItem is TXData
            ? dynamicItem
            : convertHistItemToTXData(dynamicItem as AccountHistoryResponseItem,
                txDetails: _txDetailsMap[dynamicItem.hash]);
        final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
        final String account = txDetails.getAccount(isRecipient);
        String displayName = Address(account).getShortestString() ?? "";

        // check if there's a username:
        for (final User user in _users) {
          if (user.address == account.replaceAll("xrb_", "nano_")) {
            displayName = user.getDisplayName()!;
            break;
          }
        }

        String? amountStr;
        int? localTimestamp;

        if (txDetails.request_time != null) {
          localTimestamp = txDetails.request_time;
        }

        if (txDetails.amount_raw != null && txDetails.amount_raw!.isNotEmpty) {
          amountStr = getRawAsThemeAwareAmount(context, txDetails.amount_raw);
          if (txDetails.is_request) {
            if (isRecipient) {
              if (AppLocalization.of(context).request.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            } else {
              if (AppLocalization.of(context).asked.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            }
          }
        }

        if (txDetails.is_tx) {
          if (txDetails.sub_type == BlockTypes.SEND) {
            if (AppLocalization.of(context).sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (txDetails.sub_type == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context).received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (localTimestamp != null) {
          final String timeStr = getTimeAgoString(context, localTimestamp);
          if (timeStr.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (amountStr != null && amountStr.contains(lowerCaseSearch)) {
          shouldRemove = false;
        }
        if (isNotEmpty(txDetails.memo)) {
          if (txDetails.memo!.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          if (AppLocalization.of(context).loaded.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (isNotEmpty(displayName)) {
          if (displayName.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        } else if (account.toLowerCase().contains(lowerCaseSearch)) {
          shouldRemove = false;
        }

        if (shouldRemove) {
          removeIndices.add(unifiedList.indexOf(dynamicItem));
        }
      }

      for (int i = removeIndices.length - 1; i >= 0; i--) {
        unifiedList.removeAt(removeIndices[i]);
      }
    }

    // sort by timestamp
    // should already be sorted but:
    // needed to sort payment requests by request time from each other:
    // if (!overrideSort) {
    //   unifiedList.sort(defaultSortComparison);
    // } else {
    //   unifiedList.sort(amountSortComparison);
    // }

    final bool areThereNoSearchResults = unifiedList.isEmpty && _searchController.text.isNotEmpty;

    if (areThereNoSearchResults) {
      unifiedList.add(const SizedBox());
    }

    if (areThereNoSearchResults != _noSearchResults) {
      setState(() {
        _noSearchResults = areThereNoSearchResults;
      });
    }

    // create a list of indices to remove:
    removeIndices = [];

    // remove anything that's not supposed to be there anymore:
    ULM.items.where((dynamic item) => !unifiedList.contains(item)).forEach((dynamic dynamicItem) {
      removeIndices.add(ULM!.items.indexOf(dynamicItem));
    });
    // mark anything out of place or not in the unified list as to be removed:
    if (_searchController.text.isNotEmpty) {
      ULM.items.where((item) => ULM!.items.indexOf(item) != (unifiedList.indexOf(item))).forEach((dynamic dynamicItem) {
        removeIndices.add(ULM!.items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent an index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((int a, int b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      ULM.removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // insert unifiedList into listmap:
    unifiedList.where((dynamic item) => !ULM!.items.contains(item)).forEach((dynamic dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) {
        return;
      }
      index = max(min(index, ULM!.length), 0);
      setState(() {
        ULM!.insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    // if (StateContainer.of(context).wallet!.xmrLoading) {
    //   setState(() {
    //     // _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
    //     StateContainer.of(context).wallet!.xmrLoading = false;
    //   });
    // }
  }

  Future<void> generateUnifiedList({bool fastUpdate = false}) async {
    ListModel<dynamic>? ULM = _unifiedListMap[StateContainer.of(context).wallet!.address];

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ULM = _unifiedListMap["${StateContainer.of(context).wallet!.address}alert"];
    }

    if (_historyListMap[StateContainer.of(context).wallet!.address] == null ||
        _solidsListMap[StateContainer.of(context).wallet!.address] == null ||
        ULM == null) {
      return;
    }

    if (ULM.length > 0) {
      // log.d("generating unified list! fastUpdate: $fastUpdate");
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];
    List<int> removeIndices = [];

    // combine history and payments:
    // List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet!.history!;
    // List<TXData> solidsList = StateContainer.of(context).wallet!.solids!;
    final List<AccountHistoryResponseItem> historyList = _historyListMap[StateContainer.of(context).wallet!.address]!;
    final List<TXData> solidsList = _solidsListMap[StateContainer.of(context).wallet!.address]!;

    // for (var tx in solidsList) {
    //   print("memo: ${tx.memo} is_request: ${tx.is_request}");
    // }

    // add tx's to the unified list:
    // unifiedList.addAll(historyList);
    // unifiedList.addAll(solidsList);
    // don't process change or openblocks:
    unifiedList = List<dynamic>.from(historyList
        .where((AccountHistoryResponseItem element) => ![BlockTypes.CHANGE, BlockTypes.OPEN].contains(element.subtype))
        .toList());
    // only work with the first _maxHistItems:
    _trueMaxHistItems = unifiedList.length;
    unifiedList = unifiedList.sublist(0, min(unifiedList.length, _maxHistItems));

    final Set<String?> uuids = {};
    final List<int?> idsToRemove = [];
    for (final TXData req in solidsList) {
      if (!uuids.contains(req.uuid)) {
        uuids.add(req.uuid);
      } else {
        log.d("detected duplicate TXData2! removing...");
        idsToRemove.add(req.id);
        await sl.get<DBHelper>().deleteTXDataByID(req.id);
        if (!mounted) return;
      }
    }
    for (final int? id in idsToRemove) {
      solidsList.removeWhere((TXData element) => element.id == id);
    }

    if (!mounted) return;

    // go through each item in the solidsList and insert it into the unifiedList at the matching block:
    for (int i = 0; i < solidsList.length; i++) {
      int? index;
      int? height;

      // if the block is null, give it one:
      if (solidsList[i].block == null) {
        final String? lastBlockHash = StateContainer.of(context).wallet!.history.isNotEmpty
            ? StateContainer.of(context).wallet!.history[0].hash
            : null;
        solidsList[i].block = lastBlockHash;
        await sl.get<DBHelper>().replaceTXDataByUUID(solidsList[i]);
      }
      if (!mounted) return;

      // find the index of the item in the unifiedList:
      for (int j = 0; j < unifiedList.length; j++) {
        // skip already inserted items:
        if (unifiedList[j] is TXData) {
          continue;
        }
        // remove from the list if it's a change block:
        // just in case:
        if ([BlockTypes.CHANGE, BlockTypes.OPEN].contains(unifiedList[j].subtype)) {
          unifiedList.removeAt(j);
          j--;
          continue;
        }
        final String histItemHash = unifiedList[j].hash as String;

        if (histItemHash == solidsList[i].block || histItemHash == solidsList[i].link) {
          index = j;
          height = unifiedList[j].height + 1 as int;
          break;
        }
      }

      // found an index to insert at:
      if (index != null) {
        solidsList[i].height = height;
        unifiedList.insert(index, solidsList[i]);
      } else {
        // throw Exception("Couldn't find index to insert Solid at!");
        // just insert at the top?
        // TODO: not necessarily the best way to handle this, should get real height:
        // wallet!.confirmationHeight += 1;
        solidsList[i].height = StateContainer.of(context).wallet!.confirmationHeight + 1;
        unifiedList.insert(0, solidsList[i]);
      }
    }

    if (!mounted) return;

    bool overrideSort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      final String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search is numeric:
      overrideSort = double.tryParse(lowerCaseSearch) != null;

      for (final dynamicItem in unifiedList) {
        bool shouldRemove = true;

        final TXData txDetails = dynamicItem is TXData
            ? dynamicItem
            : convertHistItemToTXData(dynamicItem as AccountHistoryResponseItem,
                txDetails: _txDetailsMap[dynamicItem.hash]);
        final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
        final String account = txDetails.getAccount(isRecipient);

        String displayName = Address(account).getShortestString() ?? "";

        // check if there's a username:
        for (final User user in _users) {
          if (user.address == account.replaceAll("xrb_", "nano_")) {
            displayName = user.getDisplayName()!;
            break;
          }
        }

        String? amountStr;
        int? localTimestamp;

        if (txDetails.request_time != null) {
          localTimestamp = txDetails.request_time;
        }

        if (txDetails.amount_raw != null && txDetails.amount_raw!.isNotEmpty) {
          amountStr = getRawAsThemeAwareAmount(context, txDetails.amount_raw);
          if (txDetails.is_request) {
            if (isRecipient) {
              if (AppLocalization.of(context).request.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            } else {
              if (AppLocalization.of(context).asked.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            }
          }
        }

        if (txDetails.is_tx) {
          if (txDetails.sub_type == BlockTypes.SEND) {
            if (AppLocalization.of(context).sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (txDetails.sub_type == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context).received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (localTimestamp != null) {
          final String timeStr = getTimeAgoString(context, localTimestamp);
          if (timeStr.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (amountStr != null && amountStr.contains(lowerCaseSearch)) {
          shouldRemove = false;
        }
        if (isNotEmpty(txDetails.memo)) {
          if (txDetails.memo!.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          if (AppLocalization.of(context).loaded.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (isNotEmpty(displayName)) {
          if (displayName.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        } else if (account.toLowerCase().contains(lowerCaseSearch)) {
          shouldRemove = false;
        }

        if (shouldRemove) {
          removeIndices.add(unifiedList.indexOf(dynamicItem));
        }
      }

      for (int i = removeIndices.length - 1; i >= 0; i--) {
        unifiedList.removeAt(removeIndices[i]);
      }
    }

    // sort by timestamp
    // should already be sorted but:
    // needed to sort payment requests by request time from each other:
    if (!overrideSort) {
      unifiedList.sort(defaultSortComparison);
    } else {
      unifiedList.sort(amountSortComparison);
    }

    final bool areThereNoSearchResults = unifiedList.isEmpty && _searchController.text.isNotEmpty;

    if (areThereNoSearchResults) {
      unifiedList.add(const SizedBox());
    }

    if (areThereNoSearchResults != _noSearchResults) {
      setState(() {
        _noSearchResults = areThereNoSearchResults;
      });
    }

    // create a list of indices to remove:
    removeIndices = [];

    // remove anything that's not supposed to be there anymore:
    ULM.items.where((dynamic item) => !unifiedList.contains(item)).forEach((dynamic dynamicItem) {
      removeIndices.add(ULM!.items.indexOf(dynamicItem));
    });
    // mark anything out of place or not in the unified list as to be removed:
    if (_searchController.text.isNotEmpty) {
      ULM.items.where((item) => ULM!.items.indexOf(item) != (unifiedList.indexOf(item))).forEach((dynamic dynamicItem) {
        removeIndices.add(ULM!.items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent an index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((int a, int b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      ULM.removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // insert unifiedList into listmap:
    unifiedList.where((dynamic item) => !ULM!.items.contains(item)).forEach((dynamic dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) {
        return;
      }
      index = max(min(index, ULM!.length), 0);
      setState(() {
        ULM!.insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    if (StateContainer.of(context).wallet!.unifiedLoading) {
      setState(() {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
        StateContainer.of(context).wallet!.unifiedLoading = false;
      });
    }
  }

  Future<void> handleDeepLink(String? link) async {
    log.d("handling deep link: $link");
    if (link == null || link.isEmpty) {
      return;
    }

    if (link.contains("confetti")) {
      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      await Future<dynamic>.delayed(const Duration(milliseconds: 150));
      _confettiControllerLeft.play();
      _confettiControllerRight.play();
      setState(() {});
    }

    if (!mounted) return;

    final dynamic result = uriParser(link);

    if (result == null) {
      return;
    }

    if (result is Address && result.isValid()) {
      final Address address = result;
      String? amount;
      bool sufficientBalance = false;
      if (address.amount != null) {
        final BigInt? amountBigInt = BigInt.tryParse(address.amount!);
        // Require minimum 1 raw to send, and make sure sufficient balance
        if (amountBigInt != null && amountBigInt >= BigInt.from(10).pow(24)) {
          if (StateContainer.of(context).wallet!.accountBalance > amountBigInt) {
            sufficientBalance = true;
          }
          amount = address.amount;
        }
      }
      // See if a contact
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address!);
      // Remove any other screens from stack
      if (!mounted) return;
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (amount != null && sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: amount, destination: address.address!, contactName: user?.getDisplayName()));
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context).curCurrency,
                user: user,
                address: address.address,
                quickSendAmount: amount));
      }
    } else if (result is HandoffItem) {
      // handle block handoff:
      final HandoffItem handoffItem = result;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(handoffItem.account);

      // check if the user has enough balance to send this amount:
      // If balance is insufficient show error:
      final BigInt? amountBigInt = BigInt.tryParse(handoffItem.amount);
      if (amountBigInt != null && amountBigInt < BigInt.from(10).pow(24) && mounted) {
        UIUtil.showSnackbar(
            AppLocalization.of(context)
                .minimumSend
                .replaceAll("%1", "0.000001")
                .replaceAll("%2", StateContainer.of(context).currencyMode),
            context);
        return;
      } else if (StateContainer.of(context).wallet!.accountBalance < amountBigInt!) {
        UIUtil.showSnackbar(AppLocalization.of(context).insufficientBalance, context);
        return;
      }

      // if handoffItem.exact is false, we should allow the user to change the amount to send to >= amount
      if (!handoffItem.exact && mounted) {
        // TODO:
        log.d("HandoffItem exact is false: unsupported handoff flow!");
        return;
      }

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: HandoffConfirmSheet(
            handoffItem: handoffItem,
            destination: user?.address ?? handoffItem.account,
            contactName: user?.getDisplayName(),
          ));
    } else if (result is AuthItem) {
      // handle auth handoff:
      final AuthItem authItem = result;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(authItem.account);

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
        context: context,
        widget: AuthConfirmSheet(
          authItem: authItem,
          destination: user?.address ?? authItem.account,
          contactName: user?.getDisplayName(),
        ),
      );
    }
  }

  // handle receivable messages
  Future<void> handleReceivableBackgroundMessages() async {
    if (StateContainer.of(context).wallet != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final List<String>? backgroundMessages = prefs.getStringList("background_messages");
      // process the message now that we're in the foreground:

      if (backgroundMessages != null) {
        // EventTaxiImpl.singleton().fire(FcmMessageEvent(message_list: backgroundMessages));
        await StateContainer.of(context).handleStoredMessages(FcmMessageEvent(message_list: backgroundMessages));
        // clear the storage since we just processed it:
        await prefs.remove("background_messages");
      }
    }
  }

  Widget _buildListGradients(bool top) {
    if (top) {
      return // list gradients:
          Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 10.0,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StateContainer.of(context).curTheme.background00!,
                StateContainer.of(context).curTheme.background!
              ],
              begin: const AlignmentDirectional(0.5, 1.0),
              end: const AlignmentDirectional(0.5, -1.0),
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 20.0,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                StateContainer.of(context).curTheme.background00!,
                StateContainer.of(context).curTheme.background!
              ],
              begin: const AlignmentDirectional(0.5, -1),
              end: const AlignmentDirectional(0.5, 0.5),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMainColumnView(BuildContext context) {
    if (_tabController.index == 0 && _receiveDisabled) {
      if (StateContainer.of(context).wallet?.address != null &&
          StateContainer.of(context).wallet!.address!.isNotEmpty) {
        setState(() {
          _receiveDisabled = false;
        });
      }
    } else if (_tabController.index == 1 && _receiveDisabled) {
      if (StateContainer.of(context).xmrAddress.isNotEmpty) {
        setState(() {
          _receiveDisabled = false;
        });
      }
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  TopCard(
                    scaffoldKey: _scaffoldKey,
                    opacityAnimation: _opacityAnimation,
                    child: _buildSearchbarAnimation(),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                  ),
                  if (StateContainer.of(context).xmrEnabled)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        controller: _tabController,
                        indicatorWeight: 3,
                        indicatorColor: StateContainer.of(context).curTheme.primary,
                        indicatorPadding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        tabs: <Widget>[
                          Tab(
                            child: Container(
                              margin: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Text(
                                NonTranslatable.nano,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyleTransactionWelcome(context),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              margin: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Text(
                                NonTranslatable.monero,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyleTransactionWelcome(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: (StateContainer.of(context).xmrEnabled)
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              Stack(
                                children: <Widget>[
                                  _getUnifiedListWidget(context),
                                  // list gradients:
                                  _buildListGradients(true),
                                  _buildListGradients(false),
                                ],
                              ),
                              Stack(
                                children: <Widget>[
                                  _getMoneroListWidget(context),
                                  const CustomMonero(),
                                  // TextButton(
                                  //   onPressed: () async {
                                  //     Sheets.showAppHeightEightSheet(context: context, widget: SetRestoreHeightSheet());
                                  //   },
                                  //   child: Text(
                                  //     "Set Restore Height/local",
                                  //     textAlign: TextAlign.center,
                                  //     style: AppStyles.textStyleButtonPrimary(context),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          )
                        : Stack(
                            children: <Widget>[
                              _getUnifiedListWidget(context),
                              // list gradients:
                              _buildListGradients(true),
                              _buildListGradients(false),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),

              // Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS),
                      boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
                    ),
                    height: 55,
                    width: (UIUtil.getDrawerAwareScreenWidth(context) - 42).abs() / 2,
                    margin: const EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                    // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                    child: TextButton(
                      key: const Key("home_receive_button"),
                      style: TextButton.styleFrom(
                        backgroundColor: !_receiveDisabled
                            ? StateContainer.of(context).curTheme.primary
                            : StateContainer.of(context).curTheme.primary60,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                        foregroundColor:
                            !_receiveDisabled ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                        // highlightColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                        // splashColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                      ),
                      child: AutoSizeText(
                        AppLocalization.of(context).receive,
                        textAlign: TextAlign.center,
                        style: AppStyles.textStyleButtonPrimary(context),
                        maxLines: 1,
                        stepGranularity: 0.5,
                      ),
                      onPressed: () async {
                        if (_receiveDisabled) {
                          return;
                        }

                        if (_tabController.index == 0) {
                          final String data = "nano:${StateContainer.of(context).wallet!.address}";
                          final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, data),
                          );
                          if (!mounted) return;
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: ReceiveSheet(
                                localCurrency: StateContainer.of(context).curCurrency,
                                address: StateContainer.of(context).wallet!.address,
                                qrWidget: qrWidget,
                              ));
                        } else {
                          final String data = "monero:${StateContainer.of(context).xmrAddress}";
                          final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, data),
                          );
                          if (!mounted) return;
                          Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: ReceiveXMRSheet(
                              address: StateContainer.of(context).xmrAddress,
                              qrWidget: qrWidget,
                              localCurrency: StateContainer.of(context).curCurrency,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  AppPopupButton(moneroEnabled: _tabController.index == 1),
                ],
              ),

              // confetti: LEFT
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  blastDirectionality: BlastDirectionality.explosive,
                  confettiController: _confettiControllerLeft,
                  blastDirection: -pi / 3,
                  emissionFrequency: 0.02,
                  // numberOfParticles: 30,
                  numberOfParticles: 40,
                  maxBlastForce: 60,
                  minBlastForce: 10,
                  // strokeWidth: 1,
                  gravity: 0.3,
                ),
              ),
              // confetti: RIGHT
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  blastDirectionality: BlastDirectionality.explosive,
                  confettiController: _confettiControllerRight,
                  blastDirection: -2 * pi / 3,
                  emissionFrequency: 0.02,
                  // numberOfParticles: 30,
                  numberOfParticles: 40,
                  maxBlastForce: 60,
                  minBlastForce: 10,
                  gravity: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // handle branch gift if it exists:
    if (StateContainer.of(context).gift != null) {
      handleBranchGift(StateContainer.of(context).gift);
      StateContainer.of(context).resetGift();
    }

    if (!UIUtil.isTablet(context)) {
      return Scaffold(
        drawerEdgeDragWidth: 180,
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: StateContainer.of(context).curTheme.background,
        drawerScrimColor: StateContainer.of(context).curTheme.barrierWeaker,
        drawer: SizedBox(
          width: UIUtil.drawerWidth(context),
          child: Drawer(
            child: SettingsSheet(),
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.045, bottom: MediaQuery.of(context).size.height * 0.035),
          child: _buildMainColumnView(context),
        ),
      );
    }
    /* TABLET MODE */
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.background,
      body: SafeArea(
        minimum: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.045, /*bottom: MediaQuery.of(context).size.height * 0.035*/
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: UIUtil.drawerWidth(context),
              child: Drawer(
                child: SettingsSheet(),
              ),
            ),
            Container(
              width: UIUtil.getDrawerAwareScreenWidth(context),
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
              child: _buildMainColumnView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteMessageCard(AlertResponseItem? alert) {
    if (alert == null) {
      return const SizedBox();
    }
    if (alert.id == 4040) {
      alert.title = AppLocalization.of(context).branchConnectErrorTitle;
      alert.shortDescription = AppLocalization.of(context).branchConnectErrorShortDesc;
      alert.longDescription = AppLocalization.of(context).branchConnectErrorLongDesc;
      // alert.dismissable = false;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
      child: RemoteMessageCard(
        alert: alert,
        onPressed: () {
          Sheets.showAppHeightEightSheet(
            context: context,
            widget: RemoteMessageSheet(
              alert: alert,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSearchResultsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: AppLocalization.of(context).noSearchResults,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Dummy Transaction Card
  Widget _buildDummyTXCard(BuildContext context,
      {required bool is_recipient,
      String? memo,
      String? amount_raw,
      String? displayName,
      bool? is_tx,
      bool? is_message,
      bool? is_memo,
      bool? is_request,
      bool is_acknowledged = true,
      bool is_fulfilled = true,
      int timestamp = 0}) {
    final TXData txData = TXData();

    if (amount_raw != null) {
      txData.amount_raw = amount_raw;
    }
    if (is_tx != null) {
      txData.is_tx = is_tx;
    }
    if (is_message != null) {
      txData.is_message = is_message;
    }
    if (isNotEmpty(memo)) {
      txData.is_memo = true;
      txData.memo = memo;
    }
    if (is_request != null) {
      txData.is_request = is_request;
    }
    if (is_acknowledged != null) {
      txData.is_acknowledged = is_acknowledged;
    }
    if (is_fulfilled != null) {
      txData.is_fulfilled = is_fulfilled;
    }
    if (timestamp != 0) {
      txData.request_time = timestamp;
    }

    if (is_recipient) {
      txData.to_address = StateContainer.of(context).wallet!.address;
      if (txData.is_tx) {
        txData.sub_type = BlockTypes.RECEIVE;
      }
    } else {
      txData.to_address = "";
      if (txData.is_tx) {
        txData.sub_type = BlockTypes.SEND;
      }
    }

    return _buildUnifiedCard(txData, _emptyAnimation, displayName!, context);
  } //Dummy Transaction Card End

  // Welcome Card
  TextSpan _getExampleHeaderSpan(BuildContext context) {
    String workingStr;
    if (StateContainer.of(context).selectedAccount == null || StateContainer.of(context).selectedAccount!.index == 0) {
      workingStr = AppLocalization.of(context).exampleCardIntro;
    } else {
      workingStr = AppLocalization.of(context).newAccountIntro;
    }
    if (!workingStr.contains("NANO")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize NANO
    final List<String> splitStr = workingStr.split("NANO");
    if (splitStr.length != 2) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    return TextSpan(
      text: '',
      children: [
        TextSpan(
          text: splitStr[0],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
        TextSpan(
          text: "NANO",
          style: AppStyles.textStyleTransactionWelcomePrimary(context),
        ),
        TextSpan(
          text: splitStr[1],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeTransactionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getExampleHeaderSpan(context),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  Widget _buildWelcomePaymentCardTwo(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  text: TextSpan(
                    text: AppLocalization.of(context).examplePaymentExplainer,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Loading Transaction Card
  Widget _buildLoadingTransactionCard(String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color? iconColor;
    if (type == "Sent") {
      text = "Senttt";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.text20;
    } else {
      text = "Receiveddd";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.primary20;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.zero,
        ),
        // splashColor: StateContainer.of(context).curTheme.text15,
        // highlightColor: StateContainer.of(context).curTheme.text15,
        // splashColor: StateContainer.of(context).curTheme.text15,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Transaction Icon
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    SizedBox(
                      width: UIUtil.getDrawerAwareScreenWidth(context) / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              Text(
                                text,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontFamily: "NunitoSans",
                                  fontSize: AppFontSizes.small,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent,
                                ),
                              ),
                              Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.text45,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontSize: AppFontSizes.small - 4,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Amount Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              Text(
                                amount,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontFamily: "NunitoSans",
                                    color: Colors.transparent,
                                    fontSize: AppFontSizes.smallest,
                                    fontWeight: FontWeight.w600),
                              ),
                              Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.primary20,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    amount,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontFamily: "NunitoSans",
                                        color: Colors.transparent,
                                        fontSize: AppFontSizes.smallest - 3,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                SizedBox(
                  width: UIUtil.getDrawerAwareScreenWidth(context) / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          Text(
                            address,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: AppFontSizes.smallest,
                              fontFamily: 'OverpassMono',
                              fontWeight: FontWeight.w100,
                              color: Colors.transparent,
                            ),
                          ),
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: StateContainer.of(context).curTheme.text20,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                address,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.smallest - 3,
                                  fontFamily: 'OverpassMono',
                                  fontWeight: FontWeight.w100,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // Loading Transaction Card End

  Widget _buildSearchbarAnimation() {
    return SearchBarAnimation(
      isOriginalAnimation: false,
      textEditingController: _searchController,
      cursorColour: StateContainer.of(context).curTheme.primary,
      isSearchBoxOnRightSide: !Bidi.isRtlLanguage(),
      buttonIcon: AppIcons.search,
      trailingIcon: AppIcons.search,
      buttonColour: StateContainer.of(context).curTheme.backgroundDark, // icon background color
      buttonIconColour: StateContainer.of(context).curTheme.text, // icon color
      hintTextColour: StateContainer.of(context).curTheme.text30,
      searchBoxColour: StateContainer.of(context).curTheme.backgroundDark, // background of the searchbox itself
      trailingIconColour: StateContainer.of(context).curTheme.primary, // on the left after opening the search box
      secondaryButtonIconColour: StateContainer.of(context).curTheme.text,
      enableBoxShadow: false,
      enableButtonBorder: false,
      enableButtonShadow: false,
      durationInMilliSeconds: 300,
      enableKeyboardFocus: true,
      enteredTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppFontSizes.small,
        color: StateContainer.of(context).curTheme.text,
        fontFamily: "NunitoSans",
      ),
      textAlignToRight: false,
      onChanged: (String value) async {
        setState(() {});
        await generateUnifiedList(fastUpdate: true);
      },
      onCollapseComplete: () async {
        setState(() {
          _searchOpen = false;
          _searchController.text = "";
        });
        await generateUnifiedList(fastUpdate: true);
      },
      onExpansionComplete: () async {
        setState(() {
          _searchOpen = true;
          _searchController.text = "";
        });
        await generateUnifiedList(fastUpdate: true);
      },
      enableBoxBorder: true,
      searchBoxBorderColour: StateContainer.of(context).curTheme.text,
      hintText: _searchOpen ? AppLocalization.of(context).searchHint : "",
    );
  }

  //Main Card
  // Widget _buildMainCard(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {} //Main Card

  // TX / Card Action functions:
  static Future<void> resendRequest(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REQUEST, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the request again:
    final String privKey = NanoUtil.seedToPrivate(
        await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid =
        NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData requestTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: true,
      is_memo: false,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(requestTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl.get<AccountService>().requestPayment(txDetails.to_address, txDetails.amount_raw,
          StateContainer.of(context).wallet!.address, signature, nonceHex, encryptedMemo, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context).requestSendError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context).requestSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateTXMemos();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMemo(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool memoSendFailed = false;

    // send the memo again:
    final String privKey = NanoUtil.seedToPrivate(
        await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid =
        NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData memoTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(memoTXData);

    try {
      // encrypt the memo:
      final String encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      await sl.get<AccountService>().sendTXMemo(txDetails.to_address!, StateContainer.of(context).wallet!.address!,
          txDetails.amount_raw, signature, nonceHex, encryptedMemo, txDetails.block, localUuid);
    } catch (e) {
      memoSendFailed = true;
    }

    // if the memo send failed delete the object:
    if (memoSendFailed) {
      sl.get<Logger>().v("memo send failed, deleting TXData object");
      // remove from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context).sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old memo by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context).memoSentButNotReceived, context, durationMs: 5000);
      await StateContainer.of(context).updateTXMemos();
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMessage(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the message again:
    final String privKey = NanoUtil.seedToPrivate(
        await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid =
        NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData messageTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: false,
      is_message: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(messageTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl.get<AccountService>().sendTXMessage(txDetails.to_address!, StateContainer.of(context).wallet!.address!,
          signature, nonceHex, encryptedMemo!, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context).sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context).memoSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> payTX(BuildContext context, TXData txDetails) async {
    String? address;
    if (txDetails.is_request || txDetails.is_memo) {
      if (txDetails.to_address == StateContainer.of(context).wallet!.address) {
        address = txDetails.from_address;
      } else {
        address = txDetails.to_address;
      }
    } else {
      // address = item.account;
      address = txDetails.from_address;
    }
    // See if a contact
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address!);
    final String? quickSendAmount = txDetails.amount_raw;
    // a bit of a hack since send sheet doesn't have a way to tell if we're in nyano mode on creation:
    // if (StateContainer.of(context).nyanoMode) {
    //   quickSendAmount = "${quickSendAmount!}000000";
    // }

    // Go to send with address
    await Sheets.showAppHeightNineSheet(
        context: context,
        widget: SendSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: address,
          quickSendAmount: quickSendAmount,
          user: user,
        ));
  }

  Future<String> getGiftBalance(String? address) async {
    if (address == null) {
      return "";
    }

    try {
      final AccountsBalancesResponse res = await sl<AccountService>().requestAccountsBalances([address]);
      if (res.balances?[address]?.balance == null) {
        return "";
      }

      BigInt? balance = BigInt.tryParse(res.balances![address]!.balance!);
      final BigInt? receivable = BigInt.tryParse(res.balances![address]!.receivable!);

      if (balance == null || receivable == null) {
        return "";
      }
      balance = balance + receivable;
      return balance.toString();
    } catch (e) {
      sl<Logger>().e("Error getting gift balance: $e");
      return "";
    }
  }

// Transaction Card/List Item
  Widget _buildUnifiedCard(TXData txDetails, Animation<double> animation, String displayName, BuildContext context) {
    late String itemText;
    IconData? icon;
    Color? iconColor;

    bool isGift = false;
    final String? walletAddress = StateContainer.of(context).wallet!.address;

    if (txDetails.is_message) {
      // just in case:
      txDetails.amount_raw = null;
    }

    if (txDetails.isRecipient(walletAddress)) {
      txDetails.is_acknowledged = true;
    }

    if (txDetails.record_type == RecordTypes.GIFT_ACK ||
        txDetails.record_type == RecordTypes.GIFT_OPEN ||
        txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGift = true;
    }

    // set icon color:
    if (txDetails.is_message || txDetails.is_request) {
      if (txDetails.is_request) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = AppLocalization.of(context).request;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context).asked;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      } else if (txDetails.is_message) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = AppLocalization.of(context).received;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          itemText = AppLocalization.of(context).sent;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        }
      }
    } else if (txDetails.is_tx) {
      if (isGift) {
        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          itemText = AppLocalization.of(context).loaded;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else if (txDetails.record_type == RecordTypes.GIFT_OPEN) {
          itemText = AppLocalization.of(context).opened;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          throw Exception("something went wrong with gift type");
        }
      } else {
        if (txDetails.sub_type == BlockTypes.SEND) {
          itemText = AppLocalization.of(context).sent;
          icon = AppIcons.sent;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context).received;
          icon = AppIcons.received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      }
    }

    BoxShadow? setShadow;

    // set box shadow color:
    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      // normal tx:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    } else if (txDetails.status == StatusTypes.CREATE_FAILED) {
      if (txDetails.is_request || txDetails.is_message) {
        iconColor = StateContainer.of(context).curTheme.error60;
        setShadow = BoxShadow(
          color: StateContainer.of(context).curTheme.error60!.withOpacity(0.2),
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 1,
        );
      } else {
        iconColor = StateContainer.of(context).curTheme.warning60;
        setShadow = BoxShadow(
          color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 1,
        );
      }
    } else if (txDetails.is_fulfilled && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.success60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.success60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (!txDetails.is_acknowledged && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if ((!txDetails.is_acknowledged && !txDetails.is_tx) || (txDetails.is_request && !txDetails.is_fulfilled)) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else {
      // normal transaction:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    }

    bool slideEnabled = false;
    // valid wallet:
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.accountBalance > BigInt.zero) {
      // does it make sense to make it slideable?
      // if (isPaymentRequest && isRecipient && !txDetails.is_fulfilled) {
      //   slideEnabled = true;
      // }
      if (txDetails.is_request && !txDetails.is_fulfilled) {
        slideEnabled = true;
      }
      if (txDetails.is_tx && !isGift) {
        slideEnabled = true;
      }
      if (txDetails.is_message) {
        slideEnabled = true;
      }
    }

    TransactionStateOptions? transactionState;

    if (txDetails.record_type != RecordTypes.GIFT_LOAD) {
      if (txDetails.is_request) {
        if (txDetails.is_fulfilled) {
          transactionState = TransactionStateOptions.PAID;
        } else {
          transactionState = TransactionStateOptions.UNPAID;
        }
      }
      if (!txDetails.is_acknowledged) {
        transactionState = TransactionStateOptions.UNREAD;
      }

      if (txDetails.status == StatusTypes.CREATE_FAILED) {
        if (txDetails.is_request || txDetails.is_message) {
          transactionState = TransactionStateOptions.NOT_SENT;
        } else {
          transactionState = TransactionStateOptions.FAILED_MSG;
        }
      }
    }

    if (txDetails.is_tx) {
      // if ((item.confirmed != null && !item.confirmed!) || (currentConfHeight > -1 && item.height != null && item.height! > currentConfHeight)) {
      //   transactionState = TransactionStateOptions.UNCONFIRMED;
      // }
      if (_tabController.index == 0) {
        if ((!txDetails.is_fulfilled) ||
            (currentConfHeight > -1 && txDetails.height != null && txDetails.height! > currentConfHeight)) {
          transactionState = TransactionStateOptions.UNCONFIRMED;
        }
      } else {
        if (!txDetails.is_fulfilled) {
          transactionState = TransactionStateOptions.UNCONFIRMED;
        }
      }

      // watch only: receivable:
      if (txDetails.record_type == BlockTypes.RECEIVE) {
        transactionState = TransactionStateOptions.RECEIVABLE;
      }
    }

    final List<Widget> slideActions = [];
    String? label;
    if (txDetails.is_tx) {
      label = AppLocalization.of(context).send;
    } else {
      if (txDetails.is_request && txDetails.isRecipient(walletAddress)) {
        label = AppLocalization.of(context).pay;
      }
    }

    // payment request / pay button:
    if (label != null) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: label,
          onPressed: (BuildContext context) async {
            if (!mounted) return;
            await payTX(context, txDetails);
            if (!mounted) return;
            await Slidable.of(context)!.close();
          }));
    }

    // reply button:
    if (txDetails.is_message && txDetails.isRecipient(walletAddress)) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: AppLocalization.of(context).reply,
          onPressed: (BuildContext context) async {
            if (!mounted) return;
            await payTX(context, txDetails);
            if (!mounted) return;
            await Slidable.of(context)!.close();
          }));
    }

    // retry buttons:
    if (!txDetails.is_acknowledged) {
      if (txDetails.is_request) {
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await resendRequest(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_memo) {
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await resendMemo(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_message) {
        // TODO: resend message
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await resendMessage(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      }
    }

    if (txDetails.is_request || txDetails.is_message) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: AppLocalization.of(context).delete,
          onPressed: (BuildContext context) async {
            if (txDetails.uuid != null) {
              await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
            }
            if (!mounted) return;
            await StateContainer.of(context).updateSolids();
            if (!mounted) return;
            await StateContainer.of(context).updateUnified(false);
            if (!mounted) return;
            await Slidable.of(context)!.close();
          }));
    }

    final ActionPane actionPane = ActionPane(
      motion: const ScrollMotion(),
      extentRatio: slideActions.length * 0.2,
      children: slideActions,
    );

    const double cardHeight = 65;

    return Slidable(
      enabled: slideEnabled,
      endActionPane: actionPane,
      child: _SizeTransitionNoClip(
        sizeFactor: animation,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.backgroundDark,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [setShadow!],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: StateContainer.of(context).curTheme.text15,
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Sheets.showAppHeightEightSheet(
                      context: context, widget: PaymentDetailsSheet(txDetails: txDetails), animationDurationMs: 175);
                },
                child: Center(
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                    // constraints: const BoxConstraints(
                    //   minHeight: cardHeight,
                    //   maxHeight: cardHeight+10,
                    // ),
                    // padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                    // padding: const EdgeInsets.only(top: 14.0, bottom: 14.0, left: 20.0),
                    // padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                    // padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: cardHeight,
                            // maxHeight: cardHeight+20,
                          ),
                          margin: const EdgeInsetsDirectional.only(start: 20.0),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsetsDirectional.only(end: 16.0),
                                child: Icon(
                                  icon,
                                  color: iconColor,
                                  size: 20,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SubstringHighlight(
                                    caseSensitive: false,
                                    words: false,
                                    term: _searchController.text,
                                    text: itemText,
                                    textAlign: TextAlign.start,
                                    textStyle: AppStyles.textStyleTransactionType(context),
                                    textStyleHighlight: TextStyle(
                                        fontFamily: "NunitoSans",
                                        fontSize: AppFontSizes.small,
                                        fontWeight: FontWeight.w600,
                                        color: StateContainer.of(context).curTheme.warning60),
                                  ),
                                  if (!txDetails.is_message && !isEmpty(txDetails.amount_raw))
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          getThemeAwareRawAccuracy(context, txDetails.amount_raw),
                                          style: AppStyles.textStyleTransactionAmount(context),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            text: "",
                                            children: [
                                              displayCurrencySymbol(
                                                context,
                                                AppStyles.textStyleTransactionAmount(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SubstringHighlight(
                                            caseSensitive: false,
                                            words: false,
                                            term: _searchController.text,
                                            text: getRawAsThemeAwareFormattedAmount(context, txDetails.amount_raw),
                                            textAlign: TextAlign.start,
                                            textStyle: AppStyles.textStyleTransactionAmount(context),
                                            textStyleHighlight: TextStyle(
                                                fontFamily: "NunitoSans",
                                                color: StateContainer.of(context).curTheme.warning60,
                                                fontSize: AppFontSizes.smallest,
                                                fontWeight: FontWeight.w600)),
                                        if (isGift &&
                                            txDetails.record_type == RecordTypes.GIFT_LOAD &&
                                            txDetails.metadata!.split(RecordTypes.SEPARATOR).length > 2)
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                " : ",
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                              Text(
                                                getThemeAwareRawAccuracy(
                                                    context, txDetails.metadata!.split(RecordTypes.SEPARATOR)[2]),
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                              RichText(
                                                textAlign: TextAlign.start,
                                                text: TextSpan(
                                                  text: "",
                                                  children: [
                                                    displayCurrencySymbol(
                                                      context,
                                                      AppStyles.textStyleTransactionAmount(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                getRawAsThemeAwareFormattedAmount(
                                                    context, txDetails.metadata!.split(RecordTypes.SEPARATOR)[2]),
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   constraints: const BoxConstraints(
                        //     minHeight: 10,
                        //     maxHeight: 100,
                        //   ),
                        //   child: Text(
                        //     "asdadad",
                        //     style: AppStyles.textStyleTransactionAmount(context),
                        //   ),
                        // ),
                        if (txDetails.memo != null && txDetails.memo!.isNotEmpty)
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 10,
                                maxHeight: 100,
                              ),
                              child: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  SubstringHighlight(
                                      caseSensitive: false,
                                      term: _searchController.text,
                                      text: txDetails.memo!,
                                      textAlign: TextAlign.center,
                                      textStyle: AppStyles.textStyleTransactionMemo(context),
                                      textStyleHighlight: TextStyle(
                                        fontSize: AppFontSizes.smallest,
                                        fontFamily: 'OverpassMono',
                                        fontWeight: FontWeight.w100,
                                        color: StateContainer.of(context).curTheme.warning60,
                                      ),
                                      words: false),
                                ]),
                              ),
                            ),
                          ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 4.0,
                          // constraints: const BoxConstraints(maxHeight: cardHeight),
                          margin: const EdgeInsetsDirectional.only(end: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SubstringHighlight(
                                  caseSensitive: false,
                                  maxLines: 5,
                                  term: _searchController.text,
                                  text: displayName,
                                  textAlign: TextAlign.right,
                                  textStyle: AppStyles.textStyleTransactionAddress(context),
                                  textStyleHighlight: TextStyle(
                                    fontSize: AppFontSizes.smallest,
                                    fontFamily: 'OverpassMono',
                                    fontWeight: FontWeight.w100,
                                    color: StateContainer.of(context).curTheme.warning60,
                                  ),
                                  words: false),

                              // TRANSACTION STATE TAG
                              if (transactionState != null)
                                // ignore: avoid_unnecessary_containers
                                Container(
                                  // margin: const EdgeInsetsDirectional.only(
                                  //     // top: 10,
                                  //     ),
                                  child: TransactionStateTag(transactionState: transactionState),
                                ),

                              if (txDetails.request_time != null)
                                SubstringHighlight(
                                  caseSensitive: false,
                                  words: false,
                                  term: _searchController.text,
                                  text: getTimeAgoString(context, txDetails.request_time!),
                                  textAlign: TextAlign.start,
                                  textStyle: TextStyle(
                                      fontFamily: "OverpassMono",
                                      fontSize: AppFontSizes.smallest,
                                      fontWeight: FontWeight.w600,
                                      color: StateContainer.of(context).curTheme.text30),
                                  textStyleHighlight: TextStyle(
                                      fontFamily: "OverpassMono",
                                      fontSize: AppFontSizes.smallest,
                                      fontWeight: FontWeight.w600,
                                      color: StateContainer.of(context).curTheme.warning30),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // handle bars:
            if (slideEnabled)
              Container(
                width: 4,
                height: 30,
                margin: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: StateContainer.of(context).curTheme.text45,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  } // Payment Card End

  TXData convertHistItemToTXData(AccountHistoryResponseItem histItem, {TXData? txDetails}) {
    TXData converted = TXData();
    if (txDetails != null) {
      converted = txDetails;
    }
    converted.amount_raw ??= histItem.amount;

    if (histItem.subtype == BlockTypes.SEND) {
      converted.to_address ??= histItem.account;
    } else if (histItem.subtype == BlockTypes.RECEIVE) {
      converted.from_address ??= histItem.account;
    }

    converted.from_address ??= histItem.account;
    converted.to_address ??= histItem.account;

    converted.block ??= histItem.hash;
    converted.request_time ??= histItem.local_timestamp!;

    if (histItem.confirmed != null) {
      converted.is_fulfilled = histItem.confirmed!; // confirmation status
    } else {
      converted.is_fulfilled = true; // default to true as it cannot be null
    }
    converted.height ??= histItem.height!; // block height
    converted.record_type ??= histItem.type; // transaction type
    converted.sub_type ??= histItem.subtype; // transaction subtype

    if (isNotEmpty(txDetails?.memo)) {
      converted.is_memo = true;
    } else {
      converted.is_acknowledged = true;
    }
    converted.is_tx = true;
    return converted;
  }

  TXData convertMoneroHistItemToTXData(dynamic histItem, {TXData? txDetails}) {
    TXData converted = TXData();
    if (txDetails != null) {
      converted = txDetails;
    }
    histItem = histItem["state"];

    // tx:
    // if (histItem["isIncoming"] as bool) {
    //   converted.sub_type = BlockTypes.RECEIVE;
    //   converted.to_address = StateContainer.of(context).xmrAddress;
    //   converted.from_address = histItem["incomingTransfers"][0]["state"]["address"] as String;
    //   final List<dynamic> inputs = histItem["incomingTransfers"][0]["state"]["amount"]["_d"] as List<dynamic>;
    //   int totalIn = 0;
    //   for (final dynamic input in inputs) {
    //     totalIn += input as int;
    //   }
    //   converted.amount_raw = totalIn.toString();
    // } else if (histItem["isOutgoing"] as bool) {
    //   converted.sub_type = BlockTypes.SEND;
    //   converted.from_address = StateContainer.of(context).xmrAddress;
    //   converted.to_address = histItem["outgoingTransfer"]["state"]["addresses"][0] as String;
    //   final List<dynamic> outputs = histItem["outgoingTransfer"]["state"]["amount"]["_d"] as List<dynamic>;
    //   int totalOut = 0;
    //   for (final dynamic output in outputs) {
    //     totalOut += output as int;
    //   }
    //   converted.amount_raw = totalOut.toString();
    // }
    // // convert to xmr amount:
    // converted.amount_raw = (BigInt.parse(converted.amount_raw!) * BigInt.parse("1000000000000000000000000")).toString();
    // converted.block ??= histItem["hash"] as String;
    // converted.request_time ??= histItem["block"]["state"]["timestamp"] as int;
    // if (histItem["isConfirmed"] != null) {
    //   converted.is_fulfilled = histItem["isConfirmed"] as bool; // confirmation status
    // } else {
    //   converted.is_fulfilled = true; // default to true as it cannot be null
    // }
    // // converted.height ??= histItem.height!; // block height

    // transfer:

    final dynamic tx = histItem["tx"]["state"];

    if (tx["isIncoming"] as bool) {
      converted.sub_type = BlockTypes.RECEIVE;
      converted.to_address = StateContainer.of(context).xmrAddress;
      converted.from_address = histItem["address"] as String;

      final List<dynamic> inputs = histItem["amount"]["_d"] as List<dynamic>;
      int totalIn = 0;
      for (final dynamic input in inputs) {
        totalIn += input as int;
      }
      converted.amount_raw = totalIn.toString();
    } else if (tx["isOutgoing"] as bool) {
      converted.sub_type = BlockTypes.SEND;
      converted.from_address = StateContainer.of(context).xmrAddress;
      converted.to_address = histItem["addresses"][0] as String;

      final List<dynamic> outputs = histItem["amount"]["_d"] as List<dynamic>;
      int totalOut = 0;
      for (final dynamic output in outputs) {
        totalOut += output as int;
      }
      converted.amount_raw = totalOut.toString();
    }

    // convert to xmr amount:
    converted.amount_raw = (BigInt.parse(converted.amount_raw!) * NumberUtil.convertXMRtoNano).toString();

    converted.block ??= tx["hash"] as String;
    converted.request_time ??= tx["block"]["state"]["timestamp"] as int;
    converted.height ??= tx["block"]["state"]["height"] as int;

    if (tx["isConfirmed"] != null) {
      converted.is_fulfilled = tx["isConfirmed"] as bool; // confirmation status
    } else {
      converted.is_fulfilled = true; // default to true as it cannot be null
    }
    // converted.height ??= histItem.height!; // block height

    if (isNotEmpty(txDetails?.memo)) {
      converted.is_memo = true;
    } else {
      converted.is_acknowledged = true;
    }
    converted.is_tx = true;
    return converted;
  }

  // Used to build list items that haven't been removed.
  Widget _buildUnifiedItem(BuildContext context, int index, Animation<double> animation) {
    if (index < StateContainer.of(context).activeAlerts.length && StateContainer.of(context).activeAlerts.isNotEmpty) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlerts[index]);
    }
    if (index == 0 && _noSearchResults) {
      return _buildNoSearchResultsCard(context);
    }

    int localIndex = index;
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      localIndex -= StateContainer.of(context).activeAlerts.length;
    }

    String ADR = StateContainer.of(context).wallet!.address!;

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ADR = "${ADR}alert";
    }

    final dynamic indexedItem = _unifiedListMap[ADR]![localIndex];
    if (indexedItem is SizedBox) return indexedItem;

    final TXData txDetails = indexedItem is TXData
        ? indexedItem
        : convertHistItemToTXData(indexedItem as AccountHistoryResponseItem,
            txDetails: _txDetailsMap[indexedItem.hash]);
    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
    final String account = txDetails.getAccount(isRecipient);
    String displayName = Address(account).getShortestString() ?? "";

    // check if there's a username:
    for (final User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName()!;
        break;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  // Used to build list items that haven't been removed.
  Widget _buildMoneroItem(BuildContext context, int index, Animation<double> animation) {
    if (index < StateContainer.of(context).activeAlerts.length && StateContainer.of(context).activeAlerts.isNotEmpty) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlerts[index]);
    }
    if (index == 0 && _noSearchResults) {
      return _buildNoSearchResultsCard(context);
    }

    int localIndex = index;
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      localIndex -= StateContainer.of(context).activeAlerts.length;
    }

    ListModel? list;

    final String ADR = StateContainer.of(context).wallet!.address!;

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      list = _moneroList;
    } else {
      list = _moneroList; // todo:
    }

    final dynamic indexedItem = list![localIndex];
    final TXData txDetails = indexedItem is TXData
        ? indexedItem
        : convertMoneroHistItemToTXData(indexedItem /*, txDetails: _txDetailsMap[indexedItem.hash]*/);
    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).xmrAddress);
    // final String displayName = txDetails.getShortestString(isRecipient) ?? "";
    final String account = txDetails.getAccount(isRecipient);
    String displayName = "${account.substring(0, 9)}\n...${account.substring(account.length - 6)}";
    // // check if there's a username:
    for (final User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName()!;
        break;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  Widget _getMoneroListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.historyLoading == false) {
      // Setup history list
      if (_moneroHistoryList == null) {
        setState(() {
          _moneroHistoryList = [];
        });
      }

      GlobalKey<AnimatedListState>? listKey;
      ListModel? list;
      if (StateContainer.of(context).activeAlerts.isNotEmpty) {
        listKey = _moneroListKeyAlert;
        list = _moneroList; // todo:
      } else {
        listKey = _moneroListKey;
        list = _moneroList;
      }

      // Setup unified list
      if (_moneroListKey == null) {
        _moneroListKey = GlobalKey<AnimatedListState>();
        setState(() {
          _moneroList = ListModel<dynamic>(
            listKey: listKey as GlobalKey<AnimatedListState>,
            initialItems: [],
          );
        });
      }

      if (StateContainer.of(context).wallet!.xmrLoading || (list != null && list.length == 0)) {
        generateMoneroList(fastUpdate: true);
      }
    }

    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet!.loading ||
        StateContainer.of(context).wallet!.xmrLoading) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _xmrScrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              _buildLoadingTransactionCard("Sent", "10244000", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "100,00000", "@fosse1234", context),
              _buildLoadingTransactionCard("Sent", "14500000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "12,51200", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "1,45300", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "100,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Received", "24,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
            ],
          ));
    } else if (!StateContainer.of(context).wallet!.unifiedLoading) {
      _disposeAnimation();
    }

    // if (StateContainer.of(context).activeAlerts.isNotEmpty) {
    //   // Setup unified list
    //   if (_moneroListKeyAlert == null) {
    //     _moneroListKeyAlert = GlobalKey<AnimatedListState>();
    //     setState(() {
    //       _moneroList = ListModel<dynamic>(
    //         listKey: _moneroListKeyAlert!,
    //         initialItems: [],
    //       );
    //     });
    //   }
    //   return DraggableScrollbar(
    //     controller: _scrollController,
    //     scrollbarColor: StateContainer.of(context).curTheme.primary!,
    //     scrollbarTopMargin: 10.0,
    //     scrollbarBottomMargin: 20.0,
    //     child: ReactiveRefreshIndicator(
    //       backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
    //       onRefresh: _refresh,
    //       isRefreshing: _isRefreshing,
    //       child: AnimatedList(
    //         physics: const AlwaysScrollableScrollPhysics(),
    //         controller: _scrollController,
    //         key: _moneroListKeyAlert,
    //         padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
    //         initialItemCount: _moneroList!.length + StateContainer.of(context).activeAlerts.length,
    //         itemBuilder: _buildMoneroItem,
    //       ),
    //     ),
    //   );
    // }

    return DraggableScrollbar(
      controller: _xmrScrollController,
      scrollbarColor: StateContainer.of(context).curTheme.primary!,
      scrollbarTopMargin: 10.0,
      scrollbarBottomMargin: 20.0,
      child: ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
        child: AnimatedList(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _xmrScrollController,
          primary: false,
          key: _moneroListKey,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _moneroList!.length,
          itemBuilder: _buildMoneroItem,
        ),
      ),
    );
  }

  // Return widget for list
  Widget _getUnifiedListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.historyLoading == false) {
      // Setup history list
      if (!_historyListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _historyListMap.putIfAbsent(
              StateContainer.of(context).wallet!.address!, () => StateContainer.of(context).wallet!.history);
        });
      }
      // Setup payments list
      if (!_solidsListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _solidsListMap.putIfAbsent(
              StateContainer.of(context).wallet!.address!, () => StateContainer.of(context).wallet!.solids);
        });
      }

      String ADR = StateContainer.of(context).wallet!.address!;
      if (StateContainer.of(context).activeAlerts.isNotEmpty) {
        ADR = "${ADR}alert";
      }
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey(ADR)) {
        _unifiedListKeyMap.putIfAbsent(ADR, () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            ADR,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap[ADR]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
      }

      if (StateContainer.of(context).wallet!.unifiedLoading ||
          (_unifiedListMap[ADR] != null && _unifiedListMap[ADR]!.length == 0)) {
        generateUnifiedList(fastUpdate: true);
      }
    }

    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet!.loading ||
        StateContainer.of(context).wallet!.unifiedLoading) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              _buildLoadingTransactionCard("Sent", "10244000", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "100,00000", "@fosse1234", context),
              _buildLoadingTransactionCard("Sent", "14500000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "12,51200", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "1,45300", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "100,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Received", "24,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
            ],
          ));
    } else if (!StateContainer.of(context).wallet!.xmrLoading) {
      _disposeAnimation();
    }

    if (StateContainer.of(context).wallet!.history.isEmpty && StateContainer.of(context).wallet!.solids.isEmpty) {
      final List<Widget> activeAlerts = [];
      for (final AlertResponseItem alert in StateContainer.of(context).activeAlerts) {
        activeAlerts.add(_buildRemoteMessageCard(alert));
      }
      return DraggableScrollbar(
        controller: _scrollController,
        scrollbarColor: StateContainer.of(context).curTheme.primary!,
        scrollbarTopMargin: 10.0,
        scrollbarBottomMargin: 20.0,
        child: ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              // REMOTE MESSAGE CARDS
              if (StateContainer.of(context).activeAlerts.isNotEmpty)
                Column(
                  children: activeAlerts,
                ),
              _buildWelcomeTransactionCard(context),
              _buildDummyTXCard(
                context,
                amount_raw: "30000000000000000000000000000000",
                displayName: AppLocalization.of(context).exampleRecRecipient,
                memo: AppLocalization.of(context).exampleRecRecipientMessage,
                is_recipient: true,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "50000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePayRecipient,
                memo: AppLocalization.of(context).examplePayRecipientMessage,
                is_recipient: false,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 1),
              ),
              _buildWelcomePaymentCardTwo(context),

              _buildDummyTXCard(
                context,
                amount_raw: "10000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePaymentTo,
                memo: AppLocalization.of(context).examplePaymentFulfilledMemo,
                is_recipient: false,
                is_request: true,
                is_fulfilled: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 5),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "2000000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePaymentFrom,
                memo: AppLocalization.of(context).examplePaymentReceivableMemo,
                is_recipient: true,
                is_request: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 7),
              ),
              _buildDummyTXCard(
                context,
                displayName: AppLocalization.of(context).examplePaymentTo,
                memo: AppLocalization.of(context).examplePaymentMessage,
                is_recipient: true,
                is_message: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 9),
              ),
            ],
          ),
        ),
      );
    }

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey("${StateContainer.of(context).wallet!.address}alert")) {
        _unifiedListKeyMap.putIfAbsent(
            "${StateContainer.of(context).wallet!.address}alert", () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet!.address!,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap["${StateContainer.of(context).wallet!.address!}alert"]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
      }
      return DraggableScrollbar(
        controller: _scrollController,
        scrollbarColor: StateContainer.of(context).curTheme.primary!,
        scrollbarTopMargin: 10.0,
        scrollbarBottomMargin: 20.0,
        child: ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: AnimatedList(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            key: _unifiedListKeyMap["${StateContainer.of(context).wallet!.address}alert"],
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            initialItemCount: _unifiedListMap["${StateContainer.of(context).wallet!.address}alert"]!.length +
                StateContainer.of(context).activeAlerts.length,
            itemBuilder: _buildUnifiedItem,
          ),
        ),
      );
    }

    return DraggableScrollbar(
      controller: _scrollController,
      scrollbarColor: StateContainer.of(context).curTheme.primary!,
      scrollbarTopMargin: 10.0,
      scrollbarBottomMargin: 20.0,
      child: ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
        child: AnimatedList(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          primary: false,
          key: _unifiedListKeyMap[StateContainer.of(context).wallet!.address!],
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _unifiedListMap[StateContainer.of(context).wallet!.address]!.length,
          itemBuilder: _buildUnifiedItem,
        ),
      ),
    );
  }
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
class _SizeTransitionNoClip extends AnimatedWidget {
  const _SizeTransitionNoClip({required Animation<double> sizeFactor, this.child}) : super(listenable: sizeFactor);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      widthFactor: null,
      heightFactor: (listenable as Animation<double>).value,
      child: child,
    );
  }
}

class PaymentDetailsSheet extends StatefulWidget {
  const PaymentDetailsSheet({this.txDetails}) : super();
  final TXData? txDetails;

  @override
  PaymentDetailsSheetState createState() => PaymentDetailsSheetState();
}

class PaymentDetailsSheetState extends State<PaymentDetailsSheet> {
  // // Current state references
  // bool _linkCopied = false;
  // // Timer reference so we can cancel repeated events
  // Timer? _linkCopiedTimer;
  // Current state references
  bool _seedCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _seedCopiedTimer;
  // address copied
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    // check if recipient of the request
    // also check if the request is fulfilled
    bool isUnfulfilledPayableRequest = false;
    bool isUnacknowledgedSendableRequest = false;
    bool resendableMemo = false;
    bool isGiftLoad = false;

    final TXData txDetails = widget.txDetails!;

    final String? walletAddress = StateContainer.of(context).wallet!.address;

    if (walletAddress == txDetails.to_address) {
      txDetails.is_acknowledged = true;
    }

    if (walletAddress == txDetails.to_address && txDetails.is_request && !txDetails.is_fulfilled) {
      isUnfulfilledPayableRequest = true;
    }
    if (walletAddress == txDetails.from_address && txDetails.is_request && !txDetails.is_acknowledged) {
      isUnacknowledgedSendableRequest = true;
    }

    String? walletSeed;
    String? sharableLink;

    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGiftLoad = true;

      // Get the wallet seed by splitting the metadata by :
      final List<String> metadataList = txDetails.metadata!.split(RecordTypes.SEPARATOR);
      walletSeed = metadataList[0];
      sharableLink = metadataList[1];
    }

    String? addressToCopy = txDetails.to_address;
    if (txDetails.to_address == StateContainer.of(context).wallet!.address) {
      addressToCopy = txDetails.from_address;
    }

    if (txDetails.is_memo) {
      if (txDetails.status == StatusTypes.CREATE_FAILED) {
        resendableMemo = true;
      }
      if (!txDetails.is_acknowledged && txDetails.memo!.isNotEmpty && !isGiftLoad) {
        resendableMemo = true;
      }
    }

    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                // Sheet handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 24),
                  height: 5,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    color: StateContainer.of(context).curTheme.text20,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                // A row for View Details button
                if (!isGiftLoad && !txDetails.is_message)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, AppLocalization.of(context).viewTX, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        await UIUtil.showBlockExplorerWebview(context, txDetails.block);
                      }),
                    ],
                  ),
                // A row for Copy Address Button
                if (!isGiftLoad)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Copy Address Button
                          _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                          _addressCopied
                              ? AppLocalization.of(context).addressCopied
                              : AppLocalization.of(context).copyAddress,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: addressToCopy));
                        if (mounted) {
                          setState(() {
                            // Set copied style
                            _addressCopied = true;
                          });
                        }
                        if (_addressCopiedTimer != null) {
                          _addressCopiedTimer!.cancel();
                        }
                        _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          if (mounted) {
                            setState(() {
                              _addressCopied = false;
                            });
                          }
                        });
                      }),
                    ],
                  ),
                // Mark as paid / unpaid button for requests
                if (txDetails.is_request)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Share Address Button
                          AppButtonType.PRIMARY_OUTLINE,
                          !txDetails.is_fulfilled
                              ? AppLocalization.of(context).markAsPaid
                              : AppLocalization.of(context).markAsUnpaid,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        // update the tx in the db:
                        if (txDetails.is_fulfilled) {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, false);
                        } else {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, true);
                        }
                        // setState(() {});
                        if (!mounted) return;
                        await StateContainer.of(context).updateSolids();
                        if (!mounted) return;
                        await StateContainer.of(context).updateUnified(true);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),

                // pay this request button:
                if (isUnfulfilledPayableRequest)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).payRequest, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        AppHomePageState.payTX(context, txDetails);
                      }),
                    ],
                  ),

                // block this user from sending you requests:
                if (txDetails.is_request && StateContainer.of(context).wallet!.address != txDetails.from_address)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).blockUser, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: AddBlockedSheet(
                              address: txDetails.from_address,
                            ));
                      }),
                    ],
                  ),

                // re-send request button:
                if (isUnacknowledgedSendableRequest)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).sendRequestAgain, Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        // send the request again:
                        AppHomePageState.resendRequest(context, txDetails);
                      }),
                    ],
                  ),
                // re-send memo button
                if (resendableMemo)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Share Address Button
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).resendMemo,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        AppHomePageState.resendMemo(context, txDetails);
                      }),
                    ],
                  ),
                // delete this request button
                if (txDetails.is_request)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).deleteRequest, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                        sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
                        StateContainer.of(context).updateSolids();
                        StateContainer.of(context).updateUnified(false);
                      }),
                    ],
                  ),
                if (isGiftLoad)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // show link QR
                          AppButtonType.PRIMARY,
                          AppLocalization.of(context).showLinkOptions,
                          Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () async {
                        final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, sharableLink!));
                        Sheets.showAppHeightEightSheet(
                            context: context, widget: GiftQRSheet(link: sharableLink, qrWidget: qrWidget));
                      }),
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).viewTX,
                          Dimens.BUTTON_COMPACT_RIGHT_DIMENS, onPressed: () async {
                        await UIUtil.showBlockExplorerWebview(context, txDetails.block);
                      }),
                    ],
                  ),
                if (isGiftLoad)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // copy seed button
                          _seedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                          _seedCopied
                              ? AppLocalization.of(context).seedCopiedShort
                              : AppLocalization.of(context).copySeed,
                          Dimens.BUTTON_BOTTOM_EXCEPTION_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: walletSeed));
                        if (!mounted) return;
                        setState(() {
                          // Set copied style
                          _seedCopied = true;
                        });
                        if (_seedCopiedTimer != null) {
                          _seedCopiedTimer!.cancel();
                        }
                        _seedCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          if (!mounted) return;
                          setState(() {
                            _seedCopied = false;
                          });
                        });
                      }),
                    ],
                  ),
                // if (isGiftLoad)
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: <Widget>[
                //       AppButton.buildAppButton(
                //           context,
                //           // copy link button
                //           _linkCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                //           _linkCopied ? AppLocalization.of(context).linkCopied : AppLocalization.of(context).copyLink,
                //           Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () {
                //         Clipboard.setData(ClipboardData(text: sharableLink));
                //         setState(() {
                //           // Set copied style
                //           _linkCopied = true;
                //         });
                //         if (_linkCopiedTimer != null) {
                //           _linkCopiedTimer!.cancel();
                //         }
                //         _linkCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                //           setState(() {
                //             _linkCopied = false;
                //           });
                //         });
                //       }),
                //       AppButton.buildAppButton(
                //           context,
                //           // share link button
                //           AppButtonType.PRIMARY_OUTLINE,
                //           AppLocalization.of(context).shareLink,
                //           Dimens.BUTTON_COMPACT_RIGHT_DIMENS, onPressed: () {
                //         Share.share(sharableLink!);
                //       }),
                //     ],
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

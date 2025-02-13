import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_specific_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';

class FundingMessagesSheet extends StatefulWidget {

  const FundingMessagesSheet({this.alerts, this.hasDismissButton = true}) : super();
  final List<FundingResponseItem>? alerts;
  final bool hasDismissButton;

  @override
  // ignore: library_private_types_in_public_api
  _FundingMessagesSheetState createState() => _FundingMessagesSheetState();
}

class _FundingMessagesSheetState extends State<FundingMessagesSheet> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                //Container for the address text and sheet handle
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
                            CaseChange.toUpperCase(AppLocalization.of(context).fundingHeader, context),
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
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 8),
                child: Stack(
                  children: [
                    DraggableScrollbar(
                      controller: _scrollController,
                      scrollbarColor: StateContainer.of(context).curTheme.primary!,
                      scrollbarTopMargin: 16,
                      scrollbarBottomMargin: 32,
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsetsDirectional.only(top: 12, bottom: 12),
                        children: _buildFundingAlerts(context, widget.alerts),
                      ),
                    ),
                    //List Top Gradient End
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 12.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [StateContainer.of(context).curTheme.backgroundDark00!, StateContainer.of(context).curTheme.backgroundDark!],
                            begin: const AlignmentDirectional(0.5, 1.0),
                            end: const AlignmentDirectional(0.5, -1.0),
                          ),
                        ),
                      ),
                    ),
                    //List Bottom Gradient
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 36.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [StateContainer.of(context).curTheme.backgroundDark00!, StateContainer.of(context).curTheme.backgroundDark!],
                            begin: const AlignmentDirectional(0.5, -1),
                            end: const AlignmentDirectional(0.5, 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildFundingAlerts(BuildContext context, List<FundingResponseItem>? alerts) {
    List<Widget> ret = [];

    if (alerts == null) {
      return [];
    }

    for (final FundingResponseItem alert in alerts) {
      ret.add(
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12,
            end: 12,
            bottom: 20,
          ),
          child: FundingMessageCard(
            title: alert.title,
            shortDescription: alert.shortDescription,
            goalAmountRaw: alert.goalAmountRaw,
            currentAmountRaw: alert.currentAmountRaw,
            onPressed: () {
              Sheets.showAppHeightEightSheet(
                context: context,
                widget: FundingSpecificSheet(
                  alert: alert,
                  hasDismissButton: false,
                ),
              );
            },
          ),
        ),
      );
    }

    if (Platform.isIOS) {
      // add text saying we can't show more alerts on iOS:
      ret.add(
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12,
            end: 12,
            bottom: 20,
          ),
          child: Text(AppLocalization.of(context).iosFundingMessage),
        ),
      );
    }

    return ret;
  }
}

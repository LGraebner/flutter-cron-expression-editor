import 'dart:async';

import 'package:cron_expression_editor/state/cron_expression_model.dart';
import 'package:cron_expression_editor/state/state_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../helper/button_factory.dart';

class CronExpressionDisplay extends ConsumerStatefulWidget {
  CronExpressionDisplay({super.key});

  @override
  _CronExpressionDisplayState createState() => _CronExpressionDisplayState();
}

class _CronExpressionDisplayState extends ConsumerState<CronExpressionDisplay> {
  bool _showCopiedLabel = false;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    return Row(children: <Widget>[
      createMainCronExpressionLabel('${state.cronExpression}', 20.0),
      const SizedBox(width: 10),
      Container(
        width: 50,
          child: Column(
        children: [
          IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: state.cronExpression));
                setState(() {
                  _showCopiedLabel = true;
                });
                Timer(
                    Duration(milliseconds: 2000),
                    () => setState(() {
                          _showCopiedLabel = false;
                        }));
              },
              highlightColor: Colors.green,
              splashRadius: 20,
              icon: Icon(Icons.content_copy, size: 30)),
              SizedBox(height: 5,),
              Text(
                _showCopiedLabel ? 'Copied' : '',
                textAlign: TextAlign.right,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              )
        ],
      )),
      const SizedBox(width: 20),
      createDropDownButton(ref, t)
    ]);
  }

  Widget createDropDownButton(WidgetRef ref, AppLocalizations? t) {
    Map<String, String> cronExamplesMap = <String, String>{
      t!.cron_expression_every_minute: CRON_EXPRESSION_EVERY_MINUTE,
      t!.cron_expression_every_10_minutes: CRON_EXPRESSION_EVERY_10_MINUTES,
      t!.cron_expression_every_hour: CRON_EXPRESSION_EVERY_HOUR,
      t!.cron_expression_twice_a_day: CRON_EXPRESSION_TWICE_A_DAY,
      t!.cron_expression_every_day: CRON_EXPRESSION_EVERY_DAY,
      t!.cron_expression_every_weekday: CRON_EXPRESSION_EVERY_WEEKDAY,
      t!.cron_expression_every_weekend: CRON_EXPRESSION_EVERY_WEEKEND,
      t!.cron_expression_every_week: CRON_EXPRESSION_EVERY_WEEK,
      t!.cron_expression_every_month: CRON_EXPRESSION_EVERY_MONTH,
      t!.cron_expression_every_quarter: CRON_EXPRESSION_EVERY_QUARTER,
    };

    final List<DropdownMenuItem<String>> dropDownItems = [];
    cronExamplesMap.forEach((k, v) {
      dropDownItems.add(new DropdownMenuItem<String>(
        value: v,
        child: Text(k),
      ));
    });

    return DropdownButton<String>(
      value: null,
      // icon: const Icon(Icons.arrow_downward),
      hint: Container(
          padding: EdgeInsets.only(left: 3, right: 5.0),
          child: Text(
            t!.cron_expression_caption_select_example,
            style: TextStyle(fontSize: 16, color: Colors.blueAccent),
          )),
      elevation: 16,
      style: const TextStyle(color: Colors.blueAccent),
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      items: dropDownItems,
      onChanged: (value) =>
          ref.read(cronExpressionProvider.notifier).setCronExpression(value!),
    );
  }
}

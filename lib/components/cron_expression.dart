import 'package:cron_expression_editor/state/cron_expression_model.dart';
import 'package:cron_expression_editor/state/state_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../helper/button_factory.dart';


class CronExpressionDisplay extends ConsumerWidget {
  const CronExpressionDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    return Row(children: <Widget>[
      createMainButton(Icons.edit, () {}),
      const SizedBox(width: 10),
      createMainCronExpressionLabel('${state.cronExpression}', 20.0),
      const SizedBox(width: 10),
      Container(
          child: IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: state.cronExpression));
              },
              icon: Icon(Icons.content_copy, size: 30))),
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
            style: TextStyle(fontSize: 16),
          )),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      items: dropDownItems,
      onChanged: (value) =>
          ref.read(cronExpressionProvider.notifier).setCronExpression(value!),
    );
  }
}

//
// class CronExpressionDisplay extends StatefulWidget {
//
//
//
//   const CronExpressionDisplay({super.key});
//
//   @override
//   State<CronExpressionDisplay> createState() => _CronExpressionDisplayState();
// }
//
// class _CronExpressionDisplayState extends State<CronExpressionDisplay> {
//   final _cronExpressionController =
//       TextEditingController(text: INITIAL_CRON_EXPRESSION);
//
//   String cronExpression = INITIAL_CRON_EXPRESSION;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(children: <Widget>[
//       createMainButton(Icons.edit, () {}),
//       const SizedBox(width: 10),
//       Consumer(builder: (_, WidgetRef ref, __) {
//         final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
//         cronExpression = state.cronExpression;
//         return createMainCronExpressionLabel('${state.cronExpression}', 20.0);
//       }),

// Expanded(
//   child: Container(
//     decoration: BoxDecoration(
//       color: Colors.white70,
//       border: Border.all(
//         color: Colors.blueAccent,
//         width: 2,
//       ),
//       borderRadius: BorderRadius.circular(5),
//     ),
//     padding: const EdgeInsets.all(10.0),
//     margin: const EdgeInsets.only(top: 5.0),
//     child: Consumer(
//       builder: (_, WidgetRef ref, __) {
//         final state =
//             ref.watch(cronExpressionProvider) as CronExpressionModel;
//         return Text(
//           '${state.cronExpression}',
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//               color: Colors.black87),
//           textAlign: TextAlign.left,
//         );
//       },
//     ),
//   ),
// ),
//
//     const SizedBox(width: 10),
//     Container(
//         child: IconButton(
//             onPressed: () async {
//               await Clipboard.setData(ClipboardData(text: cronExpression));
//             },
//             icon: Icon(Icons.content_copy, size: 30))),
//     const SizedBox(width: 20),
//     createDropDownButton(),
//   ]);
// }
//
// @override
// void initState() {
//   // TODO: implement initState
//   super.initState();
//   _cronExpressionController.addListener(_printLatestValue);
// }
//
// @override
// void dispose() {
//   // Clean up the controller when the widget is removed from the
//   // widget tree.
//   _cronExpressionController.dispose();
//   super.dispose();
// }

// void _printLatestValue() {
//   print('Second text field: ${_cronExpressionController.text}');
//   _cronExpressionController.value = TextEditingValue(
//     text: 'test',
//     selection: TextSelection.fromPosition(
//       TextPosition(offset: 'test'.length),
//     ),
//   );
// }
// }

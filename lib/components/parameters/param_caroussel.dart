import 'package:cron_expression_editor/components/parameters/param_day_of_month.dart';
import 'package:cron_expression_editor/components/parameters/param_day_of_week.dart';
import 'package:cron_expression_editor/components/parameters/param_hours.dart';
import 'package:cron_expression_editor/components/parameters/param_minutes.dart';
import 'package:cron_expression_editor/components/parameters/param_month.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final double paramBodyHeight = 400;
final double paramBodyWidth = 700;
final double paramHeaderFontSize = 16;

class ParamCaroussel extends StatefulWidget {
  const ParamCaroussel({super.key});

  @override
  State<ParamCaroussel> createState() => _ParamCarousselState();
}

List<Item> generateItems(List<Item> parameterItems, BuildContext context) {
  if (!parameterItems.isEmpty) {
    return parameterItems;
  }
  var t = AppLocalizations.of(context);
  parameterItems.add(new Item(
      expandedValue:
          Container(alignment: Alignment.topLeft, child: Container(height: paramBodyHeight, width: paramBodyWidth, child: ParamMinutes(),)),

      headerValue: t!.param_minutes),

  );
  parameterItems.add(new Item(
      expandedValue:
      Container(alignment: Alignment.topLeft, child: Container(height: paramBodyHeight, width: paramBodyWidth, child: ParamHours(),)),
      headerValue: t!.param_hours),
  );
  parameterItems.add(new Item(
      expandedValue:
      Container(alignment: Alignment.topLeft, child: Container(height: paramBodyHeight, width: paramBodyWidth, child: ParamDayOfMonth(),)),
      headerValue: t!.param_day_of_month),
  );
  parameterItems.add(new Item(
      expandedValue:
      Container(alignment: Alignment.topLeft, child: Container(height: paramBodyHeight, width: paramBodyWidth, child: ParamMonth(),)),
      headerValue: t!.param_month),
  );
  parameterItems.add(new Item(
      expandedValue:
      Container(alignment: Alignment.topLeft, child: Container(height: paramBodyHeight, width: paramBodyWidth, child: ParamDayOfWeek(),)),
      headerValue: t!.param_day_of_week),
  );

  return parameterItems;
}

class _ParamCarousselState extends State<ParamCaroussel> {

  List<Item> _data = [];

  @override
  Widget build(BuildContext context) {
    _data = generateItems(_data, context);

    return
      Column(
        children: [
              createParamsCaroussel()
        ]
      );
  }

  Widget createParamsCaroussel()  {

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          backgroundColor: Colors.white70,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              // tileColor: Colors.white54,
              // selectedTileColor: Colors.white54,
              selectedColor: Colors.white,
              focusColor: Colors.white,

              title: Text(item.headerValue, style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: paramHeaderFontSize),),
              onTap:  () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                  // int i = _data.indexWhere((Item currentItem) => item == currentItem);
                  // _data[i].isExpanded = !item.isExpanded;
                });
              },
            );
          },
          body: ListTile(
              tileColor: Colors.white,
              title: Column(children: [item.expandedValue],),

          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );

  }


}

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedValue;
  String headerValue;
  bool isExpanded;
}
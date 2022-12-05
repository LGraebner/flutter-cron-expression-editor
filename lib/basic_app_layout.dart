import 'package:flutter/material.dart';

class BasicAppLayout extends StatefulWidget {
  const BasicAppLayout({super.key, required this.title});

  final String title;

  @override
  State<BasicAppLayout> createState() => _BasicAppLayoutState();
}

class _BasicAppLayoutState extends State<BasicAppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              Row(children: <Widget>[
                createMainButton(Icons.edit),
                const SizedBox(width: 10),
                const Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Cron Expression'),
                )),
                const SizedBox(width: 10),
                createMainButton(Icons.content_copy),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    flex: 7,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          createHeading('Parameters'),
                          // createScheduleTable()
                        ])),
                Expanded(
                    flex: 3,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          createHeading('Schedule'),
                          createScheduleTable()
                        ]))
              ])
            ])));
  }
}

Widget createHeading(String title) {
  return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(10.0),
      color: Colors.blue,
      alignment: Alignment.topLeft,
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.amber,
            color: Colors.white),
      ));
}

Widget createMainButton(IconData iconData) {
  return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey, width: 1),
      //   shape: BoxShape.circle,
      // ),
      child: IconButton(onPressed: () {}, icon: Icon(iconData, size: 30)));
}

Widget createScheduleTable() {
  return DataTable(
    columns: const <DataColumn>[
      DataColumn(
        label: Text('Date'),
      ),
      DataColumn(
        label: Text('Time'),
      ),
    ],
    rows: List<DataRow>.generate(
      10,
      (int index) => DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          // All rows will have the same selected color.
          // if (states.contains(MaterialState.selected)) {
          //   return Theme.of(ColorScheme.(brightness: brightness, primary: primary, onPrimary: onPrimary, secondary: secondary, onSecondary: onSecondary, error: error, onError: onError, background: background, onBackground: onBackground, surface: surface, onSurface: onSurface) colorScheme.primary.withOpacity(0.08);
          // }
          // Even rows will have a grey color.
          if (index.isEven) {
            return Colors.grey.withOpacity(0.3);
          }
          return null; // Use default value for other states and odd rows.
        }),
        cells: <DataCell>[
          DataCell(Text('Row $index')),
          DataCell(Text('Row $index'))
        ],
        // selected: selected[index],
        // onSelectChanged: (bool? value) {
        //   setState(() {
        //     selected[index] = value!;
        //   });
        // },
      ),
    ),
  );
}

# flutter_sticky_table

flutter table with sticky header and sticky left column

## Getting Started

### add dependencies

```
   flutter_sticky_table: any
```

### import flutter_sticky_table

```
import 'package:flutter_sticky_table/flutter_sticky_table.dart';
```

### use table widget
```
/// first: define columns and data
dynamic columns = [
  new ColumnsProps('22', 'key1',
      alignment: Alignment.center,
      width: 80.0,
      color: Colors.yellow,
      headColor: Colors.cyan),
  new ColumnsProps('列23', 'key2',
      alignment: Alignment.centerLeft, width: 400.0),
  new ColumnsProps('列3', 'key3', alignment: Alignment.center),
  new ColumnsProps('列3', 'key3', alignment: Alignment.center, width: 200,
      render: (BuildContext c, dynamic d) {
    return new Material(
      child: new FlatButton(
          onPressed: () {
            showDialog(context: context, child: Text('aaa'));
          },
          child: Text('button')),
    );
  }),
];
dynamic data = [
  {'key1': '1', 'key2': 'data2', 'key3': 'xx'},
  {'key1': '11', 'key2': 'data22', 'key3': 'xxxx'},
  {'key1': '111', 'key2': 'data22', 'key3': 'xxxxxx'}
];

/// second: use widget to show table
new SingleChildScrollView(
    child: new Columns(
        children: [
            ...
            StickyTable(stickyColumnCount: 1,
                        columns: columns,
                        data: data,
                        showBorder: true),
            ...
        ]
    ));

```
A library for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:action_box/action_box.dart';
//add
import 'example.config.dart';

@ActionBoxConfig(
    actionBoxType: 'SpcActionBox',
    actionRootType: 'ActionRoot',
    generateSourceDir: ['*']
)
final actionBox = SpcActionBox.instance;
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/yookjy/action_box_generator/issues

import 'package:action_box_generator/builder.dart';
//add
import 'example.config.dart';

@ActionCenterConfig(
  actionBoxTypeName: 'SpcActionBox',
  actionRootTypeName: 'ActionRoot',
  generateForDir: ['*']
)
final actionBox = SpcActionBox.instance;

void howToUse() {
  //request data
  actionBox.dispatch(actionChooser: (d) => d.valueConverter.getStringInStringOutValue);
  //or
  actionBox(
    actionChooser: (root) => root.valueConverter.getStringInStringOutValue,
    parameter: 'test',
  );

  //subscribe result
  actionBox.subscribe(
    actionChooser: (d) => d.valueConverter.getStringInStringOutValue,
    onNext: (String result) {
      print(result);
    }
  );

}
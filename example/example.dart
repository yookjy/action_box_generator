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
  actionBox.dispatch(action: (d) => d.valueConverter.getStringInStringOutValue);
  //or
  actionBox(
    action: (root) => root.valueConverter.getStringInStringOutValue,
    param: 'test',
  );

  //subscribe result
  actionBox.subscribe(
    action: (d) => d.valueConverter.getStringInStringOutValue,
    onNext: (String result) {
      print(result);
    }
  );

}
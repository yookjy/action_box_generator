import 'package:action_box/action_box.dart';
//add
import 'example.config.dart';

@ActionBoxConfig(
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
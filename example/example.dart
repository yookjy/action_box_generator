import 'package:action_box/action_box.dart';
//add
import 'example.a.b.dart';

@ActionBoxConfig(
  actionBoxType: 'SpcActionBox',
  actionRootType: 'ActionRoot',
  generateSourceDir: ['*']
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
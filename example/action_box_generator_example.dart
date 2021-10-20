import 'package:action_box/action_box.dart';
//add
import 'action_box_generator_example.a.b.dart';

@ActionBoxConfig(
    actionBoxType: 'SpcActionBox',
    actionRootType: 'ActionRoot',
    generateSourceDir: ['lib', 'example'])
final actionBox = SpcActionBox.instance;

//How to use
void main() {
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
      });
}

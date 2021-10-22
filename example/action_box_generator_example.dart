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
  var bag = DisposeBag();

  //request data
  actionBox.go(
    action: (root) => root.valueConverter.getStringInStringOutValue,
    param: 'test',
  );

  //subscribe result
  actionBox(action: (d) => d.valueConverter.getStringInStringOutValue)
      .listen((result) {
    print(result);
  }).disposedBy(bag);

  //call dispose method when completed
  //bag.dispose();
}

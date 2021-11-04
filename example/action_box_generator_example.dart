import 'package:action_box/action_box.dart';
//add
import 'action_box_generator_example.a.b.dart';

@ActionBoxConfig(
    // actionBoxType: 'ActionBox', //default value
    // actionRootType: 'ActionRoot',  //default value
    generateSourceDir: ['lib', 'example'])
final actionBox = ActionBox.shared();

//How to use
void main() {
  var bag = DisposeBag();

  //request data
  actionBox((root) => root.valueConverter.getStringInStringOutValue)
      .go(param: 'test', channel: (c) => c.exCh1);

  //subscribe result
  actionBox((d) => d.valueConverter.getStringInStringOutValue)
      .map(channel: (c) => c.exCh1 | c.exCh2)
      .listen((result) {
    print(result);
  }).disposedBy(bag);

  //call dispose method when completed
  //bag.dispose();
}

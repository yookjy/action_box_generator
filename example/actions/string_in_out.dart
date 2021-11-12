import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'getStringInStringOutValue', parents: ['valueConverter'])
class StringInStringOut extends Action<String, String> {
  Channel exCh1 = Channel();
  Channel exCh2 = Channel();
  Channel exCh3 = Channel();

  @override
  Stream<String> process([String? param]) {
    return Stream.value('(변환됨) $param');
  }
}

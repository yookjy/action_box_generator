import 'package:action_box/action_box.dart';

@ActionConfig(
    alias: 'getIntToStringValue',
    parents: ['valueConverter.valueConverter.valueConverter'])
class IntInStringOut extends Action<int, String?> {
  Channel exCh1 = Channel();
  Channel exCh2 = Channel();
  Channel exCh3 = Channel();

  @override
  Stream<String?> process([int? param]) {
    return Stream.value(param?.toString());
  }
}

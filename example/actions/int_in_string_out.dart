
import 'package:action_box/action_box.dart';
import 'package:action_box_generator/builder.dart';

@ActionConfig(descriptorName: 'getIntToStringValue', registerTo: 'valueConverter')
class IntInStringOut extends Action<int, String> {

  Channel exCh1 = Channel();
  Channel exCh2 = Channel();
  Channel exCh3 = Channel();

  @override
  Stream<String?> process([int? param]) {
    return Stream.value(param?.toString());
  }
}

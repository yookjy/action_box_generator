import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'getStringToListValue', parents: ['valueConverter'])
class StringInListOut extends Action<void, List<Model>?> {
  @override
  Stream<List<Model>?> process([void param]) {
    return Stream.value([Model('a'), Model('b'), Model('c')]);
  }
}

class Model {
  final String value;
  const Model(this.value);
}

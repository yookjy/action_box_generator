import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'getStringToListValue', parents: ['valueConverter'])
class StringInListOut extends Action<String, List<Model?>?> {
  @override
  Stream<List<Model>?> process([String? param]) {
    return Stream.value([Model('a'), Model('b'), Model('c')]);
  }
}

class Model {
  final String value;
  const Model(this.value);
}

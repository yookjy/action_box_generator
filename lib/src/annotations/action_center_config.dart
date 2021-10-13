
class ActionCenterConfig {
  final String actionCenterTypeName;
  final String actionRootTypeName;
  final List<String> generateForDir;

  const ActionCenterConfig({
    required this.actionCenterTypeName,
    required this.actionRootTypeName,
    this.generateForDir = const ['lib']});
}



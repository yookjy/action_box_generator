import 'package:action_box_generator/builder.dart';
//add
import 'example.config.dart';

@ActionCenterConfig(
  actionCenterTypeName: 'SpcActionCenter',
  actionRootTypeName: 'ActionRoot',
  generateForDir: ['*']
)
final SpcActionCenter actionCenter = SpcActionCenter();
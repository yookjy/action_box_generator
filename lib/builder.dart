library action_box_generator;

import 'package:action_box_generator/src/generators/action_config_generator.dart';
import 'package:action_box_generator/src/generators/action_meta_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder actionBuilder(BuilderOptions options) {
  return LibraryBuilder(
    ActionMetaGenerator(options.config),
    formatOutput: (generated) => generated.replaceAll(RegExp(r'//.*|\s'), ''),
    generatedExtension: '.action.json',
  );
}

Builder actionConfigBuilder(BuilderOptions options) {
  return LibraryBuilder(
      ActionConfigGenerator(),
      generatedExtension: '.config.dart'
  );
}
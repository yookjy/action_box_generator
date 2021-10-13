library test;


import 'package:action_box_generator/builder.dart';

import 'example.config.dart';


@ActionCenterConfig(actionCenterTypeName: 'SpcActionCenter', actionRootTypeName: 'ActionRoot', generateForDir: ['*'])
final SpcActionCenter actionCenter = SpcActionCenter();


// class ActionBuilder<TParam, TResult, TAction extends Action<TParam, TResult>> extends StreamBuilder<TResult> {
//   ActionBuilder({
//     Key? key,
//     required ActionDescriptor<TAction, TParam, TResult> Function(ActionGroup set) actionChooser, //ActionGroup 제너레이트
//     required AsyncWidgetBuilder<TResult> builder,
//     TResult? initialData,
//     Channel Function(TAction)? channelChooser,
//     Stream<TResult>? Function(Stream<TResult>)? streamHandler,
//   }) : super(
//     key: key,
//     initialData: initialData,
//     stream: SpcActionCenter.getStreamForSubscription(
//       actionChooser: actionChooser,
//       channelChooser: channelChooser,
//       streamHandler: streamHandler
//     ),
//     builder : builder,
//   );
//
// }
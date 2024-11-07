import 'package:flutter/widgets.dart';
import 'package:flutter_pods/flutter_pods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pods/pods.dart';

abstract class BrickWidget extends ConsumerStatefulWidget {
  const BrickWidget({super.key});

  Widget build(BuildContext context, PodRef ref);

  @override
  // ignore: library_private_types_in_public_api
  _ConsumerState createState() => _ConsumerState();
}

class _ConsumerState extends ConsumerState<BrickWidget> {
  @override
  WidgetRef get ref => context as WidgetRef;

  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref.s);
  }
}

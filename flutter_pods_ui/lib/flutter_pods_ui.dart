import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pods/flutter_pods.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pods/pods.dart';

class PodsTextField extends HookConsumerWidget {
  const PodsTextField(this.pod, {super.key});

  final MutPod<String> pod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: pod.watch(ref.s));
    pod.listen(ref.s, (previous, next) {
      // print('previous: $previous, next: $next');
      if (previous == next) {
        // print('previous == next');
        return;
      }
      textController.text = next;
    });

    return TextField(
      controller: textController,
      onChanged: (value) {
        pod.update(ref.s, value);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_pods/flutter_pods.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pods/pods.dart';

class PodsToggleButton extends ConsumerWidget {
  const PodsToggleButton({
    required this.pod,
    required this.builder,
    super.key,
  });

  final MutPod<bool> pod;
  final Widget Function(bool state, void Function() onToggle) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = pod.watch(ref.s);
    return builder(
      value,
      () {
        pod.update(ref.s, !value);
      },
    );
  }
}

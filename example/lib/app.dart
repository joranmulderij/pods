import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase_pods/pocketbase_pods.dart';
import 'package:pods/pods.dart';

final baseUrlPod = constPod('https://joranmulderij.com');

final pbClientPod = pocketBasePod(baseUrlPod);

final pagesPod = pocketBaseMutableRecordPod<String>(
  collectionName: 'pages',
  fromJson: (json) => jsonEncode(json),
  toJson: (value) => jsonDecode(value),
  pbClientPod: pbClientPod,
);

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pbClient = ref.watch(pbClientPod());
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  log('hi');
                },
                child: const Text("Hello, World!"),
              ),
              Text(pbClient.toString())
            ],
          ),
        ),
      ),
    );
  }
}

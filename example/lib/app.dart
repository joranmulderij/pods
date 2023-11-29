import 'package:flutter/material.dart';
import 'package:flutter_pods/flutter_pods.dart';
import 'package:flutter_pods_ui/flutter_pods_ui.dart';
import 'package:flutter_pods_ui/toggle_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase_pods/pocketbase_pods.dart';
import 'package:pods/pods.dart';

final baseUrlPod = constPod('http://localhost:8090/');

class Post {
  Post({
    required this.id,
    required this.title,
    required this.body,
    this.liked = false,
  });

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        body = json['body'],
        liked = json['liked'] ?? false;

  final String id;
  final String title;
  final String body;
  final bool liked;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'liked': liked,
      };

  Post copyWith({
    String? id,
    String? title,
    String? body,
    bool? liked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      liked: liked ?? this.liked,
    );
  }
}

final pbClientPod = pocketBasePod(baseUrlPod);

final delayDurationPod = constPod(const Duration(milliseconds: 500));

final pagesPod = pocketBaseMutableRecordPod<Post>(
  collectionName: 'posts',
  fromJson: (json) => Post.fromJson(json),
  toJson: (value) => value.toJson(),
  pbClientPod: pbClientPod,
  debounceDurationPod: delayDurationPod,
);

final pagesTitlePod = pagesPod.property(
  getChild: (parent) => parent.title,
  updateParent: (parent, child) => parent.copyWith(title: child),
  defaultChild: () => '',
);

final pagesLikedPod = pagesPod.property(
  getChild: (parent) => parent.liked,
  updateParent: (parent, child) => parent.copyWith(liked: child),
  defaultChild: () => false,
);

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesTitlePodTemp = pagesTitlePod.child('bg2p2gdn81cok14');
    final pagesTitle = pagesTitlePodTemp.watch(ref.s);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            pagesTitle.when(
              data: (data) => Text(data),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text(err.toString()),
            ),
            PodsTextField(pagesTitlePodTemp.sync(() => 'loading')),
            PodsToggleButton(
              pod: pagesLikedPod.child('bg2p2gdn81cok14').sync(() => false),
              builder: (state, onToggle) {
                return IconButton(
                  icon: Icon(state ? Icons.favorite : Icons.favorite_border),
                  onPressed: onToggle,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

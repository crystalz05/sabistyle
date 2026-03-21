import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts a [Stream] into a [Listenable] that GoRouter can use as its
/// `refreshListenable`. Every time the stream emits an event GoRouter
/// re-evaluates its `redirect` callback, ensuring the auth guard is
/// always up-to-date without any manual navigation calls in widgets.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Stream<dynamic> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_prefill.dart';

class SearchPrefillNotifier extends Notifier<SearchPrefill?> {
  @override
  SearchPrefill? build() => null;

  void set(SearchPrefill prefill) {
    state = prefill;
  }

  void clear() {
    state = null;
  }
}

final searchPrefillProvider =
    NotifierProvider<SearchPrefillNotifier, SearchPrefill?>(
      SearchPrefillNotifier.new,
    );

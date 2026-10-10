/// Search helpers for the food list.
///
/// The food database is mostly USDA entries, so a plain "contains" search for
/// "banana" returns baby food purées and banana chips before plain bananas,
/// and "chicken breast" finds nothing because the names read
/// "Chicken (Broilers Or Fryers, Breast, ...)".
library;

List<String> _words(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9à-ÿ]+'))
    .where((w) => w.isNotEmpty)
    .toList();

/// True when every word typed appears somewhere in [name], in any order.
bool foodMatchesQuery(String name, String query) {
  final queryWords = _words(query);
  if (queryWords.isEmpty) return true;
  final lower = name.toLowerCase();
  return queryWords.every(lower.contains);
}

/// Lower is better. Names that start with the query come first, then names
/// with a word starting with it, then anything else; baby food goes last
/// unless the person searched for it.
int foodSearchRank(String name, String query) {
  final lower = name.toLowerCase();
  final q = query.trim().toLowerCase();
  int rank;
  if (q.isEmpty) {
    rank = 0;
  } else if (lower.startsWith(q)) {
    rank = 0;
  } else if (_words(name).any((w) => w.startsWith(_words(q).first))) {
    rank = 1;
  } else {
    rank = 2;
  }
  if (lower.contains('babyfood') && !q.contains('baby')) rank += 3;
  return rank;
}

/// Filters [items] by [query] and orders them by [foodSearchRank], keeping the
/// original order (favourites and most used first) within each rank.
List<T> searchFoods<T>(List<T> items, String query, String Function(T) nameOf) {
  final matches = <(int, int, T)>[];
  for (var i = 0; i < items.length; i++) {
    final name = nameOf(items[i]);
    if (foodMatchesQuery(name, query)) {
      matches.add((foodSearchRank(name, query), i, items[i]));
    }
  }
  matches.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  return [for (final m in matches) m.$3];
}

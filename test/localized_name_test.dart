import 'package:fitness_tracker_app/utils/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localizedName prefers the name the server sent in the app language', () {
    expect(localizedName({'name': 'Almonds', 'display_name': 'Amandes'}), 'Amandes');
    expect(
      localizedName({'description': 'Run', 'display_description': 'Courir'}, field: 'description'),
      'Courir',
    );
  });

  test('localizedName falls back to the plain name', () {
    expect(localizedName({'name': 'Almonds', 'display_name': ''}), 'Almonds');
    expect(localizedName({'name': 'Almonds'}), 'Almonds');
    expect(localizedName({}, fallback: 'Unknown'), 'Unknown');
  });
}

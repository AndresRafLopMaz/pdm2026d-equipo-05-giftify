import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/features/profile/widgets/user_avatar.dart';

void main() {
  test('iniciales de nombre y apellido', () {
    expect(initialsForName('Andrés López'), 'AL');
  });

  test('una sola palabra usa una inicial', () {
    expect(initialsForName('Andrés'), 'A');
  });

  test('nombre vacío usa signo de interrogación', () {
    expect(initialsForName('   '), '?');
  });

  test('más de dos palabras usa primera y última', () {
    expect(initialsForName('Ana María de la Cruz'), 'AC');
  });
}

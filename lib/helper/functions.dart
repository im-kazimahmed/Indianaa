import 'dart:math';

String generateRandomTransactionId(int length) {
  const chars = '0123456789';
  final random = Random.secure();

  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
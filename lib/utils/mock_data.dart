class MockData {
  static List<String> generateItems(int count, {String prefix = 'Item'}) {
    return List<String>.generate(count, (i) => '$prefix #${i + 1}');
  }

  static List<int> durationsMs() => [300, 800, 1500];
}

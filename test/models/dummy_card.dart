class DummyCard {
  final int id;
  final String suit;
  final int rank;
  final bool isTrump;

  const DummyCard({
    this.id = 0,
    this.suit = 'hearts',
    this.rank = 7,
    this.isTrump = false,
  });

  @override
  String toString() => '$rank of $suit${isTrump ? " (Trump)" : ""}';
}
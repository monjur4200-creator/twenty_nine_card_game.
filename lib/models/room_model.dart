class RoomModel {
  final String roomId;
  final String hostId;
  final List<String> players;
  final bool isPrivate;
  final String status;

  RoomModel({
    required this.roomId,
    required this.hostId,
    required this.players,
    required this.isPrivate,
    required this.status,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      hostId: map['hostId'] ?? '',
      players: List<String>.from(map['players'] ?? []),
      isPrivate: map['isPrivate'] ?? false,
      status: map['status'] ?? 'waiting',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hostId': hostId,
      'players': players,
      'isPrivate': isPrivate,
      'status': status,
    };
  }
}
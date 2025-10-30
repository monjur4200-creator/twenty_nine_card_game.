import 'room_models.dart';

class LobbyModel {
  final List<RoomModel> rooms;

  LobbyModel({this.rooms = const []});

  /// Deserialize from Firestore or local map
  factory LobbyModel.fromMap(Map<String, dynamic> map) {
    final roomList = (map['rooms'] as List<dynamic>? ?? [])
        .map((r) => RoomModel.fromMap(Map<String, dynamic>.from(r)))
        .toList();
    return LobbyModel(rooms: roomList);
  }

  /// Serialize to Firestore or local map
  Map<String, dynamic> toMap() => {
    'rooms': rooms.map((r) => r.toMap()).toList(),
  };

  /// Create a copy with optional updated rooms
  LobbyModel copyWith({List<RoomModel>? rooms}) {
    return LobbyModel(rooms: rooms ?? List<RoomModel>.from(this.rooms));
  }

  /// Add a new room
  LobbyModel addRoom(RoomModel room) => copyWith(rooms: [...rooms, room]);

  /// Remove a room by ID
  LobbyModel removeRoom(String roomId) =>
      copyWith(rooms: rooms.where((r) => r.roomId != roomId).toList());

  /// Find a room by ID
  RoomModel? findRoom(String roomId) {
    try {
      return rooms.firstWhere((r) => r.roomId == roomId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a room exists
  bool hasRoom(String roomId) => findRoom(roomId) != null;

  /// Count rooms by status
  int roomCountByStatus(RoomStatus status) =>
      rooms.where((r) => r.status == status).length;

  /// Count active rooms
  int get activeRoomCount =>
      rooms.where((room) => room.status == RoomStatus.active).length;

  /// Filter rooms
  List<RoomModel> get publicRooms => rooms.where((r) => !r.isPrivate).toList();

  List<RoomModel> get privateRooms => rooms.where((r) => r.isPrivate).toList();

  List<RoomModel> get waitingRooms =>
      rooms.where((r) => r.status == RoomStatus.waiting).toList();

  List<RoomModel> get finishedRooms =>
      rooms.where((r) => r.status == RoomStatus.finished).toList();

  @override
  String toString() => 'LobbyModel(rooms: $rooms)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LobbyModel && _listEquals(rooms, other.rooms);

  @override
  int get hashCode => rooms.hashCode;

  static bool _listEquals(List<RoomModel> a, List<RoomModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

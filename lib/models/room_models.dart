enum RoomStatus {
  waiting,
  active,
  finished;

  static List<String> get names =>
      RoomStatus.values.map((e) => e.name).toList();
}

class RoomModel {
  final String roomId;
  final String hostId;
  final List<String> players;
  final bool isPrivate;
  final RoomStatus status;

  RoomModel({
    required this.roomId,
    required this.hostId,
    required this.players,
    required this.isPrivate,
    required this.status,
  }) : assert(roomId.isNotEmpty),
       assert(hostId.isNotEmpty);

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    final statusString = map['status'] as String? ?? 'waiting';
    final status = RoomStatus.values.firstWhere(
      (s) => s.name == statusString,
      orElse: () => RoomStatus.waiting,
    );

    return RoomModel(
      roomId: map['roomId'] as String? ?? '',
      hostId: map['hostId'] as String? ?? '',
      players: List<String>.from(map['players'] ?? []),
      isPrivate: map['isPrivate'] as bool? ?? false,
      status: status,
    );
  }

  Map<String, dynamic> toMap() => {
    'roomId': roomId,
    'hostId': hostId,
    'players': players,
    'isPrivate': isPrivate,
    'status': status.name,
  };

  RoomModel copyWith({
    String? roomId,
    String? hostId,
    List<String>? players,
    bool? isPrivate,
    RoomStatus? status,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      hostId: hostId ?? this.hostId,
      players: players ?? List<String>.from(this.players),
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
    );
  }

  bool isHost(String playerId) => hostId == playerId;

  @override
  String toString() =>
      'RoomModel(roomId: $roomId, hostId: $hostId, players: $players, isPrivate: $isPrivate, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomModel &&
          roomId == other.roomId &&
          hostId == other.hostId &&
          isPrivate == other.isPrivate &&
          status == other.status &&
          _listEquals(players, other.players);

  @override
  int get hashCode =>
      roomId.hashCode ^
      hostId.hashCode ^
      isPrivate.hashCode ^
      status.hashCode ^
      players.hashCode;

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class LobbyModel {
  final List<RoomModel> rooms;

  LobbyModel({this.rooms = const []});

  factory LobbyModel.fromMap(Map<String, dynamic> map) {
    final roomList = (map['rooms'] as List<dynamic>? ?? [])
        .map((r) => RoomModel.fromMap(Map<String, dynamic>.from(r)))
        .toList();
    return LobbyModel(rooms: roomList);
  }

  Map<String, dynamic> toMap() => {
    'rooms': rooms.map((r) => r.toMap()).toList(),
  };

  LobbyModel copyWith({List<RoomModel>? rooms}) {
    return LobbyModel(rooms: rooms ?? List<RoomModel>.from(this.rooms));
  }

  LobbyModel addRoom(RoomModel room) => copyWith(rooms: [...rooms, room]);

  LobbyModel removeRoom(String roomId) =>
      copyWith(rooms: rooms.where((r) => r.roomId != roomId).toList());

  RoomModel? findRoom(String roomId) {
    try {
      return rooms.firstWhere((r) => r.roomId == roomId);
    } catch (_) {
      return null;
    }
  }

  bool hasRoom(String roomId) => findRoom(roomId) != null;

  int roomCountByStatus(RoomStatus status) =>
      rooms.where((r) => r.status == status).length;

  List<RoomModel> get publicRooms => rooms.where((r) => !r.isPrivate).toList();

  List<RoomModel> get privateRooms => rooms.where((r) => r.isPrivate).toList();

  List<RoomModel> get waitingRooms =>
      rooms.where((r) => r.status == RoomStatus.waiting).toList();

  List<RoomModel> get activeRooms =>
      rooms.where((r) => r.status == RoomStatus.active).toList();

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

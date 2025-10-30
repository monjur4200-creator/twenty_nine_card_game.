// lib/game_logic/phases/phase.dart
/// Represents a unit of game flow (bidding, trick play, scoring, etc.).
abstract class Phase<TState> {
  /// Human-readable name for logs/analytics.
  String get name;

  /// True when this phase can accept actions.
  bool get isActive;

  /// Initialize phase with the current game state.
  void start(TState state);

  /// Attempt a phase-specific action; returns updated state.
  TState handleAction(TState state, PhaseAction action);

  /// Attempt to complete/exit the phase; returns updated state.
  /// Throws if the exit criteria are not met.
  TState complete(TState state);
}

/// Standardized action envelope so the state machine can route calls cleanly.
class PhaseAction {
  final String type; // e.g., 'play_card', 'reveal_trump'
  final Map<String, Object?> payload;

  PhaseAction(this.type, {this.payload = const {}});
}

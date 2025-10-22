// lib/game_logic/state_machine/game_phase_machine.dart
import '../game_errors.dart';
import '../phases/phase.dart';

/// A simple phase controller that owns one active phase at a time.
class GamePhaseMachine<TState> {
  Phase<TState>? _active;
  TState _state;

  GamePhaseMachine({required TState initialState}) : _state = initialState;

  Phase<TState>? get activePhase => _active;
  TState get state => _state;

  /// Start a new phase; ensures only one active phase exists.
  void start(Phase<TState> phase) {
    if (_active != null && _active!.isActive) {
      throw GameError(
        code: GameErrorCode.stateTransitionBlocked,
        message: 'Cannot start new phase: another phase is active',
        context: {'currentPhase': _active!.name, 'nextPhase': phase.name},
      );
    }
    _active = phase;
    _active!.start(_state);
  }

  /// Route an action into the active phase.
  void dispatch(PhaseAction action) {
    if (_active == null || !_active!.isActive) {
      throw GameError(
        code: GameErrorCode.stateTransitionBlocked,
        message: 'No active phase to dispatch action',
      );
    }
    _state = _active!.handleAction(_state, action);
  }

  /// Complete the active phase and clear it.
  void completeActivePhase() {
    if (_active == null || !_active!.isActive) {
      throw GameError(
        code: GameErrorCode.stateTransitionBlocked,
        message: 'No active phase to complete',
      );
    }
    _state = _active!.complete(_state);
    _active = null;
  }
}

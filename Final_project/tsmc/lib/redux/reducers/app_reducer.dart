import '../states/app_state.dart';
import '../actions/connection_actions.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is UpdateConnectionStateAction) {
    return state.copyWith(
      connectionState: action.connectionState,
      connectedDevice: action.device,
    );
  }
  return state;
} 
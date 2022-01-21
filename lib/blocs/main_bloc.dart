import 'package:rxdart/subjects.dart';

class MainBloc {
  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();

  Stream<MainPageState> observeMainPageState() => stateSubject;

  MainBloc() {
    stateSubject.add(MainPageState.noFavirotes);
  }

  void nextState() {
    final currentState = stateSubject.value;

    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];

    stateSubject.add(nextState);
  }

  void dispose() {
    stateSubject.close();
  }
}

enum MainPageState {
  noFavirotes,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

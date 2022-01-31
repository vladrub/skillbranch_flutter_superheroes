import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoritesSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);

  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);

    textSubscription =
        Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
      currentTextSubject
          .distinct()
          .debounceTime(const Duration(milliseconds: 500)),
      favoritesSuperheroesSubject,
      (searchText, favorites) =>
          MainPageStateInfo(searchText, favorites.isNotEmpty),
    ).listen((value) {
      print("changed ${value.searchText}");
      searchSubscription?.cancel();

      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }

  void dispose() {
    stateSubject.close();
    favoritesSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
    searchSubscription?.cancel();
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);

    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchedSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(const Duration(seconds: 1));
    // throw Exception();
    return SuperheroInfo.mocked;
  }

  void nextState() {
    final currentState = stateSubject.value;

    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];

    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? "");
  }

  Stream<List<SuperheroInfo>> observeFavoritesSuperheroes() =>
      favoritesSuperheroesSubject;

  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Stream<MainPageState> observeMainPageState() => stateSubject;
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperheroInfo &&
        other.name == name &&
        other.realName == realName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  @override
  String toString() =>
      'SuperheroeInfo(name: $name, realName: $realName, imageUrl: $imageUrl)';

  static const mocked = [
    SuperheroInfo(
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl:
          "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
    ),
    SuperheroInfo(
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg",
    ),
    SuperheroInfo(
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/22.jpg",
    ),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  MainPageStateInfo(this.searchText, this.haveFavorites);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MainPageStateInfo &&
        other.searchText == searchText &&
        other.haveFavorites == haveFavorites;
  }

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;

  @override
  String toString() =>
      'MainPageStateInfo(searchText: $searchText, haveFavorites: $haveFavorites)';
}

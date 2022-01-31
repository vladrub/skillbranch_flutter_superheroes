import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

    return Stack(
      children: [
        MainPageStateWidget(),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: SearchWidget(),
        )
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

      controller.addListener(() => bloc.updateText(controller.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        isDense: true,
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.white54,
          size: 24,
        ),
        suffix: GestureDetector(
          onTap: () => controller.clear(),
          child: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return const LoadingIndicator();
          case MainPageState.noFavorites:
            return const NoFavoritesWidget();
          case MainPageState.minSymbols:
            return const MinSymbolsWidget();
          case MainPageState.nothingFound:
            return const NothingFoundWidget();
          case MainPageState.loadingError:
            return const LoadingErrorWidget();
          case MainPageState.searchResults:
            return SuperheroesList(
              title: "Search results",
              stream: bloc.observeSearchedSuperheroes(),
            );
          case MainPageState.favorites:
            return SuperheroesList(
              title: "Your favorites",
              stream: bloc.observeFavoritesSuperheroes(),
            );
          default:
            return Center(
              child: Text(
                snapshot.data.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
        }
      },
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final List<SuperheroInfo> superheroes = snapshot.data!;
        return ListView.separated(
          itemCount: superheroes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 90, bottom: 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              );
            }

            final SuperheroInfo item = superheroes[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SuperheroCard(
                name: item.name,
                realName: item.realName,
                imageUrl: item.imageUrl,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SuperheroPage(name: item.name),
                  ));
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 8);
          },
        );
      },
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  const NoFavoritesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "No favorites yet",
        subtitle: "Search and add",
        buttonText: "Search",
        assetImage: SuperheroesImages.ironman,
        imageWidth: 108,
        imageHeight: 119,
        imageTopPadding: 9,
      ),
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  const LoadingErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "Error happened",
        subtitle: "Please, try again",
        buttonText: "Retry",
        assetImage: SuperheroesImages.superman,
        imageWidth: 126,
        imageHeight: 106,
        imageTopPadding: 22,
      ),
    );
  }
}

class NothingFoundWidget extends StatelessWidget {
  const NothingFoundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InfoWithButton(
        title: "Nothing found",
        subtitle: "Search for something else",
        buttonText: "Search",
        assetImage: SuperheroesImages.hulk,
        imageWidth: 84,
        imageHeight: 112,
        imageTopPadding: 16,
      ),
    );
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

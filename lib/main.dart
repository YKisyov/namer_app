import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, //Removes the deBug banner
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var currentWordPair = WordPair.random();
  //List<WordPair> listOfFavoritesPairs = [];
  Set<WordPair> setOfLikedWordPairs = {};
  int currentButtonClicks = 0;
  bool wasLikeButtonPressed = false;

  void getNext() {
    currentButtonClicks++;
    currentWordPair = WordPair.random();
    //Clear the like button to its default value as false.
    wasLikeButtonPressed = false;
    notifyListeners();
  }

  void addToFavorites() {
    if (!wasLikeButtonPressed) {
      setOfLikedWordPairs.add(currentWordPair);
    } else {
      setOfLikedWordPairs.remove(currentWordPair);
    }
    //update Like buttonState:
    wasLikeButtonPressed = !wasLikeButtonPressed;
    print("Liked So far: $setOfLikedWordPairs");
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget? page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
        defauld:
        throw UnimplementedError("No widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  print('selected: $value');
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.currentWordPair;

    IconData icon;
    if (appState.setOfLikedWordPairs.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.addToFavorites();
                },
                icon: Icon(icon),
                label: Text(icon == Icons.favorite ? "Liked" : "Like"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.inversePrimary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Text(
          pair.asCamelCase,
          style: textStyle,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyAppState myAppStateObj = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.inversePrimary,
    );

    if (myAppStateObj.setOfLikedWordPairs.isEmpty) {
      return Center(
          child: Text(
        "No favorites yet.",
        style: textStyle,
      ));
    }

    return ListView(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
            "You have ${myAppStateObj.setOfLikedWordPairs.length} favorites"),
      ),
      for (WordPair wp in myAppStateObj.setOfLikedWordPairs)
        Center(
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text(wp.asCamelCase),
          ),
        ),
    ]);
  }
}

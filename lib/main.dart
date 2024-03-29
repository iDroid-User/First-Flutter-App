import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
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
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // New property, initialized w/ an empty list (only contains word pairs)
  // Dart refuses to run if you try adding anything other than WordPair
  var favorites = <WordPair>[];

  // Either removes or adds the current word pair from favorites
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// Kept this class definition for didactic purposes
/*class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // The appropriate (shaded or not) icon is chosen depending on whether the
    // current word pair is already in Favorites
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      // Centers Column
      body: Center(
        child: Column(
          // Centers children inside Column along its main y-axis
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('A head full of dreams:'),
            BigCard(pair: pair), // Added this. Refactor... makes it a new class
            // Just takes space; a "visual gap"
            SizedBox(height: 50),
            // Row acts similarly to Column - by default, it lumps its children
            // to the left
            Row(
              // Tells Row not to take all available horizontal space
              mainAxisSize: MainAxisSize.min,
              children: [
                // ElevatedButton.icon() constructor creates a button w/ an icon
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                // Helps to keep the buttons apart
                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
                /* My attempt:
                LikeButton(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  child:
                    if ()
                ) */
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

// New MyHomePage
// The entire contents of MyHomePage is extracted into a new widget,
// GeneratorPage - except Scaffold
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Contains two children
      body: Row(
        children: [
          // First widget
          // Ensures that its child isn't obscured by a hardware notch or
          // a status bar
          SafeArea(
            child: NavigationRail(
              extended: false,
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
              selectedIndex: 0,
              onDestinationSelected: (value) {
                print('selected: $value');
              },
            ),
          ),
          // Second widget
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: GeneratorPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
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
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
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
    // Requests the app's current theme
    final theme = Theme.of(context);
    // theme.textTheme accesses the app's font theme
    // displayMedium is a large style meant for display text (short & important)
    // copyWith() returns a copy of the text style w/ the changes defined
    // Access the app's theme to get the new color: onPrimary defines a good color
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    // Composition > inheritance
    return Card(
      // Card's color matches the theme's colorScheme property
      color: theme.colorScheme.primary,
      // elevation:
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asCamelCase,
          style: style,
          // Accessibility feature
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

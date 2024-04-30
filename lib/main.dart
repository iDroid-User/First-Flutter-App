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

  // New property, initialized w/ an empty list
  // Only contains word pairs: <WordPair>[] (using generics)
  // Dart refuses to run if you try adding anything other than WordPair
  // A set ({ }) would make more sense for a collection of favs
  var favorites = <WordPair>[];

  // Either removes or adds the current word pair from favorites
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners(); // Called when a change is made to the list
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
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// The IDE created the class _MyHomePageState. This class extends State, & can
// therefore manage its own values.
// The build() method from the old, stateless widget moved to this new class.
// It was moved verbatim - it just lives somewhere else.
// The underscore makes _MyHomePageState privated, enforced by the compiler
class _MyHomePageState extends State<MyHomePage> {
  // Used in the NavigationRail definition instead of the hard-coded 0
  // Can be used to determine what screen to display
  var selectedIndex = 0; // Only variable to track
  @override
  Widget build(BuildContext context) {
    Widget page;
    // Assigns a screen to page, according to the current value in selectedIndex
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        // Used while there's no FavoritesPage - a widget that draws a crossed
        // rectangle to designate an unfinished part of the UI
        page = Placeholder();
        break;
      default:
        // Applying the fail-fast principle, this error is thrown to help to
        // prevent bugs down the line. If a new destination is added to the
        // navigation rail w/o updating this code, the program crashes in
        // development (instead of remaining ambiguous or letting you publish
        // buggy code into production)
        throw UnimplementedError('no widget for $selectedIndex');
    }
    // builder callback is called every time the constraints change (e.g., the user
    // resizes the app's window; the user rotates their phone from portrait mode to
    // landscape mode, vice versa; some widget next to MyHomePage grows in size,
    // making MyHomePage's constraints smaller).
    // Now the code can decide whether to show the label by querying the current constraints.
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        // Contains two children
        body: Row(
          children: [
            // First widget
            // Ensures that its child isn't obscured by a hardware notch or
            // a status bar
            SafeArea(
              child: NavigationRail(
                // Now the app responds to its environment (e.g., screen size, orientation, platform)
                extended: constraints.maxWidth >=
                    600, // Changing it to true shows the labels next to the icons
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
                selectedIndex:
                    selectedIndex, // 0 selects the first destination, 1 selects the second, etc.
                // Defines what happens when one of the destinations is selected
                // When called, instead of printing the new value to console, it assigns it to
                // selectedIndex inside a setState() call - this is similar to the
                // notifyListeners() method used previously (it makes sure the UI updates).
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value; // Outputs the requested index value
                  });
                },
              ),
            ),
            // Second widget; second child of Row
            // Expanded widgets are extremely useful in rows & columns:
            // they let you express layouts where some children take as much space
            // as they need (SafeArea) & other widgets take as much of the remaining
            // room as possible (Expanded; greedy).
            // Two Expanded widgets would split the horizontal space between themselves
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                // The app now switches between GeneratorPage & the placeholder that'll
                // soon become the Favorites page.
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
              Row(
                mainAxisSize:
                    MainAxisSize.min, // Fixes children lumped to the left
                children: [
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

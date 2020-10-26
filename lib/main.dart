import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'my_flutter_app_icons.dart' as custom;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

final String assetName = 'assets/body.svg';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.lightBlueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MyHomePage(title: 'VASI'),
    );
  }
}

PersistentTabController _controller = PersistentTabController(initialIndex: 2);
double head = 0;
List<Widget> tiles = List<Widget>();
List<String> bodyParts = [
  'Head/Includes face, neck, scalp/9',
  'Chest/Includes back, and abdomen/35',
  'Arms/Includes axilla/14',
  'Hands/Includes palms/4',
  'Legs/Includes buttocks and groin/32',
  'Feet/Includes soles/6'
];
List<double> percentDP = [0, 10, 25, 50, 75, 90, 100];
List<double> savalues = List<double>();
List<double> dpvalues = List<double>();
TextEditingController name = TextEditingController();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    savalues = List<double>.filled(bodyParts.length, 0);
    dpvalues = List<double>.filled(bodyParts.length, 0);
    updateFiles();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  saveCurrent() async {
    print('starting save...');
    DateTime now = DateTime.now();
    DateFormat format = DateFormat("yyyy_MM_dd");
    String formatted = format.format(now);
    print(formatted);
    final path = await _localPath;
    print('got path');
    File file = File(path + '/' + name.text + '_' + formatted + '.txt');
    String toSave = name.text + '_' + formatted;
    for (double value in savalues) {
      toSave = toSave + '/' + value.toString();
    }
    print('info to be saved: ' + toSave);
    file.writeAsString(toSave);
    print('Saved: ' + file.path);
  }

  String currentFilePath = '';

  List<Widget> loadData() {
    List<Widget> loadTiles = List<Widget>();

    bodyParts.asMap().forEach((key, line) {
      print(int.parse(line.substring(line.lastIndexOf('/') + 1)));
      loadTiles.add(Text(line.substring(0, line.indexOf('/'))));

      loadTiles.add(LinearPercentIndicator(
        percent: savalues[key] /
            int.parse(line.substring(line.lastIndexOf('/') + 1)),
      ));
      loadTiles.add(Divider());
    });

    return loadTiles;
  }

  List<Widget> _sectionTiles() {
    List<Widget> allTiles = List<Widget>();

    bodyParts.asMap().forEach((key, value) {
      List<String> split = value.split('/');
      if (split.length > 2) {
        allTiles.add(
          AppExpansionTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(split[0]),
                  VerticalDivider(),
                  Text(
                      (savalues[key] * (percentDP[dpvalues[key].toInt()] / 100))
                          .toString())
                ]),
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('% Surface Area'),
                      Slider(
                        min: 0,
                        max: double.parse(split[2]),
                        divisions: int.parse(split[2]),
                        value: savalues[key],
                        label: savalues[key].round().toString(),
                        onChanged: (value) => {
                          setState(() {
                            print(value);
                            print(savalues);
                            savalues[key] = value;
                          })
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('% Depigmentation'),
                      Slider(
                        min: 0,
                        max: 6,
                        divisions: 6,
                        value: dpvalues[key],
                        label: percentDP[dpvalues[key].toInt()]
                                .toString()
                                .substring(
                                    0,
                                    percentDP[dpvalues[key].toInt()]
                                            .toString()
                                            .length -
                                        2) +
                            '%',
                        onChanged: (value) => {
                          setState(() {
                            print(value);
                            print(dpvalues);
                            dpvalues[key] = value;
                          })
                        },
                      ),
                    ],
                  ),
                )
              ]),
            ],
          ),
        );
      }
    });

    return allTiles;
  }

  String calculateScore() {
    String score = '';
    double calc = 0;
    savalues.asMap().forEach((key, value) {
      calc = calc + savalues[key] * (percentDP[dpvalues[key].toInt()] / 100);
    });
    score = 'VASI Score: ' + calc.toString();
    return score;
  }

  List<Widget> _buildScreens() {
    return [
      Expanded(child: Container(child: Icon(custom.MyFlutterApp.body))),
      Icon(custom.MyFlutterApp.body),
      Column(
        children: [
          Expanded(
              child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Icon(custom.MyFlutterApp.body)),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(calculateScore(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          )),
          Expanded(
            flex: 2,
            child: Container(
              child: ListView(
                children: _sectionTiles(),
              ),
            ),
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor.withAlpha(100)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    showCursor: true,
                    controller: name,
                  ),
                ),
                Text('name or identifier'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      child: Text('Reset'),
                      onPressed: () => {
                        setState(() => {
                              savalues =
                                  List<double>.filled(bodyParts.length, 0),
                              dpvalues =
                                  List<double>.filled(bodyParts.length, 0),
                            })
                      },
                    ),
                    RaisedButton(
                      child: Text('Save'),
                      onPressed: saveCurrent,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      Container(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: tiles,
              ),
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: Text('insert name'))),
                      Expanded(
                          flex: 2,
                          child: Container(
                            child: FittedBox(
                                child: Icon(custom.MyFlutterApp.body)),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: loadData(),
                  ),
                )
              ],
            )),
            Container(
              height: 50,
            )
          ],
        ),
      ),
      Icon(FlutterIcons.new_message_ent),
    ];
  }

  updateFiles() async {
    String lp = await _localPath;
    List<String> files = [];
    List<FileSystemEntity> fileDetails = [];
    tiles = List<Widget>();
    Directory.fromUri(Uri.file(lp))
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      //File lm = File(entity.path).lastModified();
      files.add(entity.path);
      fileDetails.add(entity);
    }).onDone(() {
      files.sort((b, a) =>
          File(a).lastModifiedSync().compareTo(File(b).lastModifiedSync()));
      setState(() {
        print("found files: " + files.toString());
        for (String file in files) {
          tiles.add(ListTile(
            title: Text(file.substring(
                file.lastIndexOf('/') + 1, file.lastIndexOf('.'))),
          ));
        }
        print('done');
      });
    });
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(FlutterIcons.library_books_mco),
        title: ("Resources"),
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FlutterIcons.send_faw),
        title: ("Send"),
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          FlutterIcons.add_circle_mdi,
          color: Colors.white,
        ),
        title: ("New"),
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FlutterIcons.folder_ent),
        title: ("Saved"),
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FlutterIcons.settings_mco),
        title: ("Settings"),
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PersistentTabView(
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        onItemSelected: (int) {
          if (int == 3) {
            updateFiles();
          }
        },
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        bottomScreenMargin: 50,
        navBarStyle:
            NavBarStyle.style15, // Choose the nav bar style with this property.
      ),
    );
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children: const <Widget>[],
    this.trailing,
    this.initiallyExpanded: false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Widget leading;
  final Widget title;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final Color backgroundColor;
  final Widget trailing;
  final bool initiallyExpanded;

  @override
  AppExpansionTileState createState() => new AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _easeOutAnimation;
  CurvedAnimation _easeInAnimation;
  ColorTween _borderColor;
  ColorTween _headerColor;
  ColorTween _iconColor;
  ColorTween _backgroundColor;
  Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();
    _iconTurns =
        new Tween<double>(begin: 0.0, end: 0.5).animate(_easeInAnimation);
    _backgroundColor = new ColorTween();

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _activeColor = Colors.transparent;

  void setActive() {
    _activeColor = Theme.of(context).accentColor.withAlpha(100);
  }

  void setInactive() {
    _activeColor = Colors.transparent;
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
//    _backgroundColor = ColorTween(begin: Colors.transparent, end: Colors.transparent);
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded)
          _controller.forward();
        else
          _controller.reverse().then<void>((Null) {
            setState(() {
              // Rebuild without widget.children.
            });
          });
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor =
        _borderColor.evaluate(_easeOutAnimation) ?? Colors.transparent;
    final Color titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      decoration: new BoxDecoration(
          color: _activeColor,
          // _backgroundColor.evaluate(_easeOutAnimation) ?? Colors.transparent,
          border: new Border(
            top: new BorderSide(color: borderSideColor),
            bottom: new BorderSide(color: borderSideColor),
          )),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data:
                new IconThemeData(color: _iconColor.evaluate(_easeInAnimation)),
            child: new ListTile(
              onTap: toggle,
              leading: widget.leading,
              title: new DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: titleColor),
                child: widget.title,
              ),
              trailing: widget.trailing ??
                  new RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
            ),
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _easeInAnimation.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.subhead.color
      ..end = theme.accentColor;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColor.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller.isDismissed;
    return new AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : new Column(children: widget.children),
    );
  }
}
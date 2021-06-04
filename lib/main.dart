import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_flutter/providers/theme.dart';
import 'package:pomodoro_flutter/models/theme_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeChangeProvider = new ThemeProvider();

  @override
  void initState() { 
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.setTheme = await themeChangeProvider.themePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeChangeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pomodoro PUCP',
        home: HomePage(title: 'Pomodoro PUCP'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int minutos, segundos;
  @override
  void initState() {
    minutos = 0;
    segundos = 0;
    super.initState();
  }

  colocaValor() {
    segundos++;
    if (segundos == 60) {
      minutos++;
      segundos = 0;
    }
  }

  aumentaMinuto() {
    minutos++;
  }

  cero() {
    segundos = 0;
    minutos = 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: currentTheme.isDarkTheme()
        ? Color(0xff2a293d)
        : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: currentTheme.isDarkTheme()
            ? Colors.white
            : Colors.black,
          ),
        ),
        backgroundColor: currentTheme.isDarkTheme()
          ? Colors.black12
          : Colors.blue[100],
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.wb_sunny,
                color: currentTheme.isDarkTheme()
                  ? Colors.white
                  : Colors.black
              ),
              Switch(
                value: currentTheme.isDarkTheme(),
                onChanged: (value) {
                  String newTheme = value ? ThemePreference.DARK : ThemePreference.LIGHT;
                  currentTheme.setTheme = newTheme;
                }
              ),
              Icon(
                Icons.brightness_2,
                color: currentTheme.isDarkTheme()
                  ? Colors.white
                  : Colors.black
              )
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
            children: [
            Text(
              "Actividad.nombre( )",
              style: TextStyle(
                fontSize: 35.0,
                color: currentTheme.isDarkTheme()
                ? Colors.white
                : Colors.black,
              ),
            ),
            Text(
              "$minutos : $segundos",
              style: TextStyle(
                fontSize: 60.0,
                color: currentTheme.isDarkTheme()
                ? Colors.white
                : Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: currentTheme.isDarkTheme()
                    ? Colors.black
                    : Colors.white,
                  ),
                  backgroundColor: currentTheme.isDarkTheme()
                    ? Colors.blue[200]
                    : Colors.blue[400],
                  mini: true,
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    setState(aumentaMinuto);
                  },
                ),
                FloatingActionButton(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: currentTheme.isDarkTheme()
                    ? Colors.black
                    : Colors.white,
                  ),
                  backgroundColor: currentTheme.isDarkTheme()
                    ? Colors.blue[200]
                    : Colors.blue[400],
                  mini: true,
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    setState(colocaValor);
                  },
                ),
              ],
            ),
          ],
        )
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Usuario PUCP"),
              accountEmail: Text("user.name@pucp.edu.pe"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Text(
                  'C',
                  style: TextStyle(fontSize: 35.5),
                ),
              ),
            ),
            ListTile(
              title: Text('Actividades de Hoy'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Actividades Semanales'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Resumen Semanal'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Resumen Mensual'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Calendario'),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: currentTheme.isDarkTheme()
          ? Colors.black12
          : Colors.blue[100],
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {},
                  color: currentTheme.isDarkTheme()
                    ? Colors.white
                    : Colors.black,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: () {},
                  color: currentTheme.isDarkTheme()
                    ? Colors.white
                    : Colors.black,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {},
                  color: currentTheme.isDarkTheme()
                    ? Colors.white
                    : Colors.black,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.replay_outlined),
                  onPressed: () {
                    setState(cero);
                  },
                  color: currentTheme.isDarkTheme()
                    ? Colors.white
                    : Colors.black,
                  iconSize: 50)
            ],
          ),
        ),
      ),
    );
  }
}
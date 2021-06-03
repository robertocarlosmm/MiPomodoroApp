import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mi primera App de Flutter', home: Contador());
  }
}

class Contador extends StatefulWidget {
  @override
  _ContadorState createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("App Pomodoro"),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.lightBlueAccent[100],
      body: Center(
        child: Column(
            children: [
            Text(
              "Actividad.nombre()",
              style: TextStyle(fontSize: 35.0),
            ),
            Text(
              "$minutos : $segundos",
              style: TextStyle(fontSize: 60.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: Icon(Icons.add_circle_outline),
                  backgroundColor: Colors.indigo,
                  mini: true,
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    setState(aumentaMinuto);
                  },
                ),
                FloatingActionButton(
                  child: Icon(Icons.add_circle_outline),
                  backgroundColor: Colors.indigo,
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
        color: Colors.indigo,
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {},
                  color: Colors.white,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: () {},
                  color: Colors.white,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {},
                  color: Colors.white,
                  iconSize: 50),
              IconButton(
                  icon: Icon(Icons.replay_outlined),
                  onPressed: () {
                    setState(cero);
                  },
                  color: Colors.white,
                  iconSize: 50)
            ],
          ),
        ),
      ),
    );
  }
}
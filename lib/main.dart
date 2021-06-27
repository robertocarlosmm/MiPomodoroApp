import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:pomodoro_flutter/providers/theme.dart';
import 'package:pomodoro_flutter/models/theme_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';


enum PomodoroState {getReady,pomodoro,shortBreak,longBreak}

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
    themeChangeProvider.setTheme =
        await themeChangeProvider.themePreference.getTheme();
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
  int min10, min, seg10, seg, contador, maxpom,tiempopom,valor;
  bool indicador,descanso,fin;
  double percent;
  @override
  void initState() {
    min10 = 0;
    min = 0;
    seg10 = 0;
    seg = 0;
    contador = 0;
    tiempopom = 0;
    maxpom = 0;
    indicador = false;
    descanso=false;
    fin=false;
    percent=0;
    valor=0;
    super.initState();
  }

  Timer timer;

  StartTimer(){
    int Time=indicador?(descanso?5*60:tiempopom):0;
    double segPercent;
    if(Time>0)segPercent=(100/Time);
    print("porcentaje: $segPercent");
    timer = Timer.periodic(Duration(seconds: 1), (timer){ 
      print(Time);
        if(Time>0){
          Time--;
          
          print("percent: $percent");
          if(percent<1){
            if(percent +(segPercent/100) >1){
              percent=1;
            }
            else{
              percent+=(segPercent/100);
            }
            valor=(percent*100).toInt();
          }
          else{
            percent=1;
            valor=100;
          }
          
        }
        else{
            //percent=0;
            //valor=0;
            //Time=indicador?(descanso?5*60:tiempopom):0;
            //timer.cancel();
            setState(nextPomodoro());
          }
    });
  }
  StopTimer(){
    timer.cancel();
  }

  enPlay(){
    tiempopom=(min10*10+min)*60 + seg10*10+seg;
    indicador=true;
    StartTimer();
  }

  enStop(){
    indicador=false;
    descanso=false;
    percent=0;
    valor=0;
    StopTimer();
    cero();
  }

  devuelveValor(){
    min10=(tiempopom~/60)~/10;
    min=(tiempopom~/60)%10;
    seg10=(tiempopom-(min10*10+min)*60)~/10;
    seg=(tiempopom-(min10*10+min)*60)%10;
  }

  valorDescanso(){
    min10=0;
    min=5;
    seg10=0;
    seg=0;
  }

  nextPomodoro(){
    percent=0;
    valor=0;
    StopTimer();
    if(!descanso){//estaba en modo pomodoro
      contador++;
      maxpom--;
    }
    descanso=!descanso;
    descanso?valorDescanso():devuelveValor();
    if(maxpom==0){
        cero();
        indicador=false;
        descanso=false;
      }
    else{
      StartTimer();
    }
  }

  incPom(){
    if(maxpom<5) maxpom++;
  }

  decPom(){
    (maxpom>0)?maxpom--:maxpom=0;
  }

  incSeg() {
    seg++;
    if (seg == 10) {
      seg = 0;
      seg10++;
      if (seg10 == 6) {
        seg10 = 0;
        min++;
        if (min == 10) {
          min = 0;
          min10++;
          if (min10 == 10) {
            min10 = 0;
          }
        }
      }
    }
  }

  incSeg10() {
    seg10++;
    if (seg10 == 6) {
      seg10 = 0;
      min++;
      if (min == 10) {
        min = 0;
        min10++;
        if (min10 == 10) {
          min10 = 0;
        }
      }
    }
  }

  incMin() {
    min++;
    if (min == 10) {
      min = 0;
      min10++;
      if (min10 == 10) {
        min10 = 0;
      }
    }
  }

  incMin10() {
    min10++;
    if (min10 == 10) {
      min10 = 0;
    }
  }

  cero() {
    seg10 = 0;
    seg = 0;
    min10 = 0;
    min = 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    final size = 200.0;
    final pi = 3.14159265;
    return Scaffold(
      backgroundColor:
          currentTheme.isDarkTheme() ? Color(0xff2a293d) : Colors.white,
      appBar: AppBar(
        title: Text(
          "App Pomodoro v1.0",
          style: TextStyle(
            color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            currentTheme.isDarkTheme() ? Colors.black12 : Colors.blue[100],
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.wb_sunny,
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black),
              Switch(
                  value: currentTheme.isDarkTheme(),
                  onChanged: (value) {
                    String newTheme =
                        value ? ThemePreference.DARK : ThemePreference.LIGHT;
                    currentTheme.setTheme = newTheme;
                  }),
              Icon(Icons.brightness_2,
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black)
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      if(!indicador)setState(incMin10);
                    },
                    child: Text(
                      '$min10',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: currentTheme.isDarkTheme()
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        if(!indicador)setState(incMin);
                      },
                      child: Text(
                        '$min',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: currentTheme.isDarkTheme()
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                  Text(':',style: TextStyle(
                        fontSize: 30.0,
                        color: currentTheme.isDarkTheme()
                          ? Colors.white
                          : Colors.black,
                        ),
                      ),
                  TextButton(
                      onPressed: () {
                        if(!indicador)setState(incSeg10);
                      },
                      child: Text(
                        '$seg10',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: currentTheme.isDarkTheme()
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                  TextButton(
                      onPressed: () {
                        if(!indicador)setState(incSeg);
                      },
                      child: Text(
                        '$seg',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: currentTheme.isDarkTheme()
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 200.0,
              width: 200.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularPercentIndicator(
                    percent: percent,
                    animation: true,
                    animateFromLastPercent: true,
                    radius: 200.0,
                    lineWidth: 10.0,
                    progressColor: currentTheme.isDarkTheme()
                              ? Colors.blueGrey
                              : Colors.lightBlue,
                    center: Text("$valor%",
                            style: TextStyle(
                            fontSize: 50.0,
                            color: currentTheme.isDarkTheme()
                                ? Colors.blueGrey
                                : Colors.lightBlue,
                          ),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
                  height: 30.0,
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  //isActive?Icons.pause:Icons.play_arrow
                  child: Icon(indicador?Icons.skip_next:Icons.play_arrow),
                  onPressed: () {
                        indicador?setState(nextPomodoro):setState(enPlay);
                      },
                ),
                SizedBox(
                  width: indicador?30.0:0,
                ),

                indicador?FloatingActionButton(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.stop),
                  onPressed: () {
                        setState(enStop);
                      },
                ):Container()
              ],
            ),
            SizedBox(
                  height: 20.0,
                ),
            SizedBox(
              height: 40.0,
              child: indicador?Text(
                descanso?"DESCANSANDO...":"TRABAJANDO!!!",
                style: TextStyle(
                  color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                ),
              ):Container()
            ),
            SizedBox(
                  height: indicador?20.0:0,
                ),
            !indicador?Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: Icon(
                    Icons.arrow_circle_up_rounded,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                  ),
                  backgroundColor:
                      currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                        setState(incPom);
                      },
                ),
                SizedBox(
                  width: 30.0,
                ),
                FloatingActionButton(
                  child: Icon(
                    Icons.arrow_circle_down_rounded,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                  ),
                  backgroundColor:
                      currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                        setState(decPom);
                      },
                ),
              ],
            ):Container(),
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
        color: currentTheme.isDarkTheme() ? Colors.black12 : Colors.blue[100],
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Pomodoros: ",
                style: TextStyle(
                  color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                ),
              ),
              maxpom>0?IconButton(
                  icon: Icon(Icons.airline_seat_recline_normal_rounded),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(), 
              maxpom>1?IconButton(
                  icon: Icon(Icons.airline_seat_recline_normal_rounded),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>2?IconButton(
                  icon: Icon(Icons.airline_seat_recline_normal_rounded),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>3?IconButton(
                  icon: Icon(Icons.airline_seat_recline_normal_rounded),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>4?IconButton(
                  icon: Icon(Icons.airline_seat_recline_normal_rounded),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
            ],
          ),
        ),
      ),
    );
  }
}

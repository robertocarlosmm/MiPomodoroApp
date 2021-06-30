import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:pomodoro_flutter/providers/theme.dart';
import 'package:pomodoro_flutter/models/theme_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';


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
  int min10=0, min=0, seg10=0, seg=0, contador=0, maxpom=0,tiempopom=0,_start=0;
  bool indicador=false,descanso=false,fin=false;
  double percent=0,segPercent=0;
  int valorPorcentaje=0;
  @override
  void initState() {
    super.initState();
  }

  Timer _timer;
  
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if(_start>0)segPercent=(100/_start);//el porcentaje del tiempo en 1 segundo
    print(segPercent);
    _timer = new Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start < 1) {
          setState(() {
                      nextPomodoro();
                    });
        } else {  
          _start = _start - 1;
          print(_start);
          setState(() {
            decTiempo();             
          });
          print("percent: $percent");
          print("valor:   $valorPorcentaje");
          if(percent<1){
            if(percent +(segPercent/100) >1){
              percent=1;
            }
            else{
              percent+=(segPercent/100);
            }
            valorPorcentaje=(percent*100).toInt();
          }
          else{
            percent=1;
            valorPorcentaje=100;
          }
        }
      });
    });
  }


  StopTimer(){
    _timer?.cancel();
  }

  enPlay(){
    tiempopom=(min10*10+min)*60 + seg10*10+seg;
    indicador=true;
    _start=tiempopom;
    startTimer();
  }

  nextPomodoro(){
    percent=0;
    valorPorcentaje=0;
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
      _start=indicador?(descanso?5*60:tiempopom):0;
      startTimer();
    }
  }

  enStop(){
    indicador=false;
    descanso=false;
    percent=0;
    valorPorcentaje=0;
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

  incPom(){
    if(maxpom<5) maxpom++;
  }

  decTiempo(){
    if(seg>0){//Mm:Ss
      seg--;
    }
    else{//Mm:S0
      if(seg10>0){
        seg10--;
        seg=9;
      }
      else{//mm:00
        if(min>0){
          min--;
          seg10=5;
          seg=9;
        }
        else{//m0:00
          if(min10>0){
            min10--;
            min=9;
            seg10=5;
            seg=9;
          }
        }
      }
    }
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
              width:  200.0,
              child: LiquidCircularProgressIndicator(
                value: percent, // Defaults to 0.5.
                backgroundColor: currentTheme.isDarkTheme() ? Colors.black12 : Colors.grey[100],
                valueColor: AlwaysStoppedAnimation(
                  currentTheme.isDarkTheme() ? Colors.cyan[900] : Colors.lightBlueAccent[300]
                  ), // Defaults to the current Theme's accentColor.
                borderColor: Colors.transparent,
                borderWidth: 5.0,
                direction: Axis.vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                center: Text("$valorPorcentaje%",
                            style: TextStyle(
                              fontSize: 30.0,
                              color: currentTheme.isDarkTheme()
                                  ? Colors.white
                                  : Colors.black,
                        ),),
              ),
            ),
            //ACA IRA LA RUEDITA
            
            

            SizedBox(
                  height: 30.0,
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  //isActive?Icons.pause:Icons.play_arrow
                  child: Icon(
                    indicador?Icons.skip_next:Icons.play_arrow,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                  onPressed: () {
                        indicador?setState(nextPomodoro):setState(enPlay);
                      },
                ),
                SizedBox(
                  width: indicador?30.0:0,
                ),

                indicador?FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  child: Icon(
                    Icons.stop,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                  ),
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
      
      //DRAWER QUE NO HACE NADA
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


      //CANTIDAD DE POMODOROS
      bottomNavigationBar: BottomAppBar(
        color: currentTheme.isDarkTheme() ? Colors.black12 : Colors.blue[100],
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /*Text(
                "Pomodoros: ",
                style: TextStyle(
                  color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                ),
              ),*/
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



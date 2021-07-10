import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:pomodoro_flutter/providers/theme.dart';
import 'package:pomodoro_flutter/models/theme_preferences.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:audioplayers/audioplayers.dart';

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
  int valorPorcentaje=0,tiempodescanso=0,temporal=0;
  int d_min10=0, d_min=5, d_seg10=0, d_seg=0;
  bool p_select=false,d_select=false;
  @override
  void initState() {
    super.initState();
  }

  Timer _timer;
  final player = AudioCache();
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

  playSoundBubble(){
    
    player.play('bubbles_not.mp3');
    print("REPRODUCIDO");
  }

  StopTimer(){
    _timer?.cancel();
  }

  enPlay(){
    tiempopom=(min10*10+min)*60 + seg10*10+seg;
    tiempodescanso=(d_min10*10+d_min)*60 + d_seg10*10+d_seg;
    indicador=true;
    _start=tiempopom;
    startTimer();
  }

  nextPomodoro(){
    setState(() {
                      playSoundBubble();
                    });
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
      _start=indicador?(descanso?tiempodescanso:tiempopom):0;
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
    min10=(tiempodescanso~/60)~/10;
    min=(tiempodescanso~/60)%10;
    seg10=(tiempodescanso-(min10*10+min)*60)~/10;
    seg=(tiempodescanso-(min10*10+min)*60)%10;
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

  setPom(int num){
    min10=num~/10;
    min=num%10;
    seg10=0;
    seg=0;
  }

  setDes(int num){
    d_min10=num~/10;
    d_min=num%10;
    d_seg10=0;
    d_seg=0;
  }

  configuraDescanso(BuildContext context){
    showDialog(context: context,builder: (context)=>AlertDialog(
      title: Text("Tiempo de descanso"),
      content: SizedBox(
        width:  200.0,
        height: 200.0,
        child: Center(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Minutos',
              labelText: 'Tiempo de descanso',
              prefixIcon: Icon(Icons.charging_station_rounded),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2,
            onChanged: (valor){
              temporal = int.parse(valor);
            },
          ),
        )
      ),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Aceptar"),
          onPressed: (){
            setState(() {
              setDes(temporal);
                        });
            Navigator.pop(context);
          },
        )
      ],
    ));
  }

  configura(BuildContext context){
    showDialog(context: context,builder: (context)=>AlertDialog(
      title: Text("Tiempo de estudio"),
      content: SizedBox(
        width:  200.0,
        height: 200.0,
        child: Center(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Minutos',
              labelText: 'Tiempo de Estudio',
              prefixIcon: Icon(Icons.airline_seat_recline_normal_rounded),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2,
            onChanged: (valor){
              temporal = int.parse(valor);
            },
          ),
        )
      ),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Aceptar"),
          onPressed: (){
            setState(() {
              setPom(temporal);
                        });
            Navigator.pop(context);
          },
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor:
          currentTheme.isDarkTheme() ? Color(0xff2a293d) : Colors.white,
          
      appBar: AppBar(
        title: Text(
          indicador?(descanso?"   DESCANSANDO":"   TIEMPO DE ESTUDIO"):"   ¿LISTO?",
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
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black),
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
                  currentTheme.isDarkTheme() ? 
                  (descanso?Colors.pinkAccent[700]
                  :Colors.cyan[900]) 
                  : (descanso?Colors.pink[200]
                  :Colors.lightBlueAccent[300])
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
                !indicador?FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  //isActive?Icons.pause:Icons.play_arrow
                  child: Icon(Icons.hourglass_top_rounded,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                    onPressed: () {
                        configura(context);
                      },
                ):Container(),

                SizedBox(
                  width: !indicador?30.0:0,
                ),

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
                  width: 30.0,
                ),

                FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme() ? Colors.blue[400] : Colors.blue[100],
                  child: Icon(
                    !indicador?Icons.charging_station_rounded:Icons.stop,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                  ),
                  onPressed: () {
                        indicador?setState(enStop):configuraDescanso(context);
                      },
                )
              ],
            ),

            SizedBox(
                  height: 6.0,
                ),
            
            indicador?SizedBox(height: 60.0):Container(),

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



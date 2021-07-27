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
  int min10=2, min=0, seg10=0, seg=0, contador=0, maxpom=0,tiempopom=0,_start=0;
  bool indicador=false,descanso=false,fin=false;
  double percent=0,segPercent=0;
  int valorPorcentaje=0,tiempodescanso=0,temporal=0;
  int d_min10=0, d_min=5, d_seg10=0, d_seg=0;
  bool p_select=false,d_select=false;
  bool editar=false,editar2=false;
  @override
  void initState() {
    super.initState();
  }

  Timer _timer;
  final player = AudioCache();
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if(_start>0)segPercent=(100/_start);//el porcentaje del tiempo en 1 segundo
    //print(segPercent);
    _timer = new Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start < 1) {
          
          setState(() {
                      nextPomodoro();
                    });
        } else {  
          _start = _start - 1;
          //print(_start);
          setState(() {
            decTiempo();             
          });
          //print("percent: $percent");
          //print("valor:   $valorPorcentaje");
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
    player.play('bubbles_not.mp3');
    //print("REPRODUCIDO");
  }

  StopTimer(){
    _timer?.cancel();
  }

  enPlay(){
    tiempopom=(min10*10+min)*60 + seg10*10+seg;
    tiempodescanso=(d_min10*10+d_min)*60 + d_seg10*10+d_seg;
    if(maxpom>0 && tiempodescanso>0 && tiempopom>0){
      indicador=true;
      _start=tiempopom;
      startTimer();
    }    
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
        devuelveValor();
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
    devuelveValor();
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
  double currentSlider=0;
  double temporal_pom=0;
  prototipo(){
    indicador
    ?Container()
    :Container(
      child: Column(
        children: [
          Row(
            children: [
              Slider(
                value: (min10*10+min).toDouble(),
                min: 10,
                max: 90,
                onChanged: (newValue){
                  setState(() {
                    tiempopom=newValue.toInt();
                    setPom(tiempopom);
                                    });
                },
              )
            ],
          ),
          Row(),
        ],
      ),
    );
  }


  muestraSlider(BuildContext context){
    showDialog(context: context,builder: (context)=>AlertDialog(
      title: Text("Tiempo de Concentración"),
      content: SizedBox(
        width:  100.0,
        height: 100.0,
        child: Center(
          child: Column(
            children: [
              Slider(
                value: temporal_pom,
                min: 0.0,
                max: 90.0,
                onChanged:(newValue){
                  setState(() {
                    temporal_pom = newValue;           
                    print('$newValue');  
                    Navigator.pop(context);
                    muestraSlider(context);
                  });
                }, 
              ),
              SizedBox(
                height: 20,
                child: Text(
                  '$temporal_pom',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          
          
        )
      ),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: (){
            setState(() {
                temporal_pom=(min10*10+min).toDouble();
                        });
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Aceptar"),
          onPressed: (){
            setState(() {
              setPom(temporal_pom.toInt());
                        });
            Navigator.pop(context);
          },
        )
      ],
    ));
  }

  configuraDescanso(BuildContext context){
    showDialog(context: context,builder: (context)=>AlertDialog(
      title: Text("Tiempo de descanso"),
      content: SizedBox(
        width:  100.0,
        height: 100.0,
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
        width:  100.0,
        height: 100.0,
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
      resizeToAvoidBottomInset:false,
      backgroundColor:
          currentTheme.isDarkTheme() ? Color(0xff2a293d) : Colors.white,
          
      appBar: AppBar(
        title: Text(
          indicador?(descanso?"   DESCANSANDO":"   TIEMPO DE ESTUDIO"):"   ¿LISTO?",
          style: TextStyle(
            color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.black12)
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
            //currentTheme.isDarkTheme() ? Colors.black12 : Colors.blue[100],
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.wb_sunny,
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black),
              Switch(
                  activeColor: 
                    indicador
                      ?(descanso?Colors.pink[300]
                      :Colors.cyan[400])
                    :Colors.blue[400],
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
                  (descanso?Colors.pink[600]
                  :Colors.cyan[800]) 
                  : (descanso?Colors.pink[300]
                  :Colors.lightBlueAccent[400])
                  ), // Defaults to the current Theme's accentColor.
                borderColor: Colors.transparent,
                borderWidth: 5.0,
                direction: Axis.vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                center: Text("$valorPorcentaje%",
                            style: TextStyle(
                              fontSize: 35.0,
                              color: currentTheme.isDarkTheme()
                                  ? Colors.white
                                  : Colors.black,
                        ),),
              ),
            ),
            //ACA IRA LA RUEDITA
            
            indicador
    ?Container()
    :Container(
      child: Column(
        children: [
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Icon(Icons.lock_clock,color: currentTheme.isDarkTheme()?Colors.white:Colors.black)
              ),
              SizedBox(
                height: 50,
                width: 200,
                child:Slider(
                  value: (min10*10+min).toDouble(),
                  min: 0,
                  max: 90,
                  activeColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  onChanged: (newValue){
                    setState(() {
                      tiempopom=newValue.toInt();
                      setPom(tiempopom);
                                      });
                  },
                ),
              ),
              
              SizedBox(
                width: 50,
                height: 50,
                child:editar
                ?TextField(
                decoration: InputDecoration(
                  //hintText: 'Minutos',
                  //labelText: 'Minutos',
                  //prefixIcon: Icon(Icons.charging_station_rounded),
                  border: OutlineInputBorder(),
                ),
                keyboardAppearance: currentTheme.isDarkTheme()?Brightness.dark:Brightness.light,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: currentTheme.isDarkTheme()?Colors.white:Colors.black),
                //maxLength: 2,
                
                onChanged: (valor){
                  setState(() {
                    tiempopom = int.parse(valor);
                    if(tiempopom>90)tiempopom=90;
                    setPom(tiempopom);
                                    });
                },
                )
                :TextButton(
                  child: Text(
                    "${min10*10+min}",
                    style: TextStyle(
                      fontSize: 25,
                      color: currentTheme.isDarkTheme()?Colors.white:Colors.black,
                    ),
                  ),
                  onPressed: (){
                    setState(() {
                      editar=!editar;
                                });
                    
                  },
                ),//buscar aquí                
              ),
              editar
              ?FloatingActionButton(
                mini: true,
                backgroundColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  //isActive?Icons.pause:Icons.play_arrow
                child: Icon(Icons.check,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                onPressed: (){
                  setState(() {
                    editar=!editar;
                                    });
                }
                )
              :Container()
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Icon(Icons.lock_open_outlined,color: currentTheme.isDarkTheme()?Colors.white:Colors.black)
              ),
              SizedBox(
                height: 50,
                width: 200,
                child:Slider(
                  value: (d_min10*10+d_min).toDouble(),
                  min: 0,
                  max: 30,
                  activeColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  onChanged: (newValue){
                    setState(() {
                      tiempodescanso=newValue.toInt();
                      setDes(tiempodescanso);
                                      });
                  },
                ),
              ),
              
              SizedBox(
                width: 50,
                height: 50,
                child:editar2
                ?TextField(
                decoration: InputDecoration(
                  //hintText: 'Minutos',
                  //labelText: 'Minutos',
                  //prefixIcon: Icon(Icons.charging_station_rounded),
                  border: OutlineInputBorder(),
                ),
                keyboardAppearance: currentTheme.isDarkTheme()?Brightness.dark:Brightness.light,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: currentTheme.isDarkTheme()?Colors.white:Colors.black),
                //maxLength: 2,
                
                onChanged: (valor){
                  setState(() {
                    tiempodescanso = int.parse(valor);
                    if(tiempodescanso>30)tiempodescanso=30;
                    setDes(tiempodescanso);
                                    });
                },
                )
                :TextButton(
                  child: Text(
                    "${d_min10*10+d_min}",//buscame
                    style: TextStyle(
                      fontSize: 25,
                      color: currentTheme.isDarkTheme()?Colors.white:Colors.black,
                    ),
                  ),
                  onPressed: (){
                    setState(() {
                      editar2=!editar2;
                                });
                    
                  },
                ),//buscar aquí                
              ),
              editar2
              ?FloatingActionButton(
                mini: true,
                backgroundColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  //isActive?Icons.pause:Icons.play_arrow
                child: Icon(Icons.check,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                onPressed: (){
                  setState(() {
                    editar2=!editar2;
                                    });
                }
                )
              :Container()
            ],
          ),
        ],
      ),
    ),

            SizedBox(
                  height: 30.0,
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [/*
                !indicador?FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  //isActive?Icons.pause:Icons.play_arrow
                  child: Icon(Icons.hourglass_top_rounded,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                    onPressed: () {
                      
                        muestraSlider(context);               
                                            
                      
                      },
                ):Container(),*/

                SizedBox(
                  width: !indicador?30.0:0,
                ),

                FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
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

                indicador?FloatingActionButton(
                  backgroundColor: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.blue[400])
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
                  child: Icon(
                    !indicador?Icons.charging_station_rounded:Icons.stop,
                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                  ),
                  onPressed: () {
                        setState(enStop);
                      },
                )
                :Container(),
              ],
            ),

            SizedBox(
                  height: 6.0,
                ),
            
            indicador?SizedBox(height: 60.0):Container(),

            SizedBox(
              height: 40.0,
              child: indicador?Text(
                descanso?"¡¡TE GANASTE UN BREAK!!":"¡¡NO VEAS ESTO!!",
                style: TextStyle(
                  color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  fontSize: 30.0
                ),
              ):Container()
            ),

            SizedBox(
                  height: indicador?20.0:0,
                ),

            indicador?SizedBox(
              height: 55.0,
              width:  55.0,
              child:Center(
                child: Icon(
                descanso?Icons.celebration:Icons.no_cell_rounded,
                size: 55.0,
                color: currentTheme.isDarkTheme()
                  ?(
                    descanso?Colors.pink[600]
                    :Colors.cyan[800]
                    )
                  :(
                    descanso?Colors.pink[300]
                    :Colors.lightBlueAccent[400]
                    ),
                ),
              ) 
            ):Container(),

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
        color: currentTheme.isDarkTheme()
                  ?(indicador
                    ?(descanso?Colors.pink[600]
                      :Colors.cyan[800])
                    :Colors.black12)
                  :(indicador
                    ?(descanso?Colors.pink[300]
                      :Colors.lightBlueAccent[400])
                    :Colors.blue[100]),
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
                  icon: Icon(Icons.bolt),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(), 
              maxpom>1?IconButton(
                  icon: Icon(Icons.bolt),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>2?IconButton(
                  icon: Icon(Icons.bolt),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>3?IconButton(
                  icon: Icon(Icons.bolt),
                  onPressed: () {},
                  color:
                      currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                  iconSize: 50):Container(),
              maxpom>4?IconButton(
                  icon: Icon(Icons.bolt),
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



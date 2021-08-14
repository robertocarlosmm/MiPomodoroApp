//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:pomodoro_flutter/providers/theme.dart';
import 'package:pomodoro_flutter/models/theme_preferences.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_flutter/mis__iconos_icons.dart';
import 'package:pomodoro_flutter/SliderLabel.dart';
import 'package:pomodoro_flutter/SliderRotable.dart';
import 'package:flutter_launcher_icons/android.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock/wakelock.dart';


void main() async{
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
  int min10=2, min=0, seg10=0, seg=0, contador=0, maxpom=1,tiempopom=0,_start=0;
  bool indicador=false,descanso=false,fin=false;
  double percent=0,segPercent=0;
  int valorPorcentaje=0,tiempodescanso=0,temporal=0;
  int d_min10=0, d_min=5, d_seg10=0, d_seg=0;
  bool p_select=false,d_select=false;
  bool editar=false,editar2=false,pausado=false;
  bool tiempo1=true,tiempo2=false;
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
    setState(() {
      Wakelock.enable();
    });
    pausado=false;
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
      if(maxpom>0)maxpom--;
    }
    descanso=!descanso;
    descanso?valorDescanso():devuelveValor();
    if(maxpom==0){
        devuelveValor();
        indicador=false;
        descanso=false;
        pausado=false;
        maxpom=1;
        setState(() {
          Wakelock.disable();
        });
      }
    else{
      _start=indicador?(descanso?tiempodescanso:tiempopom):0;
      startTimer();
    }
  }

  enStop(){
    pausado=false;
    indicador=false;
    descanso=false;
    percent=0;
    valorPorcentaje=0;
    StopTimer();
    devuelveValor();
    setState(() {
          Wakelock.disable();
        });
  }

  enPausa(){
    pausado=true;
    StopTimer();
  }

  enContinuacion(){
    pausado=false;
    startTimer();
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
    if(indicador)return;
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
    if(indicador)return;
    if(maxpom>1)maxpom--;
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

  setPomodoros(int num){
    int temp;
    if(num==0)num=1;
    temp=maxpom;
    if(!indicador) temp=num;
    maxpom=temp;
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
    final Size tam = MediaQuery.of(context).size;
    double ancho=tam.width;
    double alto =tam.height;
    double circulo=alto*2/5;
    if(circulo > ancho*4/5)
      circulo=ancho*4/5;
      
    final currentTheme = Provider.of<ThemeProvider>(context);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      //resizeToAvoidBottomInset:false,
      backgroundColor:
          currentTheme.isDarkTheme() ? Color(0xff2a293d) : Colors.white,
          
      appBar: AppBar(
        title: Text(
          indicador?(descanso?"   DESCANSANDO":"   CONCENTRADO"):"   Focusing time!}",
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
                    ?(descanso?Colors.pink[400]
                      :Colors.greenAccent[400])
                    :Colors.blue),
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
                      ?(descanso?Colors.pink[400]
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
        child: ListView(
          //padding: EdgeInsets.all(32),
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: alto/20,
                  ),
                  SizedBox(
                    height: circulo,
                    width:  circulo,
                    child: LiquidCircularProgressIndicator(
                      value: percent, // Defaults to 0.5.
                      backgroundColor: currentTheme.isDarkTheme() ? Colors.black12 : Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation(
                        indicador
                        ?currentTheme.isDarkTheme()?
                        (descanso?Colors.pink[600]
                        :Colors.cyan[800]) 
                        : (descanso?Colors.pink[400]
                        :Colors.greenAccent[400])
                        :Colors.blue
                        ), // Defaults to the current Theme's accentColor.
                      borderColor: Colors.transparent,
                      borderWidth: 5.0,
                      direction: Axis.vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: circulo/5,
                          child: TextButton(
                            onPressed: () {
                              if(!indicador)setState(incMin10);
                            },
                            child: Text(
                              '$min10',
                              style: TextStyle(
                                fontSize: circulo*3/28,
                                color: currentTheme.isDarkTheme()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: circulo/5,
                          child: TextButton(
                              onPressed: () {
                                if(!indicador)setState(incMin);
                              },
                              child: Text(
                                '$min',
                                style: TextStyle(
                                  fontSize: circulo*3/28,
                                  color: currentTheme.isDarkTheme()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )),
                        ),
                        Text(':',style: TextStyle(
                              fontSize: circulo*3/28,
                              color: currentTheme.isDarkTheme()
                                ? Colors.white
                                : Colors.black,
                              ),
                            ),
                        SizedBox(
                          width: circulo/5,
                          child: TextButton(
                              onPressed: () {
                                if(!indicador)setState(incSeg10);
                              },
                              child: Text(
                                '$seg10',
                                style: TextStyle(
                                  fontSize: circulo*3/28,
                                  color: currentTheme.isDarkTheme()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )),
                        ),
                        SizedBox(
                          width: circulo/5,
                          child: TextButton(
                              onPressed: () {
                                if(!indicador)setState(incSeg);
                              },
                              child: Text(
                                '$seg',
                                style: TextStyle(
                                  fontSize: circulo*3/28,
                                  color: currentTheme.isDarkTheme()
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              )),
                        ),
                      ],
                    ),
                    ),
                  ),
                  //ACA IRA LA RUEDITA
                  
    indicador
    ?Container()
    :Container(
      child: Column(
              children: [
                
                SizedBox(height: alto/40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    editar?Container():SizedBox(width: ancho/30,),
                    SizedBox(
                      height:alto/15,
                      width: ancho/30,
                      child: Icon(MisIconos.mind,color: currentTheme.isDarkTheme()?Colors.white:Colors.black)
                    ),                
                        SizedBox(
                          height: alto/15,
                          width: ancho*0.5,
                          child:Slider(
                            value: (min10*10+min).toDouble(),
                            min: 0,
                            max: 90,
                            activeColor: Colors.blue,
                            onChanged: (newValue){
                              setState(() {
                                tiempopom=newValue.toInt();
                                setPom(tiempopom);
                                                });
                            },
                          ),
                        ),
                      
                    
                    SizedBox(
                      width: alto/14,
                      height: alto/15,
                      child:editar
                      ?TextField(
                      decoration: InputDecoration(
                        //hintText: 'Minutos',
                        //labelText: 'Minutos',
                        //prefixIcon: Icon(Icons.charging_station_rounded),
                        border: OutlineInputBorder(),
                        focusColor:Colors.blue,
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
                            fontSize: alto/31,
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
                      backgroundColor: Colors.blue,
                        //isActive?Icons.pause:Icons.play_arrow
                      child: Icon(Icons.check,
                          color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                      onPressed: (){
                        setState(() {
                          editar=!editar;
                                          });
                      }
                      )
                    :Container(),
                    SizedBox(width: ancho/30),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    editar?Container():SizedBox(width: ancho/30,),
                    SizedBox(
                      height: alto/15,
                      width: ancho/30,
                      child: Icon(MisIconos.cup_of_drink,color: currentTheme.isDarkTheme()?Colors.white:Colors.black),
                    ),
                    SizedBox(
                      height: alto/15,
                      width: ancho*0.5,
                      child:Slider(
                        value: (d_min10*10+d_min).toDouble(),
                        min: 0,
                        max: 30,
                        activeColor: Colors.blue,
                        onChanged: (newValue){
                          setState(() {
                            tiempodescanso=newValue.toInt();
                            setDes(tiempodescanso);
                                            });
                        },
                      ),
                    ),
                    
                    SizedBox(
                      width: alto/14,
                      height: alto/15,
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
                            fontSize: alto/31,
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
                      backgroundColor: Colors.blue,
                        //isActive?Icons.pause:Icons.play_arrow
                      child: Icon(Icons.check,
                          color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                      onPressed: (){
                        setState(() {
                          editar2=!editar2;
                                          });
                      }
                      )
                    :Container(),
                    SizedBox(width: ancho/30),
                  ],
                ),
              ],
      ),
    ),

                  SizedBox(
                        height: indicador?alto/30:alto/90,
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: !indicador?alto/30:0,
                      ),
                      
                      FloatingActionButton(
                        backgroundColor: currentTheme.isDarkTheme()
                        ?(indicador
                          ?(descanso?Colors.pink[600]
                            :Colors.cyan[800])
                          :Colors.blue)
                        :(indicador
                          ?(descanso?Colors.pink[400]
                            :Colors.greenAccent[400])
                          :Colors.blue),
                        //isActive?Icons.pause:Icons.play_arrow
                        child: Icon(
                          indicador?(pausado?Icons.play_arrow:Icons.pause):Icons.play_arrow,
                          color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,),
                          onPressed: () {
                              indicador
                              // ignore: unnecessary_statements
                              ?(pausado?setState(enContinuacion):setState(enPausa))
                              :setState(enPlay);
                            },
                      ),
                      SizedBox(
                        width: alto/30,
                      ),

                      indicador?FloatingActionButton(
                        backgroundColor: currentTheme.isDarkTheme()
                        ?(descanso?Colors.pink[600]
                            :Colors.cyan[800])
                        :(descanso?Colors.pink[400]
                            :Colors.greenAccent[400]) ,
                        child: Icon(
                          Icons.stop,
                          color: currentTheme.isDarkTheme() ? Colors.white : Colors.black ,
                        ),
                        onPressed: () {
                              setState(enStop);
                            },
                      )
                      :Container(),
                    ],
                  ),

                  indicador?SizedBox(height: alto/30):Container(),

                  SizedBox(
                    height: alto/20,
                    child: indicador?Text(
                      descanso?"¡¡TE GANASTE UN BREAK!!":"¡¡NO VEAS TU CELULAR!!",
                      style: TextStyle(
                        color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                        fontSize: alto/30
                      ),
                    ):Container()
                  ),

                  SizedBox(
                        height: indicador?alto/80:0,
                      ),

                  indicador?SizedBox(
                    height: alto/17,
                    width:  alto/17,
                    child:Center(
                      child: Icon(
                      descanso?Icons.celebration:Icons.no_cell_rounded,
                      size: alto/17,
                      color: currentTheme.isDarkTheme()
                        ?(
                          descanso?Colors.pink[600]
                          :Colors.cyan[800]
                          )
                        :(
                          descanso?Colors.pink[400]
                          :Colors.greenAccent[400]
                          ),
                      ),
                    ) 
                  ):Container(),
                  //sliderRotableFunc(0,5,5,0,maxpom,40,30),
                  //SliderLabelWidget(),
                  
                ],
              ),
            ),
          ],
        )
      ),

      //CANTIDAD DE POMODOROS
      bottomNavigationBar: BottomAppBar(
        color: currentTheme.isDarkTheme()
                  ?Colors.black12
                  :(indicador
                    ?(descanso?Colors.pink[400]
                      :Colors.greenAccent[400])
                    :Colors.blue[100]),
        child: Container(
          height: 70,
          child: /*indicador?*/
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SliderTheme(
                  data: SliderThemeData(
                  trackHeight: 70,
                  thumbShape: SliderComponentShape.noOverlay,
                  overlayShape: SliderComponentShape.noOverlay,
                  valueIndicatorShape: SliderComponentShape.noOverlay,
                  trackShape: RectangularSliderTrackShape(),
                  /// ticks in between
                  //activeTickMarkColor: Colors.transparent,
                  //inactiveTickMarkColor: Colors.transparent,
                  
                ),
                child: Container(
                  height: 70,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            RotatedBox(
                              quarterTurns: 0,
                              child: Slider(
                                
                                value: maxpom.toDouble(),
                                min: 0,
                                max: 5,
                                divisions: 5,
                                activeColor: currentTheme.isDarkTheme()
                                ?(indicador
                                  ?(descanso
                                    ?Colors.pink[600]
                                    :Colors.cyan[800])
                                  :Colors.blue)
                                :(indicador
                                  ?(descanso
                                    ?Colors.pink[400]
                                    :Colors.greenAccent[400])
                                  :Colors.blue),
                                inactiveColor: currentTheme.isDarkTheme()
                                  ?Colors.black12
                                  :(indicador
                                    ?(descanso?Colors.pink[300]
                                      :Colors.greenAccent[100])
                                    :Colors.blue[100]),
                                //label: maxpom.round().toString(),
                                onChanged: (value){
                                  setState(() {
                                    setPomodoros(value.toInt());
                                  });
                                },
                              ),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[ 
                                  SizedBox(
                                    height: 70,
                                    width: 60,
                                    child: IconButton(onPressed: (){ setState(decPom);}, 
                                    icon: Icon(Icons.remove),
                                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                                    iconSize: 40),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(indicador
                                        ?'Restantes: $maxpom'
                                        :'Repeticiones: $maxpom',
                                        style: TextStyle(
                                          color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: alto/30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 70,
                                    width: 60,
                                    child: IconButton(onPressed: (){ setState(incPom);}, 
                                    icon: Icon(Icons.add),
                                    color: currentTheme.isDarkTheme() ? Colors.white : Colors.black,
                                    iconSize: 40),
                                  ),
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                      //const SizedBox(height: 16),

                    ],
                  ),
                ),
              ),
              )
            ],
          )
          
        )
      ),
    );
  }
}



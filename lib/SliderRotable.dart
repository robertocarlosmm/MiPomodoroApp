import 'package:flutter/material.dart';

class SliderVerticalWidget extends StatefulWidget {
  @override
  _SliderVerticalWidgetState createState() => _SliderVerticalWidgetState();
}

class _SliderVerticalWidgetState extends State<SliderVerticalWidget> {
  double value = 75;

  @override
  Widget build(BuildContext context) {
    final double min = 0;
    final double max = 100;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 80,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,

        trackShape: RectangularSliderTrackShape(),

        /// ticks in between
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        height: 360,
        child: Column(
          children: [
            buildSideLabel(max),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: value,
                      min: min,
                      max: max,
                      divisions: 20,
                      label: value.round().toString(),
                      onChanged: (value) => setState(() => this.value = value),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${value.round()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            buildSideLabel(min),
          ],
        ),
      ),
    );
  }



Widget sliderRotableFunc(double min, double max, int division, int rotation, int variable, double altura, double track){
  return SliderTheme(
      data: SliderThemeData(
        trackHeight: track,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,

        trackShape: RectangularSliderTrackShape(),

        /// ticks in between
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        height: altura,
        child: Column(
          children: [
            //buildSideLabel(max),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  RotatedBox(
                    quarterTurns: rotation,
                    child: Slider(
                      value: variable.toDouble(),
                      min: min,
                      max: max,
                      divisions: division,
                      label: variable.round().toString(),
                      onChanged: (value) => setState(() => variable = value.toInt()),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${variable.round()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //const SizedBox(height: 16),
            //buildSideLabel(min),
          ],
        ),
      ),
    );
}

Widget buildSideLabel(double value) => Text(
        value.round().toString(),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );
}
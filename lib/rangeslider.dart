import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart';

class RangeSliderExample extends StatefulWidget {
  const RangeSliderExample({super.key});

  @override
  State<RangeSliderExample> createState() => _RangeSliderExampleState();
}

// TODO: başlangıç ve bitiş verisini globals.dart a aktarıp, sonrada filtrelerken çekip database deki verinin arada olup olmadığına bakabilirsin !!

class _RangeSliderExampleState extends State<RangeSliderExample> {
  RangeValues _currentRangeValues = const RangeValues(200, 350);
  final ValueNotifier<RangeValues> _rangeNotifier = ValueNotifier<RangeValues>(const RangeValues(200, 350));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RangeSlider(
          values: _currentRangeValues,
          max: 800,
          divisions: 16,
          labels: RangeLabels(
            _currentRangeValues.start.round().toString(),
            _currentRangeValues.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentRangeValues = values;
              _rangeNotifier.value = values;
              // filtreleme için globals.dart a veri gönderiyorum
              minPrice = _currentRangeValues.start.round();
              maxPrice = _currentRangeValues.end.round();
            });
          },
        ),
        RangeValuesDisplay(rangeNotifier: _rangeNotifier),
      ],
    );
  }
}


class RangeValuesDisplay extends StatelessWidget {
  final ValueNotifier<RangeValues> rangeNotifier;

  const RangeValuesDisplay({super.key, required this.rangeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RangeValues>(
      valueListenable: rangeNotifier,
      builder: (context, rangeValues, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'Fiyat Aralığı: ${rangeValues.start.round()} - ${rangeValues.end.round()}',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
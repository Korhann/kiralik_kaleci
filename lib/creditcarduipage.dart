import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardWidget extends StatefulWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;

  const CardWidget({
    super.key,
    required this.cardNumberController,
    required this.expiryDateController,
    required this.cvvController,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

// TODO: Sonradan devam edilecek

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card Number Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: widget.cardNumberController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter(),
            ],
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'XXXX XXXX XXXX XXXX',
              labelText: 'Kart Numarası',
              isDense: true,
            ),
            maxLength: 19,
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 10), // Add space between fields

        // Expiry Date and CVV fields in a row
        Row(
          children: [
            // Expiry Date Field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: widget.expiryDateController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CardExpirationFormatter(),
                  ],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'MM/YY',
                    labelText: 'Son Kullanma Tarihi',
                    isDense: true,
                  ),
                  maxLength: 5,
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(width: 10),

            // CVV Field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: widget.cvvController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'XXX',
                    labelText: 'CVV',
                    isDense: true,
                  ),
                  maxLength: 4,
                  obscureText: false,
                  onChanged: (value) {},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.controller,
    required this.txtLabel,
  });

  final TextEditingController controller;
  final String txtLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.name,
          cursorHeight: 26,
          decoration: InputDecoration(
            hintText: 'Enter $txtLabel',
            label: Text(txtLabel),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$txtLabel can not be empty';
            }
            return null;
          },
        ),
      ],
    );
  }
}

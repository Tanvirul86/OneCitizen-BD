import 'package:flutter/services.dart';

/// Blocks anything but digits and at most one decimal point while typing —
/// for amounts/measurements that may have a fractional part (GPA, land size,
/// income, BDT amounts).
final decimalInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
];

/// Blocks anything but digits while typing — for whole-number fields (phone,
/// NID, roll/registration numbers, EIIN, counts).
final integerInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
];

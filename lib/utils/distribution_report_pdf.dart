import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a printable/shareable PDF for a fund-distribution report.
/// Amounts use "Tk" rather than the ৳ glyph — the default PDF font can't
/// render it, which would otherwise show as a missing-character box.
Future<Uint8List> buildDistributionReportPdf({
  required String periodTypeLabel,
  required String periodLabel,
  required double total,
  required int recipientCount,
  required Map<String, ({int count, double total})> byCardType,
  required Map<String, List<Distribution>> recordsByCardType,
}) async {
  final doc = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text(
          'OneCitizen BD — Fund Distribution Report',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '$periodTypeLabel: $periodLabel',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Total Disbursed: Tk ${total.toStringAsFixed(0)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
            pw.Text(
              'Recipients: $recipientCount',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Breakdown by Card Type',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: const ['Card Type', 'Recipients', 'Total (Tk)'],
          data: byCardType.entries
              .map(
                (entry) => [
                  entry.key,
                  '${entry.value.count}',
                  entry.value.total.toStringAsFixed(0),
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Details',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        for (final entry in recordsByCardType.entries) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            entry.key,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headers: const ['Recipient', 'Amount (Tk)', 'Date & Time'],
            data: entry.value
                .map(
                  (dist) => [
                    dist.citizenName ?? 'Citizen',
                    dist.amount.toStringAsFixed(0),
                    dateFormat.format(dist.distributionDate),
                  ],
                )
                .toList(),
          ),
        ],
      ],
    ),
  );

  return doc.save();
}

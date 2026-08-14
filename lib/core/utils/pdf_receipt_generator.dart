import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'currency_formatter.dart';

class PdfReceiptGenerator {
  static Future<void> generateAndShareReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
    String nif = '',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              if (address1.isNotEmpty) pw.Text(address1, textAlign: pw.TextAlign.center),
              if (address2.isNotEmpty) pw.Text(address2, textAlign: pw.TextAlign.center),
              if (phone.isNotEmpty) pw.Text('Telefone: $phone', textAlign: pw.TextAlign.center),
              if (nif.isNotEmpty) pw.Text('NIF: $nif', textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 16),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(flex: 2, child: pw.Text('Artigo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('Qtd', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 8),
              ...items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(flex: 2, child: pw.Text(item['name'].toString())),
                      pw.Expanded(flex: 1, child: pw.Text(item['qty'].toString(), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 1, child: pw.Text(AppCurrency.formatPlain(item['total'] as num), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text(AppCurrency.format(total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 16),
              if (footer.isNotEmpty) pw.Text(footer, textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Talão de $shopName');
  }
}

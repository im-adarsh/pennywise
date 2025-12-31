import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pennywise/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class ExportService {
  Future<void> exportToCSV(List<Expense> expenses) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Category', 'Description', 'Amount', 'Member'],
      ...expenses.map((expense) => [
            DateFormat('yyyy-MM-dd').format(expense.date),
            expense.category,
            expense.description,
            expense.amount.toStringAsFixed(2),
            expense.memberId ?? 'Unassigned',
          ]),
    ];

    final String csv = const ListToCsvConverter().convert(rows);
    final Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final String filePath =
        '${directory.path}/expenses_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final File file = File(filePath);
    await file.writeAsString(csv);
  }

  Future<void> exportToPDF(List<Expense> expenses, DateTime month) async {
    final pdf = pw.Document();
    final monthExpenses = expenses.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Monthly Expense Report - ${DateFormat('MMMM yyyy').format(month)}',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Category',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Description',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...monthExpenses.map((expense) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            DateFormat('MMM dd, yyyy').format(expense.date)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(expense.category),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(expense.description),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child:
                            pw.Text('\$${expense.amount.toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('')),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '\$${monthExpenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final String filePath =
        '${directory.path}/expenses_${DateFormat('yyyyMM').format(month)}.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }
}

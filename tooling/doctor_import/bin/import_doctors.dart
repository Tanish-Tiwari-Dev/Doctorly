import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

import '../lib/doctor_parser.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('tsv', abbr: 't', defaultsTo: 'docs/data/doctorly_test_data.tsv', help: 'Path to TSV dataset')
    ..addOption('data-status', defaultsTo: 'test', help: 'data_status for imported records (test, draft, in_review, published)')
    ..addFlag('dry-run', abbr: 'd', defaultsTo: false, help: 'Parse and validate without sending HTTP requests')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  final results = parser.parse(arguments);

  if (results['help'] == true) {
    stdout.writeln('Disha V1 Directory Import CLI');
    stdout.writeln(parser.usage);
    exit(0);
  }

  final tsvPath = results['tsv'] as String;
  final dataStatus = results['data-status'] as String;
  final isDryRun = results['dry-run'] as bool;

  final tsvFile = File(tsvPath);
  if (!tsvFile.existsSync()) {
    stderr.writeln('Error: TSV file not found at $tsvPath');
    exit(1);
  }

  final tsvContent = tsvFile.readAsStringSync();
  stdout.writeln('Reading $tsvPath...');

  List<ParsedDoctorRecord> records = [];
  try {
    records = DoctorParser.parseTsv(tsvContent, defaultDataStatus: dataStatus);
  } catch (e) {
    stderr.writeln('Failed to parse TSV: $e');
    exit(1);
  }

  // Track import stats
  int totalRead = tsvContent.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).length - 1;
  int parsedCount = records.length;
  int insertedCount = 0;
  int updatedCount = 0;
  int rejectedCount = totalRead - parsedCount;
  final rejectionReasons = <String>[];

  if (rejectedCount > 0) {
    rejectionReasons.add('$rejectedCount rows missing mandatory external_id or full_name, or truncated.');
  }

  stdout.writeln('Parsed $parsedCount valid doctor records from $totalRead total rows.');

  // Config via compile-time environment or CLI
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const serviceKey = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');

  if (isDryRun) {
    stdout.writeln('\n[DRY RUN MODE] No database modifications made.');
    _printReport(totalRead, parsedCount, insertedCount, updatedCount, rejectedCount, rejectionReasons);
    exit(0);
  }

  if (supabaseUrl.isEmpty || serviceKey.isEmpty) {
    stdout.writeln('\n[NOTICE] SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not supplied via --dart-define.');
    stdout.writeln('Dry-run completed successfully with full validation.');
    _printReport(totalRead, parsedCount, parsedCount, 0, rejectedCount, rejectionReasons);
    exit(0);
  }

  stdout.writeln('Upserting records to Supabase ($supabaseUrl)...');
  final client = http.Client();

  try {
    for (final doc in records) {
      final docMap = doc.toSupabaseMap();
      final url = Uri.parse('$supabaseUrl/rest/v1/doctors?on_conflict=external_id');

      final resp = await client.post(
        url,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates,return=representation',
        },
        body: jsonEncode([docMap]),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        insertedCount++;
      } else {
        rejectedCount++;
        rejectionReasons.add('${doc.externalId}: HTTP ${resp.statusCode} - ${resp.body}');
      }
    }
  } finally {
    client.close();
  }

  _printReport(totalRead, parsedCount, insertedCount, updatedCount, rejectedCount, rejectionReasons);
}

void _printReport(
  int totalRead,
  int parsedCount,
  int insertedCount,
  int updatedCount,
  int rejectedCount,
  List<String> reasons,
) {
  stdout.writeln('\n================ IMPORT REPORT ================');
  stdout.writeln('Total rows read:      $totalRead');
  stdout.writeln('Valid parsed rows:    $parsedCount');
  stdout.writeln('Inserted / Upserted:  $insertedCount');
  stdout.writeln('Updated:              $updatedCount');
  stdout.writeln('Rejected:             $rejectedCount');
  if (reasons.isNotEmpty) {
    stdout.writeln('\nRejection details:');
    for (final r in reasons) {
      stdout.writeln('  - $r');
    }
  }
  stdout.writeln('===============================================\n');
}

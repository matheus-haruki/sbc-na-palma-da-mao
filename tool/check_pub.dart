
import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

const String _apiUrl = 'https://pub.dev/api/packages';

void main() async {
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('ERROR: pubspec.yaml not found.');
    exitCode = 1;
    return;
  }

  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  try {
    final yaml = loadYaml(await pubspecFile.readAsString());

    if (yaml is! YamlMap) {
      stderr.writeln('ERROR: Invalid pubspec.yaml.');
      exitCode = 1;
      return;
    }

    final dependencies = <String, String>{};

    _loadDependencies(yaml['dependencies'], dependencies);
    _loadDependencies(yaml['dev_dependencies'], dependencies);

    if (dependencies.isEmpty) {
      stdout.writeln('No hosted dependencies found.');
      return;
    }

    stdout.writeln('');
    stdout.writeln('DEPENDENCY CHECKER');
    stdout.writeln('Packages found: ${dependencies.length}');
    stdout.writeln('-' * 100);

    stdout.writeln(
      '${'PACKAGE'.padRight(30)}'
      '${'REQUESTED'.padRight(20)}'
      '${'LATEST'.padRight(18)}'
      '${'LATEST ALLOWED'.padRight(20)}'
      'STATUS',
    );

    stdout.writeln('-' * 100);

    var errors = 0;

    for (final entry in dependencies.entries) {
      try {
        final result = await _checkPackage(
          client,
          entry.key,
          entry.value,
        );

        final status = result.status;

        stdout.writeln(
          '${entry.key.padRight(30)}'
          '${entry.value.padRight(20)}'
          '${result.latest.padRight(18)}'
          '${result.latestAllowed.padRight(20)}'
          '$status',
        );

        if (result.isError) {
          errors++;
        }
      } catch (error) {
        errors++;

        stdout.writeln(
          '${entry.key.padRight(30)}'
          '${entry.value.padRight(20)}'
          'ERROR: $error',
        );
      }
    }

    stdout.writeln('-' * 100);
    stdout.writeln('Finished: ${dependencies.length} packages checked.');
    stdout.writeln('Errors: $errors');
    stdout.writeln('');

    if (errors > 0) {
      exitCode = 1;
    }
  } catch (error) {
    stderr.writeln('ERROR: $error');
    exitCode = 1;
  } finally {
    client.close(force: true);
  }
}

void _loadDependencies(
  dynamic section,
  Map<String, String> dependencies,
) {
  if (section is! YamlMap) return;

  for (final entry in section.entries) {
    final name = entry.key.toString();
    final specification = entry.value;

    // Ignore Flutter SDK, Dart SDK, Git and local dependencies.
    if (specification is YamlMap) {
      if (specification.containsKey('sdk') ||
          specification.containsKey('git') ||
          specification.containsKey('path')) {
        continue;
      }
    }

    String constraint = 'any';

    if (specification is String) {
      constraint = specification;
    } else if (specification is YamlMap &&
        specification.containsKey('version')) {
      constraint = specification['version'].toString();
    } else if (specification is! YamlMap) {
      continue;
    }

    dependencies[name] = constraint;
  }
}

Future<PackageResult> _checkPackage(
  HttpClient client,
  String package,
  String requestedConstraint,
) async {
  final uri = Uri.parse('$_apiUrl/$package');

  final request = await client.getUrl(uri).timeout(
    const Duration(seconds: 15),
  );

  request.headers.set(HttpHeaders.acceptHeader, 'application/json');

  final response = await request.close().timeout(
    const Duration(seconds: 20),
  );

  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode != 200) {
    throw HttpException(
      'HTTP ${response.statusCode}',
      uri: uri,
    );
  }

  final data = jsonDecode(body) as Map<String, dynamic>;

  final isDiscontinued = data['isDiscontinued'] == true;
  final latestData = data['latest'] as Map<String, dynamic>;
  final versions = data['versions'] as List<dynamic>;

  final constraint = VersionConstraint.parse(requestedConstraint);

  final stableVersions = <Version>[];

  for (final item in versions) {
    final versionData = item as Map<String, dynamic>;

    if (versionData['retracted'] == true) continue;

    final version = Version.parse(versionData['version'] as String);

    if (version.preRelease.isEmpty) {
      stableVersions.add(version);
    }
  }

  if (stableVersions.isEmpty) {
    return PackageResult(
      latest: 'N/A',
      latestAllowed: 'N/A',
      status: 'NO STABLE VERSIONS',
      isError: true,
    );
  }

  stableVersions.sort();

  final latest = stableVersions.last;

  final compatibleVersions = stableVersions
      .where((version) => constraint.allows(version))
      .toList();

  if (compatibleVersions.isEmpty) {
    return PackageResult(
      latest: latest.toString(),
      latestAllowed: 'NONE',
      status: 'NO MATCH',
      isError: true,
    );
  }

  final latestAllowed = compatibleVersions.last;

  final isLatestRetracted = latestData['retracted'] == true;

  String status;

  if (isDiscontinued) {
    status = 'DISCONTINUED';
  } else if (isLatestRetracted) {
    status = 'LATEST RETRACTED';
  } else if (latestAllowed < latest) {
    status = 'RANGE LIMITED';
  } else {
    status = 'OK';
  }

  return PackageResult(
    latest: latest.toString(),
    latestAllowed: latestAllowed.toString(),
    status: status,
    isError: isDiscontinued || isLatestRetracted,
  );
}

class PackageResult {
  final String latest;
  final String latestAllowed;
  final String status;
  final bool isError;

  const PackageResult({
    required this.latest,
    required this.latestAllowed,
    required this.status,
    required this.isError,
  });
}

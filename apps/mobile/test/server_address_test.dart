import 'package:flutter_test/flutter_test.dart';
import 'package:tendant/core/server/server_address.dart';
import 'package:tendant/core/server/native_env_io.dart';

void main() {
  group('normalizeServerBaseUrl', () {
    test('adds default http scheme', () {
      expect(normalizeServerBaseUrl('localhost:8080'),
          'http://localhost:8080');
    });

    test('keeps an explicit https scheme and host without port', () {
      expect(normalizeServerBaseUrl('https://tendant.example.com'),
          'https://tendant.example.com');
    });

    test('strips a /graphql path and trailing slash', () {
      expect(normalizeServerBaseUrl('http://host:8080/graphql/'),
          'http://host:8080');
    });

    test('drops query and fragment', () {
      expect(normalizeServerBaseUrl('http://host:8080/x?y=1#z'),
          'http://host:8080');
    });

    test('returns null for blank or host-less input', () {
      expect(normalizeServerBaseUrl(''), isNull);
      expect(normalizeServerBaseUrl('   '), isNull);
      expect(normalizeServerBaseUrl('http://'), isNull);
    });
  });

  group('serverUrlCandidates', () {
    test('local host: http + 8080 first, both schemes/ports tried', () {
      expect(serverUrlCandidates('localhost'), [
        'http://localhost:8080',
        'http://localhost',
        'https://localhost:8080',
        'https://localhost',
      ]);
    });

    test('public host: https-first, default port before 8080', () {
      expect(serverUrlCandidates('tendant.example.com'), [
        'https://tendant.example.com',
        'https://tendant.example.com:8080',
        'http://tendant.example.com',
        'http://tendant.example.com:8080',
      ]);
    });

    test('explicit scheme and port are honored exactly', () {
      expect(serverUrlCandidates('https://host:8443'), ['https://host:8443']);
    });

    test('path is stripped', () {
      expect(serverUrlCandidates('http://host:8080/graphql'),
          ['http://host:8080']);
    });

    test('IPv6 is bracketed', () {
      expect(serverUrlCandidates('http://[::1]:8080'), ['http://[::1]:8080']);
    });

    test('blank input yields no candidates', () {
      expect(serverUrlCandidates('   '), isEmpty);
    });
  });

  group('detectServer', () {
    test('returns the first candidate whose probe succeeds', () async {
      final probed = <String>[];
      final found = await detectServer(
        ['http://a:8080', 'http://b:8080', 'http://c:8080'],
        probe: (url) async {
          probed.add(url);
          return url == 'http://b:8080';
        },
      );
      expect(found, 'http://b:8080');
      // Stops after the first hit — c is never probed.
      expect(probed, ['http://a:8080', 'http://b:8080']);
    });

    test('returns null when nothing answers', () async {
      final found = await detectServer(
        ['http://a:8080', 'http://b:8080'],
        probe: (_) async => false,
      );
      expect(found, isNull);
    });
  });

  group('isTendantHealthzBody', () {
    test('accepts a tendant-identified body', () {
      expect(isTendantHealthzBody('{"service":"tendant","ok":true}'), isTrue);
    });

    test('rejects a generic 200 body without the marker', () {
      expect(isTendantHealthzBody('{"ok":true}'), isFalse);
      expect(isTendantHealthzBody('OK'), isFalse);
      expect(isTendantHealthzBody('{"service":"something-else"}'), isFalse);
    });
  });

  group('parseServerUrlFromConfig', () {
    test('reads a quoted server_url key, ignoring comments', () {
      const body = '''
# tendant client config
server_url = "https://host:8443"
''';
      expect(parseServerUrlFromConfig(body), 'https://host:8443');
    });

    test('reads an unquoted key with a colon separator', () {
      expect(parseServerUrlFromConfig('server_url: http://host:8080'),
          'http://host:8080');
    });

    test('falls back to a bare URL line', () {
      expect(parseServerUrlFromConfig('http://bare:8080'),
          'http://bare:8080');
    });

    test('prefers the key over a bare line', () {
      const body = '''
http://bare:9999
server_url = http://keyed:8080
''';
      expect(parseServerUrlFromConfig(body), 'http://keyed:8080');
    });

    test('returns null when nothing usable is present', () {
      expect(parseServerUrlFromConfig('# just a comment\n'), isNull);
    });
  });
}

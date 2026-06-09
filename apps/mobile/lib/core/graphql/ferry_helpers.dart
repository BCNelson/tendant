import 'package:ferry/ferry.dart';

/// runOnce executes a Ferry operation and resolves with the first authoritative
/// (network) response. It completes on the `Link` data source — not on
/// `loading` — because [OperationResponse.loading] stays true for GraphQL-error
/// responses (data null + no link exception) and for legitimately-null query
/// results, which would otherwise hang the future.
///
/// Requests should be built with `fetchPolicy = FetchPolicy.NetworkOnly` (or
/// NoCache) so the awaited response originates from the link, not the cache.
Future<TData?> runOnce<TData, TVars>(
  Client client,
  OperationRequest<TData, TVars> req,
) async {
  final resp = await client.request(req).firstWhere(
        (r) => r.dataSource == DataSource.Link || r.linkException != null,
      );
  if (resp.hasErrors) {
    final gql = resp.graphqlErrors?.map((e) => e.message).join('; ');
    if (gql != null && gql.isNotEmpty) throw Exception(gql);
    throw Exception(resp.linkException?.toString() ?? 'GraphQL error');
  }
  return resp.data;
}

/// runOnceRequired is [runOnce] for operations whose result must be non-null
/// (mutations, list queries). Throws if the server returns null data.
Future<TData> runOnceRequired<TData, TVars>(
  Client client,
  OperationRequest<TData, TVars> req,
) async {
  final data = await runOnce(client, req);
  if (data == null) throw Exception('No data returned');
  return data;
}

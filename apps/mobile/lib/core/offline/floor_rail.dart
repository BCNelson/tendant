/// WriteClass discriminates low-stakes writes (outbox-eligible) from
/// floor-relevant writes (refused offline). The floor doesn't *exist*
/// in Phase 2, but the rail is installed so when Phase 3 wires the four
/// decision mutations, offline attempts already fail safe.
enum WriteClass { lowStakes, floorRelevant }

/// classify returns the WriteClass for the named GraphQL mutation. Unknown
/// mutations are floor-relevant by default (fail-safe; matches the spec's
/// FR-027 default).
WriteClass classify(String mutationName) {
  switch (mutationName) {
    case 'dismissProposedTask':
    case 'acceptProposedTask':
    case 'markRead':
      return WriteClass.lowStakes;
    case 'approveArtifact':
    case 'rejectApproval':
    case 'answerQuestion':
    case 'decidePromotion':
      return WriteClass.floorRelevant;
  }
  return WriteClass.floorRelevant;
}

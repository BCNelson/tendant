import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/core/offline/floor_rail.dart';

void main() {
  test('low-stakes mutations classify as lowStakes', () {
    expect(classify('dismissProposedTask'), WriteClass.lowStakes);
    expect(classify('acceptProposedTask'), WriteClass.lowStakes);
  });

  test('decision mutations classify as floorRelevant', () {
    expect(classify('approveArtifact'), WriteClass.floorRelevant);
    expect(classify('rejectApproval'), WriteClass.floorRelevant);
    expect(classify('answerQuestion'), WriteClass.floorRelevant);
    expect(classify('decidePromotion'), WriteClass.floorRelevant);
  });

  test('unknown mutations classify as floorRelevant (fail-safe)', () {
    expect(classify('somethingNew'), WriteClass.floorRelevant);
  });
}

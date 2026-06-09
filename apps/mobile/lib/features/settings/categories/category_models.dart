/// CategoryView is the view-model for one task-category row. `stageBindings`
/// carries the raw per-stage binding map
/// ({"execution":{"agents":[...],"eligibility":{...}}}); the form edits it as
/// JSON. `depth` is derived client-side from the parent chain for tree indent.
class CategoryView {
  const CategoryView({
    required this.key,
    required this.label,
    this.description,
    this.parentKey,
    required this.stageBindings,
    this.depth = 0,
  });

  final String key;
  final String label;
  final String? description;
  final String? parentKey;
  final Map<String, dynamic> stageBindings;
  final int depth;

  CategoryView withDepth(int d) => CategoryView(
        key: key,
        label: label,
        description: description,
        parentKey: parentKey,
        stageBindings: stageBindings,
        depth: d,
      );
}

/// CategoryEdit is the owner-submitted upsert payload from the edit form.
class CategoryEdit {
  const CategoryEdit({
    required this.key,
    this.label,
    this.description,
    this.parent,
    this.stageBindings,
  });

  final String key;
  final String? label;
  final String? description;

  /// Parent key. null ⇒ derive from the key path prefix server-side; ""
  /// ⇒ force a root category.
  final String? parent;

  /// Parsed stage-bindings map; null ⇒ leave as "{}".
  final Map<String, dynamic>? stageBindings;
}

import 'package:flutter/material.dart';

import 'tasks_models.dart';

/// Human-readable title for an activity event, derived from its kind + payload.
/// Unknown kinds fall back to the kind with underscores spaced out, so a new
/// audit kind still renders something sensible.
String activityTitle(ActivityEventRef e) {
  final d = e.detail;
  String s(String k) => d[k]?.toString() ?? '';
  switch (e.kind) {
    case 'workflow_started':
      return 'Workflow started';
    case 'workflow_cancelled':
      return 'Workflow cancelled';
    case 'stage_advance':
      return 'Stage: ${s('from')} → ${s('to')}';
    case 'state_transition':
      return 'State: ${s('from')} → ${s('to')}';
    case 'agent_run_started':
      return '${d['config_name'] ?? s('stage')} started';
    case 'agent_run_finished':
      return '${d['config_name'] ?? s('stage')} finished';
    case 'router_selected':
      return 'Router selected specialist';
    case 'assignment_created':
      return 'Assigned to you (${s('stage')})';
    case 'assignment_resolved':
      return 'Assignment resolved (${s('stage')})';
    case 'agent_call_refused':
      return 'Tool call refused: ${s('tool_name')}';
    case 'budget_exhausted':
      return 'Budget exhausted';
    case 'max_iterations_reached':
      return 'Max iterations reached';
    case 'tool_call_composed':
      return 'Tool call: ${d['tool_global_uri'] ?? d['tool_id'] ?? ''}';
    case 'gate_verdict':
      return 'Gate verdict: ${s('decision')}';
    case 'gate_script_evaluated':
      return 'Gate script: ${s('verdict')}';
    case 'overseer_evaluated':
      return 'Overseer: ${s('verdict')}';
    case 'decision_resolved':
      return d['approved'] == true ? 'Approved' : 'Rejected';
    case 'tool_dispatched':
      final err = d['error'];
      return err is String && err.isNotEmpty
          ? 'Tool dispatch failed'
          : 'Tool dispatched';
    case 'tool_outcome_recorded':
      return 'Tool outcome: ${s('outcome')}';
    default:
      return e.kind.replaceAll('_', ' ');
  }
}

/// Optional secondary line — the salient metric/reason for the event.
String? activitySubtitle(ActivityEventRef e) {
  final d = e.detail;
  switch (e.kind) {
    case 'agent_run_finished':
      final parts = <String>[];
      if (d['iterations'] != null) parts.add('${d['iterations']} iter');
      if (d['tokens_in'] != null || d['tokens_out'] != null) {
        parts.add('${d['tokens_in'] ?? 0}+${d['tokens_out'] ?? 0} tok');
      }
      return parts.isEmpty ? null : parts.join(' · ');
    case 'stage_advance':
    case 'state_transition':
    case 'workflow_cancelled':
      final r = d['reason'];
      return r is String && r.isNotEmpty ? r : null;
    case 'tool_dispatched':
      final err = d['error'];
      if (err is String && err.isNotEmpty) return err;
      return d['provider']?.toString();
    case 'decision_resolved':
      final r = d['reason'];
      return r is String && r.isNotEmpty ? r : null;
    default:
      return null;
  }
}

/// Icon for an activity event grouped by concern.
IconData activityIcon(String kind) {
  if (kind.startsWith('agent_run')) return Icons.smart_toy;
  if (kind.startsWith('tool_') || kind == 'tool_call_composed') {
    return Icons.build;
  }
  if (kind.startsWith('gate')) return Icons.verified_user;
  if (kind == 'overseer_evaluated') return Icons.gavel;
  if (kind == 'decision_resolved') return Icons.how_to_reg;
  if (kind.startsWith('assignment')) return Icons.person;
  if (kind.startsWith('stage')) return Icons.arrow_forward;
  if (kind.startsWith('state')) return Icons.swap_horiz;
  if (kind.startsWith('workflow')) return Icons.flag;
  if (kind.startsWith('router')) return Icons.alt_route;
  return Icons.fiber_manual_record;
}

/// Short local clock time (HH:mm:ss) for an ISO-8601 timestamp; falls back to
/// the raw string if it can't be parsed.
String activityTime(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
}

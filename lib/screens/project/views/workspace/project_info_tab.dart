import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/api_models.dart';
import '../../../../models/team_contact.dart';
import '../../../../providers/project_workspace_provider.dart';

class ProjectInfoTab extends StatelessWidget {
  const ProjectInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectWorkspaceProvider>();

    if (provider.isLoading && provider.details == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.details == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final details = provider.details!;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(details: details),
          const SizedBox(height: 12),
          _KeyFactsCard(details: details),
          const SizedBox(height: 12),
          _ContractCard(details: details),
          const SizedBox(height: 12),
          _AddressCard(details: details),
          const SizedBox(height: 12),
          _TeamCard(
            team: provider.team,
            teamLoadFailed: provider.teamLoadFailed,
          ),
          const SizedBox(height: 12),
          _DocumentsCard(details: details),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  final ProjectDetails details;
  const _HeaderCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.code != null)
              Text(details.code!, style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              )),
            const SizedBox(height: 4),
            Text(details.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(status: details.status ?? 'Unknown'),
                const SizedBox(width: 8),
                if (details.phase != null)
                  _StatusChip(status: details.phase!, outlined: true),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: details.progress.clamp(0.0, 1.0),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Text(
              '${(details.progress * 100).toStringAsFixed(0)}% complete',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool outlined;
  const _StatusChip({required this.status, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    if (outlined) {
      return Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        padding: EdgeInsets.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        backgroundColor: Colors.transparent,
      );
    }
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      padding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// Key Facts Card
// ---------------------------------------------------------------------------

class _KeyFactsCard extends StatelessWidget {
  final ProjectDetails details;
  const _KeyFactsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Key Facts',
      children: [
        _InfoRow(label: 'Type', value: details.projectType),
        _InfoRow(label: 'Start Date', value: details.startDate),
        _InfoRow(label: 'End Date', value: details.endDate),
        _InfoRow(
          label: 'Area',
          value: details.sqFeet != null
              ? '${details.sqFeet!.toStringAsFixed(0)} sq ft'
              : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contract Card
// ---------------------------------------------------------------------------

class _ContractCard extends StatelessWidget {
  final ProjectDetails details;
  const _ContractCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contract', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              details.contractValueDisplay ?? 'Not set',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Start',
              value: details.startDate,
            ),
            _InfoRow(
              label: 'Est. completion',
              value: details.estimatedCompletionDate,
            ),
            _InfoRow(
              label: 'Package',
              value: details.designPackage,
            ),
            _InfoRow(
              label: 'Agreement Signed',
              value: details.isDesignAgreementSigned ? 'Yes' : 'No',
            ),
            _InfoRow(label: 'Responsible Person', value: details.responsiblePerson),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Address Card
// ---------------------------------------------------------------------------

class _AddressCard extends StatelessWidget {
  final ProjectDetails details;
  const _AddressCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final location = details.location;
    return _InfoCard(
      title: 'Address',
      trailing: location != null
          ? IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Open in Maps',
              onPressed: () => launchUrl(
                Uri.parse(
                    'https://maps.google.com/?q=${Uri.encodeComponent(location)}'),
                mode: LaunchMode.externalApplication,
              ),
            )
          : null,
      children: [
        _InfoRow(label: 'Location', value: location),
        _InfoRow(label: 'State', value: details.state),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Team Card
// ---------------------------------------------------------------------------

class _TeamCard extends StatelessWidget {
  final List<TeamContact>? team;
  final bool teamLoadFailed;
  const _TeamCard({required this.team, required this.teamLoadFailed});

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (teamLoadFailed) {
      body = const Text(
        'Couldn\'t load team contacts. Pull down to refresh.',
        style: TextStyle(color: Colors.red),
      );
    } else if (team == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (team!.isEmpty) {
      body = const Text(
        'No team contacts available yet.',
        style: TextStyle(color: Colors.grey),
      );
    } else {
      body = Column(
        children: team!.map((m) => _TeamMemberTile(member: m)).toList(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  final TeamContact member;
  const _TeamMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: member.photoUrl != null
                ? NetworkImage(member.photoUrl!)
                : null,
            child: member.photoUrl == null
                ? Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(member.designation,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: member.hasPhone ? 'Call ${member.name}' : 'No phone available',
            onPressed: member.hasPhone
                ? () => launchUrl(Uri.parse('tel:${member.phone}'),
                    mode: LaunchMode.externalApplication)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: member.hasEmail ? 'Email ${member.name}' : 'No email available',
            onPressed: member.hasEmail
                ? () => launchUrl(Uri.parse('mailto:${member.email}'),
                    mode: LaunchMode.externalApplication)
                : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Documents Card
// ---------------------------------------------------------------------------

class _DocumentsCard extends StatelessWidget {
  final ProjectDetails details;
  const _DocumentsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final docs = details.documents;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documents', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (docs.isEmpty)
              const Text(
                'No documents uploaded yet.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...docs.map((doc) => _DocumentTile(doc: doc)),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final ProjectDocumentSummary doc;
  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(doc.filename, style: const TextStyle(fontSize: 14)),
      subtitle: doc.categoryName != null ? Text(doc.categoryName!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.download_outlined),
        onPressed: () => launchUrl(
          Uri.parse(doc.downloadUrl),
          mode: LaunchMode.externalApplication,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared components
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _InfoCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not set',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

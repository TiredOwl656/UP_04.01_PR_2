import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../repositories/api_audit_repository.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<Map<String, dynamic>>? _entries;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<ApiAuditRepository>().all();
      if (!mounted) return;
      setState(() {
        _entries = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Аудит')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_entries == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Журнал действий')),
      body: _entries!.isEmpty
          ? const Center(child: Text('Записей нет'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _entries!.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final e = _entries![i];
                return ListTile(
                  title: Text('${e['method']} ${e['path']}'),
                  subtitle: Text('${e['user']} (${e['role']}) • ${e['at']}'),
                );
              },
            ),
    );
  }
}
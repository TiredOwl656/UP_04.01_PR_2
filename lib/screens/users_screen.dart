import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../repositories/supabase_user_repository.dart';
import '../state/auth_notifier.dart' show Role;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<ManagedUser>? _users;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<SupabaseUserRepository>().all();
      if (!mounted) return;
      setState(() {
        _users = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _setRole(ManagedUser u, Role role) async {
    try {
      await context.read<SupabaseUserRepository>().setRole(u.userId, role);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Пользователи')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_users == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи и роли')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _users!.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final u = _users![i];
              return ListTile(
                title: Text(u.fullName),
                subtitle: Text(u.email),
                trailing: DropdownButton<Role>(
                  value: u.role,
                  onChanged: (r) {
                    if (r != null) _setRole(u, r);
                  },
                  items: Role.values
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.label)),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

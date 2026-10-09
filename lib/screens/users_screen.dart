import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../repositories/api_user_repository.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AppUser>? _users;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<ApiUserRepository>().all();
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

  Future<void> _setRole(int id, Role role) async {
    try {
      await context.read<ApiUserRepository>().setRole(id, role);
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
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users!.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final u = _users![i];
          return ListTile(
            title: Text(u.fullName),
            subtitle: Text('@${u.username} • ${u.role.label}'),
            trailing: DropdownButton<Role>(
              value: u.role,
              onChanged: (r) {
                if (r != null) _setRole(u.id, r);
              },
              items: Role.values
                  .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r.label)))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
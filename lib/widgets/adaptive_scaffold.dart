import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_notifier.dart';

class AdaptiveNavItem {
  final IconData icon;
  final String label;
  final String route;

  const AdaptiveNavItem(this.icon, this.label, this.route);
}

class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<AdaptiveNavItem> items;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 768;

    final logout = IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Выйти',
      onPressed: () async {
        await context.read<AuthNotifier>().logout();
        if (context.mounted) context.go('/login');
      },
    );

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: body,
      ),
    );

    if (isWide) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: [logout]),
        body: Row(
          children: [
            SingleChildScrollView(
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (i) => context.go(items[i].route),
                  labelType: NavigationRailLabelType.all,
                  destinations: items
                      .map(
                        (it) => NavigationRailDestination(
                          icon: Icon(it.icon),
                          label: Text(it.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [logout]),
      drawer: items.length > 4
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  for (final it in items)
                    ListTile(
                      leading: Icon(it.icon),
                      title: Text(it.label),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(it.route);
                      },
                    ),
                ],
              ),
            )
          : null,
      body: content,
      bottomNavigationBar: items.length > 4
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (i) => context.go(items[i].route),
              items: items
                  .map(
                    (it) => BottomNavigationBarItem(
                      icon: Icon(it.icon),
                      label: it.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

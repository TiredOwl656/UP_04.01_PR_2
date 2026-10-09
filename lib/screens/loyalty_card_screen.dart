import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/loyalty_card.dart';
import '../repositories/api_loyalty_repository.dart';

class LoyaltyCardScreen extends StatefulWidget {
  const LoyaltyCardScreen({super.key});

  @override
  State<LoyaltyCardScreen> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen> {
  LoyaltyCard? _card;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await context.read<ApiLoyaltyRepository>().myCard();
      if (!mounted) return;
      setState(() {
        _card = c;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карта лояльности')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карта лояльности')),
        body: const Center(child: Text('У вас пока нет карты лояльности')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Карта лояльности')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Номер карты',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  _card!.number,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Бонусные баллы',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  '${_card!.bonusPoints}',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
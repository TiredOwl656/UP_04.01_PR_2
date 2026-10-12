import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoyaltyCardScreen extends StatefulWidget {
  const LoyaltyCardScreen({super.key});

  @override
  State<LoyaltyCardScreen> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen> {
  Map<String, dynamic>? _card;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = Supabase.instance.client;
      final userId = db.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Не выполнен вход');
      }

      final row = await db
          .from('customers')
          .select('card_number, bonus_points')
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _card = row;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта лояльности'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _card == null || _card!['card_number'] == null
          ? const Center(
              child: Text(
                'У вас пока нет карты лояльности.\n'
                'Обратитесь к менеджеру для её оформления.',
                textAlign: TextAlign.center,
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Номер карты',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${_card!['card_number']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Бонусные баллы',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${_card!['bonus_points'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

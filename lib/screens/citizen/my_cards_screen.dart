import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/card.dart';
import 'package:onecitizen/providers/card_provider.dart';
import 'package:onecitizen/widgets/card_tile.dart';
import 'package:onecitizen/widgets/qr_display.dart';
import 'package:onecitizen/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Cards'),
      ),
      body: RefreshIndicator(
        onRefresh: () => cardProvider.loadCards(),
        child: cardProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : cardProvider.cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 60,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards issued yet.',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push('/citizen/apply'),
                          child: const Text('Apply for a new card'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cardProvider.cards.length,
                    itemBuilder: (context, index) {
                      final card = cardProvider.cards[index];
                      return CardTile(
                        card: card,
                        onTap: () => context.push('/citizen/cards/${card.id}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCardById(widget.cardId);
    });
  }

  Color _cardStatusColor(CardStatus status) {
    switch (status) {
      case CardStatus.active:
        return Colors.green;
      case CardStatus.expired:
        return Colors.red;
      case CardStatus.suspended:
        return Colors.orange;
      case CardStatus.pending:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();
    final card = cardProvider.selectedCard;

    if (cardProvider.isLoadingDetail) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card Details')),
        body: Center(
          child: Text(
            cardProvider.detailError ?? 'Card not found.',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Card Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card visual
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreen.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.cardTypeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge(
                        label: card.status.name,
                        color: _cardStatusColor(card.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    card.cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    card.holderName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Divider(height: 24),
                    _InfoRow('Card Number', card.cardNumber),
                    _InfoRow('Card Type', card.cardTypeName),
                    _InfoRow('Holder Name', card.holderName ?? 'N/A'),
                    if (card.issuedAt != null)
                      _InfoRow(
                        'Issued On',
                        DateFormat('dd MMM yyyy').format(card.issuedAt!),
                      ),
                    if (card.expiresAt != null)
                      _InfoRow(
                        'Expires On',
                        DateFormat('dd MMM yyyy').format(card.expiresAt!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // QR Code section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Scan to Verify',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrDisplay(data: card.qrData),
                    const SizedBox(height: 12),
                    Text(
                      'Show this QR code to verify your card at service points.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

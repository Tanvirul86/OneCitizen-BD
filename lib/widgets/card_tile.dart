import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/models/card.dart';
import 'package:onecitizen/widgets/status_badge.dart';

class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.card, this.onTap});

  final CitizenCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.credit_card,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardTypeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.cardNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: card.status.name),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.arrow_forward_ios, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/horse.dart';

class BetInputRow extends StatelessWidget {
  final Horse horse;
  final TextEditingController controller;

  const BetInputRow({
    super.key,
    required this.horse,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh ngựa thay cho số
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: horse.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: horse.color.withOpacity(0.55),
                width: 1.2,
              ),
            ),
            child: Image.asset(
              horse.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.pets,
                  color: horse.color,
                  size: 30,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              horse.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: 110,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Tiền cược',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: horse.color.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
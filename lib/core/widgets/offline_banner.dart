import 'package:flutter/material.dart';
import '../services/network_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService().connectionStream,
      initialData: NetworkService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade700,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'অফলাইন মোড - শুধুমাত্র সংরক্ষিত তথ্য দেখানো হচ্ছে',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CachedDataNotice extends StatelessWidget {
  final String message;
  
  const CachedDataNotice({
    super.key,
    this.message = 'সংরক্ষিত তথ্য দেখানো হচ্ছে',
  });
  
  @override
  Widget build(BuildContext context) {
    if (NetworkService().isOnline) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

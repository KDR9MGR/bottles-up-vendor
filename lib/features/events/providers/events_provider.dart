import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/firebase_service.dart';
 
final eventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  return await firebaseService.getAllEvents();
}); 
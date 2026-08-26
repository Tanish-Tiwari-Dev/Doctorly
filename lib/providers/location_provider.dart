import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

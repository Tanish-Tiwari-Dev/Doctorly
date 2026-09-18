/// Normalized doctor record ready for insertion into Supabase public.doctors.
class ParsedDoctorRecord {
  ParsedDoctorRecord({
    required this.externalId,
    required this.fullName,
    this.qualification,
    this.specialty = 'Neurosurgery',
    this.subSpecialty,
    this.yearsOfExperience = 0,
    this.designation,
    this.hospitalName,
    this.practiceType,
    this.country,
    this.state,
    this.district,
    this.city,
    this.pinCode,
    this.mobile,
    this.whatsapp,
    this.hospitalPhone,
    this.emergencyContact,
    this.email,
    this.websiteUrl,
    this.languages = const [],
    this.teleconsultation = 'unknown',
    this.emergency24x7 = 'unknown',
    this.opdDays = const [],
    this.opdOpen,
    this.opdClose,
    this.opdByAppointment = false,
    this.councilName,
    this.registrationNo,
    this.registrationState,
    this.registrationStatus,
    this.registrationVerifiedOn,
    this.sourceType,
    this.primarySourceUrl,
    this.secondarySourceUrl,
    this.remarks,
    this.verifiedBy,
    this.lastVerifiedAt,
    this.latitude,
    this.longitude,
    this.verificationStatus = 'partially_verified',
    this.dataStatus = 'test',
    this.servicesMap = const {},
  });

  final String externalId;
  final String fullName;
  final String? qualification;
  final String specialty;
  final String? subSpecialty;
  final int yearsOfExperience;
  final String? designation;
  final String? hospitalName;
  final String? practiceType;
  final String? country;
  final String? state;
  final String? district;
  final String? city;
  final String? pinCode;
  final String? mobile;
  final String? whatsapp;
  final String? hospitalPhone;
  final String? emergencyContact;
  final String? email;
  final String? websiteUrl;
  final List<String> languages;
  final String teleconsultation;
  final String emergency24x7;
  final List<String> opdDays;
  final String? opdOpen;
  final String? opdClose;
  final bool opdByAppointment;
  final String? councilName;
  final String? registrationNo;
  final String? registrationState;
  final String? registrationStatus;
  final String? registrationVerifiedOn;
  final String? sourceType;
  final String? primarySourceUrl;
  final String? secondarySourceUrl;
  final String? remarks;
  final String? verifiedBy;
  final String? lastVerifiedAt;
  final double? latitude;
  final double? longitude;
  final String verificationStatus;
  final String dataStatus;
  final Map<String, String> servicesMap;

  Map<String, dynamic> toSupabaseMap() {
    return {
      'external_id': externalId,
      'full_name': fullName,
      'name': fullName,
      'qualification': qualification,
      'primary_specialty': specialty,
      'specialty': specialty,
      'sub_specialty': subSpecialty,
      'years_experience': yearsOfExperience,
      'years_of_experience': yearsOfExperience,
      'designation': designation,
      'hospital_name': hospitalName,
      'practice_type': practiceType,
      'country': country,
      'state': state,
      'district': district,
      'city': city,
      'pin_code': pinCode,
      'mobile': mobile,
      'phone': mobile ?? hospitalPhone,
      'whatsapp': whatsapp,
      'hospital_phone': hospitalPhone,
      'emergency_contact': emergencyContact,
      'email': email,
      'website_url': websiteUrl,
      'languages': languages,
      'teleconsultation': teleconsultation,
      'emergency_24x7': emergency24x7,
      'opd_days': opdDays,
      'opd_open': opdOpen,
      'opd_close': opdClose,
      'opening_time': opdOpen ?? '09:00',
      'closing_time': opdClose ?? '17:00',
      'opd_by_appointment': opdByAppointment,
      'council_name': councilName,
      'registration_no': registrationNo,
      'registration_state': registrationState,
      'registration_status': registrationStatus,
      'registration_verified_on': registrationVerifiedOn,
      'source_type': sourceType,
      'primary_source_url': primarySourceUrl,
      'secondary_source_url': secondarySourceUrl,
      'remarks': remarks,
      'verified_by': verifiedBy,
      'last_verified_at': lastVerifiedAt,
      'lat': latitude,
      'lng': longitude,
      'verification_status': verificationStatus,
      'data_status': dataStatus,
    };
  }
}

/// Normalizers and parsers for TSV row fields.
class DoctorParser {
  /// Normalizes phone numbers: converts Indian formats to E.164 (+91XXXXXXXXXX)
  /// and preserves 10-digit test placeholders (like 0000000001) as '+910000000001'
  /// without throwing exceptions.
  static String? normalizePhone(String? input) {
    if (input == null) return null;
    final clean = input.replaceAll(RegExp(r'[\s\-\(\)]'), '').trim();
    if (clean.isEmpty) return null;

    final regex = RegExp(r'^(\+91|0)?([6-9]\d{9})$');
    final match = regex.firstMatch(clean);
    if (match != null) {
      final digits = match.group(2)!;
      return '+91$digits';
    }

    // Support placeholder test numbers (e.g. 0000000001) gracefully without crashing
    if (RegExp(r'^\d{10}$').hasMatch(clean)) {
      return '+91$clean';
    }

    return null;
  }

  /// Splits comma-separated languages, trims each token, and filters empty strings.
  static List<String> parseLanguages(String? input) {
    if (input == null || input.trim().isEmpty) return [];
    return input
        .split(RegExp(r'[,;/]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Parses OPD days string (e.g. 'Mon-Sat', 'Mon/Wed/Fri', 'Tue/Thu/Sat', 'Daily').
  static List<String> parseOpdDays(String? input) {
    if (input == null || input.trim().isEmpty) return [];
    final clean = input.trim().toLowerCase();

    if (clean.contains('daily') || clean.contains('all days') || clean.contains('all day')) {
      return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    }
    if (clean.contains('mon-sat') || clean.contains('mon to sat')) {
      return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    }
    if (clean.contains('mon-fri') || clean.contains('mon to fri')) {
      return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    }
    if (clean.contains('mon/wed/fri') || clean.contains('mon, wed, fri')) {
      return ['Monday', 'Wednesday', 'Friday'];
    }
    if (clean.contains('tue/thu/sat') || clean.contains('tue, thu, sat')) {
      return ['Tuesday', 'Thursday', 'Saturday'];
    }

    return input
        .split(RegExp(r'[,/|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Parses OPD timing string (e.g. '10:00 AM-1:00 PM' -> {'open': '10:00', 'close': '13:00'}).
  static ({String? open, String? close, bool byAppointment}) parseOpdTiming(String? input) {
    if (input == null || input.trim().isEmpty) {
      return (open: null, close: null, byAppointment: false);
    }

    final lower = input.trim().toLowerCase();
    final isAppointment = lower.contains('by appointment') ||
        lower.contains('appointment only') ||
        lower.contains('prior appointment');

    if (isAppointment) {
      return (open: null, close: null, byAppointment: true);
    }

    final parts = input.split(RegExp(r'[-–to]')).map((s) => s.trim()).toList();
    if (parts.length >= 2) {
      final openStr = _standardizeTime(parts[0]);
      final closeStr = _standardizeTime(parts[1]);
      return (open: openStr, close: closeStr, byAppointment: false);
    }

    return (open: null, close: null, byAppointment: false);
  }

  static String? _standardizeTime(String input) {
    final clean = input.trim();
    final timeRegex = RegExp(r'^(\d{1,2}):?(\d{2})?\s*(am|pm)?$', caseSensitive: false);
    final match = timeRegex.firstMatch(clean);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final meridian = match.group(3)?.toLowerCase();

      if (meridian == 'pm' && hour < 12) hour += 12;
      if (meridian == 'am' && hour == 12) hour = 0;

      final hStr = hour.toString().padLeft(2, '0');
      final mStr = minute.toString().padLeft(2, '0');
      return '$hStr:$mStr';
    }
    return null;
  }

  /// Validates lat 20–25 and lon 68–75, returning null if out of range.
  static ({double? lat, double? lon}) validateCoordinates(String? latStr, String? lonStr) {
    if (latStr == null || lonStr == null) return (lat: null, lon: null);
    final lat = double.tryParse(latStr.trim());
    final lon = double.tryParse(lonStr.trim());

    if (lat != null && lon != null && lat >= 20.0 && lat <= 25.0 && lon >= 68.0 && lon <= 75.0) {
      return (lat: lat, lon: lon);
    }
    return (lat: null, lon: null);
  }

  /// Maps Yes/No/Unknown flags.
  static String mapFlag(String? input) {
    if (input == null) return 'unknown';
    final clean = input.trim().toLowerCase();
    if (clean == 'yes' || clean == 'y' || clean == 'true' || clean == '1') return 'yes';
    if (clean == 'no' || clean == 'n' || clean == 'false' || clean == '0') return 'no';
    return 'unknown';
  }

  static String _normalizeKey(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Parses TSV content into a list of parsed doctor records, tolerating both 52-column
  /// human-readable headers and legacy underscore headers.
  static List<ParsedDoctorRecord> parseTsv(String tsvContent, {String defaultDataStatus = 'test'}) {
    final lines = tsvContent.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return [];

    final headerLine = lines.first;
    final headers = headerLine.split('\t').map((h) => h.trim()).toList();
    final normHeaders = headers.map(_normalizeKey).toList();

    int colIndex(List<String> variants) {
      for (final v in variants) {
        final nv = _normalizeKey(v);
        final idx = normHeaders.indexOf(nv);
        if (idx != -1) return idx;
      }
      return -1;
    }

    final extIdIdx = colIndex(['Doctor ID', 'external_id', 'id']);
    final nameIdx = colIndex(['Full Name', 'full_name', 'name']);

    if (extIdIdx == -1 || nameIdx == -1) {
      throw FormatException('TSV missing mandatory header: Doctor ID / external_id or Full Name / full_name');
    }

    final records = <ParsedDoctorRecord>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final cols = line.split('\t');

      // Tolerate a truncated final line: if external_id and name cannot be read, skip gracefully
      if (cols.length <= extIdIdx || cols.length <= nameIdx) {
        continue;
      }

      String? getVal(List<String> variants) {
        final idx = colIndex(variants);
        if (idx != -1 && idx < cols.length) {
          final v = cols[idx].trim();
          return v.isEmpty ? null : v;
        }
        return null;
      }

      final extId = getVal(['Doctor ID', 'external_id', 'id']);
      final name = getVal(['Full Name', 'full_name', 'name']);

      if (extId == null || extId.isEmpty || name == null || name.isEmpty) {
        continue;
      }

      final mobile = normalizePhone(getVal(['Mobile No.', 'mobile', 'phone_number', 'phone']));
      final whatsapp = normalizePhone(getVal(['WhatsApp No.', 'whatsapp']));
      final hospitalPhone = getVal(['Hospital Phone', 'hospital_phone']);
      final emergencyContact = normalizePhone(getVal(['Emergency / Referral Contact', 'emergency_contact']));

      final languages = parseLanguages(getVal(['Languages', 'languages']));
      final opdDays = parseOpdDays(getVal(['OPD Days', 'opd_days']));
      final timing = parseOpdTiming(getVal(['OPD Timing', 'opd_time', 'opd_timing', 'timing']));
      final appointmentVal = getVal(['OPD Available', 'opd_by_appointment']);
      final bool byAppointment = timing.byAppointment ||
          (appointmentVal != null && (appointmentVal.toLowerCase() == 'no' || appointmentVal.toLowerCase() == 'yes' || appointmentVal.toLowerCase() == 'true'));

      final coords = validateCoordinates(
        getVal(['Latitude', 'latitude', 'lat']),
        getVal(['Longitude', 'longitude', 'lng', 'lon']),
      );

      final teleconsultation = mapFlag(getVal(['Teleconsultation', 'teleconsultation']));
      final emergency24x7 = mapFlag(getVal(['24x7 Emergency Neurosurgery', 'emergency_24x7', 'emergency_contact']));

      final yearsExp = int.tryParse(getVal(['Years of Experience', 'years_experience', 'years_of_experience']) ?? '') ?? 0;

      // Service statuses map
      final serviceMap = <String, String>{};
      final knownServices = {
        'trauma': ['Trauma', 'service_trauma', 'trauma'],
        'brain_tumor': ['Brain Tumor', 'service_brain_tumor', 'brain_tumor'],
        'spine': ['Spine', 'service_spine', 'spine'],
        'stroke': ['Stroke', 'service_stroke', 'stroke'],
        'neurovascular': ['Neurovascular', 'service_neurovascular', 'neurovascular'],
        'pediatric': ['Pediatric Neurosurgery', 'service_pediatric', 'pediatric'],
        'functional': ['Functional Neurosurgery', 'service_functional', 'functional'],
        'epilepsy': ['Epilepsy Surgery', 'service_epilepsy', 'epilepsy'],
        'skull_base': ['Skull Base', 'service_skull_base', 'skull_base'],
        'endovascular': ['Endovascular / Neurointervention', 'service_endovascular', 'endovascular'],
        'minimally_invasive_spine': ['Minimally Invasive Spine', 'service_minimally_invasive_spine', 'minimally_invasive_spine'],
      };

      for (final entry in knownServices.entries) {
        final rawVal = getVal(entry.value);
        if (rawVal != null) {
          serviceMap[entry.key] = mapFlag(rawVal);
        }
      }

      final rawVer = getVal(['Profile Verified', 'verification_status']) ?? 'partially_verified';
      final verificationStatus = rawVer.toLowerCase().replaceAll(' ', '_');

      final record = ParsedDoctorRecord(
        externalId: extId,
        fullName: name,
        qualification: getVal(['Qualification', 'qualification']),
        specialty: getVal(['Primary Specialty', 'primary_specialty', 'specialty']) ?? 'Neurosurgery',
        subSpecialty: getVal(['Sub-specialty / Fellowship', 'sub_specialty']),
        yearsOfExperience: yearsExp,
        designation: getVal(['Current Designation', 'designation']),
        hospitalName: getVal(['Hospital / Institute', 'hospital_name']),
        practiceType: getVal(['Practice Type', 'practice_type']),
        country: getVal(['Country', 'country']) ?? 'India',
        state: getVal(['State', 'state']) ?? 'Gujarat',
        district: getVal(['District', 'district']),
        city: getVal(['City / Town', 'city']),
        pinCode: getVal(['PIN Code', 'pin_code']),
        mobile: mobile,
        whatsapp: whatsapp,
        hospitalPhone: hospitalPhone,
        emergencyContact: emergencyContact,
        email: getVal(['Email', 'email']),
        websiteUrl: getVal(['Website / Profile URL', 'website_url']),
        languages: languages,
        teleconsultation: teleconsultation,
        emergency24x7: emergency24x7,
        opdDays: opdDays,
        opdOpen: timing.open,
        opdClose: timing.close,
        opdByAppointment: byAppointment,
        councilName: getVal(['Medical Council', 'council_name']),
        registrationNo: getVal(['Registration No.', 'registration_no']),
        registrationState: getVal(['Registration State', 'registration_state']),
        registrationStatus: getVal(['Registration Status', 'registration_status']),
        registrationVerifiedOn: getVal(['Registration Verified On', 'registration_verified_on']),
        sourceType: getVal(['Source Type', 'source_type']),
        primarySourceUrl: getVal(['Primary Source URL', 'primary_source_url']),
        secondarySourceUrl: getVal(['Secondary Source URL', 'secondary_source_url']),
        remarks: getVal(['Remarks', 'remarks']),
        verifiedBy: getVal(['Verified By', 'verified_by']),
        lastVerifiedAt: getVal(['Last Verified Date', 'last_verified_at']),
        latitude: coords.lat,
        longitude: coords.lon,
        verificationStatus: verificationStatus,
        dataStatus: defaultDataStatus,
        servicesMap: serviceMap,
      );

      records.add(record);
    }

    return records;
  }
}

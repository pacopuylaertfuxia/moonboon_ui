/// Mock state for the V2 Settings flow prototype.
/// Plain mutable singleton — pages mutate it and setState locally.
library;

class Caregiver {
  String firstName;
  String lastName;
  String role; // Mother · Father · Guardian
  String country;
  String email;
  bool owner;
  bool hasPhoto;
  final String memberSince;

  Caregiver({
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.country,
    required this.email,
    this.owner = false,
    this.hasPhoto = false,
    required this.memberSince,
  });

  String get name => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
}

class Baby {
  String name;
  DateTime birthdate;
  bool hasPhoto;

  Baby({required this.name, required this.birthdate, this.hasPhoto = true});

  /// "3 weeks" under a month · "7 months" · "1 year 2 months" past a year.
  String get age {
    final now = DateTime.now();
    int months = (now.year - birthdate.year) * 12 + now.month - birthdate.month;
    if (now.day < birthdate.day) months -= 1;
    if (months < 1) {
      final weeks = now.difference(birthdate).inDays ~/ 7;
      return weeks <= 1 ? '1 week' : '$weeks weeks';
    }
    if (months < 12) return months == 1 ? '1 month' : '$months months';
    final years = months ~/ 12;
    final rest = months % 12;
    final y = years == 1 ? '1 year' : '$years years';
    if (rest == 0) return y;
    return '$y ${rest == 1 ? '1 month' : '$rest months'}';
  }
}

enum FamilyScenario { full, solo, empty }

/// Who is holding the phone in the demo.
enum Viewer { owner, member }

class FlowState {
  FlowState._();
  static final FlowState i = FlowState._();

  FamilyScenario scenario = FamilyScenario.full;
  Viewer viewer = Viewer.owner;

  Baby? baby = Baby(
    name: 'Vera',
    birthdate: DateTime.now().subtract(const Duration(days: 213)),
  );

  final Caregiver paco = Caregiver(
    firstName: 'Paco',
    lastName: 'Puylaert',
    role: 'Father',
    country: 'Denmark',
    email: 'paco@puylaert.dk',
    owner: true,
    memberSince: 'January 2026',
  );

  final Caregiver sofie = Caregiver(
    firstName: 'Sofie',
    lastName: 'Puylaert',
    role: 'Mother',
    country: 'Denmark',
    email: 'sofie@puylaert.dk',
    memberSince: 'February 2026',
  );

  /// The person using the app right now.
  Caregiver get me => viewer == Viewer.owner ? paco : sofie;

  List<Caregiver> get members => switch (scenario) {
        FamilyScenario.full => [paco, sofie],
        FamilyScenario.solo => [paco],
        FamilyScenario.empty => [],
      };

  bool get hasFamily => scenario != FamilyScenario.empty && baby != null;
  bool get iAmOwner => me.owner;

  void removeMember(Caregiver m) {
    if (identical(m, sofie)) scenario = FamilyScenario.solo;
  }

  void createFamily(String name, DateTime birthdate, bool hasPhoto) {
    baby = Baby(name: name, birthdate: birthdate, hasPhoto: hasPhoto);
    scenario = FamilyScenario.solo;
    viewer = Viewer.owner;
  }
}

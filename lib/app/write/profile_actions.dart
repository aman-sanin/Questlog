import '../../data/db/database.dart';
import '../../domain/model/models.dart';

class ProfileActions {
  final AppDatabase db;

  ProfileActions(this.db);

  Future<void> setName(String name) async {
    await db.profileDao.updateName(name);
  }

  Future<void> chooseCalling(CallingDomain domain, DateTime now) async {
    await db.transaction(() async {
      await db.profileDao.updateCalling(domain.index, now);
      await db.ledgerDao.markMomentSeen('calling', now);
    });
  }

  Future<void> respecCalling(CallingDomain domain, DateTime now) async {
    await db.profileDao.updateCalling(domain.index, now);
  }

  Future<void> setThemeMode(int mode) async {
    await db.profileDao.updateThemeMode(mode);
  }

  Future<void> setAccent(String accent) async {
    await db.profileDao.updateAccent(accent);
  }

  Future<void> setCadenceSettings({required int resetMinute, required int weekStart}) async {
    await db.profileDao.updateCadenceSettings(resetMinute, weekStart);
  }

  Future<void> setNotifications({required bool enabled, required int minute}) async {
    await db.profileDao.updateNotifications(enabled, minute);
  }
}

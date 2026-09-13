import 'package:timezone/data/latest.dart' as tzdata;

bool _loaded = false;

/// Loads the bundled IANA tzdb once per process. Must run before any
/// `tz.getLocation(...)` call (used by [TzResolver], the materializer, and
/// timezone pickers).
void ensureTimeZoneDatabaseLoaded() {
  if (_loaded) return;
  tzdata.initializeTimeZones();
  _loaded = true;
}

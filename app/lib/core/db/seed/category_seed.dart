import '../../ids/deterministic_id.dart';

/// A system ActivityCategory seed (schema 6). Six seeds are created per user with
/// `is_system = true` and a deterministic UUIDv5 id derived from the user id and
/// the [slug].
class SeedCategory {
  const SeedCategory({
    required this.slug,
    required this.nama,
    required this.warna,
    required this.icon,
  });

  /// Stable ASCII slug used in the UUIDv5 canonical name
  /// (`urn:dailys:v1.0:activity-category:{user_id}:{slug}`). This is the wire
  /// contract for the id; changing a slug changes the id, so it must stay
  /// identical across the Dart and Node.js implementations.
  final String slug;
  final String nama;
  final String warna; // Hex #RRGGBB
  final String icon;

  /// Deterministic seed id for [userId].
  String idFor(String userId) => DeterministicId.seedActivityCategory(userId, slug);
}

/// The six system categories (schema 6): Kuliah, Tugas, Personal, Istirahat,
/// Sosial, Olahraga. Order is display order.
const List<SeedCategory> kSeedActivityCategories = [
  SeedCategory(slug: 'kuliah', nama: 'Kuliah', warna: '#4C6FFF', icon: 'school'),
  SeedCategory(slug: 'tugas', nama: 'Tugas', warna: '#F59E0B', icon: 'assignment'),
  SeedCategory(slug: 'personal', nama: 'Personal', warna: '#10B981', icon: 'person'),
  SeedCategory(slug: 'istirahat', nama: 'Istirahat', warna: '#8B5CF6', icon: 'bedtime'),
  SeedCategory(slug: 'sosial', nama: 'Sosial', warna: '#EC4899', icon: 'groups'),
  SeedCategory(slug: 'olahraga', nama: 'Olahraga', warna: '#EF4444', icon: 'fitness_center'),
];

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuselage_kpp/data/mission/mission_item.dart';
import 'package:fuselage_kpp/data/repositories/connection_repository.dart';

class MissionController extends Notifier<List<MissionItem>> {
  @override
  List<MissionItem> build() {
    ref.listen(fcSessionProvider, (prev, next) {
      if (next == null) {
        state = const [];
      } else {
        state = List.of(next.missions.items);
      }
    });
    return ref.read(fcSessionProvider)?.missions.items ?? const [];
  }

  void replace(List<MissionItem> items) {
    final session = ref.read(fcSessionProvider);
    final ordered = [for (var i = 0; i < items.length; i++) items[i].copyWith(seq: i)];
    session?.missions.setLocalItems(ordered);
    state = ordered;
  }

  void add(MissionItem item) => replace([...state, item]);

  void updateAt(int index, MissionItem item) {
    final next = [...state];
    next[index] = item;
    replace(next);
  }

  void removeAt(int index) {
    final next = [...state]..removeAt(index);
    replace(next);
  }

  Future<void> download() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    state = await session.missions.download();
  }

  Future<void> upload() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    await session.missions.upload(state);
    state = List.of(session.missions.items);
  }

  Future<void> clearRemote() async {
    final session = ref.read(fcSessionProvider);
    if (session == null) {
      return;
    }
    await session.missions.clear();
    state = const [];
  }
}

final missionProvider = NotifierProvider<MissionController, List<MissionItem>>(MissionController.new);

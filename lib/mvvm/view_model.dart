import 'view_state_observer.dart';

abstract class EventViewModel {
  final List<ViewStateObserver> _observerList = List.empty(growable: true);

  void subscribe(ViewStateObserver o) {
    if (_observerList.contains(o)) return;

    _observerList.add(o);
  }

  bool unsubscribe(ViewStateObserver o) {
    if (_observerList.contains(o)) {
      _observerList.remove(o);
      return true;
    } else {
      return false;
    }
  }

  void notify(ViewState event) {
    for (var element in _observerList) {
      element.notify(event);
    }
  }
}
import 'package:async/async.dart';

import '../../logging/helper.dart';

enum _PageLoadPhase { idle, loading, loaded }

final class PageLoadRuntime {
  CancelableCompleter<void>? _loadSession;
  int? _currentLoadSessionId;
  int _nextLoadSessionId = 0;

  CancelableCompleter<void>? get _retainedLoadSession {
    final loadSession = _loadSession;
    return (loadSession != null && !loadSession.isCanceled)
        ? loadSession
        : null;
  }

  _PageLoadPhase get _phase {
    final loadSession = _retainedLoadSession;
    if (loadSession == null) return _PageLoadPhase.idle;
    return loadSession.isCompleted
        ? _PageLoadPhase.loaded
        : _PageLoadPhase.loading;
  }

  void cancel({required String logName}) {
    final loadSession = _loadSession;
    if (loadSession == null) return;
    final loadSessionId = _currentLoadSessionId;

    void onCancelled() {
      if (_loadSession == loadSession) {
        _loadSession = null;
        _currentLoadSessionId = null;
      }
      appLog.load.info(logName, ex: ['cancelled', loadSession.hashCode]);
    }

    appLog.load.info(logName, ex: [loadSessionId, loadSession.hashCode]);
    if (loadSession.isCompleted || loadSession.isCanceled) {
      onCancelled();
    } else {
      loadSession.operation.cancel();
      onCancelled();
    }
  }

  bool get hasLoad => _phase != _PageLoadPhase.idle;

  bool get hasLoaded => _phase == _PageLoadPhase.loaded;

  int? get currentLoadId => _currentLoadSessionId;

  Future<void> run({
    required String logName,
    required List<Object?> alreadyLoadingEx,
    required Future<void> Function(CancelableCompleter<void> loading) loadData,
    required void Function(
      CancelableCompleter<void> loading,
      Object error,
      StackTrace stackTrace,
    )
    onError,
  }) async {
    final currentLoadSession = _retainedLoadSession;
    if (currentLoadSession != null) {
      appLog.load.warn(
        logName,
        ex: [...alreadyLoadingEx, currentLoadSession.isCompleted],
      );
      return currentLoadSession.operation.valueOrCancellation();
    }

    final loadSession = _loadSession = CancelableCompleter<void>();
    _currentLoadSessionId = ++_nextLoadSessionId;
    loadData(
      loadSession,
    ).catchError((e, s) => onError(loadSession, e, s)).whenComplete(() {
      if (!loadSession.isCompleted && !loadSession.isCanceled) {
        loadSession.complete();
      }
    });

    return loadSession.operation.valueOrCancellation();
  }
}

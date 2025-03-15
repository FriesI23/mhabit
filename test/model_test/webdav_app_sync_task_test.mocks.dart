// Mocks generated by Mockito 5.4.4 from annotations
// in mhabit/test/model_test/webdav_app_sync_task_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:convert' as _i2;

import 'package:mhabit/model/_app_sync_tasks/app_sync_task.dart' as _i7;
import 'package:mhabit/model/_app_sync_tasks/webdav_app_sync_task.dart' as _i5;
import 'package:mhabit/model/app_sync_server.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeConverter_0<S1, T1> extends _i1.SmartFake
    implements _i2.Converter<S1, T1> {
  _FakeConverter_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSink_1<T1> extends _i1.SmartFake implements Sink<T1> {
  _FakeSink_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDateTime_2 extends _i1.SmartFake implements DateTime {
  _FakeDateTime_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_3 extends _i1.SmartFake implements Uri {
  _FakeUri_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppSyncServerForm_4 extends _i1.SmartFake
    implements _i3.AppSyncServerForm {
  _FakeAppSyncServerForm_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppSyncServer_5 extends _i1.SmartFake implements _i3.AppSyncServer {
  _FakeAppSyncServer_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_6<T1> extends _i1.SmartFake implements _i4.Future<T1> {
  _FakeFuture_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebDavAppSyncTaskResult_7 extends _i1.SmartFake
    implements _i5.WebDavAppSyncTaskResult {
  _FakeWebDavAppSyncTaskResult_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Converter].
///
/// See the documentation for Mockito's code generation for more information.
class MockConverter<S, T> extends _i1.Mock implements _i2.Converter<S, T> {
  MockConverter() {
    _i1.throwOnMissingStub(this);
  }

  @override
  T convert(S? input) => (super.noSuchMethod(
        Invocation.method(
          #convert,
          [input],
        ),
        returnValue: _i6.dummyValue<T>(
          this,
          Invocation.method(
            #convert,
            [input],
          ),
        ),
      ) as T);

  @override
  _i2.Converter<S, TT> fuse<TT>(_i2.Converter<T, TT>? other) =>
      (super.noSuchMethod(
        Invocation.method(
          #fuse,
          [other],
        ),
        returnValue: _FakeConverter_0<S, TT>(
          this,
          Invocation.method(
            #fuse,
            [other],
          ),
        ),
      ) as _i2.Converter<S, TT>);

  @override
  Sink<S> startChunkedConversion(Sink<T>? sink) => (super.noSuchMethod(
        Invocation.method(
          #startChunkedConversion,
          [sink],
        ),
        returnValue: _FakeSink_1<S>(
          this,
          Invocation.method(
            #startChunkedConversion,
            [sink],
          ),
        ),
      ) as Sink<S>);

  @override
  _i4.Stream<T> bind(_i4.Stream<S>? stream) => (super.noSuchMethod(
        Invocation.method(
          #bind,
          [stream],
        ),
        returnValue: _i4.Stream<T>.empty(),
      ) as _i4.Stream<T>);

  @override
  _i2.Converter<RS, RT> cast<RS, RT>() => (super.noSuchMethod(
        Invocation.method(
          #cast,
          [],
        ),
        returnValue: _FakeConverter_0<RS, RT>(
          this,
          Invocation.method(
            #cast,
            [],
          ),
        ),
      ) as _i2.Converter<RS, RT>);
}

/// A class which mocks [AppWebDavSyncServer].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppWebDavSyncServer extends _i1.Mock
    implements _i3.AppWebDavSyncServer {
  MockAppWebDavSyncServer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get identity => (super.noSuchMethod(
        Invocation.getter(#identity),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#identity),
        ),
      ) as String);

  @override
  DateTime get createTime => (super.noSuchMethod(
        Invocation.getter(#createTime),
        returnValue: _FakeDateTime_2(
          this,
          Invocation.getter(#createTime),
        ),
      ) as DateTime);

  @override
  DateTime get modifyTime => (super.noSuchMethod(
        Invocation.getter(#modifyTime),
        returnValue: _FakeDateTime_2(
          this,
          Invocation.getter(#modifyTime),
        ),
      ) as DateTime);

  @override
  _i3.AppSyncServerType get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: _i3.AppSyncServerType.unknown,
      ) as _i3.AppSyncServerType);

  @override
  bool get verified => (super.noSuchMethod(
        Invocation.getter(#verified),
        returnValue: false,
      ) as bool);

  @override
  bool get configed => (super.noSuchMethod(
        Invocation.getter(#configed),
        returnValue: false,
      ) as bool);

  @override
  String get password => (super.noSuchMethod(
        Invocation.getter(#password),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#password),
        ),
      ) as String);

  @override
  Uri get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _FakeUri_3(
          this,
          Invocation.getter(#path),
        ),
      ) as Uri);

  @override
  String get username => (super.noSuchMethod(
        Invocation.getter(#username),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#username),
        ),
      ) as String);

  @override
  bool get ignoreSSL => (super.noSuchMethod(
        Invocation.getter(#ignoreSSL),
        returnValue: false,
      ) as bool);

  @override
  bool get syncInLowData => (super.noSuchMethod(
        Invocation.getter(#syncInLowData),
        returnValue: false,
      ) as bool);

  @override
  Iterable<_i3.AppSyncServerMobileNetwork> get syncMobileNetworks =>
      (super.noSuchMethod(
        Invocation.getter(#syncMobileNetworks),
        returnValue: <_i3.AppSyncServerMobileNetwork>[],
      ) as Iterable<_i3.AppSyncServerMobileNetwork>);

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#name),
        ),
      ) as String);

  @override
  bool isSameConfig(
    _i3.AppSyncServer? other, {
    bool? withoutPassword = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #isSameConfig,
          [other],
          {#withoutPassword: withoutPassword},
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isSameServer(
    _i3.AppSyncServer? other, {
    bool? withoutPassword = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #isSameServer,
          [other],
          {#withoutPassword: withoutPassword},
        ),
        returnValue: false,
      ) as bool);

  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  _i3.AppSyncServerForm toForm() => (super.noSuchMethod(
        Invocation.method(
          #toForm,
          [],
        ),
        returnValue: _FakeAppSyncServerForm_4(
          this,
          Invocation.method(
            #toForm,
            [],
          ),
        ),
      ) as _i3.AppSyncServerForm);

  @override
  String toDebugString() => (super.noSuchMethod(
        Invocation.method(
          #toDebugString,
          [],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #toDebugString,
            [],
          ),
        ),
      ) as String);
}

/// A class which mocks [AppSyncServer].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSyncServer extends _i1.Mock implements _i3.AppSyncServer {
  MockAppSyncServer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#name),
        ),
      ) as String);

  @override
  String get identity => (super.noSuchMethod(
        Invocation.getter(#identity),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#identity),
        ),
      ) as String);

  @override
  DateTime get createTime => (super.noSuchMethod(
        Invocation.getter(#createTime),
        returnValue: _FakeDateTime_2(
          this,
          Invocation.getter(#createTime),
        ),
      ) as DateTime);

  @override
  DateTime get modifyTime => (super.noSuchMethod(
        Invocation.getter(#modifyTime),
        returnValue: _FakeDateTime_2(
          this,
          Invocation.getter(#modifyTime),
        ),
      ) as DateTime);

  @override
  _i3.AppSyncServerType get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: _i3.AppSyncServerType.unknown,
      ) as _i3.AppSyncServerType);

  @override
  bool get verified => (super.noSuchMethod(
        Invocation.getter(#verified),
        returnValue: false,
      ) as bool);

  @override
  bool get configed => (super.noSuchMethod(
        Invocation.getter(#configed),
        returnValue: false,
      ) as bool);

  @override
  bool isSameConfig(
    _i3.AppSyncServer? other, {
    bool? withoutPassword = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #isSameConfig,
          [other],
          {#withoutPassword: withoutPassword},
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isSameServer(
    _i3.AppSyncServer? other, {
    bool? withoutPassword = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #isSameServer,
          [other],
          {#withoutPassword: withoutPassword},
        ),
        returnValue: false,
      ) as bool);

  @override
  _i3.AppSyncServerForm toForm() => (super.noSuchMethod(
        Invocation.method(
          #toForm,
          [],
        ),
        returnValue: _FakeAppSyncServerForm_4(
          this,
          Invocation.method(
            #toForm,
            [],
          ),
        ),
      ) as _i3.AppSyncServerForm);

  @override
  String toDebugString() => (super.noSuchMethod(
        Invocation.method(
          #toDebugString,
          [],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #toDebugString,
            [],
          ),
        ),
      ) as String);

  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}

/// A class which mocks [AppSyncContext].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSyncContext extends _i1.Mock implements _i7.AppSyncContext {
  MockAppSyncContext() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get sessionId => (super.noSuchMethod(
        Invocation.getter(#sessionId),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#sessionId),
        ),
      ) as String);

  @override
  _i3.AppSyncServer get config => (super.noSuchMethod(
        Invocation.getter(#config),
        returnValue: _FakeAppSyncServer_5(
          this,
          Invocation.getter(#config),
        ),
      ) as _i3.AppSyncServer);

  @override
  _i7.AppSyncTaskStatus get status => (super.noSuchMethod(
        Invocation.getter(#status),
        returnValue: _i7.AppSyncTaskStatus.idle,
      ) as _i7.AppSyncTaskStatus);

  @override
  bool get isProcessing => (super.noSuchMethod(
        Invocation.getter(#isProcessing),
        returnValue: false,
      ) as bool);

  @override
  bool get isCancalling => (super.noSuchMethod(
        Invocation.getter(#isCancalling),
        returnValue: false,
      ) as bool);

  @override
  bool get isDone => (super.noSuchMethod(
        Invocation.getter(#isDone),
        returnValue: false,
      ) as bool);
}

/// A class which mocks [AppSyncSubTask].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSyncSubTask<T> extends _i1.Mock implements _i7.AppSyncSubTask<T> {
  MockAppSyncSubTask() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<T> run(_i7.AppSyncContext? context) => (super.noSuchMethod(
        Invocation.method(
          #run,
          [context],
        ),
        returnValue: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #run,
                  [context],
                ),
              ),
              (T v) => _i4.Future<T>.value(v),
            ) ??
            _FakeFuture_6<T>(
              this,
              Invocation.method(
                #run,
                [context],
              ),
            ),
      ) as _i4.Future<T>);
}

/// A class which mocks [AppSyncSubTask].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSyncSubTaskWithResult extends _i1.Mock
    implements _i7.AppSyncSubTask<_i5.WebDavAppSyncTaskResult> {
  @override
  _i4.Future<_i5.WebDavAppSyncTaskResult> run(_i7.AppSyncContext? context) =>
      (super.noSuchMethod(
        Invocation.method(
          #run,
          [context],
        ),
        returnValue: _i4.Future<_i5.WebDavAppSyncTaskResult>.value(
            _FakeWebDavAppSyncTaskResult_7(
          this,
          Invocation.method(
            #run,
            [context],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i5.WebDavAppSyncTaskResult>.value(
                _FakeWebDavAppSyncTaskResult_7(
          this,
          Invocation.method(
            #run,
            [context],
          ),
        )),
      ) as _i4.Future<_i5.WebDavAppSyncTaskResult>);
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_setup/core/base/base_state.dart';
import 'package:flutter_setup/core/base/failure.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_setup/core/utils/dimens.dart';

part 'dialog/progress_dialog.dart';

part 'dialog/error_dialog.dart';

part 'dialog/success_dialog.dart';

class PageProvider<S extends BaseState> extends StateNotifier<S> {
  void Function(S state)? _listener;
  BuildContext? _context;

  bool _progressDialogInRun = false;

  PageProvider(super.state);

  void emit(BaseState newState) {
    state = newState as S;
    _invokeListener();
  }

  void _invokeListener() {
    _listener?.call(state);
  }

  void emitFailure(Failure failure, {VoidCallback? onOk}) {
    setProgressDialog(null);
    showDialog(
      barrierDismissible: false,
      context: _context!,
      builder: (context) => _ErroDialog(
        failure: failure,
        onOk: onOk,
      ),
    );
  }

  void setProgressDialog(String? message, {bool dismissible = false, BuildContext? context}) {
    if (message == null) {
      if ((context ?? _context) != null && _progressDialogInRun) {
        _progressDialogInRun = false;
        Navigator.pop(context ?? _context!);
      }
    } else {
      if (_context != null) {
        _progressDialogInRun = true;
        showDialog(
          barrierDismissible: dismissible,
          context: context ?? _context!,
          builder: (context) => _ProgressDialog(
            message,
            onDismiss: dismissible
                ? () {
                    _progressDialogInRun = false;
                  }
                : null,
          ),
        );
      }
    }
  }

  void showSuccessDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
  }) {
    showDialog(
      context: _context!,
      builder: (context) => _SuccessDialog(
        title: title,
        message: message,
        onOk: onOk,
      ),
    );
  }

  void showErrorDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
  }) {
    showDialog(
      context: _context!,
      builder: (context) => _ErroDialog(
        failure: Failure(message: ''),
        title: title,
        message: message,
        onOk: onOk,
      ),
    );
  }

  bool _onReadyCalled = false;

  void go(String routeName, {Object? extra}) {
    if (_context != null) {
      GoRouter.of(_context!).pushNamed(routeName, extra: extra);
    }
  }

  void replaceWith(String routeName, {Object? extra}) {
    if (_context != null) {
      GoRouter.of(_context!).pushReplacementNamed(routeName, extra: extra);
    }
  }

  void back() {
    if (_context != null) {
      GoRouter.of(_context!).pop();
    }
  }

  void clearAndGo() {}

  Future supressFailure(Future<void> Function() callback) async {
    try {
      return callback;
    } catch (e) {
      return null;
    }
  }
}

// ============================================== BasePage ======================================================

abstract class _BasePage<T extends PageProvider<S>, S extends BaseState> extends ConsumerStatefulWidget {
  const _BasePage({
    super.key,
    required this.builder,
    this.onReady,
    this.onDispose,
    this.initState,
    this.listener,
  });

  final ValueChanged<T>? onReady;
  final ValueChanged<T>? initState;
  final VoidCallback? onDispose;
  final Widget Function(BuildContext context, T provider, S state) builder;
  final void Function(BuildContext context, T provider, S state)? listener;
}

// ============================================== Normal BasePage ======================================================

class BasePage<T extends PageProvider<S>, S extends BaseState> extends _BasePage<T, S> {
  const BasePage({
    super.key,
    required this.provider,
    required super.builder,
    super.listener,
    super.onReady,
    super.initState,
    super.onDispose,
  });

  final StateNotifierProvider<T, S> provider;

  @override
  ConsumerState<BasePage<T, S>> createState() => _BasePageState();
}

class _BasePageState<T extends PageProvider<S>, S extends BaseState> extends ConsumerState<BasePage<T, S>> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _createPageModel();
    });
    super.initState();
  }

  void _createPageModel() {
    final pageProvider = ref.read(widget.provider.notifier);
    pageProvider._listener = (state) => widget.listener?.call(context, pageProvider, state);
    pageProvider._context = context;

    if (widget.initState != null) {
      if (pageProvider._onReadyCalled) {
        widget.initState!(pageProvider);
      }
    }

    if (widget.onReady != null) {
      if (!pageProvider._onReadyCalled) {
        widget.onReady!(pageProvider);
        pageProvider._onReadyCalled = true;
      } else {
        widget.onReady!(pageProvider);
      }
    }
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageModel = ref.watch(widget.provider.notifier);
    final pageState = ref.watch(widget.provider);

    return widget.builder(context, pageModel, pageState);
  }
}

// ============================================== Disposable Base Page ======================================================

class DisposableBasePage<T extends PageProvider<S>, S extends BaseState> extends _BasePage<T, S> {
  const DisposableBasePage({
    super.key,
    required this.provider,
    required super.builder,
    super.listener,
    super.onReady,
    super.initState,
    super.onDispose,
  });

  final AutoDisposeStateNotifierProvider<T, S> provider;

  @override
  ConsumerState<DisposableBasePage<T, S>> createState() => _DisposableBasePageState();
}

class _DisposableBasePageState<T extends PageProvider<S>, S extends BaseState> extends ConsumerState<DisposableBasePage<T, S>> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _createPageModel();
    });
    super.initState();
  }

  void _createPageModel() {
    final pageProvider = ref.read(widget.provider.notifier);
    pageProvider._listener = (state) => widget.listener?.call(context, pageProvider, state);
    pageProvider._context = context;

    if (widget.initState != null) {
      if (pageProvider._onReadyCalled) {
        widget.initState!(pageProvider);
      }
    }

    if (widget.onReady != null) {
      if (!pageProvider._onReadyCalled) {
        widget.onReady!(pageProvider);
        pageProvider._onReadyCalled = true;
      } else {
        widget.onReady!(pageProvider);
      }
    }
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageModel = ref.watch(widget.provider.notifier);
    final pageState = ref.watch(widget.provider);

    return widget.builder(context, pageModel, pageState);
  }
}

// ============================================== Family Base Page ======================================================

class BasePageFamily<T extends PageProvider<S>, S extends BaseState, K> extends _BasePage<T, S> {
  const BasePageFamily({
    super.key,
    required this.provider,
    required this.argument,
    required super.builder,
    super.listener,
    super.onReady,
    super.initState,
    super.onDispose,
  });

  final StateNotifierProviderFamily<T, S, K> provider;
  final K argument;

  @override
  ConsumerState<BasePageFamily<T, S, K>> createState() => _BasePageFamily();
}

class _BasePageFamily<T extends PageProvider<S>, S extends BaseState, K> extends ConsumerState<BasePageFamily<T, S, K>> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _createPageModel();
    });
    super.initState();
  }

  void _createPageModel() {
    final pageProvider = ref.read(widget.provider(widget.argument).notifier);
    pageProvider._listener = (state) => widget.listener?.call(context, pageProvider, state);
    pageProvider._context = context;

    if (widget.initState != null) {
      if (pageProvider._onReadyCalled) {
        widget.initState!(pageProvider);
      }
    }

    if (widget.onReady != null) {
      if (!pageProvider._onReadyCalled) {
        widget.onReady!(pageProvider);
        pageProvider._onReadyCalled = true;
      } else {
        widget.onReady!(pageProvider);
      }
    }
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = ref.read(widget.provider(widget.argument).notifier);
    final pageState = ref.watch(widget.provider(widget.argument));

    return widget.builder(context, pageProvider, pageState);
  }
}

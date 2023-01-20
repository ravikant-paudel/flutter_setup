import 'package:equatable/equatable.dart';
import 'package:flutter_setup/core/base/failure.dart';

abstract class BaseState<S> extends Equatable {
  final bool isLoading;
  final Failure? failure;

  const BaseState(this.isLoading, this.failure);

  BaseState setLoading(bool loading);

  BaseState setFailure(Failure? failure);
}

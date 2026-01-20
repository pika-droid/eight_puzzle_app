import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'app_theme.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final AppTheme theme;

  const ChangeTheme(this.theme);

  @override
  List<Object> get props => [theme];
}

// State
class ThemeState extends Equatable {
  final AppTheme theme;

  const ThemeState({required this.theme});

  @override
  List<Object> get props => [theme];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(theme: AppTheme.cosmic)) {
    on<ChangeTheme>((event, emit) {
      emit(ThemeState(theme: event.theme));
    });
  }
}

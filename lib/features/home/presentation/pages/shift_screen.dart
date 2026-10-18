import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../working_hours/presentation/cubit/working_hours_cubit.dart';
import '../../../working_hours/presentation/pages/working_hours_screen.dart';

export '../../../working_hours/presentation/pages/working_hours_screen.dart';

/// Legacy forwarder to [WorkingHoursScreen] ensuring backward compatibility.
class WorkHoursScreen extends StatelessWidget {
  const WorkHoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<WorkingHoursCubit>();
      return const WorkingHoursScreen();
    } catch (_) {
      return BlocProvider<WorkingHoursCubit>(
        create: (context) => di.sl<WorkingHoursCubit>(),
        child: const WorkingHoursScreen(),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/app_icon_button.dart';
import '../bloc/todos_bloc.dart';
import '../bloc/todos_event.dart';
import '../bloc/todos_state.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodosBloc>(
      create: (context) => sl<TodosBloc>()..add(LoadTodosEvent()),
      child: const TodosScreenView(),
    );
  }
}

class TodosScreenView extends StatefulWidget {
  const TodosScreenView({super.key});

  @override
  State<TodosScreenView> createState() => _TodosScreenViewState();
}

class _TodosScreenViewState extends State<TodosScreenView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Text(
          'Tasks Checklist',
          style: AppTextStyles.titleMedium,
        ),
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: AppDimensions.fontTitleM,
          onPressed: () => context.go(AppRouter.dashboardPath),
        ),
      ),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<TodosBloc>().add(LoadTodosEvent());
          } else if (state is TodosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            if (state is TodosLoading || state is TodosInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is TodosLoaded) {
              final todos = state.todos;
              final completedCount = todos.where((t) => t.isCompleted).length;
              final totalCount = todos.length;
              final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

              return Column(
                children: [
                  // Offline & Sync Indicators Container
                  if (state.isOffline || state.pendingSyncCount > 0)
                    Container(
                      width: double.infinity,
                      color: state.isOffline ? const Color(0xFFFEF3C7) : AppColors.tealLight,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                        vertical: AppDimensions.paddingM,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.isOffline ? Icons.cloud_off : Icons.sync,
                            color: state.isOffline ? const Color(0xFFD97706) : AppColors.primary,
                            size: AppDimensions.iconM,
                          ),
                          SizedBox(width: AppDimensions.spaceM),
                          Expanded(
                            child: Text(
                              state.isOffline
                                  ? 'Offline Mode - Changes are cached locally'
                                  : '${state.pendingSyncCount} changes pending to sync',
                              style: AppTextStyles.label.copyWith(
                                color: state.isOffline ? const Color(0xFFB45309) : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Header metrics Card
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingXL),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 720.0 : double.infinity,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(AppDimensions.paddingXXL),
                          decoration: ShapeDecoration(
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                              side: const BorderSide(color: AppColors.border, width: 1),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0A19202D),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text(
                                    'Shift Progress',
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  Text(
                                    '$completedCount / $totalCount completed',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.spaceXXL),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                child: LinearProgressIndicator(
                                  value: completionRate,
                                  minHeight: AppDimensions.spaceM,
                                  backgroundColor: const Color(0xFFE6EAEF),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // List of checklist items
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 720.0 : double.infinity,
                        ),
                        child: todos.isEmpty
                            ? _buildEmptyState(context)
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
                                itemCount: todos.length,
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: AppDimensions.paddingM),
                                    decoration: ShapeDecoration(
                                      color: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                        side: const BorderSide(color: AppColors.border, width: 1),
                                      ),
                                      shadows: const [
                                        BoxShadow(
                                          color: Color(0x0519202D),
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppDimensions.paddingXL,
                                        vertical: AppDimensions.paddingS,
                                      ),
                                      leading: InkWell(
                                        onTap: () {
                                          context.read<TodosBloc>().add(
                                                ToggleTodoStatusEvent(todo: todo),
                                              );
                                        },
                                        child: Container(
                                          width: AppDimensions.space7XL,
                                          height: AppDimensions.space7XL,
                                          decoration: BoxDecoration(
                                            color: todo.isCompleted ? AppColors.tealLight : Colors.transparent,
                                            border: Border.all(
                                              color: todo.isCompleted ? AppColors.primary : AppColors.textLight,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                          ),
                                          child: todo.isCompleted
                                              ? const Icon(
                                                  Icons.check,
                                                  color: AppColors.primary,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                      ),
                                      title: Text(
                                        todo.title,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                          color: todo.isCompleted ? AppColors.textLight : AppColors.textPrimary,
                                          fontWeight: todo.isCompleted ? FontWeight.w400 : FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Updated: ${_formatDate(todo.updatedAt)}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontSize: AppDimensions.fontS - 1,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<TodosBloc, TodosState>(
        builder: (context, state) {
          if (state is TodosLoaded) {
            return FloatingActionButton(
              onPressed: () => context.push(AppRouter.addTodoPath).then((_) {
                if (context.mounted) {
                  context.read<TodosBloc>().add(LoadTodosEvent());
                }
              }),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: AppDimensions.sizeLogo + 20,
          height: AppDimensions.sizeLogo + 20,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.checklist_rtl_rounded,
            size: AppDimensions.iconXXL,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppDimensions.space3XL),
        Text(
          'No tasks on checklist',
          style: AppTextStyles.titleSmall,
        ),
        SizedBox(height: AppDimensions.spaceM),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding3XL),
          child: Text(
            'Keep track of your operations and synchronize completion events live or offline.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ),
        SizedBox(height: AppDimensions.space7XL),
        ElevatedButton.icon(
          onPressed: () => context.push(AppRouter.addTodoPath).then((_) {
            if (context.mounted) {
              context.read<TodosBloc>().add(LoadTodosEvent());
            }
          }),
          icon: const Icon(Icons.add, color: AppColors.white),
          label: const Text(
            'Create Task',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXXL,
              vertical: AppDimensions.paddingL - 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

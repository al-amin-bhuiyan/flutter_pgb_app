import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_icon_button.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/todos_bloc.dart';
import '../bloc/todos_event.dart';
import '../bloc/todos_state.dart';

class AddTodoScreen extends StatelessWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodosBloc>(
      create: (context) => sl<TodosBloc>(),
      child: const AddTodoForm(),
    );
  }
}

class AddTodoForm extends StatefulWidget {
  const AddTodoForm({super.key});

  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}

class _AddTodoFormState extends State<AddTodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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
          'Create Task',
          style: AppTextStyles.titleMedium,
        ),
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: AppDimensions.fontTitleM,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoActionSuccess) {
            Navigator.of(context).pop(true);
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
            final isLoading = state is TodosLoading;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.paddingXL),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600.0 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.paddingXXL),
                      decoration: ShapeDecoration(
                        color: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusContainer),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x1E19202D),
                            blurRadius: 30,
                            offset: Offset(0, 8),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a new operation tracking checklist task',
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(height: AppDimensions.space3XL),
                          
                          // Task Title Field
                          AppTextField(
                            controller: _titleController,
                            labelText: 'Task Title',
                            hintText: 'e.g. Inspect boundary flags',
                            prefixIcon: Icons.checklist_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter task title';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppDimensions.space7XL),

                          // Submit Button
                          AppButton(
                            text: 'Create Task',
                            isLoading: isLoading,
                            onPressed: _submitForm,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<TodosBloc>().add(
            AddTodoEvent(
              title: _titleController.text.trim(),
            ),
          );
    }
  }
}

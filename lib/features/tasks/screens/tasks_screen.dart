import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:gistol_dashboard/features/tasks/view/widgets/task_nav_bar.dart';
import 'package:gistol_dashboard/features/tasks/view/widgets/tasks_list.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final tasksProvider = context.read<TasksProvider>();
    final groupProvider = context.read<GroupProvider>();
    try {
      if (!groupProvider.isReady()) {
        await groupProvider.initData();
      }
      await tasksProvider.initData();
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tasks.title.tr(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Expanded(
            child: LoaderWrapper(
              loading: provider.isOperationLoading,
              child: const BlockContainer(
                maxWidth: 1200,
                maxHeight: 700,
                navBar: TasksNavbar(),
                content: TasksList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

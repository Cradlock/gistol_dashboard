import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/view/provider.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exam_nav_bar.dart';
import 'package:gistol_dashboard/features/exams/view/widgets/exams_list.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:provider/provider.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final examsProvider = context.read<ExamsProvider>();
    final groupProvider = context.read<GroupProvider>();
    try {
      if (!groupProvider.isReady()) {
        await groupProvider.initData();
      }
      await examsProvider.initData();
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamsProvider>();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.exams.title.tr(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Expanded(
            child: LoaderWrapper(
              loading: provider.isLoading,
              child: const BlockContainer(
                maxWidth: 1200,
                maxHeight: 700,
                navBar: ExamsNavbar(),
                content: ExamsList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

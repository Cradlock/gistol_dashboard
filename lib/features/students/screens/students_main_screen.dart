import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:gistol_dashboard/features/students/view/widgets/nav_bar.dart';
import 'package:gistol_dashboard/features/students/view/widgets/students_list.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final provider = context.read<StudentsProvider>();
    try {
      await provider.init();
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.students.title.tr(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const Expanded(
            child: BlockContainer(
              maxWidth: 1200,
              maxHeight: 700,
              navBar: StudentsNavbar(),
              content: StudentsList(),
            ),
          ),
        ],
      ),
    );
  }
}

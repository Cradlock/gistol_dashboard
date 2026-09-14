import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:gistol_dashboard/features/students/view/widgets/edit_card.dart';
import 'package:gistol_dashboard/features/students/view/widgets/student_tile.dart';
import 'package:provider/provider.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    context.read<StudentsProvider>().loadMoreOnScroll(_controller);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentsProvider>();
    final students = provider.students;

    if (students.isEmpty && provider.isLoadingMore) {
      return const Center(child: StandardSpinner());
    }

    if (students.isEmpty) {
      return Center(
        child: AppBtn(
          icon: Icons.restore,
          onPressed: () => provider.fetchStudents(isRefresh: true),
        ),
      );
    }

    final itemCount = students.length + (provider.hasMore ? 1 : 0);

    return ListView.separated(
      controller: _controller,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        if (index >= students.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: StandardSpinner()),
          );
        }

        final student = students[index];
        final fullName = [
          student.surname,
          student.name,
        ].where((part) => part != null && part.isNotEmpty).join(' ');

        return StudentTile(
          id: student.id,
          name: fullName.isEmpty ? '—' : fullName,
          year: student.year?.toString() ?? '—',
          group: student.group?.title ?? '—',
          isSelected: provider.selectedStudents.contains(student.id),
          isDeleted: student.deleted,
          isConfirmed: student.confirmed,
          onSelect: provider.toggleStudentSelect,
          onEditTap: student.deleted
              ? null
              : (id) {
                  showAppDialog(
                    context: context,
                    content: EditStudentCard(student: student),
                  );
                },
        );
      },
    );
  }
}

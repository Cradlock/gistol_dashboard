import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/strings.dart';
import 'package:gistol_dashboard/core/utils/show_dialog.dart';
import 'package:gistol_dashboard/core/widgets/app_btn.dart';

class TableOperation {
  final IconData icon;
  final String title;
  final String description;
  final Future<void> Function() onSelected;
  final Color? iconColor;

  const TableOperation({
    required this.icon,
    required this.title,
    required this.description,
    required this.onSelected,
    this.iconColor,
  });
}

Future<void> showTableOperations({
  required BuildContext context,
  required List<TableOperation> operations,
}) {
  return showAppDialog<void>(
    context: context,
    content: TableOperationsDialog(operations: operations),
  );
}

class TableOperationsButton extends StatelessWidget {
  final List<TableOperation> operations;

  const TableOperationsButton({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    return AppBtn(
      icon: Icons.more_horiz,
      text: AppStrings.common.operations.tr(),
      borderRadius: 50,
      onPressed: () => showTableOperations(
        context: context,
        operations: operations,
      ),
    );
  }
}

class TableOperationsDialog extends StatelessWidget {
  final List<TableOperation> operations;

  const TableOperationsDialog({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.common.operations.tr(),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: operations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final operation = operations[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(operation.icon, color: operation.iconColor),
                  title: Text(operation.title),
                  subtitle: Text(operation.description),
                  onTap: () async {
                    Navigator.pop(context);
                    await operation.onSelected();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

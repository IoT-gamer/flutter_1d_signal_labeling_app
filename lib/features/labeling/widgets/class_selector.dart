import 'package:flutter/material.dart';

import '../../../core/constants.dart';

Future<LabelClass?> showClassSelectorDialog(BuildContext context) {
  return showDialog<LabelClass>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Signal Label'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableClasses.length,
            itemBuilder: (context, index) {
              final labelClass = availableClasses[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: labelClass.color,
                  child: Text(
                    labelClass.id.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(labelClass.name),
                onTap: () {
                  Navigator.of(context).pop(labelClass);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

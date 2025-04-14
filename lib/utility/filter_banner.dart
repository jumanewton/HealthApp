// import 'package:flutter/material.dart';

// class FilterBanner extends StatelessWidget {
//   final String filterName;
//   final VoidCallback onClear;

//   const FilterBanner({
//     Key? key,
//     required this.filterName,
//     required this.onClear,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: Theme.of(context).colorScheme.surfaceVariant,
//       child: Row(
//         children: [
//           Text(
//             'Filter: $filterName',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const Spacer(),
//           TextButton(
//             child: const Text('Clear Filter'),
//             onPressed: onClear,
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/models/room_model.dart';
// import 'package:flutter_application_1/utils/app_palette.dart';
// import 'package:flutter_application_1/utils/constants.dart';

// class _FeaturedSpaceCard extends StatelessWidget {
//   final Room room;
//   final VoidCallback onTap;

//   const _FeaturedSpaceCard({
//     required this.room,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final title = _roomTitle(room);
//     final location = _roomLocation(room);
//     final imageUrl = _roomImage(room);
//     final rating = _roomRating(room);
//     final capacity = _roomCapacity(room);
//     final tags = _roomTags(room).take(2).toList();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: context.appColors.surface,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: context.appColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: context.appColors.shadow,
//             blurRadius: 11,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(13),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               Stack(
//                 children: [
//                   _RoomThumbnail(imageUrl: imageUrl),
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: _RatingBadge(rating: rating),
//                   ),
//                 ],
//               ),

//               const SizedBox(width: 14),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: context.appText.titleMedium?.copyWith(
//                         color: context.appColors.text,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),

//                     const SizedBox(height: 4),

//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           size: 15,
//                           color: context.appColors.text,
//                         ),
//                         const SizedBox(width: 3),
//                         Expanded(
//                           child: Text(
//                             location,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: context.appText.bodySmall?.copyWith(
//                               color: context.appColors.text,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 10),

//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 6,
//                       children: tags
//                           .map((tag) => _MiniAmenityChip(text: tag))
//                           .toList(),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 8),

//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.people_alt_outlined,
//                     size: 17,
//                     color: context.appColors.text,
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     '$capacity',
//                     style: context.appText.bodySmall?.copyWith(
//                       color: context.appColors.text,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RoomThumbnail extends StatelessWidget {
//   final String imageUrl;

//   const _RoomThumbnail({
//     required this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final placeholder = Container(
//       width: 88,
//       height: 100,
//       decoration: BoxDecoration(
//         color: context.appColors.primarySoft,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       alignment: Alignment.center,
//       child: const Icon(
//         Icons.meeting_room_outlined,
//         color: AppConstants.primary,
//         size: 34,
//       ),
//     );

//     if (imageUrl.trim().isEmpty) {
//       return placeholder;
//     }

//     Widget image;

//     if (imageUrl.startsWith('http')) {
//       image = Image.network(
//         imageUrl,
//         width: 88,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => placeholder,
//       );
//     } else if (imageUrl.startsWith('/')) {
//       image = Image.file(
//         File(imageUrl),
//         width: 88,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => placeholder,
//       );
//     } else {
//       image = Image.asset(
//         imageUrl,
//         width: 88,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => placeholder,
//       );
//     }

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: image,
//     );
//   }
// }

// class _RatingBadge extends StatelessWidget {
//   final double rating;

//   const _RatingBadge({
//     required this.rating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: context.appColors.surface,
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: context.appColors.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Icons.star_rounded,
//             color: Colors.orange,
//             size: 13,
//           ),
//           const SizedBox(width: 2),
//           Text(
//             rating.toStringAsFixed(1),
//             style: context.appText.bodySmall?.copyWith(
//               color: context.appColors.text,
//               fontSize: 10,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MiniAmenityChip extends StatelessWidget {
//   final String text;

//   const _MiniAmenityChip({
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: context.appColors.primarySoft,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         text.toUpperCase(),
//         style: context.appText.bodySmall?.copyWith(
//           color: AppConstants.primary,
//           fontSize: 8,
//           letterSpacing: .8,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }
// }

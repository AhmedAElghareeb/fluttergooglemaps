import 'package:flutter/material.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/data/models/place_suggestions.dart';

class PlaceItem extends StatelessWidget {
  const PlaceItem({super.key, required this.suggestions});

  final PlaceSuggestions suggestions;

  @override
  Widget build(BuildContext context) {
    var subTitle = suggestions.description.replaceAll(
      suggestions.description.split(',')[0],
      '',
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightBlue,
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.blue,
                size: 20,
              ),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${suggestions.description.split(',')[0]}\n',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: subTitle.substring(2),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

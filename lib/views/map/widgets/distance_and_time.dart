import 'package:flutter/material.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/data/models/directions.dart';

class DistanceAndTime extends StatelessWidget {
  final PlaceDirections? placeDirections;
  final bool isTimeAndDistanceVisible;

  const DistanceAndTime({
    super.key,
    this.placeDirections,
    required this.isTimeAndDistanceVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isTimeAndDistanceVisible,
      child: Positioned(
        top: 0,
        bottom: 650,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: buildDurationCard(),
            ),
            Flexible(
              flex: 1,
              child: buildDistanceCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDistanceCard() {
    return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              color: Colors.white,
              child: ListTile(
                dense: true,
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.directions_car,
                  color: AppColors.blue,
                  size: 30,
                ),
                title: Text(
                  placeDirections!.totalDistance,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
  }

  Widget buildDurationCard() {
    return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              color: Colors.white,
              child: ListTile(
                dense: true,
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.access_time,
                  color: AppColors.blue,
                  size: 30,
                ),
                title: Text(
                  placeDirections!.totalDuration,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
  }
}

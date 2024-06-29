import 'dart:developer' as dev;

import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/widgets/preview_title.dart';
import 'package:flutter_application_1/screens/widgets/submit_button.dart';

/// For showing snackbars.
final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// The values that will be used to choose between different
/// style of snackbar.
enum SnackBarType { error, information, success }

/// Shows a snackbar.
void showSnackBarColored(
    String message,
    SnackBarType snackBarType,
    ) {
  Color color;
  if (snackBarType == SnackBarType.success) {
    color = Colors.green;
  } else if (snackBarType == SnackBarType.information) {
    color = Colors.blue;
  } else {
    color = Colors.red;
  }

  globalScaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
        content: Text(message),
      ),
    );
}

const kSpacer = SizedBox(height: 20.0);

class ReverseGeocodingView extends StatefulWidget {
  const ReverseGeocodingView(this.geocoder, {Key? key}) : super(key: key);

  final FlGeocoder geocoder;

  @override
  State<ReverseGeocodingView> createState() => _ReverseGeocodingViewState();
}

class _ReverseGeocodingViewState extends State<ReverseGeocodingView> {
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;
  final addresses = <Result>[];
  bool isFiltered = false;

  @override
  void initState() {
    super.initState();
    latitudeController = TextEditingController(text: '40.714224');
    longitudeController = TextEditingController(text: '-73.961452');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewTitle(title: 'Reverse Geocoding'),
        LayoutBuilder(builder: (context, constraints) {
          final fieldWidth = constraints.maxWidth * 0.45;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: fieldWidth,
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  controller: latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  controller: longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ],
          );
        }),
        kSpacer,
        Row(
          children: [
            Checkbox(
              value: isFiltered,
              onChanged: (value) => setState(() => isFiltered = value!),
            ),
            const Text('Filter results?'),
          ],
        ),
        Center(
          child: SubmitButton(
            onPressed: () async {
              final latitude = double.parse(latitudeController.text);
              final longitude = double.parse(longitudeController.text);
              final coordinates = Location(latitude, longitude);
              try {
                final results =
                await widget.geocoder.findAddressesFromLocationCoordinates(
                  location: coordinates,
                  useDefaultResultTypeFilter: isFiltered,
                  // resultType: 'route', // Optional. For custom filter.
                );

                addresses.clear();
                addresses.addAll(results);
                setState(() {});
              } on GeocodeFailure catch (e) {
                // Do some debugging or show an error message.
                dev.log(e.message ?? 'Unknown error occured.');
                showSnackBarColored(
                  e.message ?? 'Unknown error occured.',
                  SnackBarType.error,
                );
              } catch (e) {
                // Do some debugging or show an error message.
                dev.log(e.toString());
                showSnackBarColored(e.toString(), SnackBarType.error);
              }
            },
            text: 'Search',
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            PreviewTitle(title: 'Result/s:'),
            SizedBox(width: 10),
            Text(
              'Tap the text to copy geometry',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final adress = addresses[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                adress.formattedAddress ??
                    'No formatted address, please try other format.',
              ),
            );
          },
        ),
      ],
    );
  }
}
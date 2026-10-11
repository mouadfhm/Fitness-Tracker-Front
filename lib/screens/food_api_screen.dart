import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';
import '../l10n/app_localizations.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  final FoodService _foodService = FoodService();
  Food? _scannedFood;
  bool _isLoading = false;
  /// Built at display time so it follows the current language.
  String Function(AppLocalizations l10n)? _errorMessage;

  /// Initiates barcode scanning, fetches food info and updates UI.
  Future<void> _scanBarcode() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _scannedFood = null;
    });
    try {
      // Trigger the barcode scan
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        setState(() {
          _errorMessage = (l10n) => l10n.foodsNoBarcodeScanned;
          _isLoading = false;
        });
        return;
      }
      // Fetch food info using the scanned barcode
      var foodInfo = await _foodService.getFoodInfo(barcode);
      if (foodInfo != null) {
        setState(() {
          _scannedFood = Food.fromJson(foodInfo);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = (l10n) => l10n.foodsNotFoundForBarcode(barcode);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = (l10n) => l10n.foodsScanError('$e');
        _isLoading = false;
      });
    }
  }

  /// Navigate to FoodDetailsScreen, where users can add the food into a meal.
  void _goToFoodDetails() {
    if (_scannedFood != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailsScreen(food: _scannedFood!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodScanTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.foodScanButton),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!(l10n),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  if (_scannedFood != null)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scannedFood!.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(l10n.foodScanCalories('${_scannedFood!.calories}')),
                            Text(l10n.foodScanProtein('${_scannedFood!.protein}')),
                            Text(l10n.foodScanCarbs('${_scannedFood!.carbs}')),
                            Text(l10n.foodScanFats('${_scannedFood!.fats}')),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _goToFoodDetails,
                              child: Text(l10n.foodScanAddToMeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

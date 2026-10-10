import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';
import 'new_food_screen.dart';
import '../utils/add_banner.dart';
import '../utils/ad_list_helper.dart';
import '../utils/friendly_error.dart';
import '../utils/food_search.dart';
import '../utils/labels.dart';

enum SortBy {
  default_,
  calories,
  protein,
  carbs,
  fats
}

class FoodsScreen extends StatefulWidget {
  /// When set, the screen is a picker opened from Home: choosing a food logs
  /// it to this meal and returns to Home with a confirmation message.
  final String? addToMeal;

  const FoodsScreen({super.key, this.addToMeal});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen>
    with AutomaticKeepAliveClientMixin {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();
  SortBy _currentSortBy = SortBy.default_;
  bool _sortAscending = false;  // false = high to low (descending), true = low to high (ascending)

  Food? _scannedFood;

  bool get _isPicker => widget.addToMeal != null;

  /// Opens a food. If it gets logged and we're picking for Home, go straight
  /// back to Home with the confirmation; otherwise just show it here.
  Future<void> _openFood(Food food) async {
    final added = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailsScreen(food: food, initialMealTime: widget.addToMeal),
      ),
    );
    if (!mounted || added == null) return;
    if (_isPicker) {
      Navigator.pop(context, added);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added)));
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // The provider first loads at app start, which fails if the person
    // wasn't logged in yet. Retry when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<FoodProvider>(context, listen: false);
      if (!provider.isLoading && (provider.foods.isEmpty || provider.errorMessage.isNotEmpty)) {
        provider.refreshFoods();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Barcode scanning: attempts to scan and then fetch food info.
  Future<void> _scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        _showSnackBar('No barcode scanned.');
        return;
      }
      setState(() {});
      var foodInfo = await _foodService.getFoodInfo(barcode);
      if (!mounted) return;
      if (foodInfo != null) {
        final scannedFood = Food.fromJson(foodInfo);
        // ignore: use_build_context_synchronously
        await Provider.of<FoodProvider>(
          context,
          listen: false,
        ).addFood(scannedFood);
        if (!mounted) return;
        await _openFood(scannedFood);
        if (mounted) setState(() => _scannedFood = null);
      } else {
        _showSnackBar("We couldn't find that product. Try searching by name, or add it yourself with the + button.");
      }
    } catch (e) {
      _showSnackBar("Couldn't scan the barcode. ${friendlyError(e)}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  /// Navigates to NewFoodScreen. On return, refresh the provider.
  Future<void> _goToNewFood() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewFoodScreen()),
    );
    if (!mounted) return;
    Provider.of<FoodProvider>(context, listen: false).refreshFoods();
  }

  /// Toggle sort option
  void _toggleSort(SortBy sortBy) {
    setState(() {
      // If same sort is selected, toggle direction
      if (_currentSortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        // For a new sort type, set to descending (high to low) by default
        _currentSortBy = sortBy;
        _sortAscending = false;
      }
    });
    Navigator.pop(context);
  }

  /// Show sort options dialog
  void _showSortOptions() {    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Sort Foods By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.restore, 
                  color: _currentSortBy == SortBy.default_ 
                    ? Theme.of(context).colorScheme.primary
                    : null),
                title: Text('Default',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.default_ 
                  ? Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary) 
                  : null,
                selected: _currentSortBy == SortBy.default_,
                onTap: () => _toggleSort(SortBy.default_),
              ),
              ListTile(
                leading: Icon(Icons.local_fire_department, 
                  color: _currentSortBy == SortBy.calories 
                    ? Theme.of(context).colorScheme.error
                    : null),
                title: Text('Calories',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.calories 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.error)
                  : null,
                selected: _currentSortBy == SortBy.calories,
                onTap: () => _toggleSort(SortBy.calories),
              ),
              ListTile(
                leading: Icon(Icons.fitness_center,
                  color: _currentSortBy == SortBy.protein 
                    ? Colors.blue.shade700
                    : null),
                title: Text('Protein',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.protein 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.blue.shade700)
                  : null,
                selected: _currentSortBy == SortBy.protein,
                onTap: () => _toggleSort(SortBy.protein),
              ),
              ListTile(
                leading: Icon(Icons.grain,
                  color: _currentSortBy == SortBy.carbs
                    ? Colors.green.shade700
                    : null),
                title: Text('Carbs',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.carbs 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.green.shade700)
                  : null,
                selected: _currentSortBy == SortBy.carbs,
                onTap: () => _toggleSort(SortBy.carbs),
              ),
              ListTile(
                leading: Icon(Icons.opacity,
                  color: _currentSortBy == SortBy.fats
                    ? Colors.orange.shade700
                    : null),
                title: Text('Fat',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.fats 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.orange.shade700)
                  : null,
                selected: _currentSortBy == SortBy.fats,
                onTap: () => _toggleSort(SortBy.fats),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sort foods based on the current sort option
  List<Food> _sortFoods(List<Food> foods) {
    // Make a copy to avoid modifying the original list
    List<Food> sortedFoods = List.from(foods);
    
    switch (_currentSortBy) {
      case SortBy.default_:
        // Default sort - return the original list unsorted
        return foods;
      case SortBy.calories:
        sortedFoods.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      case SortBy.protein:
        sortedFoods.sort((a, b) => a.protein.compareTo(b.protein));
        break;
      case SortBy.carbs:
        sortedFoods.sort((a, b) => a.carbs.compareTo(b.carbs));
        break;
      case SortBy.fats:
        sortedFoods.sort((a, b) => a.fats.compareTo(b.fats));
        break;
    }
    
    // If not ascending (high to low), reverse the list
    if (!_sortAscending) {
      return sortedFoods.reversed.toList();
    }
    
    return sortedFoods;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Get corresponding colors for nutrition based on theme
    final proteinColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    final carbsColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final fatsColor = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    final caloriesColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
    
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        // Filter foods based on search query.
        List<Food> filteredFoods =
            searchFoods(foodProvider.foods, _searchController.text, (food) => food.name);
        
        // Apply sorting
        filteredFoods = _sortFoods(filteredFoods);

        // Get sort title to display
        String sortTitle = _getSortTitle();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isPicker ? 'Add to ${mealTimeLabel(widget.addToMeal!)}' : 'Foods',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortOptions,
                tooltip: 'Sort foods',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                foodProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : foodProvider.errorMessage.isNotEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              foodProvider.errorMessage,
                              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: foodProvider.refreshFoods,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        _buildSearchAndScanBar(),
                        const SizedBox(height: 10),
                        // Display current sort method
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Sorting by: $sortTitle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (_currentSortBy != SortBy.default_)
                                Icon(
                                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_scannedFood != null)
                          Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(_scannedFood!.name),
                              subtitle: Text(
                                '${_scannedFood!.calories.round()} kcal per 100 g',
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                color: colorScheme.primary),
                              onTap: () => _openFood(_scannedFood!),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filteredFoods.isEmpty
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'No foods match your search.',
                                            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: _goToNewFood,
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add your own food'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    key: const PageStorageKey<String>(
                                      'food_list',
                                    ),
                                    itemCount: effectiveItemCount(filteredFoods.length),
                                    itemBuilder: (context, index) => adAwareItemBuilder(
                                      index,
                                      (realIndex) {
                                        final food = filteredFoods[realIndex];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          // Name and heart/chevron on top, macros on a
                                          // full-width row underneath, so the badges
                                          // get the card's whole width instead of the
                                          // narrow column a ListTile leaves them.
                                          child: InkWell(
                                            onTap: () => _openFood(food),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        food.isFavorite == 1
                                                            ? Icons.favorite
                                                            : Icons.favorite_border,
                                                        color: food.isFavorite == 1
                                                            ? colorScheme.error
                                                            : colorScheme.onSurfaceVariant,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              food.name,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                                color: colorScheme.onSurface,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              '${food.calories.round()} kcal per 100 g',
                                                              style: TextStyle(
                                                                color: colorScheme.onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.chevron_right,
                                                        color: colorScheme.primary,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildNutritionInfo(food, proteinColor, carbsColor, fatsColor, caloriesColor),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                        ),
                      ],
                    ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _goToNewFood,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            icon: const Icon(Icons.add),
            label: const Text('New food'),
          ),
          bottomNavigationBar: _isPicker
              ? null
              : const AdBannerWidget(),
        );
      },
    );
  }

  // Build relevant nutrition info based on current sort
  Widget _buildNutritionInfo(Food food, Color proteinColor, Color carbsColor, Color fatsColor, Color caloriesColor) {
    switch (_currentSortBy) {
      case SortBy.protein:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: proteinColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Protein: ${_grams(food.protein)} per 100 g',
            style: TextStyle(
              color: proteinColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.carbs:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: carbsColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Carbs: ${_grams(food.carbs)} per 100 g',
            style: TextStyle(
              color: carbsColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.fats:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: fatsColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Fat: ${_grams(food.fats)} per 100 g',
            style: TextStyle(
              color: fatsColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.calories:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: caloriesColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${food.calories.round()} kcal per 100 g',
            style: TextStyle(
              color: caloriesColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        // Default shows all three macros as equal-width pills across the card.
        return Row(
          children: [
            _macroPill('Protein ${_grams(food.protein)}', proteinColor),
            const SizedBox(width: 8),
            _macroPill('Carbs ${_grams(food.carbs)}', carbsColor),
            const SizedBox(width: 8),
            _macroPill('Fat ${_grams(food.fats)}', fatsColor),
          ],
        );
    }
  }

  Widget _macroPill(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 3.0 -> "3 g", 2.5 -> "2.5 g".
  String _grams(double value) =>
      '${value == value.roundToDouble() ? value.round() : value.toStringAsFixed(1)} g';

  // Helper method to get readable sort title
  String _getSortTitle() {
    switch (_currentSortBy) {
      case SortBy.default_:
        return 'Default';
      case SortBy.calories:
        return 'Calories';
      case SortBy.protein:
        return 'Protein';
      case SortBy.carbs:
        return 'Carbs';
      case SortBy.fats:
        return 'Fat';
    }
  }

  Widget _buildSearchAndScanBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search foods',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                cursorColor: colorScheme.primary,
                onChanged: (query) => setState(() {}), // triggers rebuild to filter list
              ),
            ),
            const SizedBox(width: 8),
            // Same height and corner radius as the search field, filled with
            // the primary colour like the app's other main actions.
            AspectRatio(
              aspectRatio: 1,
              child: IconButton.filled(
                onPressed: _scanBarcode,
                tooltip: 'Scan a barcode',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
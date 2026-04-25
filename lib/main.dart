import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const NexStockApp());
}

/// Core Model for Inventory
class InventoryItem {
  String id;
  String name;
  String sku;
  int quantity;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
  });
}

/// Core Model for Sales
class SaleRecord {
  final String id;
  final String itemName;
  final String sku;
  final int quantitySold;
  final DateTime date;

  SaleRecord({
    required this.id,
    required this.itemName,
    required this.sku,
    required this.quantitySold,
    required this.date,
  });
}

class NexStockApp extends StatefulWidget {
  const NexStockApp({Key? key}) : super(key: key);

  @override
  State<NexStockApp> createState() => _NexStockAppState();
}

class _NexStockAppState extends State<NexStockApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexStock',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: DashboardScreen(
        toggleTheme: toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        prefixIconColor: Colors.indigo,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        prefixIconColor: Colors.indigoAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigoAccent, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.indigoAccent[400],
        foregroundColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Application State
  final List<InventoryItem> _items = [
    InventoryItem(id: '1', name: 'Wireless Mouse', sku: 'WM-001', quantity: 45),
    InventoryItem(id: '2', name: 'Mechanical Keyboard', sku: 'MK-102', quantity: 3),
    InventoryItem(id: '3', name: 'USB-C Cable', sku: 'UC-554', quantity: 120),
    InventoryItem(id: '4', name: '27" 4K Monitor', sku: 'MN-27K', quantity: 0),
    InventoryItem(id: '5', name: 'Ergonomic Chair', sku: 'EC-990', quantity: 7),
  ];

  final List<SaleRecord> _salesHistory = [];

  late List<InventoryItem> _filteredItems;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOption = 'Name (A-Z)';

  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_items);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Simulate startup loading for UX improvement
    _simulateStartup();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _simulateStartup() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    });
  }

  void _filterAndSortItems() {
    setState(() {
      var filtered = _items.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
            item.sku.toLowerCase().contains(query);
      }).toList();

      if (_sortOption == 'Name (A-Z)') {
        filtered.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortOption == 'Name (Z-A)') {
        filtered.sort((a, b) => b.name.compareTo(a.name));
      } else if (_sortOption == 'Quantity (Lowest)') {
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
      } else if (_sortOption == 'Quantity (Highest)') {
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
      } else if (_sortOption == 'SKU (A-Z)') {
        filtered.sort((a, b) => a.sku.compareTo(b.sku));
      } else if (_sortOption == 'SKU (Z-A)') {
        filtered.sort((a, b) => b.sku.compareTo(a.sku));
      }

      _filteredItems = filtered;
    });

    // Reset and trigger list entry animation when filtering changes
    _animationController.reset();
    _animationController.forward();
  }

  void _showSnackBar(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
      ),
    );
  }

  void _addItem(String name, String sku, int quantity) {
    setState(() {
      _items.add(InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        sku: sku,
        quantity: quantity,
      ));
      _filterAndSortItems();
    });
    _showSnackBar('Item "$name" added successfully', Colors.green.shade700, Icons.check_circle_outline);
  }

  void _restockItem(InventoryItem item) {
    setState(() {
      item.quantity += 10;
      _filterAndSortItems(); // Re-sort and filter list
    });
    _showSnackBar('Restocked +10 units of ${item.name}', Colors.indigo.shade600, Icons.add_shopping_cart);
  }

  void _sellItem(InventoryItem item) {
    if (item.quantity <= 0) {
      _showSnackBar('${item.name} is currently out of stock!', Colors.red.shade700, Icons.error_outline);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int sellQuantity = 1;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Text('Confirm Sale'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many units of ${item.name} would you like to sell?\n\nCurrent stock: ${item.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: sellQuantity > 1 ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: sellQuantity > 1
                              ? () => setDialogState(() => sellQuantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$sellQuantity',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: sellQuantity < item.quantity ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: sellQuantity < item.quantity
                              ? () => setDialogState(() => sellQuantity++)
                              : null,
                          icon: const Icon(Icons.add),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      item.quantity -= sellQuantity;
                      _salesHistory.insert(0, SaleRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        itemName: item.name,
                        sku: item.sku,
                        quantitySold: sellQuantity,
                        date: DateTime.now(),
                      ));
                      _filterAndSortItems();
                    });
                    _showSnackBar('Sold $sellQuantity unit(s) of ${item.name}', Colors.orange.shade700, Icons.sell_outlined);
                  },
                  child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String sku = '';
    int quantity = 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_box_outlined, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'New Inventory',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter an item name' : null,
                    onSaved: (val) => name = val!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'SKU (Stock Keeping Unit)',
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter an SKU';
                      if (_items.any((item) => item.sku.toLowerCase() == val.trim().toLowerCase())) {
                        return 'This SKU already exists in inventory';
                      }
                      return null;
                    },
                    onSaved: (val) => sku = val!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Initial Quantity',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter a quantity';
                      return null;
                    },
                    onSaved: (val) => quantity = int.parse(val!),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _addItem(name, sku, quantity);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    if (hour == 0) hour = 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $ampm';
  }

  void _showSalesHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, size: 24, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  const Text('Sales History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _salesHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          const Text('No sales recorded yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _salesHistory.length,
                      itemBuilder: (context, index) {
                        final sale = _salesHistory[index];
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).cardTheme.color ?? Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.sell_outlined, color: Colors.green),
                            ),
                            title: Text(sale.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SKU: ${sale.sku}', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(_formatDate(sale.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            trailing: Text(
                              '-${sale.quantitySold}',
                              style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w900),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalItems = _items.fold(0, (sum, i) => sum + i.quantity);
    final lowStock = _items.where((i) => i.quantity > 0 && i.quantity < 5).length;
    final outOfStock = _items.where((i) => i.quantity == 0).length;

    // A beautiful horizontal scrollable row of cards
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatCard('Total\nStock', totalItems.toString(), Icons.inventory_2, [Colors.blue.shade700, Colors.blue.shade400]),
          const SizedBox(width: 12),
          _buildStatCard('Low\nStock', lowStock.toString(), Icons.warning_amber, [Colors.orange.shade700, Colors.orange.shade400]),
          const SizedBox(width: 12),
          _buildStatCard('Out of\nStock', outOfStock.toString(), Icons.error_outline, [Colors.red.shade700, Colors.red.shade400]),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> gradient) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  _searchQuery = val;
                  _filterAndSortItems();
                },
                decoration: const InputDecoration(
                  hintText: 'Search by Name or SKU...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.filter_list, color: widget.isDarkMode ? Colors.white70 : Colors.black87),
                tooltip: 'Sort Options',
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  _sortOption = val;
                  _filterAndSortItems();
                },
                itemBuilder: (context) => [
                  'Name (A-Z)',
                  'Name (Z-A)',
                  'Quantity (Lowest)',
                  'Quantity (Highest)',
                  'SKU (A-Z)',
                  'SKU (Z-A)',
                ].map((e) => PopupMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(
                            _sortOption == e ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 18,
                            color: _sortOption == e ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(e, style: TextStyle(fontWeight: _sortOption == e ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(InventoryItem item, int index) {
    // Determine strict color coding per prompt (+5 Green, <5 Red)
    final bool isCritical = item.quantity < 5;
    final Color stockColor = isCritical ? Colors.red : Colors.green.shade600;
    final bool isOutOfStock = item.quantity == 0;

    // Staggered animation values
    final double start = (index * 0.1).clamp(0.0, 1.0);
    final double end = (start + 0.4).clamp(0.0, 1.0);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(curve),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // For future detail view expansion
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isOutOfStock ? Icons.cancel_outlined : (isCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline),
                    color: stockColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SKU: ${item.sku}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Stock: ', style: TextStyle(fontSize: 14)),
                          Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: stockColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: Icons.remove,
                      label: 'Sell',
                      color: Colors.orange.shade700,
                      onTap: () => _sellItem(item),
                      disabled: isOutOfStock,
                    ),
                    const SizedBox(height: 8),
                    _actionButton(
                      icon: Icons.add,
                      label: 'Restock',
                      color: Colors.indigo.shade600,
                      onTap: () => _restockItem(item),
                      disabled: false,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool disabled,
  }) {
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.withOpacity(0.1) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: disabled ? Colors.transparent : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: disabled ? Colors.grey : color, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: disabled ? Colors.grey : color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty ? 'No matches found.' : 'Your inventory is empty.',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search query or clear filters.'
                  : 'Start managing your products by adding items.',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add First Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NexStock Management',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Sales', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _showSalesHistory,
            ),
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text('Loading Inventory...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildSummaryCards(),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filteredItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 88, top: 4), // Padding for FAB
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildListItem(_filteredItems[index], index);
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isLoading
          ? null
          : TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: FloatingActionButton.extended(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
                elevation: 4,
              ),
            ),
    );
  }
}
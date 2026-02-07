import 'package:flutter/material.dart';
import 'api_service.dart';

class PredictionForm extends StatefulWidget {
  const PredictionForm({super.key});

  @override
  State<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  List<String> _locations = [];
  String? _selectedLocation;
  String? _selectedStatus = 'Ready to move';
  final List<String> _statusOptions = ['Ready to move', 'Under Construction'];

  double _bhk = 2;
  double _bathroom = 2;
  final TextEditingController _areaController = TextEditingController();

  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _apiService.fetchLocations();
      setState(() {
        _locations = locations;
        if (_locations.isNotEmpty) {
          _selectedLocation = _locations[0];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load locations: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    }
  }

  Future<void> _predict() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      setState(() {
        _isLoading = true;
        _result = '';
      });

      try {
        final inputData = {
          'location': _selectedLocation,
          'status': _selectedStatus,
          'bhk': _bhk,
          'bathroom': _bathroom,
          'area': double.parse(_areaController.text),
        };

        final price = await _apiService.predictPrice(inputData);
        setState(() {
          _result = '₹${price.toStringAsFixed(2)} Lakhs';
        });
      } catch (e) {
        setState(() {
          _result = 'Error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHENNAI',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Real Estate\nPredictor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_locations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else
                      Column(
                        children: [
                          _buildDropdown(
                            label: 'LOCATION',
                            value: _selectedLocation,
                            items: _locations,
                            onChanged: (val) =>
                                setState(() => _selectedLocation = val),
                          ),
                          const SizedBox(height: 20),
                          _buildDropdown(
                            label: 'STATUS',
                            value: _selectedStatus,
                            items: _statusOptions,
                            onChanged: (val) =>
                                setState(() => _selectedStatus = val),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                return Column(
                                  children: [
                                    _buildDropdown<double>(
                                      label: 'BHK',
                                      value: _bhk,
                                      items: List.generate(6, (i) => i + 1.0),
                                      displayItem: (val) => '${val.toInt()}',
                                      onChanged: (val) =>
                                          setState(() => _bhk = val!),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDropdown<double>(
                                      label: 'BATHROOMS',
                                      value: _bathroom,
                                      items: List.generate(5, (i) => i + 1.0),
                                      displayItem: (val) => '${val.toInt()}',
                                      onChanged: (val) =>
                                          setState(() => _bathroom = val!),
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown<double>(
                                        label: 'BHK',
                                        value: _bhk,
                                        items: List.generate(6, (i) => i + 1.0),
                                        displayItem: (val) => '${val.toInt()}',
                                        onChanged: (val) =>
                                            setState(() => _bhk = val!),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildDropdown<double>(
                                        label: 'BATHROOMS',
                                        value: _bathroom,
                                        items: List.generate(5, (i) => i + 1.0),
                                        displayItem: (val) => '${val.toInt()}',
                                        onChanged: (val) =>
                                            setState(() => _bathroom = val!),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _areaController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'AREA (SQFT)',
                              prefixIcon: Icon(
                                Icons.square_foot,
                                color: Colors.white,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.white,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    if (_result.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[900],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ESTIMATED PRICE',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _predict,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('CALCULATE PRICE'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? displayItem,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: _getIconForLabel(label),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            displayItem != null ? displayItem(item) : item.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Icon? _getIconForLabel(String label) {
    if (label == 'LOCATION')
      return const Icon(Icons.location_on_outlined, color: Colors.white);
    if (label == 'STATUS')
      return const Icon(Icons.info_outline, color: Colors.white);
    if (label == 'BHK')
      return const Icon(Icons.bedroom_parent_outlined, color: Colors.white);
    if (label == 'BATHROOMS')
      return const Icon(Icons.bathroom_outlined, color: Colors.white);
    return null;
  }
}

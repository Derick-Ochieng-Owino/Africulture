import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geocoding/geocoding.dart';

class TransportHirePage extends StatefulWidget {
  @override
  _TransportHirePageState createState() => _TransportHirePageState();
}

class _TransportHirePageState extends State<TransportHirePage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  DateTime? _pickupTime;
  String? _selectedVehicle;
  double? _distance;
  double? _price;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'type': 'pickup_truck',
      'name': 'Pickup Truck',
      'rate': 50.0,
      'image': 'assets/vehicles/pickup_truck.jpg'
    },
    {
      'type': 'tractor_trailer',
      'name': 'Tractor Trailer',
      'rate': 80.0,
      'image': 'assets/vehicles/tractor_trailer.jpg'
    },
    {
      'type': 'refrigerated_van',
      'name': 'Refrigerated Van',
      'rate': 70.0,
      'image': 'assets/vehicles/refrigerated_van.jpg'
    },
    {
      'type': 'motorcycle',
      'name': 'Motorcycle',
      'rate': 30.0,
      'image': 'assets/vehicles/motorcycle.jpg'
    },
  ];


  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _showLocationError('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _showLocationError('Location permissions denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _pickupLocation = LatLng(position.latitude, position.longitude);
      _pickupController.text = 'Current Location';
    });
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _listenForLocation(bool isPickup) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (!available) return;

      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            if (isPickup) {
              _pickupController.text = result.recognizedWords;
            } else {
              _destinationController.text = result.recognizedWords;
            }
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _resolveDestinationLocation() async {
    try {
      List<Location> locations = await locationFromAddress(_destinationController.text);
      if (locations.isNotEmpty) {
        _destinationLocation = LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      _showLocationError('Failed to find destination location');
    }
  }

  Future<void> _calculatePrice() async {
    if (_pickupLocation == null || _destinationController.text.isEmpty || _selectedVehicle == null) return;

    await _resolveDestinationLocation();

    if (_destinationLocation == null) return;

    double distanceInKm = await _calculateDistance();
    double rate = _vehicleTypes.firstWhere((v) => v['type'] == _selectedVehicle)['rate'];

    setState(() {
      _distance = distanceInKm;
      _price = rate * distanceInKm;
    });
  }

  Future<double> _calculateDistance() async {
    double latDiff = (_destinationLocation!.latitude - _pickupLocation!.latitude).abs();
    double lngDiff = (_destinationLocation!.longitude - _pickupLocation!.longitude).abs();
    return (latDiff + lngDiff) * 111;
  }

  Future<void> _selectPickupTime() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _pickupTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hire Transport'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLocationInput(
              controller: _pickupController,
              label: 'Pickup Location',
              isPickup: true,
            ),
            SizedBox(height: 16),
            _buildLocationInput(
              controller: _destinationController,
              label: 'Destination',
              isPickup: false,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _cargoController,
              decoration: InputDecoration(
                labelText: 'Cargo Description',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: () => _listenForCargo(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectPickupTime,
              child: Text(_pickupTime == null
                  ? 'Select Pickup Time'
                  : 'Pickup: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_pickupTime!)}'),
            ),
            SizedBox(height: 24),
            Text('Select Vehicle Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildVehicleTypeGrid(),
            SizedBox(height: 24),
            if (_distance != null)
              Text('Distance: ${_distance!.toStringAsFixed(2)} km', style: TextStyle(fontSize: 16)),
            if (_price != null)
              Text('Estimated Price: \$${_price!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitBooking,
              child: Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required String label,
    required bool isPickup,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: () => _listenForLocation(isPickup),
              ),
            ),
          ),
        ),
        if (isPickup) ...[
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ],
    );
  }

  Widget _buildVehicleTypeGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _vehicleTypes.map((vehicle) {
        return GestureDetector(
          onTap: () {
            setState(() => _selectedVehicle = vehicle['type']);
            _calculatePrice();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedVehicle == vehicle['type']
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Image.asset(
                    vehicle['image'],
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 4),
                Flexible(
                  child: Text(vehicle['name'], overflow: TextOverflow.ellipsis),
                ),
                Flexible(
                  child: Text('\$${vehicle['rate']}/km', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),

          ),
        );
      }).toList(),
    );
  }



  void _listenForCargo() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (!available) return;

      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _cargoController.text = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _submitBooking() {
    if (_pickupLocation == null ||
        _destinationLocation == null ||
        _selectedVehicle == null ||
        _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Confirmed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${_pickupController.text}'),
            Text('To: ${_destinationController.text}'),
            Text(
                'Vehicle: ${_vehicleTypes.firstWhere((v) => v['type'] == _selectedVehicle)['name']}'),
            Text('Price: \$${_price!.toStringAsFixed(2)}'),
            Text('Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_pickupTime!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Booking history screen
class BookingHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking History')),
      body: Center(child: Text('Your booking history will appear here')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(HotelReservationApp());
}

class HotelReservationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Reservation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 87, 238, 92)
      ),
      home: HotelReservationScreen(),
    );
  }
}

class HotelReservationScreen extends StatefulWidget {
  @override
  _HotelReservationScreenState createState() => _HotelReservationScreenState();
}

class _HotelReservationScreenState extends State<HotelReservationScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _roomType;
  bool _isLoading = false;
  DateTime? _confirmationTime;
  int _selectedItemIndex = -1; // State to track selected item

  final List<Receipt> _receipts = [];

  final Map<String, double> _roomPrices = {
    'Single': 100.0,
    'Double': 150.0,
    'Suite': 200.0,
    'Deluxe': 250.0,
  };

  final Map<String, String> _roomImages = {
    'Single': 'assets/images/single_room.jpg',
    'Double': 'assets/images/double_room.jpg',
    'Suite': 'assets/images/suite_room.jpeg',
    'Deluxe': 'assets/images/deluxe_room.jpg',
  };

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (_startDate ?? _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  double _calculateTotalPrice() {
    if (_startDate == null || _endDate == null || _roomType == null) {
      return 0.0;
    }
    final int days = _endDate!.difference(_startDate!).inDays;
    final double roomPrice = _roomPrices[_roomType!]!;
    return days * roomPrice;
  }

  void _confirmReservation() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _confirmationTime = DateTime.now();
      _receipts.add(Receipt(
        startDate: _startDate!,
        endDate: _endDate!,
        roomType: _roomType!,
        totalPrice: _calculateTotalPrice(),
        confirmationTime: _confirmationTime!,
      ));
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          startDate: _startDate!,
          endDate: _endDate!,
          roomType: _roomType!,
          totalPrice: _calculateTotalPrice(),
          confirmationTime: _confirmationTime!,
        ),
      ),
    );
  }

  void _viewReceipts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptsListScreen(
          receipts: _receipts,
          onDeleteReceipt: (Receipt receipt) {
            setState(() {
              _receipts.remove(receipt);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon.png', 
                width: 90, 
                height: 90, 
              ),
              Text(
                'Sunshine Hotel',
                textAlign: TextAlign.center,
                style: GoogleFonts.dancingScript(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
       ),
        backgroundColor: const Color.fromARGB(255, 87, 238, 92),
        centerTitle: true,
        // bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(4.0),
        //     child: Container(
        //       color: Colors.blue, // Cor da linha
        //       height: 2.0, // Altura da linha
        //     ),
        //   ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _startDate == null
                                  ? '📅  Data de Início'
                                  : '📅 ${_dateFormat.format(_startDate!)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _endDate == null
                                  ? '📅 Data de Saída'
                                  : '📅 ${_dateFormat.format(_endDate!)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Selecione o Tipo de Quarto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _roomPrices.keys.map((String key) {
                    final isSelected = _selectedItemIndex == _roomPrices.keys.toList().indexOf(key);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItemIndex = _roomPrices.keys.toList().indexOf(key);
                          _roomType = key;
                        });
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: isSelected ? 8 : 2,
                        color: isSelected ? Colors.blue : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: isSelected ? Colors.blue : Colors.grey),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: _roomImages.containsKey(key)
                                  ? Image.asset(
                                      _roomImages[key]!,
                                      fit: BoxFit.cover,
                                      color: Colors.black.withOpacity(0.5),
                                      colorBlendMode: BlendMode.darken,
                                    )
                                  : Container(color: Colors.grey),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    key,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue : Colors.white),
                                  ),
                                  Text(
                                    '\$${_roomPrices[key]}/night',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? Colors.blue : Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20.0),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: (_startDate == null ||
                                _endDate == null
                                                                || _roomType == null)
                            ? null
                            : _confirmReservation,
                        child: const Text('Confirmar'),
                      ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _viewReceipts,
                  child: const Text('Ver minhas reservas',),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String roomType;
  final double totalPrice;
  final DateTime confirmationTime;

  ReceiptScreen({
    required this.startDate,
    required this.endDate,
    required this.roomType,
    required this.totalPrice,
    required this.confirmationTime,
  });

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parabéns! Você fez uma reserva',
        style: TextStyle(
          fontSize: 20, // Ajuste o tamanho da fonte conforme necessário
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
       ),
       backgroundColor: const Color.fromARGB(255, 87, 238, 92),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Data de Início: ${_dateFormat.format(startDate)}'),
            Text('Data de Saída: ${_dateFormat.format(endDate)}'),
            Text('Tipo de Quarto: $roomType'),
            Text('Preço Total: \$${totalPrice.toStringAsFixed(2)}'),
            Text(
                'Hora da Confirmação: ${_timeFormat.format(confirmationTime)}'),
          ],
        ),
      ),
    );
  }
}

class ReceiptsListScreen extends StatelessWidget {
  final List<Receipt> receipts;
  final Function(Receipt) onDeleteReceipt;

  ReceiptsListScreen({required this.receipts, required this.onDeleteReceipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas',
        style: GoogleFonts.dancingScript(
          fontSize: 30, // Ajuste o tamanho da fonte conforme necessário
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
       ),
       backgroundColor: const Color.fromARGB(255, 87, 238, 92),
      ),
      body: ListView.builder(
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          return ListTile(
            title: Text(
                '${receipt.roomType} - ${receipt.startDate.toString().substring(0, 10)} to ${receipt.endDate.toString().substring(0, 10)}'),
            subtitle: Text('\$${receipt.totalPrice.toStringAsFixed(2)}'),
            // trailing: GestureDetector(
            //   onTap: () => onDeleteReceipt(receipt),
            //   child: Icon(Icons.delete, color: Colors.red),
            // ),
          );
        },
      ),
    );
  }
}

class Receipt {
  final DateTime startDate;
  final DateTime endDate;
  final String roomType;
  final double totalPrice;
  final DateTime confirmationTime;

  Receipt({
    required this.startDate,
    required this.endDate,
    required this.roomType,
    required this.totalPrice,
    required this.confirmationTime,
  });
}

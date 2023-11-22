import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/link.dart';
import 'roda_gigante.dart';
import 'cancela.dart';
import 'carrinho_pet.dart';
import 'desviando.dart';
import 'led_robo.dart';
import 'pega_pega.dart';
import 'roda_gigante2.dart';
import 'semaforo.dart';
import 'semaforo_rgb.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection connection;
  late List<BluetoothDevice> _devicesList;
  late BluetoothDevice device;
  List<Map<String, String>> inComingData = [];
  bool devicesLoad = false;
  bool get isConnected => connection.isConnected;
  String deviceMacAddress = "";

  Future<List<BluetoothDevice>> getPairedDevices() async {
    List<BluetoothDevice> getDevicesList = [];
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.bluetooth
      ].request();

      if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
          statuses[Permission.bluetoothScan] == PermissionStatus.granted) {
        // permission granted
      }
      getDevicesList = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    return getDevicesList;
  }

  void showSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        margin: const EdgeInsets.all(50),
        elevation: 1,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void searchDevices() async {
    _devicesList = await getPairedDevices();
    setState(() {
      _devicesList;
      devicesLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(
                height: 50,
              ),
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/banner.gif', height: 200),
                  Column(
                    children: [
                      const Text('Bem-vindo a Robótica fácil!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white)),
                      Link(
                        uri: Uri.parse('https://youtube.com'),
                        builder: (context, followLink) => ElevatedButton(
                          onPressed: followLink,
                          child: const Text(
                            '▶️',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ListTile(title: Text('PROJETOS')),
              ListTile(
                title: ElevatedButton(
                  child: const Text('CANCELA'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Cancela()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('CARRINHO PET'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarrinhoPet()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('DESVIANDO'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Desviando()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('PEGA-PEGA'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PegaPega()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('ROBÔ CICLOPE'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LedRobo()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('RODA GIDANTE 1'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RodaGigante()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('RODA GIDANTE 2'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RodaGigante2()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('SEMÁFORO'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Semaforo()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('SEMÁFORO RGB'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SemaforoRGB()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('VENTILADOR 1'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RodaGigante()),
                    );
                  },
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('VENTILADOR 2'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RodaGigante2()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

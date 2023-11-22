import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class SemaforoRGB extends StatefulWidget {
  const SemaforoRGB({Key? key}) : super(key: key);
  @override
  State<SemaforoRGB> createState() => _SemaforoRGBState();
}

class _SemaforoRGBState extends State<SemaforoRGB> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection connection;
  late List<BluetoothDevice> _devicesList;
  late BluetoothDevice device;
  List<Map<String, String>> inComingData = [];
  bool devicesLoad = false;
  bool get isConnected => connection.isConnected;
  String deviceMacAddress = "";
  String textFieldText = "";

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

  void disconnectDevice() {
    setState(() {
      deviceMacAddress = '';
      inComingData = [];
    });
    connection.close();
  }

  void connectDevice(String address) {
    BluetoothConnection.toAddress(address).then((conn) {
      connection = conn;
      setState(() {
        deviceMacAddress = address;
        devicesLoad = false;
      });
      //listenForData();
    });
  }

  void listenForData() {
    connection.input!.listen((Uint8List data) {
      String serialData = ascii.decode(data);
      serialData = serialData.substring(0, serialData.indexOf('.') + 2);
      showSnackBar('Recebendo dados');
      setState(() {
        inComingData.insert(0, {
          "time": DateFormat('hh:mm:ss:S').format(DateTime.now()),
          "data": serialData
        });
      });
      print('Data incoming: $serialData');
      connection.output.add(data);
      if (ascii.decode(data).contains('!')) {
        connection.finish();
        print('Disconnecting by local host');
      }
    }).onDone(() {
      print('Disconnected by remote request');
    });
  }

  void sendMessageBluetooth(String text) async {
    print('sending data');
    showSnackBar('Enviando dados');
    if (isConnected) {
      connection.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
      await connection.output.allSent;
    } else {
      disconnectDevice();
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      connection.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width * 0.9;

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
              SizedBox(
                  width: widthScreen,
                  child: ElevatedButton(
                      onPressed: () => searchDevices(),
                      child: const Text('Buscar dispositivos'))),
              if (devicesLoad && _devicesList.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
                  height: 200,
                  width: widthScreen,
                  child: ListView.builder(
                    physics: _devicesList.length < 3
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    itemCount: _devicesList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => deviceMacAddress !=
                                _devicesList[index].address.toString()
                            ? {
                                setState(() {
                                  device = _devicesList[index];
                                }),
                                connectDevice(
                                    _devicesList[index].address.toString())
                              }
                            : disconnectDevice(),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _devicesList[index].name.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: deviceMacAddress !=
                                          _devicesList[index].address.toString()
                                      ? Colors.blue
                                      : Colors.green),
                            ),
                            Text(_devicesList[index].address.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300))
                          ],
                        ),
                        subtitle: deviceMacAddress !=
                                _devicesList[index].address.toString()
                            ? const Text("Clique para conectar")
                            : const Text('Clique para desconectar'),
                      );
                    },
                  ),
                ),
              const Divider(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Componentes',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Portas',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text(
                      'LED RGB',
                    ),
                    Image.asset(
                      'assets/images/ledrgb.png',
                      height: 100,
                    ),
                  ]),
                  const Text('D3 10 11'),
                ],
              ),
              const Divider(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 0, 255, 0), // Background color
                      ),
                      child: const Text('Ligar'),
                      onPressed: () => deviceMacAddress.isNotEmpty
                          ? sendMessageBluetooth('s')
                          : showSnackBar('Primeiro conecte-se ao dispositivo'),
                    ),
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 255, 0, 0), // Background color
                      ),
                      child: const Text('Desligar'),
                      onPressed: () => deviceMacAddress.isNotEmpty
                          ? sendMessageBluetooth('E')
                          : showSnackBar('Primeiro conecte-se ao dispositivo'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

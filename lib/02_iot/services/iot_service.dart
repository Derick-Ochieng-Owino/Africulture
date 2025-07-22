import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IoTService {
  late MqttServerClient client;
  bool isConnected = false;

  Future<bool> connect() async {
    client = MqttServerClient('test.mosquitto.org', 'farmer_app_${DateTime.now().millisecondsSinceEpoch}');
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;

    client.onConnected = () {
      isConnected = true;
      print('✅ Connected');
    };
    client.onDisconnected = () {
      isConnected = false;
      print('❌ Disconnected');
    };
    client.onSubscribed = (String topic) {
      print('📌 Subscribed to $topic');
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('farmer_app_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .keepAliveFor(30)
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      print('🔌 Connecting to broker...');
      await client.connect();

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected');
        return true;
      } else {
        print('❌ Connection failed: ${client.connectionStatus}');
        disconnect();
        return false;
      }
    } catch (e) {
      print('❌ Exception during connection: $e');
      disconnect();
      return false;
    }
  }

  void disconnect() {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.disconnect();
    }
  }

  void controlDevice(String deviceId, String command) {
    if (!isConnected || client.connectionStatus!.state != MqttConnectionState.connected) {
      print('⚠️ Cannot send command. MQTT not connected.');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode({
      'device_id': deviceId,
      'command': command,
      'timestamp': DateTime.now().toIso8601String(),
    }));

    final topic = 'farms/$deviceId/control';
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 Command sent to $topic');
  }

  Stream<Map<String, dynamic>> getDeviceUpdates(String deviceId) {
    final topic = 'farms/$deviceId/status';

    if (!isConnected || client.connectionStatus!.state != MqttConnectionState.connected) {
      throw Exception('🚫 Not connected to MQTT broker');
    }

    client.subscribe(topic, MqttQos.atLeastOnce);

    return client.updates!.map((events) {
      final recMsg = events[0].payload as MqttPublishMessage;
      final msg = MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
      print('📩 Message received: $msg');
      return jsonDecode(msg);
    });
  }
}

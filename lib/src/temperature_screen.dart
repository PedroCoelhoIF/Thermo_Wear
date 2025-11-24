import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Tela que exibe a temperatura ambiente do sensor
class TemperatureScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TemperatureScreen({
    Key? key,
    this.onBack,
  }) : super(key: key);

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  static const platform = MethodChannel('thermo_wear/sensors');
  double? _temperature;
  bool _isLoading = true;
  String? _error;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _getTemperature();
    // Atualiza a temperatura a cada 3 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _getTemperature();
      }
    });
  }

  Future<void> _getTemperature() async {
    try {
      final dynamic result = await platform.invokeMethod('getAmbientTemperature');
      if (mounted) {
        setState(() {
          _temperature = (result as num).toDouble();
          _isLoading = false;
          _error = null;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
      if (mounted) {
        setState(() {
          _error = 'Sensor não disponível';
          _temperature = 22.5; // Temperatura de fallback
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao obter temperatura: $e');
      if (mounted) {
        setState(() {
          _error = 'Configure o sensor';
          _temperature = 22.5; // Temperatura de fallback
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thermostat,
                    size: 40,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Temperatura\nAmbiente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.orange)
                  else
                    Column(
                      children: [
                        Text(
                          '${_temperature?.toStringAsFixed(1) ?? '--'}°C',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (widget.onBack != null)
                    ElevatedButton(
                      onPressed: widget.onBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

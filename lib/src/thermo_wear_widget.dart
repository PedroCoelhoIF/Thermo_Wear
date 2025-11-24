import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import 'welcome_screen.dart';
import 'temperature_screen.dart';

/// Widget principal do ThermoWear que gerencia navegação por tilt gesture
class ThermoWearWidget extends StatefulWidget {
  /// Título exibido na tela de boas-vindas
  final String welcomeTitle;
  
  /// Mensagem exibida na tela de boas-vindas
  final String welcomeMessage;
  
  /// Limiar de mudança de aceleração para detectar o gesto (em m/s²)
  final double tiltThreshold;

  const ThermoWearWidget({
    Key? key,
    this.welcomeTitle = 'Bem-vindo!',
    this.welcomeMessage = 'Incline o relógio para ver a temperatura',
    this.tiltThreshold = 3.0,
  }) : super(key: key);

  @override
  State<ThermoWearWidget> createState() => _ThermoWearWidgetState();
}

class _ThermoWearWidgetState extends State<ThermoWearWidget> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _showTemperature = false;
  DateTime? _lastTiltTime;
  bool _isInitialized = false;
  
  // Armazena os valores anteriores do acelerômetro
  double _previousX = 0.0;
  double _previousY = 0.0;
  double _previousZ = 0.0;
  bool _hasInitialReading = false;
  int _stableReadings = 0;

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  Future<void> _initializeSensors() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _startListeningToAccelerometer();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar sensores: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _startListeningToAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 200),
      ).listen(
        (AccelerometerEvent event) {
          // Aguarda algumas leituras estáveis antes de começar a detectar
          if (!_hasInitialReading) {
            _stableReadings++;
            if (_stableReadings > 5) {
              _hasInitialReading = true;
              _previousX = event.x;
              _previousY = event.y;
              _previousZ = event.z;
              debugPrint('✅ Calibração inicial completa');
              debugPrint('Posição base - X: ${event.x.toStringAsFixed(2)}, '
                  'Y: ${event.y.toStringAsFixed(2)}, '
                  'Z: ${event.z.toStringAsFixed(2)}');
            }
            return;
          }
          
          // Calcula a diferença em relação à leitura anterior
          final deltaX = (event.x - _previousX).abs();
          final deltaY = (event.y - _previousY).abs();
          final deltaZ = (event.z - _previousZ).abs();
          
          // Calcula a magnitude total da mudança
          final deltaMagnitude = math.sqrt(
            deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
          );
          
          // Debug apenas quando há mudança significativa
          if (deltaMagnitude > 1.0) {
            debugPrint('📊 Mudança detectada - ΔX: ${deltaX.toStringAsFixed(2)}, '
                'ΔY: ${deltaY.toStringAsFixed(2)}, '
                'ΔZ: ${deltaZ.toStringAsFixed(2)}, '
                'Total: ${deltaMagnitude.toStringAsFixed(2)}');
          }
          
          // Detecta inclinação significativa baseada na MUDANÇA
          if (deltaMagnitude > widget.tiltThreshold) {
            final now = DateTime.now();
            
            // Evita múltiplas detecções em sequência rápida
            if (_lastTiltTime == null || 
                now.difference(_lastTiltTime!) > const Duration(seconds: 2)) {
              _lastTiltTime = now;
              
              debugPrint('🎯 TILT DETECTADO! Magnitude da mudança: ${deltaMagnitude.toStringAsFixed(2)}');
              
              if (!_showTemperature && mounted) {
                setState(() {
                  _showTemperature = true;
                });
              }
            }
          }
          
          // Atualiza os valores anteriores
          _previousX = event.x;
          _previousY = event.y;
          _previousZ = event.z;
        },
        onError: (error) {
          debugPrint('❌ Erro no acelerômetro: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ Erro ao iniciar listener do acelerômetro: $e');
    }
  }

  void _goBackToWelcome() {
    if (mounted) {
      setState(() {
        _showTemperature = false;
        // Reset da detecção ao voltar
        _hasInitialReading = false;
        _stableReadings = 0;
      });
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: _showTemperature
          ? TemperatureScreen(
              key: const ValueKey('temperature'),
              onBack: _goBackToWelcome,
            )
          : WelcomeScreen(
              key: const ValueKey('welcome'),
              title: widget.welcomeTitle,
              message: widget.welcomeMessage,
            ),
    );
  }
}
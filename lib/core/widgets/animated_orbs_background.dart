import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ---------------------------------------------------------------------------
// Message types passed between UI isolate and physics isolate
// ---------------------------------------------------------------------------

class _InitMsg {
  const _InitMsg({
    required this.sendPort,
    required this.width,
    required this.height,
    required this.count,
    required this.seed,
  });
  final SendPort sendPort;
  final double width;
  final double height;
  final int count;
  final int seed;
}

class _TouchMsg {
  const _TouchMsg(this.x, this.y);
  final double x;
  final double? y;
}

class _ClearTouchMsg {
  const _ClearTouchMsg();
}

class _ResizeMsg {
  const _ResizeMsg(this.width, this.height);
  final double width, height;
}

// Each orb: [x, y, r, phase]  (4 doubles per orb)
// Sent as Float64List for zero-copy transfer

// ---------------------------------------------------------------------------
// Physics — runs entirely inside its own isolate
// ---------------------------------------------------------------------------

void _physicsEntryPoint(SendPort uiPort) {
  final recv = ReceivePort();
  uiPort.send(recv.sendPort);

  double w = 0, h = 0;
  double? touchX, touchY;
  int n = 0;
  late List<double> x, y, vx, vy, r, phase;
  bool ready = false;
  int lastMicros = DateTime.now().microsecondsSinceEpoch;

  void step() {
    if (!ready) return;
    final now = DateTime.now().microsecondsSinceEpoch;
    final dt = ((now - lastMicros) / 1e6).clamp(0.0, 0.05);
    lastMicros = now;

    for (int i = 0; i < n; i++) {
      if (touchX != null && touchY != null) {
        final dx = x[i] - touchX!;
        final dy = y[i] - touchY!;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < 140 && d > 0.5) {
          final f = 4.0 * (1 - d / 140) * dt * 60;
          vx[i] += dx / d * f;
          vy[i] += dy / d * f;
        }
      }
      vx[i] *= 0.988;
      vy[i] *= 0.988;
      final spd = math.sqrt(vx[i] * vx[i] + vy[i] * vy[i]);
      if (spd > 3.0) {
        vx[i] = vx[i] / spd * 3;
        vy[i] = vy[i] / spd * 3;
      }
      if (spd < 0.3 && spd > 0.001) {
        vx[i] = vx[i] / spd * 0.3;
        vy[i] = vy[i] / spd * 0.3;
      }
      x[i] += vx[i] * dt * 60;
      y[i] += vy[i] * dt * 60;
      if (x[i] - r[i] < 0) {
        x[i] = r[i];
        vx[i] = vx[i].abs();
      } else if (x[i] + r[i] > w) {
        x[i] = w - r[i];
        vx[i] = -vx[i].abs();
      }
      if (y[i] - r[i] < 0) {
        y[i] = r[i];
        vy[i] = vy[i].abs();
      } else if (y[i] + r[i] > h) {
        y[i] = h - r[i];
        vy[i] = -vy[i].abs();
      }
    }

    // Pack result: [x0, y0, r0, phase0, x1, y1, r1, phase1, ...]
    final out = List<double>.filled(n * 4, 0);
    for (int i = 0; i < n; i++) {
      out[i * 4] = x[i];
      out[i * 4 + 1] = y[i];
      out[i * 4 + 2] = r[i];
      out[i * 4 + 3] = phase[i];
    }
    uiPort.send(out);
  }

  recv.listen((msg) {
    if (msg is _InitMsg) {
      w = msg.width;
      h = msg.height;
      n = msg.count;
      final rng = math.Random(msg.seed);
      x = List.generate(n, (_) => rng.nextDouble() * w);
      y = List.generate(n, (_) => rng.nextDouble() * h);
      r = List.generate(n, (_) => 50 + rng.nextDouble() * 55);
      phase = List.generate(n, (_) => rng.nextDouble() * 2 * math.pi);
      vx = List<double>.filled(n, 0);
      vy = List<double>.filled(n, 0);
      for (int i = 0; i < n; i++) {
        final angle = rng.nextDouble() * 2 * math.pi;
        vx[i] = math.cos(angle) * 0.7;
        vy[i] = math.sin(angle) * 0.7;
      }
      ready = true;
      lastMicros = DateTime.now().microsecondsSinceEpoch;
      step();
    } else if (msg is _TouchMsg) {
      touchX = msg.x;
      touchY = msg.y;
    } else if (msg is _ClearTouchMsg) {
      touchX = null;
      touchY = null;
    } else if (msg is _ResizeMsg) {
      w = msg.width;
      h = msg.height;
    } else if (msg == 'tick') {
      step();
    }
  });
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class OrbsWidget extends StatefulWidget {
  const OrbsWidget({super.key});

  @override
  State<OrbsWidget> createState() => _OrbsWidgetState();
}

class _OrbsWidgetState extends State<OrbsWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Isolate? _isolate;
  SendPort? _toPhysics;
  List<double> _data = [];
  Size _size = Size.zero;
  bool _initialized = false;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _startIsolate();
  }

  Future<void> _startIsolate() async {
    final fromPhysics = ReceivePort();
    _isolate = await Isolate.spawn(_physicsEntryPoint, fromPhysics.sendPort);
    fromPhysics.listen(_onMessage);
  }

  void _onMessage(dynamic msg) {
    if (msg is SendPort) {
      _toPhysics = msg;
      if (!_size.isEmpty) _sendInit();
    } else if (msg is List<double>) {
      if (mounted) setState(() => _data = msg);
    }
  }

  void _sendInit() {
    _toPhysics?.send(
      _InitMsg(
        sendPort: _toPhysics!,
        width: _size.width,
        height: _size.height,
        count: 7,
        seed: 77,
      ),
    );
    _initialized = true;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    _t = elapsed.inMicroseconds / 1e6;
    if (_initialized && _toPhysics != null) {
      _toPhysics!.send('tick');
    }
  }

  void _onTouch(Offset pos) => _toPhysics?.send(_TouchMsg(pos.dx, pos.dy));

  void _onClearTouch() => _toPhysics?.send(const _ClearTouchMsg());

  @override
  void dispose() {
    _ticker.dispose();
    _isolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _onTouch(e.localPosition),
      onPointerMove: (e) => _onTouch(e.localPosition),
      onPointerUp: (_) => _onClearTouch(),
      onPointerCancel: (_) => _onClearTouch(),
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (size != _size &&
                !size.isEmpty &&
                size.width.isFinite &&
                size.height.isFinite) {
              _size = size;
              if (_toPhysics != null && !_initialized) {
                _sendInit();
              } else if (_initialized) {
                _toPhysics?.send(_ResizeMsg(size.width, size.height));
              }
            }
            return CustomPaint(
              painter: _OrbsPainter(data: _data, t: _t),
              size: size,
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter — UI thread only
// ---------------------------------------------------------------------------

class _OrbsPainter extends CustomPainter {
  const _OrbsPainter({required this.data, required this.t});
  final List<double> data;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final n = data.length ~/ 4;
    for (int i = 0; i < n; i++) {
      final ox = data[i * 4];
      final oy = data[i * 4 + 1];
      final or_ = data[i * 4 + 2];
      final ph = data[i * 4 + 3];
      final pulse = 0.82 + 0.18 * math.sin(t * 1.5 + ph);
      final r = or_ * pulse;
      final center = Offset(ox, oy);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x1A000000), Color(0x00000000)],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbsPainter old) => data != old.data || t != old.t;
}

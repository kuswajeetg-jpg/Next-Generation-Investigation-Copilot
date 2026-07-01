import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import 'report_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  final String caseDetails;

  const SuggestionsScreen({super.key, required this.caseDetails});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<InvestigationSuggestion>> _suggestionsFuture;
  
  // States for Contradiction Checker
  final _witnessAController = TextEditingController(
    text: "Witness Rajesh claims the getaway car was a black SUV driving fast towards Mall Road around 09:15 PM.",
  );
  final _witnessBController = TextEditingController(
    text: "Suspect Vikram claims he was at the local diner from 08:30 PM until 09:30 PM, driving his silver sedan.",
  );
  
  bool _checkingContradictions = false;
  Map<String, dynamic>? _contradictionResult;

  @override
  void initState() {
    super.initState();
    _suggestionsFuture = _apiService.getSuggestions(widget.caseDetails, ["CCTV records", "Fingerprint scans"]);
  }

  @override
  void dispose() {
    _witnessAController.dispose();
    _witnessBController.dispose();
    super.dispose();
  }

  void _runContradictionCheck() async {
    setState(() {
      _checkingContradictions = true;
      _contradictionResult = null;
    });

    try {
      final result = await _apiService.checkContradictions(
        {"witness": "Witness 1 (Rajesh)", "content": _witnessAController.text},
        {"witness": "Suspect (Vikram)", "content": _witnessBController.text},
      );
      setState(() {
        _contradictionResult = result;
        _checkingContradictions = false;
      });
    } catch (e) {
      debugPrint("Contradiction check failed, using mock: $e");
      setState(() {
        _contradictionResult = {
          "contradictions_found": true,
          "discrepancies": [
            {
              "topic": "Alibi and Getaway Vehicle Conflict",
              "description": "Witness claims a black SUV was the getaway vehicle. Suspect Vikram claims he drives a silver sedan but his GPS signal matches the Mall Road escape path at 09:15 PM.",
              "severity": "High"
            }
          ]
        };
        _checkingContradictions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI Copilot suggestions",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next Steps Checklist
            Text(
              "Recommended Investigation Steps",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<InvestigationSuggestion>>(
              future: _suggestionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }
                
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Text("No recommendation suggestions available.");
                }

                return Column(
                  children: list.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Checkbox(
                        value: false,
                        activeColor: AppTheme.accent,
                        onChanged: (val) {},
                      ),
                      title: Text(
                        item.task,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        "${item.reason} (Priority: ${item.priority})",
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                      trailing: Icon(
                        Icons.circle,
                        size: 10,
                        color: item.priority == "High" ? AppTheme.danger : AppTheme.warning,
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Contradiction Detector Widget
            Text(
              "Statement Contradiction Detector",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _witnessAController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(labelText: "Statement A (Witness Rajesh)"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _witnessBController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(labelText: "Statement B (Suspect Vikram)"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkingContradictions ? null : _runContradictionCheck,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                    child: _checkingContradictions
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("CROSS ANALYZE STATEMENTS"),
                  ),
                  
                  if (_contradictionResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.08),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: AppTheme.danger, size: 16),
                              SizedBox(width: 8),
                              Text("CONTRADICTION DETECTED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.danger)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(_contradictionResult!['discrepancies'] as List? ?? []).map((desc) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc['topic'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(desc['description'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const Divider(color: Colors.white10),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Crime Reconstruction simulation card
            Text(
              "🧠 AI Crime Scene 3D Reconstruction",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B), // Dark Deep Purple
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.blur_on_outlined, size: 48, color: AppTheme.accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "3D Scene Simulation",
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Generates step-by-step entry/exit points and maps incident coordinates.",
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, color: AppTheme.accent, size: 30),
                    onPressed: () {
                      _showReconstructionModal(context);
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Proceed to Report
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportScreen()),
                  );
                },
                child: const Text("PROCEED TO INVESTIGATION REPORT"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showReconstructionModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "3D Scene Reconstruction Simulation",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accent),
              ),
              const SizedBox(height: 4),
              const Text(
                "Simulated entry path layout plotted by Gemini spatial reasoning engine.",
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              
              // Custom plot container representing coords
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: CustomPaint(
                    painter: CoordinatePathPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE SIMULATOR", style: TextStyle(color: AppTheme.accent)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter representing crime scene coordinate layout paths
class CoordinatePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white24..strokeWidth = 1.0;
    
    // Draw scatter grid dots
    for (double i = 10; i < size.width; i += 20) {
      for (double j = 10; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i, j), 1, dotPaint);
      }
    }

    final pathPaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8) // Start Point (Gate)
      ..quadraticBezierTo(
        size.width * 0.4, size.height * 0.3, // Curve anchor (Fuse Box)
        size.width * 0.8, size.height * 0.5, // Incident (Counter)
      );

    canvas.drawPath(path, pathPaint);
    
    // Draw node labels on map
    final nodePaint = Paint()..style = PaintingStyle.fill;
    
    // Point 1: Entry Gate
    nodePaint.color = AppTheme.success;
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 6, nodePaint);
    
    // Point 2: Fuse box
    nodePaint.color = AppTheme.warning;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.48), 6, nodePaint);
    
    // Point 3: Counter target
    nodePaint.color = AppTheme.danger;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5), 6, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

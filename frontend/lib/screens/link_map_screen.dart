import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import 'suggestions_screen.dart';

class LinkMapScreen extends StatefulWidget {
  final String caseDetails;

  const LinkMapScreen({super.key, required this.caseDetails});

  @override
  State<LinkMapScreen> createState() => _LinkMapScreenState();
}

class _LinkMapScreenState extends State<LinkMapScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _linkMapFuture;

  @override
  void initState() {
    super.initState();
    _linkMapFuture = _apiService.getEvidenceLinkMap(widget.caseDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Evidence Link Map",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _linkMapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }

          final nodes = snapshot.data?['nodes'] as List<LinkMapNode>? ?? [];
          final edges = snapshot.data?['edges'] as List<LinkMapEdge>? ?? [];

          if (nodes.isEmpty) {
            return const Center(child: Text("No linked entities identified."));
          }

          return Column(
            children: [
              // Graph Canvas representation
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Graph Background Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GraphPatternPainter(),
                          ),
                        ),
                        
                        // Interactive Graph representation
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GraphElementsPainter(nodes: nodes, edges: edges),
                          ),
                        ),
                        
                        // Overlay Hint
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.share, size: 12, color: AppTheme.accent),
                                SizedBox(width: 6),
                                Text(
                                  "AI Connected Graph (USP)",
                                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Detail List view of entities
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: edges.length,
                  itemBuilder: (context, index) {
                    final edge = edges[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: AppTheme.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary),
                                  children: [
                                    TextSpan(
                                      text: "${edge.from.toUpperCase()} ",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
                                    ),
                                    TextSpan(
                                      text: "➔ (${edge.relation}) ➔ ",
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    TextSpan(
                                      text: edge.to.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Primary suggest button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestionsScreen(caseDetails: widget.caseDetails),
                        ),
                      );
                    },
                    child: const Text("GENERATE AI RECOMMENDATIONS"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GraphPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.15)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GraphElementsPainter extends CustomPainter {
  final List<LinkMapNode> nodes;
  final List<LinkMapEdge> edges;

  GraphElementsPainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final random = Random(42); // Lock seed to prevent shifting layouts on render
    final Map<String, Offset> nodePositions = {};
    
    // Position nodes in a circular or layout distribution
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(size.width, size.height) * 0.35;

    for (int i = 0; i < nodes.length; i++) {
      final double angle = (2 * pi / nodes.length) * i;
      // Stagger center node for the primary victim
      if (nodes[i].type == 'victim') {
        nodePositions[nodes[i].id] = Offset(centerX, centerY);
      } else {
        nodePositions[nodes[i].id] = Offset(
          centerX + radius * cos(angle),
          centerY + radius * sin(angle),
        );
      }
    }

    // Paint Edges first
    final edgePaint = Paint()
      ..color = AppTheme.accent.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final edge in edges) {
      final start = nodePositions[edge.from];
      final end = nodePositions[edge.to];

      if (start != null && end != null) {
        canvas.drawLine(start, end, edgePaint);
        
        // Draw small arrow indicator in middle of connection line
        final midX = (start.dx + end.dx) / 2;
        final midY = (start.dy + end.dy) / 2;
        
        canvas.drawCircle(Offset(midX, midY), 3, Paint()..color = AppTheme.accent);
      }
    }

    // Paint Nodes
    for (final node in nodes) {
      final pos = nodePositions[node.id];
      if (pos != null) {
        Color nodeColor = AppTheme.primary;
        IconData nodeIcon = Icons.bubble_chart;

        switch (node.type.toLowerCase()) {
          case 'victim':
            nodeColor = AppTheme.success;
            nodeIcon = Icons.person;
            break;
          case 'suspect':
            nodeColor = AppTheme.danger;
            nodeIcon = Icons.gavel;
            break;
          case 'phone':
            nodeColor = AppTheme.accent;
            nodeIcon = Icons.phone_android;
            break;
          case 'vehicle':
            nodeColor = Colors.orange;
            nodeIcon = Icons.directions_car;
            break;
          case 'cctv':
            nodeColor = Colors.purple;
            nodeIcon = Icons.videocam;
            break;
        }

        // Draw outer glowing circle
        final glowPaint = Paint()
          ..color = nodeColor.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 28, glowPaint);

        // Draw inner circle
        final innerPaint = Paint()
          ..color = nodeColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 20, innerPaint);

        // Draw label
        textPainter.text = TextSpan(
          text: node.label.split(" ").first,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            backgroundColor: Colors.black54,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + 30));
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphElementsPainter oldDelegate) => false;
}

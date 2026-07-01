import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import 'link_map_screen.dart';

class TimelineScreen extends StatefulWidget {
  final String caseText;

  const TimelineScreen({super.key, required this.caseText});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TimelineEvent>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _timelineFuture = _apiService.getTimeline(widget.caseText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Case Timeline",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<TimelineEvent>>(
              future: _timelineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }
                
                final events = snapshot.data ?? [];
                
                if (events.isEmpty) {
                  return const Center(child: Text("No events extracted for this case."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final isLast = index == events.length - 1;
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline line and bullet
                        Column(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.background, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accent.withOpacity(0.4),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 80,
                                color: const Color(0xFF334155),
                              ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        
                        // Event Details Card
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time indicator
                              Row(
                                children: [
                                  Text(
                                    event.time,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      event.source,
                                      style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              
                              Text(
                                event.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              
                              Text(
                                event.description,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          
          // Proceed to Link Map button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LinkMapScreen(caseDetails: widget.caseText),
                    ),
                  );
                },
                child: const Text("VIEW EVIDENCE LINK MAP"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

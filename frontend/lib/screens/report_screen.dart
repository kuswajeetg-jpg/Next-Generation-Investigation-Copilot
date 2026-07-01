import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  void _exportPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            "PDF Export Successful",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            "Case report 'FIR-2026-891_AI_Summary.pdf' compiled and saved to device downloads folder.",
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: AppTheme.accent)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI Investigation Report",
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
            // Case Title Card header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CASE STUDY: BURGLARY AT MEHTA JEWELLERS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "FIR Reference: FIR-2026-891  |  Officer: Insp. A. Hasan",
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStatus(Icons.gavel, "Suspects: 2"),
                      _buildMiniStatus(Icons.link, "Nodes: 5"),
                      _buildMiniStatus(Icons.assignment_turned_in, "Tasks: 4/5"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Case Summary Section
            Text(
              "Executive Summary",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent),
            ),
            const SizedBox(height: 8),
            const Text(
              "On July 1st, 2026, at 09:00 PM, an intruder broke into Mehta Jewellers rear storage gate. "
              "The AI system parsed testimonies and pointed out contradictions in Vikram Malhotra's alibi, "
              "connecting his registered vehicle to CCTV captures outside the jewelers shop.",
              style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 24),

            // Timeline summary
            Text(
              "Event Timeline Overview",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent),
            ),
            const SizedBox(height: 12),
            _buildReportTimelineRow("08:30 PM", "Victim Left Home", "Sanjay Mehta left residence."),
            _buildReportTimelineRow("08:45 PM", "CCTV Detection", "Rear security camera records shadow."),
            _buildReportTimelineRow("09:00 PM", "Phone Switched Off", "Sanjay's phone drops cellular signal."),
            _buildReportTimelineRow("09:15 PM", "Silent Alarm Trigger", "Silent sensor alarms triggered at counter."),
            const SizedBox(height: 24),

            // Evidence list
            Text(
              "Evidence catalog index",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent),
            ),
            const SizedBox(height: 12),
            _buildEvidenceRow("PDF Report", "FIR_MehtaJewellers_2026.pdf", "Original police report."),
            _buildEvidenceRow("Audio Clip", "witness_audio_clash.wav", "Recorded statement Rajesh."),
            _buildEvidenceRow("Image JPEG", "cctv_shutter_leak.jpg", "Rear gate footage snapshot."),
            _buildEvidenceRow("Mobile Log", "telecom_cell_dump.csv", "Tower signal dump spreadsheet."),
            
            const SizedBox(height: 48),

            // Export to PDF button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _exportPdf(context),
                label: const Text("EXPORT COMPLETE PDF REPORT"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatus(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildReportTimelineRow(String time, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                Text(desc, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEvidenceRow(String type, String name, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          const Icon(Icons.folder_open, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                Text("$type - $details", style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

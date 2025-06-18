import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../data/answer_options.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';

class TestScreen extends StatefulWidget {
  final int page;
  const TestScreen({Key? key, required this.page}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const int perPage = 6;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TestProvider>();
    final questions = prov.pageQuestions(widget.page, perPage);
    final totalPages = (prov.total / perPage).ceil();
    final isLast = widget.page == totalPages;

    final progressPercent = (prov.answered / prov.total * 100).round();

    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('$progressPercent% tamamlandı • ${prov.total - prov.answered} soru kaldı'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progressPercent / 100),
          const SizedBox(height: 16),
          for (var q in questions) _buildQuestionCard(prov, q['id']!, q['question']!),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: prov.pageQuestions(widget.page, perPage).every((q) => prov.answers.containsKey(q['id']))
                ? () async {
                    if (isLast) {
                      final ok = await prov.submit();
                      if (ok && mounted) Navigator.pushReplacementNamed(context, '/test-success');
                    } else {
                      Navigator.pushReplacementNamed(context, '/test/${widget.page + 1}');
                    }
                  }
                : null,
            child: Text(isLast ? 'TESTİ BİTİR' : 'SONRAKİ'),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestProvider prov, String qId, String question) {
    return Card(
      color: const Color(0xFF4A4B4E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: answerOptions.map((opt) {
                final selected = prov.answers[qId] == opt.id;
                return GestureDetector(
                  onTap: () => prov.setAnswer(qId, opt.id),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(opt.color),
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(opt.point.toString(), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 
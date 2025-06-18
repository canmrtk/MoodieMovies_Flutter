import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../data/answer_options.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_drawer.dart';
import '../utils/notifications.dart';

class TestScreen extends StatefulWidget {
  final int page;
  const TestScreen({Key? key, required this.page}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const int perPage = 6;
  late final List<Map<String, String>> _questionsForPage;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _questionsForPage =
        context.read<TestProvider>().pageQuestions(widget.page, perPage);
  }

  Future<void> _onNext() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    final prov = context.read<TestProvider>();
    final totalPages = (prov.total / perPage).ceil();
    final isLastPage = widget.page == totalPages;

    if (isLastPage) {
      if (prov.answered < prov.total) {
        showError(context, "Lütfen tüm soruları yanıtlayın. Eksik sayfaları kontrol edebilirsiniz.");
        setState(() => _isNavigating = false);
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await prov.submit();
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) Navigator.pushReplacementNamed(context, '/test-success');
      } else {
        if (mounted) showError(context, prov.error ?? 'Test sonuçları gönderilemedi.');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/test/${widget.page + 1}');
    }

    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TestProvider>();
    final totalPages = (prov.total / perPage).ceil();
    final progressPercent = (prov.answered / prov.total * 100).clamp(0, 100).round();
    final allQuestionsOnPageAnswered =
        _questionsForPage.every((q) => prov.answers.containsKey(q['id']));

    return Scaffold(
      appBar: const AppNavbar(),
      endDrawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$progressPercent% tamamlandı',
                    style: const TextStyle(color: Colors.white70)),
                Text('${prov.total - prov.answered} soru kaldı',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercent / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 24),
          const Center(
              child: Text('Her ifadenin sizi ne kadar doğru yansıttığını seçin.',
                  style: TextStyle(fontSize: 16))),
          const SizedBox(height: 24),
          ..._questionsForPage
              .map((q) => _buildQuestionCard(prov, q['id']!, q['question']!)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                prov.submitting || !allQuestionsOnPageAnswered || _isNavigating ? null : _onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
            ),
            child: prov.submitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ))
                : Text(widget.page == totalPages ? 'TESTİ BİTİR' : 'SONRAKİ SAYFA'),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestProvider prov, String qId, String question) {
    return Card(
      color: const Color(0xFF2D3237),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(question,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: answerOptions.map((opt) {
                final selected = prov.answers[qId] == opt.id;
                return GestureDetector(
                  onTap: () => prov.setAnswer(qId, opt.id),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 44 : 40,
                        height: selected ? 44 : 40,
                        decoration: BoxDecoration(
                          color: Color(opt.color),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: selected ? Colors.white : Colors.transparent,
                              width: 3),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: 80,
                          child: Text(opt.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11))),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/gemini_service.dart';

void main() {
  runApp(const PromptPilotApp());
}

class PromptPilotApp extends StatelessWidget {
  const PromptPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptPilot',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ======================================================
// HOME SCREEN
// ======================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController promptController =
      TextEditingController();

  bool isGenerating = false;

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Future<void> generatePrompt() async {
    final idea = promptController.text.trim();

    if (idea.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an idea first!'),
        ),
      );
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      final generatedPrompt =
          await GeminiService.generatePrompt(idea);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPromptScreen(
            idea: idea,
            generatedPrompt: generatedPrompt,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // ==================================================
              // LOGO
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF2563EB),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PromptPilot',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ==================================================
              // HEADING
              // ==================================================

              const Text(
                'Turn Ideas Into\nPowerful Prompts.',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Your idea in. The perfect prompt out.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // INPUT
              // ==================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151F),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: TextField(
                  controller: promptController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'What do you want AI to do?',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GENERATE BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: isGenerating
                      ? null
                      : generatePrompt,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome,
                        ),
                  label: Text(
                    isGenerating
                        ? 'Generating...'
                        : 'Generate Prompt',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6D28D9),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF4C1D95),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Try an example',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // EXAMPLES
              // ==================================================

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ExampleChip(
                    text: 'Build a Python app',
                    onTap: () {
                      promptController.text =
                          'Build a Python app';
                    },
                  ),
                  _ExampleChip(
                    text: 'Study for exams',
                    onTap: () {
                      promptController.text =
                          'Help me create a study plan for exams';
                    },
                  ),
                  _ExampleChip(
                    text: 'Create a business plan',
                    onTap: () {
                      promptController.text =
                          'Create a business plan for a startup';
                    },
                  ),
                ],
              ),

              const Spacer(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// GENERATED PROMPT SCREEN
// ======================================================

class GeneratedPromptScreen extends StatefulWidget {
  final String idea;
  final String generatedPrompt;

  const GeneratedPromptScreen({
    super.key,
    required this.idea,
    required this.generatedPrompt,
  });

  @override
  State<GeneratedPromptScreen> createState() =>
      _GeneratedPromptScreenState();
}

class _GeneratedPromptScreenState
    extends State<GeneratedPromptScreen> {
  late String generatedPrompt;

  bool isImproving = false;

  @override
  void initState() {
    super.initState();

    generatedPrompt = widget.generatedPrompt;
  }

  // ==================================================
  // IMPROVE PROMPT
  // ==================================================

  Future<void> improvePrompt() async {
    setState(() {
      isImproving = true;
    });

    try {
      final improvedPrompt =
          await GeminiService.improvePrompt(
        generatedPrompt,
      );

      if (!mounted) return;

      setState(() {
        generatedPrompt = improvedPrompt;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prompt improved successfully! 🚀',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to improve prompt: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isImproving = false;
        });
      }
    }
  }

  // ==================================================
  // COPY PROMPT
  // ==================================================

  Future<void> copyPrompt() async {
    await Clipboard.setData(
      ClipboardData(
        text: generatedPrompt,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Prompt copied successfully! 🚀',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generated Prompt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ORIGINAL IDEA
            // ==================================================

            const Text(
              'Your idea',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.idea,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PROMPT TITLE
            // ==================================================

            const Text(
              '✨ Your Powerful Prompt',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // GENERATED PROMPT
            // ==================================================

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151F),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    generatedPrompt,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // IMPROVE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed:
                    isImproving ? null : improvePrompt,
                icon: isImproving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                      ),
                label: Text(
                  isImproving
                      ? 'Improving...'
                      : 'Improve Prompt',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF6D28D9),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // COPY BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: copyPrompt,
                icon: const Icon(Icons.copy),
                label: const Text(
                  'Copy Prompt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// EXAMPLE CHIP
// ======================================================

class _ExampleChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F),
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
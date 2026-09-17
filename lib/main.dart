import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void openLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LibraryScreen(),
      ),
    );
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

              // ==================================================
              // MY LIBRARY BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: openLibrary,
                  icon: const Icon(
                    Icons.library_books_outlined,
                  ),
                  label: const Text(
                    'My Library',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF6D28D9),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

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
  // COPY PROMPT + OPEN AI SELECTION
  // ==================================================

  Future<void> copyPrompt() async {
    await Clipboard.setData(
      ClipboardData(
        text: generatedPrompt,
      ),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AISelectionScreen(
          prompt: generatedPrompt,
        ),
      ),
    );
  }

  // ==================================================
  // SAVE PROMPT
  // ==================================================

  Future<void> savePrompt() async {
    final prefs = await SharedPreferences.getInstance();

    final existingHistory =
        prefs.getStringList('prompt_history') ?? [];

    final promptData = jsonEncode({
      'idea': widget.idea,
      'prompt': generatedPrompt,
      'savedAt': DateTime.now().toIso8601String(),
    });

    existingHistory.insert(0, promptData);

    await prefs.setStringList(
      'prompt_history',
      existingHistory,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Prompt saved to Library! 💾',
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Generated Prompt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            4,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // YOUR IDEA
              // ==================================================

              const Text(
                'Your idea',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF15151F),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: Text(
                  widget.idea,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // POWERFUL PROMPT TITLE
              // ==================================================

              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color:
                        Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Your Powerful Prompt',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==================================================
              // PROMPT CARD
              // ==================================================

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF15151F),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          const Color(0xFF6D28D9),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color(0x336D28D9),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child:
                      SingleChildScrollView(
                    child: SelectableText(
                      generatedPrompt,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color:
                            Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // IMPROVE + COPY
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: isImproving
                          ? null
                          : improvePrompt,
                      icon: isImproving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.auto_awesome,
                              size: 18,
                            ),
                      label: Text(
                        isImproving
                            ? 'Improving...'
                            : 'Improve',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.white,
                        side:
                            const BorderSide(
                          color:
                              Color(0xFF6D28D9),
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed: copyPrompt,
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                      ),
                      label: const Text(
                        'Copy',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF6D28D9,
                        ),
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ==================================================
              // SAVE
              // ==================================================

              SizedBox(
                width: double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed: savePrompt,
                  icon: const Icon(
                    Icons.bookmark_border,
                    size: 19,
                  ),
                  label: const Text(
                    'Save to Library',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Colors.white,
                    side:
                        const BorderSide(
                      color: Colors.white24,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// AI SELECTION SCREEN
// ======================================================

class AISelectionScreen extends StatefulWidget {
  final String prompt;

  const AISelectionScreen({
    super.key,
    required this.prompt,
  });

  @override
  State<AISelectionScreen> createState() =>
      _AISelectionScreenState();
}

class _AISelectionScreenState
    extends State<AISelectionScreen> {
  String selectedAI = 'ChatGPT';

  // ==================================================
  // OPEN SELECTED AI
  // ==================================================

  Future<void> openSelectedAI() async {
    String url;

    switch (selectedAI) {
      case 'ChatGPT':
        url = 'https://chatgpt.com/';
        break;

      case 'Gemini':
        url = 'https://gemini.google.com/';
        break;

      case 'Claude':
        url = 'https://claude.ai/';
        break;

      default:
        return;
    }

    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open $selectedAI',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error opening $selectedAI',
          ),
        ),
      );
    }
  }

  // ==================================================
  // AI CARD
  // ==================================================

  Widget aiCard({
    required String name,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected =
        selectedAI == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAI = name;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF21143D)
              : const Color(0xFF15151F),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color:
                        Color(0x336D28D9),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15),
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF2563EB),
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style:
                        const TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : Colors.white30,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Choose AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            Colors.transparent,
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              const Text(
                'Where do you want to\nuse your prompt?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Select your preferred AI assistant.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // CHATGPT
              // ==================================================

              aiCard(
                name: 'ChatGPT',
                description:
                    'Use your prompt with ChatGPT',
                icon:
                    Icons.chat_bubble_outline,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // GEMINI
              // ==================================================

              aiCard(
                name: 'Gemini',
                description:
                    'Use your prompt with Gemini',
                icon:
                    Icons.auto_awesome,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // CLAUDE
              // ==================================================

              aiCard(
                name: 'Claude',
                description:
                    'Use your prompt with Claude',
                icon:
                    Icons.psychology_outlined,
              ),

              const Spacer(),

              // ==================================================
              // CONTINUE BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed:
                      openSelectedAI,
                  icon: const Icon(
                    Icons.open_in_new,
                  ),
                  label: Text(
                    'Continue with $selectedAI',
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF6D28D9,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// EXAMPLE CHIP
// ======================================================

class _ExampleChip
    extends StatelessWidget {
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
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xFF15151F),
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

// ======================================================
// LIBRARY SCREEN
// ======================================================

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() =>
      _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> savedPrompts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLibrary();
  }

  // ==================================================
  // LOAD SAVED PROMPTS
  // ==================================================

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();

    final history =
        prefs.getStringList('prompt_history') ?? [];

    final loadedPrompts =
        <Map<String, dynamic>>[];

    for (final item in history) {
      try {
        final data = jsonDecode(item);

        loadedPrompts.add({
          'idea': data['idea'] ?? '',
          'prompt': data['prompt'] ?? '',
          'savedAt': data['savedAt'] ?? '',
        });
      } catch (e) {
        // Ignore invalid saved entries.
      }
    }

    if (!mounted) return;

    setState(() {
      savedPrompts = loadedPrompts;
      isLoading = false;
    });
  }

  // ==================================================
  // FORMAT DATE
  // ==================================================

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return '';
    }
  }

  // ==================================================
  // OPEN SAVED PROMPT
  // ==================================================

  void openSavedPrompt(
    Map<String, dynamic> savedPrompt,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedPromptScreen(
          idea: savedPrompt['idea'] ?? '',
          prompt: savedPrompt['prompt'] ?? '',
          savedAt: savedPrompt['savedAt'] ?? '',
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : savedPrompts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 70,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Your Library is Empty',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Generate a prompt and save it to your Library.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadLibrary,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        30,
                      ),
                      itemCount:
                          savedPrompts.length,
                      itemBuilder:
                          (context, index) {
                        final savedPrompt =
                            savedPrompts[index];

                        final idea =
                            savedPrompt['idea'] ?? '';

                        final prompt =
                            savedPrompt['prompt'] ?? '';

                        final savedAt =
                            savedPrompt['savedAt'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            openSavedPrompt(
                              savedPrompt,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),
                            padding:
                                const EdgeInsets.all(18),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF15151F,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color:
                                    Colors.white12,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration:
                                          BoxDecoration(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                        gradient:
                                            const LinearGradient(
                                          colors: [
                                            Color(
                                              0xFF7C3AED,
                                            ),
                                            Color(
                                              0xFF2563EB,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .auto_awesome,
                                        color:
                                            Colors.white,
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        idea,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),

                                    const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      size: 16,
                                      color:
                                          Colors.white38,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 14,
                                ),

                                Text(
                                  prompt,
                                  maxLines: 3,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white60,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(
                                  height: 14,
                                ),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .access_time_outlined,
                                      size: 15,
                                      color:
                                          Colors.white38,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      formatDate(
                                        savedAt,
                                      ),
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

// ======================================================
// SAVED PROMPT SCREEN
// ======================================================

class SavedPromptScreen extends StatelessWidget {
  final String idea;
  final String prompt;
  final String savedAt;

  const SavedPromptScreen({
    super.key,
    required this.idea,
    required this.prompt,
    required this.savedAt,
  });

  // ==================================================
  // COPY SAVED PROMPT
  // ==================================================

  Future<void> copySavedPrompt(
    BuildContext context,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: prompt,
      ),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Prompt copied! 📋',
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Saved Prompt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            5,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Your idea',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151F),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: Text(
                  idea,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Saved Prompt',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151F),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6D28D9),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x336D28D9),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      prompt,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    copySavedPrompt(context);
                  },
                  icon: const Icon(
                    Icons.copy,
                  ),
                  label: const Text(
                    'Copy Prompt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
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
      ),
    );
  }
}
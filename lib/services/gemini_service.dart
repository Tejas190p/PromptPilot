import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'YOUR_API_KEY';

  static Future<String> generatePrompt(String idea) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
You are PromptPilot, an expert AI prompt engineer.

The user gives you this simple idea:

"$idea"

Transform this idea into a highly detailed, intelligent, ready-to-use prompt.

Understand the actual intent instead of blindly following a generic template.

Build the prompt using the information that is relevant to the user's idea, including:
- Role
- Goal
- Context
- Requirements
- Specific tasks
- Important details
- Expected output
- Format
- Constraints
- Quality standards

Add useful details intelligently when they improve the result.

The final prompt should be specific, practical, professional, and ready to copy into ChatGPT, Gemini, Claude, or another AI assistant.

Return ONLY the final prompt.
Do not explain your reasoning.
Do not mention PromptPilot.
Do not use placeholders unless absolutely necessary.
'''
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return data['candidates'][0]['content']['parts'][0]['text'];
  }

  // IMPROVE PROMPT
  static Future<String> improvePrompt(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
You are an expert AI prompt engineer.

Improve the following prompt:

"$prompt"

Make it significantly better while keeping the original goal.

Improve:
- Clarity
- Specificity
- Context
- Instructions
- Expected output
- Structure
- Constraints
- Quality requirements

Do not change the user's original intention.

Make the improved prompt:
- Professional
- Specific
- Practical
- Detailed
- Ready to use with ChatGPT, Gemini, Claude, or another AI assistant

Return ONLY the improved prompt.
Do not explain your changes.
Do not mention PromptPilot.
'''
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}
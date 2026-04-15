import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GeminiService {
  static Future<String> generateHealthChart({
    required String chartType,
    required String childName,
    required int childAge,
    required String requirements,
  }) async {
    try {
      String prompt = _buildPrompt(chartType, childName, childAge, requirements);
      
      final response = await http.post(
        Uri.parse('${AppConstants.geminiApiUrl}?key=${AppConstants.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText;
      } else {
        throw Exception('Failed to generate chart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating chart: $e');
    }
  }

  static String _buildPrompt(String chartType, String childName, int childAge, String requirements) {
    switch (chartType) {
      case AppConstants.chartTypeFood:
        return '''
You are a pediatric nutritionist. Create a detailed weekly food chart for a child.

Child Details:
- Name: $childName
- Age: $childAge years
- Special Requirements: $requirements

Please create a comprehensive 7-day meal plan with the following structure:

**Weekly Food Chart for $childName (Age: $childAge years)**

For each day (Monday to Sunday), provide:
- Breakfast (with time suggestion)
- Mid-Morning Snack
- Lunch (with time suggestion)
- Evening Snack
- Dinner (with time suggestion)

Include:
- Nutritious, age-appropriate meals
- Portion sizes suitable for $childAge year old
- Variety of fruits, vegetables, proteins, and grains
- Consider the requirements: $requirements

Format the response in a clear, easy-to-read structure with proper headings and bullet points.
''';

      case AppConstants.chartTypeMedicine:
        return '''
You are a pediatrician. Create a monthly medicine and supplement schedule for a child.

Child Details:
- Name: $childName
- Age: $childAge years
- Requirements: $requirements

Please create a comprehensive monthly medicine chart with the following:

**Monthly Medicine Chart for $childName (Age: $childAge years)**

Include:
1. Daily Vitamins/Supplements (if recommended for this age)
   - Name of supplement
   - Dosage
   - Time to take
   - Duration

2. Common Preventive Medicines (age-appropriate)
   - Deworming schedule
   - Vitamin D supplements
   - Iron supplements (if needed)
   - Any other age-appropriate supplements

3. Important Notes:
   - When to take (before/after meals)
   - Storage instructions
   - Precautions

4. Vaccination Reminders (if any due at this age)

Consider the requirements: $requirements

Format clearly with proper sections and bullet points. Include dosage based on age.
''';

      case AppConstants.chartTypeActivity:
        return '''
You are a child development specialist. Create a daily activity schedule for a child.

Child Details:
- Name: $childName
- Age: $childAge years
- Preferences: $requirements

Please create a comprehensive daily activity chart:

**Daily Activity Chart for $childName (Age: $childAge years)**

Create a schedule from morning to night including:

1. Morning Routine (6:00 AM - 9:00 AM)
   - Wake up time
   - Morning activities
   - Breakfast time

2. Learning Time (9:00 AM - 12:00 PM)
   - Educational activities
   - Creative play
   - Skill development

3. Afternoon (12:00 PM - 3:00 PM)
   - Lunch time
   - Quiet time/Nap
   - Free play

4. Evening Activities (3:00 PM - 6:00 PM)
   - Outdoor play
   - Physical activities
   - Social interaction

5. Night Routine (6:00 PM - 9:00 PM)
   - Dinner time
   - Family time
   - Bedtime routine

Include:
- Age-appropriate activities
- Balance of physical, mental, and creative activities
- Screen time limits (if applicable)
- Sleep schedule
- Consider preferences: $requirements

Format with clear time slots and activity descriptions.
''';

      default:
        return 'Generate a health chart for $childName, age $childAge years. Requirements: $requirements';
    }
  }
}

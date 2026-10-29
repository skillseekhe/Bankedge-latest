import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GrexaRealApp());
}

class GrexaRealApp extends StatelessWidget {
  const GrexaRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grexa AI Growth Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F52BA),
          primary: const Color(0xFF0F52BA),
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  String _provider = 'Gemini'; // 'Gemini', 'OpenRouter', 'Groq', 'OpenAI'
  String _apiKey = '';
  String _businessName = '';
  String _businessType = '';
  String _businessCity = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _provider = prefs.getString('api_provider') ?? 'Gemini';
      _apiKey = prefs.getString('api_key') ?? '';
      _businessName = prefs.getString('biz_name') ?? 'My Local Business';
      _businessType = prefs.getString('biz_type') ?? 'Retail / Institute / Services';
      _businessCity = prefs.getString('biz_city') ?? 'Gurugram';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      GrowthAgentView(
        provider: _provider,
        apiKey: _apiKey,
        bizName: _businessName,
        bizType: _businessType,
        bizCity: _businessCity,
        onOpenSettings: () => _openSettingsDialog(context),
      ),
      GbpGeneratorView(
        provider: _provider,
        apiKey: _apiKey,
        bizName: _businessName,
        bizType: _businessType,
        bizCity: _businessCity,
      ),
      ReviewResponderView(
        provider: _provider,
        apiKey: _apiKey,
        bizName: _businessName,
      ),
      WhatsAppBroadcastView(
        provider: _provider,
        apiKey: _apiKey,
        bizName: _businessName,
        bizType: _businessType,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _businessName.isEmpty ? 'Grexa AI Growth' : _businessName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _apiKey.isEmpty ? Icons.key_off : Icons.vpn_key,
              color: _apiKey.isEmpty ? Colors.amber[800] : Colors.green[700],
            ),
            tooltip: 'Configure AI Key & Profile',
            onPressed: () => _openSettingsDialog(context),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Advisor',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_location_alt_rounded),
            label: 'Google Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_rounded),
            label: 'Review AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_to_mobile_rounded),
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }

  void _openSettingsDialog(BuildContext context) {
    String selectedProvider = _provider;
    final keyController = TextEditingController(text: _apiKey);
    final nameController = TextEditingController(text: _businessName);
    final typeController = TextEditingController(text: _businessType);
    final cityController = TextEditingController(text: _businessCity);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          String hint = 'Paste your API key here';
          if (selectedProvider == 'Gemini') {
            hint = 'Gemini API key or OAuth Token (AQ...)';
          } else if (selectedProvider == 'OpenRouter') {
            hint = 'sk-or-v1-... (free at openrouter.ai)';
          } else if (selectedProvider == 'Groq') {
            hint = 'gsk_... (free at console.groq.com)';
          } else if (selectedProvider == 'OpenAI') {
            hint = 'sk-proj-...';
          }

          return AlertDialog(
            title: const Text('Setup AI Provider & Business'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select AI Engine:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedProvider,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Gemini', child: Text('Google Gemini (Direct / Bearer)')),
                      DropdownMenuItem(value: 'OpenRouter', child: Text('OpenRouter (Free / Any model)')),
                      DropdownMenuItem(value: 'Groq', child: Text('Groq (Fast / Llama 3)')),
                      DropdownMenuItem(value: 'OpenAI', child: Text('OpenAI (GPT-4o mini)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedProvider = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '$selectedProvider API Key',
                      hintText: hint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Category / Offering (e.g. Banking Training)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Location / City (e.g. Sector 2, Gurugram)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('api_provider', selectedProvider);
                  await prefs.setString('api_key', keyController.text.trim());
                  await prefs.setString('biz_name', nameController.text.trim());
                  await prefs.setString('biz_type', typeController.text.trim());
                  await prefs.setString('biz_city', cityController.text.trim());
                  setState(() {
                    _provider = selectedProvider;
                    _apiKey = keyController.text.trim();
                    _businessName = nameController.text.trim();
                    _businessType = typeController.text.trim();
                    _businessCity = cityController.text.trim();
                  });
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Universal Multi-Provider AI Engine (Supports Gemini, OpenRouter, Groq, OpenAI)
// ---------------------------------------------------------------------------
Future<String> queryUniversalAi({
  required String provider,
  required String apiKey,
  required String systemInstruction,
  required String prompt,
}) async {
  if (apiKey.isEmpty) {
    return "Error: No API key provided. Tap the Key icon at the top right to configure your API key.";
  }

  try {
    // 1. Google Gemini (Supports both URL param key and Bearer auth tokens like AQ...)
    if (provider == 'Gemini') {
      final isBearer = apiKey.startsWith('AQ') || apiKey.startsWith('ya29.');
      final uriStr = isBearer
          ? 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'
          : 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (isBearer) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final body = jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": "$systemInstruction\n\nUser Task: $prompt"}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 800,
        }
      });

      var response = await http.post(Uri.parse(uriStr), headers: headers, body: body);

      // Fallback to gemini-2.0-flash if 2.5 is not accessible
      if (response.statusCode == 404) {
        final fallbackUri = isBearer
            ? 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'
            : 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';
        response = await http.post(Uri.parse(fallbackUri), headers: headers, body: body);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          return candidates[0]['content']['parts'][0]['text'] ?? "Empty response.";
        }
      } else {
        final err = jsonDecode(response.body);
        return "Gemini API Error (${response.statusCode}): ${err['error']['message'] ?? response.body}";
      }
    }

    // 2. OpenRouter (Universal endpoint, works with sk-or-v1-...)
    if (provider == 'OpenRouter') {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://grexa.ai',
          'X-Title': 'Grexa Growth App',
        },
        body: jsonEncode({
          "model": "google/gemini-2.0-flash-exp:free",
          "messages": [
            {"role": "system", "content": systemInstruction},
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "Empty response.";
      } else {
        return "OpenRouter Error (${response.statusCode}): ${response.body}";
      }
    }

    // 3. Groq (High-speed Llama 3 / Mixtral with gsk_...)
    if (provider == 'Groq') {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": systemInstruction},
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "Empty response.";
      } else {
        return "Groq Error (${response.statusCode}): ${response.body}";
      }
    }

    // 4. OpenAI (GPT-4o mini with sk-proj-...)
    if (provider == 'OpenAI') {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": systemInstruction},
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "Empty response.";
      } else {
        return "OpenAI Error (${response.statusCode}): ${response.body}";
      }
    }
  } catch (e) {
    return "Network Exception: $e. Verify internet access.";
  }

  return "Unknown provider selected.";
}

// ---------------------------------------------------------------------------
// TAB 1: Conversational Business Growth Agent
// ---------------------------------------------------------------------------
class GrowthAgentView extends StatefulWidget {
  final String provider;
  final String apiKey;
  final String bizName;
  final String bizType;
  final String bizCity;
  final VoidCallback onOpenSettings;

  const GrowthAgentView({
    super.key,
    required this.provider,
    required this.apiKey,
    required this.bizName,
    required this.bizType,
    required this.bizCity,
    required this.onOpenSettings,
  });

  @override
  State<GrowthAgentView> createState() => _GrowthAgentViewState();
}

class _GrowthAgentViewState extends State<GrowthAgentView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello! I am your Grexa AI Business Growth Agent. Ask me anything: how to get 20 walk-ins this weekend, strategies to rank #1 on Google Maps, or lead-generation funnels.'
    }
  ];

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _loading) return;

    if (widget.apiKey.isEmpty) {
      widget.onOpenSettings();
      return;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _msgController.clear();
    _scrollToBottom();

    final sys = 'You are Grexa AI, an expert marketing advisor for ${widget.bizName}, a ${widget.bizType} in ${widget.bizCity}. '
        'Provide actionable, high-converting growth tactics, scripts, and promotional hooks.';

    final reply = await queryUniversalAi(
      provider: widget.provider,
      apiKey: widget.apiKey,
      systemInstruction: sys,
      prompt: text,
    );

    if (mounted) {
      setState(() {
        _messages.add({'role': 'ai', 'text': reply});
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.apiKey.isEmpty)
          Container(
            color: Colors.amber[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.brown, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tap Key icon at top right to enter your API key.',
                    style: TextStyle(color: Colors.brown, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenSettings,
                  child: const Text('Setup Key'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final m = _messages[idx];
              final isAi = m['role'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.grey[200] : const Color(0xFF0F52BA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SelectableText(
                    m['text']!,
                    style: TextStyle(
                      color: isAi ? Colors.black87 : Colors.white,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'e.g. How can I get 15 student enrollments this week?',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loading ? null : _send,
                icon: const Icon(Icons.send_rounded),
              )
            ],
          ),
        )
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: Google Business Profile Post Generator & Local SEO
// ---------------------------------------------------------------------------
class GbpGeneratorView extends StatefulWidget {
  final String provider;
  final String apiKey;
  final String bizName;
  final String bizType;
  final String bizCity;

  const GbpGeneratorView({
    super.key,
    required this.provider,
    required this.apiKey,
    required this.bizName,
    required this.bizType,
    required this.bizCity,
  });

  @override
  State<GbpGeneratorView> createState() => _GbpGeneratorViewState();
}

class _GbpGeneratorViewState extends State<GbpGeneratorView> {
  final TextEditingController _topicController = TextEditingController();
  String _generatedPost = '';
  bool _loading = false;

  Future<void> _generatePost() async {
    final topic = _topicController.text.trim().isEmpty
        ? 'Festive admission discount & 100% placement assurance'
        : _topicController.text.trim();

    setState(() => _loading = true);

    final sys = 'You are an expert Local SEO & Google Business Profile copywriter for ${widget.bizName} in ${widget.bizCity}. '
        'Create an engaging, emoji-rich, SEO-optimized Google Update Post. '
        'Include local keywords for ${widget.bizCity}, clear value proposition, and a strong Call to Action. Keep it under 150 words.';

    final result = await queryUniversalAi(
      provider: widget.provider,
      apiKey: widget.apiKey,
      systemInstruction: sys,
      prompt: 'Write a high-converting Google Business Profile update post about: $topic',
    );

    if (mounted) {
      setState(() {
        _generatedPost = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1-Click AI Local SEO Post',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rank higher on Google Maps in ${widget.bizCity.isEmpty ? "your city" : widget.bizCity}.',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Offer or Event (Optional)',
                    hintText: 'e.g. Free counseling session, Weekend 20% off',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generatePost,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: const Text('Generate AI SEO Post'),
                ),
              ],
            ),
          ),
        ),
        if (_generatedPost.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Ready to Publish on Google:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: SelectableText(
              _generatedPost,
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ),
        ]
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3: Google Reviews Auto-Responder AI
// ---------------------------------------------------------------------------
class ReviewResponderView extends StatefulWidget {
  final String provider;
  final String apiKey;
  final String bizName;

  const ReviewResponderView({
    super.key,
    required this.provider,
    required this.apiKey,
    required this.bizName,
  });

  @override
  State<ReviewResponderView> createState() => _ReviewResponderViewState();
}

class _ReviewResponderViewState extends State<ReviewResponderView> {
  final TextEditingController _reviewController = TextEditingController();
  int _stars = 5;
  String _aiReply = '';
  bool _loading = false;

  Future<void> _generateReply() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);

    final sys = 'You are the customer reputation manager for ${widget.bizName}. '
        'Generate an authentic, professional response to a customer review that improves Google search credibility. '
        'If positive, express gratitude. If negative, apologize professionally and provide a polite resolution path.';

    final result = await queryUniversalAi(
      provider: widget.provider,
      apiKey: widget.apiKey,
      systemInstruction: sys,
      prompt: 'Customer gave $_stars stars and wrote: "$text". Write an ideal owner response.',
    );

    if (mounted) {
      setState(() {
        _aiReply = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Review Responder',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paste customer feedback to craft polite, reputation-boosting responses.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Rating: '),
                    DropdownButton<int>(
                      value: _stars,
                      items: [5, 4, 3, 2, 1]
                          .map((n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n Stars ⭐'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _stars = v ?? 5),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Customer Review Text',
                    hintText: 'e.g. Great faculty and fast placement support, highly recommended!',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generateReply,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.reply),
                  label: const Text('Draft AI Reply'),
                ),
              ],
            ),
          ),
        ),
        if (_aiReply.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Recommended Reply:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: SelectableText(
              _aiReply,
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ),
        ]
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 4: WhatsApp Campaign Copy & Direct Sender
// ---------------------------------------------------------------------------
class WhatsAppBroadcastView extends StatefulWidget {
  final String provider;
  final String apiKey;
  final String bizName;
  final String bizType;

  const WhatsAppBroadcastView({
    super.key,
    required this.provider,
    required this.apiKey,
    required this.bizName,
    required this.bizType,
  });

  @override
  State<WhatsAppBroadcastView> createState() => _WhatsAppBroadcastViewState();
}

class _WhatsAppBroadcastViewState extends State<WhatsAppBroadcastView> {
  final TextEditingController _campaignGoal = TextEditingController();
  final TextEditingController _testPhone = TextEditingController();
  String _generatedCopy = '';
  bool _loading = false;

  Future<void> _generateCopy() async {
    final goal = _campaignGoal.text.trim().isEmpty
        ? 'Urgent invitation for 30-day banking job training batch starting Monday'
        : _campaignGoal.text.trim();

    setState(() => _loading = true);

    final sys = 'You are a direct-response WhatsApp marketing copywriter for ${widget.bizName} (${widget.bizType}). '
        'Write a high-converting, friendly, emoji-rich WhatsApp broadcast message. '
        'Structure: Attention hook, core benefit, limited availability urgency, and a 1-tap call to action.';

    final result = await queryUniversalAi(
      provider: widget.provider,
      apiKey: widget.apiKey,
      systemInstruction: sys,
      prompt: 'Write a high converting WhatsApp broadcast for: $goal',
    );

    if (mounted) {
      setState(() {
        _generatedCopy = result;
        _loading = false;
      });
    }
  }

  Future<void> _sendViaWhatsApp() async {
    if (_generatedCopy.isEmpty) return;
    final phone = _testPhone.text.trim().replaceAll('+', '').replaceAll(' ', '');
    final encoded = Uri.encodeComponent(_generatedCopy);
    
    final uri = phone.isNotEmpty
        ? Uri.parse('https://wa.me/$phone?text=$encoded')
        : Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WhatsApp Lead Broadcast Generator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Draft high-converting WhatsApp promotional messages and send them instantly.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _campaignGoal,
                  decoration: const InputDecoration(
                    labelText: 'Campaign Goal / Target Audience',
                    hintText: 'e.g. New batch starting Monday for graduates',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generateCopy,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.campaign_rounded),
                  label: const Text('Generate WhatsApp Copy'),
                ),
              ],
            ),
          ),
        ),
        if (_generatedCopy.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Generated Message Preview:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: SelectableText(
              _generatedCopy,
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _testPhone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Target Phone Number (Optional, with country code)',
              hintText: '9198XXXXXXXX',
              border: OutlineInputBorder(),
              helperText: 'Leave empty to share generally or select contact in WhatsApp',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _sendViaWhatsApp,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Open & Send in WhatsApp App'),
          ),
        ]
      ],
    );
  }
}

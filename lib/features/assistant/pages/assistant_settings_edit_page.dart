import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../../icons/lucide_adapter.dart';
import '../../../theme/design_tokens.dart';
import '../../../core/models/assistant.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/mcp_provider.dart';
import '../../model/widgets/model_select_sheet.dart';
import '../../chat/widgets/reasoning_budget_sheet.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../chat/widgets/chat_message_widget.dart';
import '../../../core/models/chat_message.dart';
import '../../../utils/sandbox_path_resolver.dart';
import 'dart:io' show File;

class AssistantSettingsEditPage extends StatefulWidget {
  const AssistantSettingsEditPage({super.key, required this.assistantId});
  final String assistantId;

  @override
  State<AssistantSettingsEditPage> createState() => _AssistantSettingsEditPageState();
}

class _AssistantSettingsEditPageState extends State<AssistantSettingsEditPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final provider = context.watch<AssistantProvider>();
    final assistant = provider.getById(widget.assistantId);

    if (assistant == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Lucide.ArrowLeft, size: 22), onPressed: () => Navigator.of(context).maybePop()),
          title: Text(zh ? '助手' : 'Assistant'),
        ),
        body: Center(child: Text(zh ? '助手不存在' : 'Assistant not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Lucide.ArrowLeft, size: 22), onPressed: () => Navigator.of(context).maybePop()),
        title: Text(assistant.name.isNotEmpty ? assistant.name : (zh ? '助手' : 'Assistant')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: _SegTabBar(
                    controller: _tabController,
                    tabs: [zh ? '基础设置' : 'Basic', zh ? '提示词' : 'Prompts', 'MCP', zh ? '自定义请求' : 'Custom'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BasicSettingsTab(assistantId: assistant.id),
          _PromptTab(assistantId: assistant.id),
          _McpTab(assistantId: assistant.id),
          _CustomRequestTab(assistantId: assistant.id),
        ],
      ),
    );
  }
}

class _CustomRequestTab extends StatelessWidget {
  const _CustomRequestTab({required this.assistantId});
  final String assistantId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final ap = context.watch<AssistantProvider>();
    final a = ap.getById(assistantId)!;

    Widget card({required Widget child}) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
              boxShadow: isDark ? [] : AppShadows.soft,
            ),
            child: Padding(padding: const EdgeInsets.all(12), child: child),
          ),
        );

    void addHeader() {
      final list = List<Map<String, String>>.of(a.customHeaders);
      list.add({'name': '', 'value': ''});
      context.read<AssistantProvider>().updateAssistant(a.copyWith(customHeaders: list));
    }

    void removeHeader(int index) {
      final list = List<Map<String, String>>.of(a.customHeaders);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        context.read<AssistantProvider>().updateAssistant(a.copyWith(customHeaders: list));
      }
    }

    void updateHeader(int index, {String? name, String? value}) {
      final list = List<Map<String, String>>.of(a.customHeaders);
      if (index >= 0 && index < list.length) {
        final cur = Map<String, String>.from(list[index]);
        if (name != null) cur['name'] = name;
        if (value != null) cur['value'] = value;
        list[index] = cur;
        context.read<AssistantProvider>().updateAssistant(a.copyWith(customHeaders: list));
      }
    }

    void addBody() {
      final list = List<Map<String, String>>.of(a.customBody);
      list.add({'key': '', 'value': ''});
      context.read<AssistantProvider>().updateAssistant(a.copyWith(customBody: list));
    }

    void removeBody(int index) {
      final list = List<Map<String, String>>.of(a.customBody);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        context.read<AssistantProvider>().updateAssistant(a.copyWith(customBody: list));
      }
    }

    void updateBody(int index, {String? key, String? value}) {
      final list = List<Map<String, String>>.of(a.customBody);
      if (index >= 0 && index < list.length) {
        final cur = Map<String, String>.from(list[index]);
        if (key != null) cur['key'] = key;
        if (value != null) cur['value'] = value;
        list[index] = cur;
        context.read<AssistantProvider>().updateAssistant(a.copyWith(customBody: list));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // Headers
        card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(zh ? '自定义 Header' : 'Custom Headers',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: addHeader,
                    icon: Icon(Lucide.Plus, size: 16, color: cs.primary),
                    label: Text(zh ? '添加 Header' : 'Add Header', style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < a.customHeaders.length; i++) ...[
                _HeaderRow(
                  index: i,
                  name: a.customHeaders[i]['name'] ?? '',
                  value: a.customHeaders[i]['value'] ?? '',
                  onChanged: (k, v) => updateHeader(i, name: k, value: v),
                  onDelete: () => removeHeader(i),
                ),
                const SizedBox(height: 10),
              ],
              if (a.customHeaders.isEmpty)
                Text(
                  zh ? '未添加 Header' : 'No headers added',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12),
                ),
            ],
          ),
        ),

        // Body
        card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(zh ? '自定义 Body' : 'Custom Body',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: addBody,
                    icon: Icon(Lucide.Plus, size: 16, color: cs.primary),
                    label: Text(zh ? '添加 Body' : 'Add Body', style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < a.customBody.length; i++) ...[
                _BodyRow(
                  index: i,
                  keyName: a.customBody[i]['key'] ?? '',
                  value: a.customBody[i]['value'] ?? '',
                  onChanged: (k, v) => updateBody(i, key: k, value: v),
                  onDelete: () => removeBody(i),
                ),
                const SizedBox(height: 10),
              ],
              if (a.customBody.isEmpty)
                Text(
                  zh ? '未添加 Body 项' : 'No body items added',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatefulWidget {
  const _HeaderRow({required this.index, required this.name, required this.value, required this.onChanged, required this.onDelete});
  final int index;
  final String name;
  final String value;
  final void Function(String name, String value) onChanged;
  final VoidCallback onDelete;

  @override
  State<_HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<_HeaderRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _valCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _valCtrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _HeaderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) _nameCtrl.text = widget.name;
    if (oldWidget.value != widget.value) _valCtrl.text = widget.value;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.white10 : const Color(0xFFF2F3F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary.withOpacity(0.4))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                decoration: _dec(context, zh ? 'Header 名称' : 'Header Name'),
                onChanged: (v) => widget.onChanged(v, _valCtrl.text),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onDelete,
              icon: Icon(Lucide.Trash2, size: 18, color: cs.error),
              tooltip: zh ? '删除' : 'Delete',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _valCtrl,
          decoration: _dec(context, zh ? 'Header 值' : 'Header Value'),
          onChanged: (v) => widget.onChanged(_nameCtrl.text, v),
        ),
      ],
    );
  }
}

class _BodyRow extends StatefulWidget {
  const _BodyRow({required this.index, required this.keyName, required this.value, required this.onChanged, required this.onDelete});
  final int index;
  final String keyName;
  final String value;
  final void Function(String key, String value) onChanged;
  final VoidCallback onDelete;

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  late final TextEditingController _keyCtrl;
  late final TextEditingController _valCtrl;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.keyName);
    _valCtrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _BodyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyName != widget.keyName) _keyCtrl.text = widget.keyName;
    if (oldWidget.value != widget.value) _valCtrl.text = widget.value;
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.white10 : const Color(0xFFF2F3F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary.withOpacity(0.4))),
      alignLabelWithHint: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keyCtrl,
                decoration: _dec(context, zh ? 'Body Key' : 'Body Key'),
                onChanged: (v) => widget.onChanged(v, _valCtrl.text),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onDelete,
              icon: Icon(Lucide.Trash2, size: 18, color: cs.error),
              tooltip: zh ? '删除' : 'Delete',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _valCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: _dec(context, zh ? 'Body 值 (JSON)' : 'Body Value (JSON)'),
          onChanged: (v) => widget.onChanged(_keyCtrl.text, v),
        ),
      ],
    );
  }
}

class _BasicSettingsTab extends StatefulWidget {
  const _BasicSettingsTab({required this.assistantId});
  final String assistantId;

  @override
  State<_BasicSettingsTab> createState() => _BasicSettingsTabState();
}

class _BasicSettingsTabState extends State<_BasicSettingsTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _thinkingCtrl;
  late final TextEditingController _maxTokensCtrl;
  late final TextEditingController _backgroundCtrl;

  @override
  void initState() {
    super.initState();
    final ap = context.read<AssistantProvider>();
    final a = ap.getById(widget.assistantId)!;
    _nameCtrl = TextEditingController(text: a.name);
    _thinkingCtrl = TextEditingController(text: a.thinkingBudget?.toString() ?? '');
    _maxTokensCtrl = TextEditingController(text: a.maxTokens?.toString() ?? '');
    _backgroundCtrl = TextEditingController(text: a.background ?? '');
  }

  @override
  void didUpdateWidget(covariant _BasicSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assistantId != widget.assistantId) {
      final ap = context.read<AssistantProvider>();
      final a = ap.getById(widget.assistantId)!;
      _nameCtrl.text = a.name;
      _thinkingCtrl.text = a.thinkingBudget?.toString() ?? '';
      _maxTokensCtrl.text = a.maxTokens?.toString() ?? '';
      _backgroundCtrl.text = a.background ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _thinkingCtrl.dispose();
    _maxTokensCtrl.dispose();
    _backgroundCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final ap = context.watch<AssistantProvider>();
    final a = ap.getById(widget.assistantId)!;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary)),
        );

    Widget card({required Widget child}) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
              boxShadow: isDark ? [] : AppShadows.soft,
            ),
            child: Padding(padding: const EdgeInsets.all(12), child: child),
          ),
        );

    Widget titleDesc(String title, String? desc) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (desc != null) ...[
              const SizedBox(height: 6),
              Text(desc, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7))),
            ]
          ],
        );

    Widget avatarWidget({double size = 56}) {
      final bg = cs.primary.withOpacity(isDark ? 0.18 : 0.12);
      Widget inner;
      final av = a.avatar?.trim();
      if (av != null && av.isNotEmpty) {
        if (av.startsWith('http')) {
          inner = ClipOval(child: Image.network(av, width: size, height: size, fit: BoxFit.cover));
        } else if (av.startsWith('/') || av.contains(':')) {
          inner = ClipOval(child: Image.file(File(av), width: size, height: size, fit: BoxFit.cover));
        } else {
          inner = Text(av, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: size * 0.42));
        }
      } else {
        inner = Text(
          (a.name.trim().isNotEmpty ? String.fromCharCode(a.name.trim().runes.first).toUpperCase() : 'A'),
          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: size * 0.42),
        );
      }
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _showAvatarPicker(context, a),
        child: CircleAvatar(radius: size / 2, backgroundColor: bg, child: inner),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // Identity card (avatar + name)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(isDark ? 0.22 : 0.30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
              boxShadow: isDark ? [] : AppShadows.soft,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  avatarWidget(size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InputRow(
                      label: zh ? '助手名称' : 'Assistant Name',
                      controller: _nameCtrl,
                      onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(name: v)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Use assistant avatar
        card(
          child: Row(
            children: [
              Expanded(child: titleDesc(zh ? '使用助手头像' : 'Use Assistant Avatar', zh ? '在聊天中使用助手头像和名字而不是模型头像和名字' : 'Use assistant avatar/name instead of model')),
              Switch(
                value: a.useAssistantAvatar,
                onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(useAssistantAvatar: v)),
              ),
            ],
          ),
        ),

        // Chat model card (styled like DefaultModelPage)
        card(
          child: _AssistantModelCard(
            title: zh ? '聊天模型' : 'Chat Model',
            subtitle: zh ? '为该助手设置默认聊天模型（未设置时使用全局默认）' : 'Default chat model for this assistant (fallback to global)',
            providerKey: a.chatModelProvider,
            modelId: a.chatModelId,
            onPick: () async {
              final sel = await showModelSelector(context);
              if (sel != null) {
                await context.read<AssistantProvider>().updateAssistant(
                  a.copyWith(chatModelProvider: sel.providerKey, chatModelId: sel.modelId),
                );
              }
            },
          ),
        ),

        // Temperature
        card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(child: titleDesc('Temperature', zh ? '控制输出的随机性，范围 0–2' : 'Controls randomness, range 0–2')),
                Switch(
                  value: a.temperature != null,
                  onChanged: (v) async {
                    if (v) {
                      await context.read<AssistantProvider>().updateAssistant(a.copyWith(temperature: (a.temperature ?? 0.6)));
                    } else {
                      await context.read<AssistantProvider>().updateAssistant(a.copyWith(clearTemperature: true));
                    }
                  },
                ),
              ],
            ),
            if (a.temperature != null) ...[
              _SliderTileNew(
                value: a.temperature!.clamp(0.0, 2.0),
                min: 0.0,
                max: 2.0,
                divisions: 20,
                label: a.temperature!.toStringAsFixed(2),
                onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(temperature: v)),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: Text(
                  zh ? '已关闭（使用服务商默认）' : 'Disabled (uses provider default)',
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7)),
                ),
              ),
            ],
          ]),
        ),

        // Top P
        card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(child: titleDesc('Top P', zh ? '请不要修改此值，除非你知道自己在做什么' : 'Do not change unless you know what you are doing')),
                Switch(
                  value: a.topP != null,
                  onChanged: (v) async {
                    if (v) {
                      await context.read<AssistantProvider>().updateAssistant(a.copyWith(topP: (a.topP ?? 1.0)));
                    } else {
                      await context.read<AssistantProvider>().updateAssistant(a.copyWith(clearTopP: true));
                    }
                  },
                ),
              ],
            ),
            if (a.topP != null) ...[
              _SliderTileNew(
                value: a.topP!.clamp(0.0, 1.0),
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: a.topP!.toStringAsFixed(2),
                onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(topP: v)),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: Text(
                  zh ? '已关闭（使用服务商默认）' : 'Disabled (uses provider default)',
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7)),
                ),
              ),
            ],
          ]),
        ),

        // Context messages
        card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            titleDesc(zh ? '上下文消息数量' : 'Context Messages', zh ? '多少历史消息会被当作上下文发送给模型，超过数量会忽略，只保留最近 N 条' : 'How many recent messages to keep in context'),
            _SliderTileNew(
              value: a.contextMessageSize.toDouble().clamp(0, 256),
              min: 0,
              max: 256,
              divisions: 64, // step=4: every 4 messages per tick
              label: a.contextMessageSize.toString(),
              onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(contextMessageSize: v.round())),
            ),
          ]),
        ),

        // Stream output
        card(
          child: Row(children: [
            Expanded(child: titleDesc(zh ? '流式输出' : 'Stream Output', zh ? '是否启用消息的流式输出' : 'Enable streaming responses')),
            Switch(value: a.streamOutput, onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(streamOutput: v))),
          ]),
        ),

        // Thinking budget (card with icon and button)
        card(
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  'assets/icons/deepthink.svg',
                  colorFilter: ColorFilter.mode(cs.primary, BlendMode.srcIn),
                ),
              ),
            ),
            Expanded(child: Text(zh ? '思考预算' : 'Thinking Budget', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () async {
                final currentBudget = a.thinkingBudget;
                if (currentBudget != null) {
                  context.read<SettingsProvider>().setThinkingBudget(currentBudget);
                }
                await showReasoningBudgetSheet(context);
                final chosen = context.read<SettingsProvider>().thinkingBudget;
                await context.read<AssistantProvider>().updateAssistant(a.copyWith(thinkingBudget: chosen));
              },
              child: Text(zh ? '配置' : 'Configure'),
            ),
          ]),
        ),

        // Max tokens
        card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            titleDesc(zh ? '最大 Token 数' : 'Max Tokens', zh ? '留空表示无限制' : 'Leave empty for unlimited'),
            const SizedBox(height: 10),
            _InputRow(
              label: zh ? '最大 Token 数' : 'Max Tokens',
              hideLabel: true,
              controller: _maxTokensCtrl,
              hint: zh ? '无限制' : 'Unlimited',
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final val = int.tryParse(v.trim());
                context.read<AssistantProvider>().updateAssistant(a.copyWith(maxTokens: val, clearMaxTokens: v.trim().isEmpty));
              },
            ),
          ]),
        ),

        // Chat background
        card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            titleDesc(zh ? '聊天背景' : 'Chat Background', zh ? '设置助手聊天页面的背景图片' : 'Set a background image for this assistant'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickBackground(context, a),
                  icon: Icon(Lucide.Image, size: 18, color: cs.primary),
                  label: Text(zh ? '选择背景图片' : 'Choose Image', style: TextStyle(color: cs.primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    side: BorderSide(color: cs.primary.withOpacity(0.45)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF2F3F5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if ((a.background ?? '').isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AssistantProvider>().updateAssistant(a.copyWith(clearBackground: true)),
                    icon: Icon(Lucide.X, size: 16, color: cs.primary),
                    label: Text(zh ? '清除' : 'Clear', style: TextStyle(color: cs.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      side: BorderSide(color: cs.primary.withOpacity(0.45)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF2F3F5),
                    ),
                  ),
                ),
              if ((a.background ?? '').isNotEmpty) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 36,
                    child: (a.background!.startsWith('http'))
                        ? Image.network(a.background!, fit: BoxFit.cover)
                        : Image.file(File(a.background!), fit: BoxFit.cover),
                  ),
                ),
              ],
            ]),
          ]),
        ),
      ],
    );
  }

  Future<void> _showAvatarPicker(BuildContext context, Assistant a) async {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(zh ? '选择图片' : 'Choose Image'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickLocalImage(context, a);
                },
              ),
              ListTile(
                title: Text(zh ? '选择表情' : 'Choose Emoji'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final emoji = await _pickEmoji(context);
                  if (emoji != null) {
                    await context.read<AssistantProvider>().updateAssistant(a.copyWith(avatar: emoji));
                  }
                },
              ),
              ListTile(
                title: Text(zh ? '输入链接' : 'Enter Link'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _inputAvatarUrl(context, a);
                },
              ),
              ListTile(
                title: Text(zh ? 'QQ头像' : 'Import from QQ'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _inputQQAvatar(context, a);
                },
              ),
              ListTile(
                title: Text(zh ? '重置' : 'Reset'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await context.read<AssistantProvider>().updateAssistant(a.copyWith(clearAvatar: true));
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickBackground(BuildContext context, Assistant a) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
      if (file != null) {
        await context.read<AssistantProvider>().updateAssistant(a.copyWith(background: file.path));
      }
    } catch (_) {}
  }

}

class _SliderTileNew extends StatelessWidget {
  const _SliderTileNew({
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.label,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final active = cs.primary;
    final inactive = cs.onSurface.withOpacity(isDark ? 0.25 : 0.20);
    final double clamped = value.clamp(min, max);
    final double? step = (divisions != null && divisions! > 0) ? (max - min) / divisions! : null;
    // Compute a readable major interval and minor tick count
    final total = (max - min).abs();
    double interval;
    if (total <= 0) {
      interval = 1;
    } else if ((divisions ?? 0) <= 20) {
      interval = total / 4; // up to 5 major ticks inc endpoints
    } else if ((divisions ?? 0) <= 50) {
      interval = total / 5;
    } else {
      interval = total / 8;
    }
    if (interval <= 0) interval = 1;
    final int majorCount = (total / interval).round().clamp(1, 10);
    int minor = 0;
    if (step != null && step > 0) {
      // Ensure minor ticks align with the chosen step size
      minor = ((interval / step) - 1).round();
      if (minor < 0) minor = 0;
      if (minor > 8) minor = 8;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SfSliderTheme(
                data: SfSliderThemeData(
                  activeTrackHeight: 8,
                  inactiveTrackHeight: 8,
                  overlayRadius: 14,
                  activeTrackColor: active,
                  inactiveTrackColor: inactive,
                  // Waterdrop tooltip uses theme primary background with onPrimary text
                  tooltipBackgroundColor: cs.primary,
                  tooltipTextStyle: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600),
                  thumbStrokeColor: Colors.transparent,
                  thumbStrokeWidth: 0,
                  activeTickColor: cs.onSurface.withOpacity(isDark ? 0.45 : 0.35),
                  inactiveTickColor: cs.onSurface.withOpacity(isDark ? 0.30 : 0.25),
                  activeMinorTickColor: cs.onSurface.withOpacity(isDark ? 0.34 : 0.28),
                  inactiveMinorTickColor: cs.onSurface.withOpacity(isDark ? 0.24 : 0.20),
                ),
                child: SfSlider(
                  value: clamped,
                  min: min,
                  max: max,
                  stepSize: step,
                  enableTooltip: true,
                  // Show the paddle tooltip only while interacting
                  shouldAlwaysShowTooltip: false,
                  showTicks: true,
                  showLabels: true,
                  interval: interval,
                  minorTicksPerInterval: minor,
                  activeColor: active,
                  inactiveColor: inactive,
                  tooltipTextFormatterCallback: (actual, text) => label,
                  tooltipShape: const SfPaddleTooltipShape(),
                  labelFormatterCallback: (actual, formattedText) {
                    // Prefer integers for wide ranges, keep 2 decimals for 0..1
                    if (total <= 2.0) return actual.toStringAsFixed(2);
                    if (actual == actual.roundToDouble()) return actual.toStringAsFixed(0);
                    return actual.toStringAsFixed(1);
                  },
                  thumbIcon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                  ),
                  onChanged: (v) => onChanged(v is num ? v.toDouble() : (v as double)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ValuePill(text: label),
          ],
        ),
        // Remove explicit min/max captions since ticks already indicate range
      ],
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withOpacity(isDark ? 0.28 : 0.22)),
        boxShadow: isDark ? [] : AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

extension _AssistantAvatarActions on _BasicSettingsTabState {
  Future<String?> _pickEmoji(BuildContext context) async {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final controller = TextEditingController();
    String value = '';
    bool validGrapheme(String s) {
      final trimmed = s.characters.take(1).toString().trim();
      return trimmed.isNotEmpty && trimmed == s.trim();
    }
    final List<String> quick = const [
      '😀','😁','😂','🤣','😃','😄','😅','😊','😍','😘','😗','😙','😚','🙂','🤗','🤩','🫶','🤝','👍','👎','👋','🙏','💪','🔥','✨','🌟','💡','🎉','🎊','🎈','🌈','☀️','🌙','⭐','⚡','☁️','❄️','🌧️','🍎','🍊','🍋','🍉','🍇','🍓','🍒','🍑','🥭','🍍','🥝','🍅','🥕','🌽','🍞','🧀','🍔','🍟','🍕','🌮','🌯','🍣','🍜','🍰','🍪','🍩','🍫','🍻','☕','🧋','🥤','⚽','🏀','🏈','🎾','🏐','🎮','🎧','🎸','🎹','🎺','📚','✏️','💼','💻','🖥️','📱','🛩️','✈️','🚗','🚕','🚙','🚌','🚀','🛰️','🧠','🫀','💊','🩺','🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵'
    ];
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(builder: (ctx, setLocal) {
          final media = MediaQuery.of(ctx);
          final avail = media.size.height - media.viewInsets.bottom;
          final double gridHeight = (avail * 0.28).clamp(120.0, 220.0);
          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: cs.surface,
            title: Text(zh ? '选择表情' : 'Choose Emoji'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(value.isEmpty ? '🙂' : value.characters.take(1).toString(), style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (v) => setLocal(() => value = v),
                    onSubmitted: (_) {
                      if (validGrapheme(value)) Navigator.of(ctx).pop(value.characters.take(1).toString());
                    },
                    decoration: InputDecoration(
                      hintText: zh ? '输入或粘贴任意表情' : 'Type or paste any emoji',
                      filled: true,
                      fillColor: Theme.of(ctx).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF2F3F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.primary.withOpacity(0.4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: gridHeight,
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: quick.length,
                      itemBuilder: (c, i) {
                        final e = quick[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(ctx).pop(e),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(e, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(zh ? '取消' : 'Cancel'),
              ),
              TextButton(
                onPressed: validGrapheme(value) ? () => Navigator.of(ctx).pop(value.characters.take(1).toString()) : null,
                child: Text(
                  zh ? '保存' : 'Save',
                  style: TextStyle(
                    color: validGrapheme(value) ? cs.primary : cs.onSurface.withOpacity(0.38),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _inputAvatarUrl(BuildContext context, Assistant a) async {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        bool valid(String s) => s.trim().startsWith('http://') || s.trim().startsWith('https://');
        String value = '';
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: cs.surface,
            title: Text(zh ? '输入图片链接' : 'Enter Image URL'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: zh ? '例如: https://example.com/avatar.png' : 'e.g. https://example.com/avatar.png',
                filled: true,
                fillColor: Theme.of(ctx).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF2F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary.withOpacity(0.4)),
                ),
              ),
              onChanged: (v) => setLocal(() => value = v),
              onSubmitted: (_) {
                if (valid(value)) Navigator.of(ctx).pop(true);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(zh ? '取消' : 'Cancel'),
              ),
              TextButton(
                onPressed: valid(value) ? () => Navigator.of(ctx).pop(true) : null,
                child: Text(
                  zh ? '保存' : 'Save',
                  style: TextStyle(
                    color: valid(value) ? cs.primary : cs.onSurface.withOpacity(0.38),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
    if (ok == true) {
      final url = controller.text.trim();
      if (url.isNotEmpty) {
        await context.read<AssistantProvider>().updateAssistant(a.copyWith(avatar: url));
      }
    }
  }

  Future<void> _inputQQAvatar(BuildContext context, Assistant a) async {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        String value = '';
        bool valid(String s) => RegExp(r'^[0-9]{5,12}$').hasMatch(s.trim());
        String randomQQ() {
          final lengths = <int>[5, 6, 7, 8, 9, 10, 11];
          final weights = <int>[1, 20, 80, 100, 240, 3000, 80];
          final total = weights.fold<int>(0, (a, b) => a + b);
          final rnd = math.Random();
          int roll = rnd.nextInt(total) + 1;
          int chosenLen = lengths.last;
          int acc = 0;
          for (int i = 0; i < lengths.length; i++) {
            acc += weights[i];
            if (roll <= acc) { chosenLen = lengths[i]; break; }
          }
          final sb = StringBuffer();
          final firstGroups = <List<int>>[
            [1, 2],
            [3, 4],
            [5, 6, 7, 8],
            [9],
          ];
          final firstWeights = <int>[8, 4, 2, 1];
          final firstTotal = firstWeights.fold<int>(0, (a, b) => a + b);
          int r2 = rnd.nextInt(firstTotal) + 1;
          int idx = 0;
          int a2 = 0;
          for (int i = 0; i < firstGroups.length; i++) {
            a2 += firstWeights[i];
            if (r2 <= a2) { idx = i; break; }
          }
          final group = firstGroups[idx];
          sb.write(group[rnd.nextInt(group.length)]);
          for (int i = 1; i < chosenLen; i++) { sb.write(rnd.nextInt(10)); }
          return sb.toString();
        }
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: cs.surface,
            title: Text(zh ? '使用QQ头像' : 'Import from QQ'),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: zh ? '输入QQ号码（5-12位）' : 'Enter QQ number (5-12 digits)',
                filled: true,
                fillColor: Theme.of(ctx).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF2F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary.withOpacity(0.4)),
                ),
              ),
              onChanged: (v) => setLocal(() => value = v),
              onSubmitted: (_) { if (valid(value)) Navigator.of(ctx).pop(true); },
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () async {
                  const int maxTries = 20;
                  bool applied = false;
                  for (int i = 0; i < maxTries; i++) {
                    final qq = randomQQ();
                    final url = 'http://q2.qlogo.cn/headimg_dl?dst_uin=' + qq + '&spec=100';
                    try {
                      final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
                      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
                        await context.read<AssistantProvider>().updateAssistant(a.copyWith(avatar: url));
                        applied = true;
                        break;
                      }
                    } catch (_) {}
                  }
                  if (applied) {
                    if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(zh ? '获取随机QQ头像失败，请重试' : 'Failed to fetch random QQ avatar. Please try again.')),
                    );
                  }
                },
                child: Text(zh ? '随机一个' : 'Random One'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(zh ? '取消' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: valid(value) ? () => Navigator.of(ctx).pop(true) : null,
                    child: Text(
                      zh ? '保存' : 'Save',
                      style: TextStyle(
                        color: valid(value) ? cs.primary : cs.onSurface.withOpacity(0.38),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
    if (ok == true) {
      final qq = controller.text.trim();
      if (qq.isNotEmpty) {
        final url = 'https://q2.qlogo.cn/headimg_dl?dst_uin=' + qq + '&spec=100';
        await context.read<AssistantProvider>().updateAssistant(a.copyWith(avatar: url));
      }
    }
  }

  Future<void> _pickLocalImage(BuildContext context, Assistant a) async {
    if (kIsWeb) {
      await _inputAvatarUrl(context, a);
      return;
    }
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (!mounted) return;
      if (file != null) {
        await context.read<AssistantProvider>().updateAssistant(a.copyWith(avatar: file.path));
        return;
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final zh = Localizations.localeOf(context).languageCode == 'zh';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(zh ? '无法打开相册，试试输入图片链接' : 'Unable to open gallery. Try entering an image URL.')),
      );
      await _inputAvatarUrl(context, a);
      return;
    } catch (_) {
      if (!mounted) return;
      final zh = Localizations.localeOf(context).languageCode == 'zh';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(zh ? '发生错误，试试输入图片链接' : 'Something went wrong. Try entering an image URL.')),
      );
      await _inputAvatarUrl(context, a);
      return;
    }
  }
}

class _PromptTab extends StatefulWidget {
  const _PromptTab({required this.assistantId});
  final String assistantId;

  @override
  State<_PromptTab> createState() => _PromptTabState();
}

class _PromptTabState extends State<_PromptTab> {
  late final TextEditingController _sysCtrl;
  late final TextEditingController _tmplCtrl;
  late final FocusNode _sysFocus;
  late final FocusNode _tmplFocus;

  @override
  void initState() {
    super.initState();
    final ap = context.read<AssistantProvider>();
    final a = ap.getById(widget.assistantId)!;
    _sysCtrl = TextEditingController(text: a.systemPrompt);
    _tmplCtrl = TextEditingController(text: a.messageTemplate);
    _sysFocus = FocusNode(debugLabel: 'systemPromptFocus');
    _tmplFocus = FocusNode(debugLabel: 'messageTemplateFocus');
  }

  @override
  void didUpdateWidget(covariant _PromptTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assistantId != widget.assistantId) {
      final ap = context.read<AssistantProvider>();
      final a = ap.getById(widget.assistantId)!;
      _sysCtrl.text = a.systemPrompt;
      _tmplCtrl.text = a.messageTemplate;
    }
  }

  @override
  void dispose() {
    _sysCtrl.dispose();
    _tmplCtrl.dispose();
    _sysFocus.dispose();
    _tmplFocus.dispose();
    super.dispose();
  }

  void _insertAtCursor(TextEditingController controller, String toInsert) {
    final text = controller.text;
    final sel = controller.selection;
    final start = (sel.start >= 0 && sel.start <= text.length) ? sel.start : text.length;
    final end = (sel.end >= 0 && sel.end <= text.length && sel.end >= start) ? sel.end : start;
    final nextText = text.replaceRange(start, end, toInsert);
    controller.value = controller.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + toInsert.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final ap = context.watch<AssistantProvider>();
    final a = ap.getById(widget.assistantId)!;

    Widget chips(List<String> items, void Function(String v) onPick) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in items)
              ActionChip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                onPressed: () => onPick(t),
              ),
          ],
        ),
      );
    }

    final sysVars = const [
      '{cur_date}', '{cur_time}', '{cur_datetime}', '{model_id}', '{model_name}', '{locale}', '{timezone}', '{system_version}', '{device_info}', '{battery_level}', '{nickname}',
    ];
    final tmplVars = const [
      '{{ role }}', '{{ message }}', '{{ time }}', '{{ date }}',
    ];

    // Helper to render link-like variable chips
    Widget linkWrap(List<String> vars, void Function(String v) onPick) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (final t in vars)
              InkWell(
                onTap: () => onPick(t),
                child: Text(
                  t,
                  style: TextStyle(color: cs.primary, decoration: TextDecoration.underline, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      );
    }

    // Sample preview for message template
    final now = DateTime.now();
    final ts = zh
        ? DateFormat('yyyy年M月d日 a h:mm:ss', 'zh').format(now)
        : DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final sampleUser = zh ? '用户' : 'User';
    final sampleMsg = zh ? '你好啊' : 'Hello there';
    final sampleReply = zh ? '你好，有什么我可以帮你的吗？' : 'Hello, how can I help you?';

    String processed(String tpl) {
      final t = (tpl.trim().isEmpty ? '{{ message }}' : tpl);
      // Simple replacements consistent with PromptTransformer
      final dateStr = zh ? DateFormat('yyyy年M月d日', 'zh').format(now) : DateFormat('yyyy-MM-dd').format(now);
      final timeStr = zh ? DateFormat('a h:mm:ss', 'zh').format(now) : DateFormat('HH:mm:ss').format(now);
      return t
          .replaceAll('{{ role }}', 'user')
          .replaceAll('{{ message }}', sampleMsg)
          .replaceAll('{{ time }}', timeStr)
          .replaceAll('{{ date }}', dateStr);
    }

    // System Prompt Card
    final sysCard = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zh ? '系统提示词' : 'System Prompt', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _sysCtrl,
              focusNode: _sysFocus,
              onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(systemPrompt: v)),
              maxLines: 8,
              decoration: InputDecoration(
                hintText: zh ? '输入系统提示词…' : 'Enter system prompt…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.35))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary.withOpacity(0.5))),
                contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(zh ? '可用变量：' : 'Available variables:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _VarExplainList(
              items: [
                (zh ? '日期' : 'Date', '{cur_date}'),
                (zh ? '时间' : 'Time', '{cur_time}'),
                (zh ? '日期和时间' : 'Datetime', '{cur_datetime}'),
                (zh ? '模型ID' : 'Model ID', '{model_id}'),
                (zh ? '模型名称' : 'Model Name', '{model_name}'),
                (zh ? '语言环境' : 'Locale', '{locale}'),
                (zh ? '时区' : 'Timezone', '{timezone}'),
                (zh ? '系统版本' : 'System Version', '{system_version}'),
                (zh ? '设备信息' : 'Device Info', '{device_info}'),
                (zh ? '电池电量' : 'Battery Level', '{battery_level}'),
                (zh ? '用户昵称' : 'Nickname', '{nickname}'),
              ],
              onTapVar: (v) {
                _insertAtCursor(_sysCtrl, v);
                context.read<AssistantProvider>().updateAssistant(a.copyWith(systemPrompt: _sysCtrl.text));
                // Restore focus to the input to keep cursor active
                Future.microtask(() => _sysFocus.requestFocus());
              },
            ),
          ],
        ),
      ),
    );

    // Template Card with preview
    final tmplCard = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zh ? '聊天内容模板' : 'Message Template', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _tmplCtrl,
              focusNode: _tmplFocus,
              maxLines: 4,
              onChanged: (v) => context.read<AssistantProvider>().updateAssistant(a.copyWith(messageTemplate: v)),
              decoration: InputDecoration(
                hintText: '{{ message }}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.35))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary.withOpacity(0.5))),
              ),
            ),
            const SizedBox(height: 8),
            Text(zh ? '可用变量：' : 'Available variables:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _VarExplainList(
              items: [
                (zh ? '角色' : 'Role', '{{ role }}'),
                (zh ? '内容' : 'Message', '{{ message }}'),
                (zh ? '时间' : 'Time', '{{ time }}'),
                (zh ? '日期' : 'Date', '{{ date }}'),
              ],
              onTapVar: (v) {
                _insertAtCursor(_tmplCtrl, v);
                context.read<AssistantProvider>().updateAssistant(a.copyWith(messageTemplate: _tmplCtrl.text));
                // Restore focus to the input to keep cursor active
                Future.microtask(() => _tmplFocus.requestFocus());
              },
            ),

            const SizedBox(height: 12),
            Text(zh ? '预览' : 'Preview', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7))),
            const SizedBox(height: 6),
            // Use real chat message widgets for preview (consistent styling)
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final userMsg = ChatMessage(role: 'user', content: processed(_tmplCtrl.text), conversationId: 'preview');
              final botMsg = ChatMessage(role: 'assistant', content: sampleReply, conversationId: 'preview');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChatMessageWidget(
                    message: userMsg,
                    showModelIcon: false,
                    showTokenStats: false,
                  ),
                  ChatMessageWidget(
                    message: botMsg,
                    showModelIcon: false,
                    showTokenStats: false,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        sysCard,
        const SizedBox(height: 12),
        tmplCard,
      ],
    );
  }
}

class _VarExplainList extends StatelessWidget {
  const _VarExplainList({required this.items, required this.onTapVar});
  final List<(String, String)> items; // (label, var)
  final ValueChanged<String> onTapVar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final it in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${it.$1}: ', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.75))),
              InkWell(
                onTap: () => onTapVar(it.$2),
                child: Text(
                  it.$2,
                  style: TextStyle(color: cs.primary, decoration: TextDecoration.underline, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _McpTab extends StatelessWidget {
  const _McpTab({required this.assistantId});
  final String assistantId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final ap = context.watch<AssistantProvider>();
    final a = ap.getById(assistantId)!;
    final mcp = context.watch<McpProvider>();
    final servers = mcp.servers
        .where((s) => mcp.statusFor(s.id) == McpStatus.connected)
        .toList();

    if (servers.isEmpty) {
      return Center(
        child: Text(
          zh ? '暂无已启动的 MCP 服务器' : 'No running MCP servers',
          style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        ),
      );
    }

    Widget tag(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withOpacity(0.35)),
          ),
          child: Text(text, style: TextStyle(fontSize: 11, color: cs.primary, fontWeight: FontWeight.w600)),
        );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: servers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final s = servers[index];
        final tools = s.tools;
        final enabledTools = tools.where((t) => t.enabled).length;
        final isSelected = a.mcpServerIds.contains(s.id);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isSelected ? cs.primary.withOpacity(isDark ? 0.12 : 0.10) : (isDark ? Colors.white10 : cs.surface);
        final borderColor = isSelected ? cs.primary.withOpacity(0.45) : cs.outlineVariant.withOpacity(0.25);

        return Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () async {
              final set = a.mcpServerIds.toSet();
              if (isSelected) set.remove(s.id); else set.add(s.id);
              await context.read<AssistantProvider>().updateAssistant(a.copyWith(mcpServerIds: set.toList()));
            },
            child: Ink(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: isDark ? [] : AppShadows.soft,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF2F3F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Lucide.Terminal, size: 20, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              tag(zh ? '已连接' : 'Connected'),
                              tag(zh ? '工具: $enabledTools/${tools.length}' : 'Tools: $enabledTools/${tools.length}'),
                              tag(s.transport == McpTransportType.sse ? 'SSE' : 'HTTP'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: isSelected,
                      onChanged: (v) async {
                        final set = a.mcpServerIds.toSet();
                        if (v) set.add(s.id); else set.remove(s.id);
                        await context.read<AssistantProvider>().updateAssistant(a.copyWith(mcpServerIds: set.toList()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SegTabBar extends StatelessWidget {
  const _SegTabBar({required this.controller, required this.tabs});
  final TabController controller;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = controller.index == index;
          return GestureDetector(
            onTap: () => controller.animateTo(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? cs.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: selected ? cs.primary : cs.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({required this.value, required this.min, required this.max, required this.divisions, required this.label, required this.onChanged});
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontFeatures: const [FontFeature.tabularFigures()])),
              ),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: label,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({required this.label, required this.controller, this.hint, this.onChanged, this.enabled = true, this.suffix, this.keyboardType, this.hideLabel = false});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool hideLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideLabel) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: enabled,
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Padding(padding: const EdgeInsets.only(right: 6), child: suffix!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AssistantModelCard extends StatelessWidget {
  const _AssistantModelCard({
    required this.title,
    required this.subtitle,
    required this.onPick,
    this.providerKey,
    this.modelId,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPick;
  final String? providerKey;
  final String? modelId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    String display = zh ? '使用全局默认' : 'Use global default';
    String brandName = display;
    if (providerKey != null && modelId != null) {
      try {
        final settings = context.read<SettingsProvider>();
        final cfg = settings.getProviderConfig(providerKey!);
        final ov = cfg.modelOverrides[modelId] as Map?;
        brandName = cfg.name.isNotEmpty ? cfg.name : providerKey!;
        final mdl = (ov != null && (ov['name'] as String?)?.isNotEmpty == true) ? (ov['name'] as String) : modelId!;
        display = mdl;
      } catch (_) {
        brandName = providerKey ?? '';
        display = modelId ?? '';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7))),
        const SizedBox(height: 10),
        Material(
          color: isDark ? Colors.white10 : cs.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
                boxShadow: isDark ? [] : AppShadows.soft,
              ),
              child: Row(
                children: [
                  _BrandAvatarLike(name: (modelId ?? display), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Lucide.ChevronRight, size: 18, color: cs.onSurface.withOpacity(0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandAvatarLike extends StatelessWidget {
  const _BrandAvatarLike({required this.name, this.size = 20});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Map known names to brand assets used in default_model_page
    String? asset;
    final lower = name.toLowerCase();
    final mapping = <RegExp, String>{
      RegExp(r'openai|gpt|o\d'): 'openai.svg',
      RegExp(r'gemini'): 'gemini-color.svg',
      RegExp(r'google'): 'google-color.svg',
      RegExp(r'claude|anthropic'): 'claude-color.svg',
      RegExp(r'deepseek'): 'deepseek-color.svg',
      RegExp(r'grok|xai'): 'xai.svg',
      RegExp(r'qwen|qwq|qvq|aliyun|dashscope'): 'qwen-color.svg',
      RegExp(r'doubao|ark|volc'): 'doubao-color.svg',
      RegExp(r'openrouter'): 'openrouter.svg',
      RegExp(r'zhipu|glm|智谱'): 'zhipu-color.svg',
      RegExp(r'mistral'): 'mistral-color.svg',
      RegExp(r'meta|llama|(?<!o)llama'): 'meta-color.svg',
      RegExp(r'hunyuan|tencent'): 'hunyuan-color.svg',
      RegExp(r'gemma'): 'gemma-color.svg',
      RegExp(r'perplexity'): 'perplexity-color.svg',
      RegExp(r'alibabacloud|阿里云|百炼'): 'alibabacloud-color.svg',
      RegExp(r'cloudflare'): 'cloudflare-color.svg',
      RegExp(r'minimax'): 'minimax-color.svg',
      RegExp(r'juhenext'): 'juhenext.png',
      RegExp(r'kimi'): 'kimi-color.svg',
      RegExp(r'302'): '302ai-color.svg',
      RegExp(r'stepfun|阶跃|step'): 'stepfun-color.svg',
      RegExp(r'internlm|书生'): 'internlm-color.svg',
      RegExp(r'cohere|command-.+'): 'cohere-color.svg',
      RegExp(r'silicon|硅基'): 'siliconflow-color.svg',
      RegExp(r'aihubmix'): 'aihubmix-color.svg',
      RegExp(r'ollama'): 'ollama.svg',
      RegExp(r'github'): 'github.svg',
    };
    for (final e in mapping.entries) {
      if (e.key.hasMatch(lower)) { asset = 'assets/icons/${e.value}'; break; }
    }
    if (asset != null) {
      if (asset!.endsWith('.svg')) {
        final isColorful = asset!.contains('color');
        final ColorFilter? tint = (isDark && !isColorful) ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: isDark ? Colors.white10 : cs.primary.withOpacity(0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: SvgPicture.asset(asset!, width: size * 0.62, height: size * 0.62, colorFilter: tint),
        );
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: isDark ? Colors.white10 : cs.primary.withOpacity(0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Image.asset(asset!, width: size * 0.62, height: size * 0.62, fit: BoxFit.contain),
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: isDark ? Colors.white10 : cs.primary.withOpacity(0.1), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name.characters.first.toUpperCase() : '?', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: size * 0.42)),
    );
  }
}

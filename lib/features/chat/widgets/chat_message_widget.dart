import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
// import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'dart:convert';
import '../pages/image_viewer_page.dart';
import '../../../core/models/chat_message.dart';
import '../../../icons/lucide_adapter.dart';
import '../../../theme/design_tokens.dart';
import '../../../core/providers/user_provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/sandbox_path_resolver.dart';
import '../../../core/providers/tts_provider.dart';
import '../../../shared/widgets/markdown_with_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final Widget? modelIcon;
  final bool showModelIcon;
  // Assistant identity override
  final bool useAssistantAvatar;
  final String? assistantName;
  final String? assistantAvatar; // path/url/emoji; null => use initial
  final bool showUserAvatar;
  final bool showTokenStats;
  final VoidCallback? onRegenerate;
  final VoidCallback? onResend;
  final VoidCallback? onCopy;
  final VoidCallback? onTranslate;
  final VoidCallback? onSpeak;
  final VoidCallback? onMore;
  // Optional version switcher (branch) UI controls
  final int? versionIndex; // zero-based
  final int? versionCount;
  final VoidCallback? onPrevVersion;
  final VoidCallback? onNextVersion;
  // Optional reasoning UI props (for reasoning-capable models)
  final String? reasoningText;
  final bool reasoningExpanded;
  final bool reasoningLoading;
  final DateTime? reasoningStartAt;
  final DateTime? reasoningFinishedAt;
  final VoidCallback? onToggleReasoning;
  // For multiple reasoning segments
  final List<ReasoningSegment>? reasoningSegments;
  // Optional translation UI props
  final bool translationExpanded;
  final VoidCallback? onToggleTranslation;
  // MCP tool calls/results mixed-in cards
  final List<ToolUIPart>? toolParts;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.modelIcon,
    this.showModelIcon = true,
    this.useAssistantAvatar = false,
    this.assistantName,
    this.assistantAvatar,
    this.showUserAvatar = true,
    this.showTokenStats = true,
    this.onRegenerate,
    this.onResend,
    this.onCopy,
    this.onTranslate,
    this.onSpeak,
    this.onMore,
    this.versionIndex,
    this.versionCount,
    this.onPrevVersion,
    this.onNextVersion,
    this.reasoningText,
    this.reasoningExpanded = false,
    this.reasoningLoading = false,
    this.reasoningStartAt,
    this.reasoningFinishedAt,
    this.onToggleReasoning,
    this.reasoningSegments,
    this.translationExpanded = true,
    this.onToggleTranslation,
    this.toolParts,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final ScrollController _reasoningScroll = ScrollController();
  bool _tickActive = false;
  late final Ticker _ticker = Ticker((_) {
    if (mounted && _tickActive) setState(() {});
  });

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ChatMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  void _syncTicker() {
    final loading = widget.reasoningStartAt != null && widget.reasoningFinishedAt == null;
    _tickActive = loading;
    if (loading) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _reasoningScroll.dispose();
    super.dispose();
  }

  Widget _buildUserAvatar(UserProvider userProvider, ColorScheme cs) {
    Widget avatarContent;

    if (userProvider.avatarType == 'emoji' && userProvider.avatarValue != null) {
      avatarContent = Center(
        child: Text(
          userProvider.avatarValue!,
          style: const TextStyle(fontSize: 18),
        ),
      );
    } else if (userProvider.avatarType == 'url' && userProvider.avatarValue != null) {
      avatarContent = ClipOval(
        child: Image.network(
          userProvider.avatarValue!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Lucide.User,
            size: 18,
            color: cs.primary,
          ),
        ),
      );
    } else if (userProvider.avatarType == 'file' && userProvider.avatarValue != null) {
      avatarContent = ClipOval(
        child: Image.file(
          File(SandboxPathResolver.fix(userProvider.avatarValue!)),
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Lucide.User,
            size: 18,
            color: cs.primary,
          ),
        ),
      );
    } else {
      avatarContent = Icon(
        Lucide.User,
        size: 18,
        color: cs.primary,
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: avatarContent,
    );
  }

  Widget _buildToolMessage() {
    // Parse JSON payload embedded in tool message content
    String toolName = 'tool';
    Map<String, dynamic> args = const {};
    String result = '';
    try {
      final obj = jsonDecode(widget.message.content) as Map<String, dynamic>;
      toolName = (obj['tool'] ?? 'tool').toString();
      final a = obj['arguments'];
      if (a is Map<String, dynamic>) args = a;
      result = (obj['result'] ?? '').toString();
    } catch (_) {}

    final part = ToolUIPart(
      id: widget.message.id,
      toolName: toolName,
      arguments: args,
      content: result,
      loading: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _ToolCallItem(part: part),
    );
  }

  Widget _buildUserMessage() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final parsed = _parseUserContent(widget.message.content);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header: User info and avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userProvider.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateFormat.format(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              if (widget.showUserAvatar) ...[
                const SizedBox(width: 8),
                // User avatar
                _buildUserAvatar(userProvider, cs),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Message content
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.primary.withOpacity(0.15)
                  : cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (parsed.text.isNotEmpty)
                  Text(
                    parsed.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                if (parsed.images.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final imgs = parsed.images;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: imgs.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final p = entry.value;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ImageViewerPage(images: imgs, initialIndex: idx),
                                transitionDuration: const Duration(milliseconds: 360),
                                reverseTransitionDuration: const Duration(milliseconds: 280),
                                transitionsBuilder: (context, anim, sec, child) {
                                  final curved = CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  );
                                  return FadeTransition(
                                    opacity: curved,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.02), // subtle upward drift
                                        end: Offset.zero,
                                      ).animate(curved),
                                      child: child,
                                    ),
                                  );
                                },
                              ));
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Hero(
                                tag: 'img:$p',
                                child: Image.file(
                                  File(SandboxPathResolver.fix(p)),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 96,
                                    height: 96,
                                    color: Colors.black12,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
                if (parsed.docs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: parsed.docs.map((d) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          overlayColor: MaterialStateProperty.resolveWith(
                                (states) => cs.primary.withOpacity(states.contains(MaterialState.pressed) ? 0.14 : 0.08),
                          ),
                          splashColor: cs.primary.withOpacity(0.18),
                          onTap: () async {
                            try {
                              final fixed = SandboxPathResolver.fix(d.path);
                              final f = File(fixed);
                              if (!(await f.exists())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('文件不存在: ${d.fileName}')),
                                );
                                return;
                              }
                              final res = await OpenFilex.open(fixed, type: d.mime);
                              if (res.type != ResultType.done) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('无法打开文件: ${res.message ?? res.type.toString()}')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('打开文件失败: $e')),
                              );
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : cs.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 16),
                                  const SizedBox(width: 6),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 180),
                                    child: Text(d.fileName, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Lucide.Copy, size: 16),
                onPressed: widget.onCopy ?? () {
                  Clipboard.setData(ClipboardData(text: widget.message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              IconButton(
                icon: Icon(Lucide.RefreshCw, size: 16),
                onPressed: widget.onResend,
                tooltip: '重新发送',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              IconButton(
                icon: Icon(Lucide.Ellipsis, size: 16),
                onPressed: widget.onMore,
                tooltip: '更多',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              if ((widget.versionCount ?? 1) > 1) ...[
                const SizedBox(width: 6),
                _BranchSelector(
                  index: widget.versionIndex ?? 0,
                  total: widget.versionCount ?? 1,
                  onPrev: widget.onPrevVersion,
                  onNext: widget.onNextVersion,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _ParsedUserContent _parseUserContent(String raw) {
    final imgRe = RegExp(r"\[image:(.+?)\]");
    final fileRe = RegExp(r"\[file:(.+?)\|(.+?)\|(.+?)\]");
    final images = <String>[];
    final docs = <_DocRef>[];
    final buffer = StringBuffer();
    int idx = 0;
    while (idx < raw.length) {
      final m1 = imgRe.matchAsPrefix(raw, idx);
      final m2 = fileRe.matchAsPrefix(raw, idx);
      if (m1 != null) {
        final p = m1.group(1)?.trim();
        if (p != null && p.isNotEmpty) images.add(p);
        idx = m1.end;
        continue;
      }
      if (m2 != null) {
        final path = m2.group(1)?.trim() ?? '';
        final name = m2.group(2)?.trim() ?? 'file';
        final mime = m2.group(3)?.trim() ?? 'text/plain';
        docs.add(_DocRef(path: path, fileName: name, mime: mime));
        idx = m2.end;
        continue;
      }
      buffer.write(raw[idx]);
      idx++;
    }
    return _ParsedUserContent(buffer.toString().trim(), images, docs);
  }

  Widget _buildAssistantMessage() {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Model info and time
          Row(
            children: [
              if (widget.useAssistantAvatar) ...[
                _buildAssistantAvatar(cs),
                const SizedBox(width: 8),
              ] else if (widget.showModelIcon) ...[
                widget.modelIcon ?? Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Lucide.Bot, size: 18, color: cs.secondary),
                ),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.useAssistantAvatar
                        ? (widget.assistantName?.trim().isNotEmpty == true ? widget.assistantName!.trim() : 'Assistant')
                        : (widget.message.modelId ?? 'AI Assistant'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _dateFormat.format(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (widget.showTokenStats && widget.message.totalTokens != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${widget.message.totalTokens} tokens',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mixed reasoning and tool sections
          if (widget.reasoningSegments != null && widget.reasoningSegments!.isNotEmpty) ...[
            // Build mixed content using tool index ranges carried by segments
            ...() {
              final List<Widget> mixedContent = [];
              final tools = widget.toolParts ?? const <ToolUIPart>[];
              final segments = widget.reasoningSegments!;

              for (int i = 0; i < segments.length; i++) {
                final seg = segments[i];

                // Add the reasoning segment (if any text)
                if (seg.text.isNotEmpty) {
                  mixedContent.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ReasoningSection(
                        text: seg.text,
                        expanded: seg.expanded,
                        loading: seg.loading,
                        startAt: seg.startAt,
                        finishedAt: seg.finishedAt,
                        onToggle: seg.onToggle,
                      ),
                    ),
                  );
                }

                // Determine tool range mapped to this segment: [start, end)
                int start = seg.toolStartIndex;
                final int end = (i < segments.length - 1)
                    ? segments[i + 1].toolStartIndex
                    : tools.length;

                // Clamp to bounds and ensure non-decreasing
                if (start < 0) start = 0;
                if (start > tools.length) start = tools.length;
                final int clampedEnd = end.clamp(start, tools.length);

                for (int k = start; k < clampedEnd; k++) {
                  mixedContent.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ToolCallItem(part: tools[k]),
                    ),
                  );
                }
              }

              return mixedContent;
            }(),
          ] else ...[
            // Fallback to old behavior if no reasoning segments
            // Reasoning preview (if provided)
            if ((widget.reasoningText != null && widget.reasoningText!.isNotEmpty) || widget.reasoningLoading) ...[
              _ReasoningSection(
                text: widget.reasoningText ?? '',
                expanded: widget.reasoningExpanded,
                loading: widget.reasoningFinishedAt == null,
                startAt: widget.reasoningStartAt,
                finishedAt: widget.reasoningFinishedAt,
                onToggle: widget.onToggleReasoning,
              ),
              const SizedBox(height: 8),
            ],
            // Tool call placeholders before content
            if ((widget.toolParts ?? const <ToolUIPart>[]).isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.toolParts!
                    .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ToolCallItem(part: p),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
          ],
          // Message content with markdown support (fill available width)
          Container(
            width: double.infinity,
            child: widget.message.isStreaming && widget.message.content.isEmpty
                ? Row(
              children: [
                _LoadingIndicator(),
                const SizedBox(width: 8),
                Text(
                  '正在思考...',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownWithCodeHighlight(
                  text: widget.message.content,
                  onCitationTap: (id) => _handleCitationTap(id),
                ),
                // Inline sources removed; show a summary card at bottom instead
                if (widget.message.isStreaming)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _LoadingIndicator(),
                  ),
                // Translation section (collapsible)
                if (widget.message.translation != null && widget.message.translation!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      // Match reasoning section background; no border
                      color: Theme.of(context).colorScheme.primaryContainer
                          .withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: const Cubic(0.2, 0.8, 0.2, 1),
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: widget.onToggleTranslation,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Lucide.Languages,
                                    size: 16,
                                    color: cs.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '翻译',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cs.secondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    widget.translationExpanded
                                        ? Lucide.ChevronDown
                                        : Lucide.ChevronRight,
                                    size: 18,
                                    color: cs.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.translationExpanded) ...[
                            const SizedBox(height: 8),
                            if (widget.message.translation == '翻译中...')
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                                child: Row(
                                  children: [
                                    _LoadingIndicator(),
                                    const SizedBox(width: 8),
                                    Text(
                                      '翻译中...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: cs.onSurface.withOpacity(0.5),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                                child: MarkdownWithCodeHighlight(
                                  text: widget.message.translation!,
                                  onCitationTap: (id) => _handleCitationTap(id),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Sources summary card (tap to open full citations)
          if (_latestSearchItems().isNotEmpty) ...[
            const SizedBox(height: 8),
            _SourcesSummaryCard(
              count: _latestSearchItems().length,
              onTap: () => _showCitationsSheet(_latestSearchItems()),
            ),
          ],
          // Action buttons
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(Lucide.Copy, size: 16),
                onPressed: widget.onCopy ?? () {
                  Clipboard.setData(ClipboardData(text: widget.message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              IconButton(
                icon: Icon(Lucide.RefreshCw, size: 16),
                onPressed: widget.onRegenerate,
                tooltip: '重新生成',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              Consumer<TtsProvider>(
                builder: (context, tts, _) => IconButton(
                  icon: Icon(tts.isSpeaking ? Lucide.CircleStop : Lucide.Volume2, size: 16),
                  onPressed: widget.onSpeak,
                  tooltip: tts.isSpeaking ? '停止' : '朗读',
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(Lucide.Languages, size: 16),
                onPressed: widget.onTranslate,
                tooltip: '翻译',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              IconButton(
                icon: Icon(Lucide.Ellipsis, size: 16),
                onPressed: widget.onMore,
                tooltip: '更多',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
              ),
              if ((widget.versionCount ?? 1) > 1) ...[
                const SizedBox(width: 6),
                _BranchSelector(
                  index: widget.versionIndex ?? 0,
                  total: widget.versionCount ?? 1,
                  onPrev: widget.onPrevVersion,
                  onNext: widget.onNextVersion,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Try resolve citation id -> url from the latest search_web tool results of this assistant message
  void _handleCitationTap(String id) async {
    final items = _latestSearchItems();
    final match = items.cast<Map<String, dynamic>?>().firstWhere(
      (e) => (e?['id']?.toString() ?? '') == id,
      orElse: () => null,
    );
    final url = match?['url']?.toString();
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到引用来源')),
        );
      }
      return;
    }
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开链接: $url')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打开链接失败')),
        );
      }
    }
  }

  // Extract items from the last search_web tool result for this assistant message
  List<Map<String, dynamic>> _latestSearchItems() {
    final parts = widget.toolParts ?? const <ToolUIPart>[];
    for (int i = parts.length - 1; i >= 0; i--) {
      final p = parts[i];
      if (p.toolName == 'search_web' && (p.content?.isNotEmpty ?? false)) {
        try {
          final obj = jsonDecode(p.content!) as Map<String, dynamic>;
          final arr = obj['items'] as List? ?? const <dynamic>[];
          return [
            for (final it in arr)
              if (it is Map)
                it.cast<String, dynamic>()
          ];
        } catch (_) {
          return const <Map<String, dynamic>>[];
        }
      }
    }
    return const <Map<String, dynamic>>[];
  }

  void _showCitationsSheet(List<Map<String, dynamic>> items) {
    final cs = Theme.of(context).colorScheme;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Lucide.BookOpen, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isZh ? '引用（共${items.length}条）' : 'Citations (${items.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < items.length; i++)
                              _SourceRow(
                                index: (items[i]['index'] ?? (i + 1)).toString(),
                                title: (items[i]['title'] ?? '').toString(),
                                url: (items[i]['url'] ?? '').toString(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssistantAvatar(ColorScheme cs) {
    final av = (widget.assistantAvatar ?? '').trim();
    if (av.isNotEmpty) {
      if (av.startsWith('http')) {
        return ClipOval(
          child: Image.network(av, width: 32, height: 32, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _assistantInitial(cs)),
        );
      }
      if (av.startsWith('/') || av.contains(':')) {
        return ClipOval(
          child: Image.file(File(av), width: 32, height: 32, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _assistantInitial(cs)),
        );
      }
      // treat as emoji or single char label
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(av.characters.take(1).toString(), style: const TextStyle(fontSize: 18)),
      );
    }
    return _assistantInitial(cs);
  }

  Widget _assistantInitial(ColorScheme cs) {
    final name = (widget.assistantName ?? '').trim();
    final ch = name.isNotEmpty ? name.characters.first.toUpperCase() : 'A';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(ch, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.role == 'user') return _buildUserMessage();
    if (widget.message.role == 'tool') return _buildToolMessage();
    return _buildAssistantMessage();
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({required this.index, required this.total, this.onPrev, this.onNext});
  final int index; // zero-based
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canPrev = index > 0;
    final canNext = index < total - 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: canPrev ? onPrev : null,
          borderRadius: BorderRadius.circular(6),
          child: Icon(Lucide.ChevronLeft, size: 16, color: canPrev ? cs.onSurface : cs.onSurface.withOpacity(0.35)),
        ),
        const SizedBox(width: 6),
        Text('${index + 1}/$total', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.8), fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        InkWell(
          onTap: canNext ? onNext : null,
          borderRadius: BorderRadius.circular(6),
          child: Icon(Lucide.ChevronRight, size: 16, color: canNext ? cs.onSurface : cs.onSurface.withOpacity(0.35)),
        ),
      ],
    );
  }
}

// Loading indicator similar to OpenAI's breathing circle
class _LoadingIndicator extends StatefulWidget {
  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    // Smoother, symmetric breathing with reverse to avoid jump cuts
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        // Scale and opacity gently breathe in sync
        final scale = 0.9 + 0.2 * _curve.value; // 0.9 -> 1.1
        final opacity = 0.6 + 0.4 * _curve.value; // 0.6 -> 1.0
        final base = cs.primary;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: base.withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: base.withOpacity(0.35 * opacity),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParsedUserContent {
  final String text;
  final List<String> images;
  final List<_DocRef> docs;
  _ParsedUserContent(this.text, this.images, this.docs);
}

class _DocRef {
  final String path;
  final String fileName;
  final String mime;
  _DocRef({required this.path, required this.fileName, required this.mime});
}

// UI data for MCP tool calls/results
class ToolUIPart {
  final String id;
  final String toolName;
  final Map<String, dynamic> arguments;
  final String? content; // null means still loading/result not yet available
  final bool loading;
  const ToolUIPart({
    required this.id,
    required this.toolName,
    required this.arguments,
    this.content,
    this.loading = false,
  });
}

// Data for a reasoning segment (for mixed display)
class ReasoningSegment {
  final String text;
  final bool expanded;
  final bool loading;
  final DateTime? startAt;
  final DateTime? finishedAt;
  final VoidCallback? onToggle;
  // Index of the first tool call that occurs after this segment starts.
  final int toolStartIndex;

  const ReasoningSegment({
    required this.text,
    required this.expanded,
    required this.loading,
    this.startAt,
    this.finishedAt,
    this.onToggle,
    this.toolStartIndex = 0,
  });
}

class _ToolCallItem extends StatelessWidget {
  const _ToolCallItem({required this.part});
  final ToolUIPart part;

  IconData _iconFor(String name) {
    switch (name) {
      case 'create_memory':
      case 'edit_memory':
        return Lucide.Library;
      case 'delete_memory':
        return Lucide.Trash2;
      case 'search_web':
        return Lucide.Earth;
      default:
        return Lucide.Wrench;
    }
  }


  String _titleFor(BuildContext context, String name, Map<String, dynamic> args, {required bool isResult}) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    switch (name) {
      case 'create_memory':
        return zh ? (isResult ? '调用工具 · 创建记忆' : '调用工具 · 创建记忆') : (isResult ? 'Tool Result · Create Memory' : 'Tool Call · Create Memory');
      case 'edit_memory':
        return zh ? (isResult ? '调用工具 · 编辑记忆' : '调用工具 · 编辑记忆') : (isResult ? 'Tool Result · Edit Memory' : 'Tool Call · Edit Memory');
      case 'delete_memory':
        return zh ? (isResult ? '调用工具 · 删除记忆' : '调用工具 · 删除记忆') : (isResult ? 'Tool Result · Delete Memory' : 'Tool Call · Delete Memory');
      case 'search_web':
        final q = (args['query'] ?? '').toString();
        return zh ? (isResult ? '联网检索: $q' : '联网检索: $q') : (isResult ? 'Web Search: $q' : 'Web Search: $q');
      default:
        return zh ? (isResult ? '调用工具: $name' : '调用工具: $name') : (isResult ? 'Tool Result: $name' : 'Tool Call: $name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = cs.primaryContainer.withOpacity(isDark ? 0.25 : 0.30);
    final fg = cs.onPrimaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: part.loading
                    ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                )
                    : Icon(_iconFor(part.toolName), size: 18, color: cs.secondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleFor(context, part.toolName, part.arguments, isResult: !part.loading),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.secondary),
                    ),
                    // No inline result preview; tap to view details in sheet
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final argsPretty = const JsonEncoder.withIndent('  ').convert(part.arguments);
    final resultText = (part.content ?? '').isNotEmpty ? part.content! : (zh ? '（暂无结果）' : '(No result yet)');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_iconFor(part.toolName), size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _titleFor(context, part.toolName, part.arguments, isResult: !part.loading),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(zh ? '参数' : 'Arguments', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
                      ),
                      child: SelectableText(argsPretty, style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Text(zh ? '结果' : 'Result', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
                      ),
                      child: SelectableText(resultText, style: const TextStyle(fontSize: 12)),
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

class _SourcesList extends StatelessWidget {
  const _SourcesList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '引用 (${items.length})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.75)),
            ),
          ),
          for (int i = 0; i < items.length; i++)
            _SourceRow(index: (items[i]['index'] ?? (i + 1)).toString(), title: (items[i]['title'] ?? '').toString(), url: (items[i]['url'] ?? '').toString()),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.index, required this.title, required this.url});
  final String index;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.20),
              borderRadius: BorderRadius.circular(9),
            ),
            margin: const EdgeInsets.only(top: 2),
            child: Text(index, style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () async {
                try {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              child: Text(
                title.isNotEmpty ? title : url,
                style: TextStyle(color: cs.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesSummaryCard extends StatelessWidget {
  const _SourcesSummaryCard({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final label = isZh ? '共$count条引用' : 'Citations ($count)';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            // Match deep thinking (reasoning) card background
            color: cs.primaryContainer.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.30,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Lucide.BookOpen, size: 16, color: cs.secondary),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.secondary)),
            ],
          ),
        ),
      ),
    );
  }
}

ImageProvider _imageProviderFor(String src) {
  if (src.startsWith('http://') || src.startsWith('https://')) {
    return NetworkImage(src);
  }
  if (src.startsWith('data:')) {
    try {
      final base64Marker = 'base64,';
      final idx = src.indexOf(base64Marker);
      if (idx != -1) {
        final b64 = src.substring(idx + base64Marker.length);
        return MemoryImage(base64Decode(b64));
      }
    } catch (_) {}
  }
  return FileImage(File(src));
}

class _ReasoningSection extends StatefulWidget {
  const _ReasoningSection({
    required this.text,
    required this.expanded,
    required this.loading,
    required this.startAt,
    required this.finishedAt,
    this.onToggle,
  });

  final String text;
  final bool expanded;
  final bool loading;
  final DateTime? startAt;
  final DateTime? finishedAt;
  final VoidCallback? onToggle;

  @override
  State<_ReasoningSection> createState() => _ReasoningSectionState();
}

class _ReasoningSectionState extends State<_ReasoningSection> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = Ticker((_) => setState(() {}));
  final ScrollController _scroll = ScrollController();
  bool _hasOverflow = false;

  String _sanitize(String s) {
    return s.replaceAll('\r', '').trim();
  }

  String _elapsed() {
    final start = widget.startAt;
    if (start == null) return '';
    final end = widget.finishedAt ?? DateTime.now();
    final ms = end.difference(start).inMilliseconds;
    return '(${(ms / 1000).toStringAsFixed(1)}s)';
  }

  @override
  void initState() {
    super.initState();
    if (widget.loading) _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void didUpdateWidget(covariant _ReasoningSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !_ticker.isActive) _ticker.start();
    if (!widget.loading && _ticker.isActive) _ticker.stop();
    if (widget.loading && widget.expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _checkOverflow() {
    if (!_scroll.hasClients) return;
    final over = _scroll.position.maxScrollExtent > 0.5;
    if (over != _hasOverflow && mounted) setState(() => _hasOverflow = over);
  }

  String _sanitizedeepthink(String s) {
    // 统一换行
    s = s.replaceAll('\r\n', '\n');

    // 去掉首尾零宽字符（模型有时会插入）
    s = s
        .replaceAll(RegExp(r'^[\u200B\u200C\u200D\uFEFF]+'), '')
        .replaceAll(RegExp(r'[\u200B\u200C\u200D\uFEFF]+$'), '');

    // 去掉**开头**的纯空白行
    s = s.replaceFirst(RegExp(r'^\s*\n+'), '');

    // 去掉**结尾**的纯空白行
    s = s.replaceFirst(RegExp(r'\n+\s*$'), '');

    return s;
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loading = widget.loading;

    // Android-like surface style
    final bg = cs.primaryContainer.withOpacity(isDark ? 0.25 : 0.30);
    final fg = cs.onPrimaryContainer;

    final curve = const Cubic(0.2, 0.8, 0.2, 1);

    // Build a compact header with optional scrolling preview when loading
    Widget header = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/deepthink.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            _Shimmer(
              enabled: loading,
              child: Text('深度思考', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.secondary)),
            ),
            const SizedBox(width: 8),
            if (widget.startAt != null)
              _Shimmer(
                enabled: loading,
                child: Text(_elapsed(), style: TextStyle(fontSize: 13, color: cs.secondary.withOpacity(0.9))),
              ),
            // No header marquee; content area handles scrolling when loading
            const Spacer(),
            Icon(
              widget.expanded
                  ? Lucide.ChevronDown
                  : (loading && !widget.expanded ? Lucide.ChevronRight : Lucide.ChevronRight),
              size: 18,
              color: cs.secondary,
            ),
          ],
        ),
      ),
    );

// 抽公共样式，继承当前 DefaultTextStyle（从而继承正确的颜色）
    final TextStyle baseStyle =
    DefaultTextStyle.of(context).style.copyWith(fontSize: 12.5, height: 1.32);

    const StrutStyle baseStrut = StrutStyle(
      forceStrutHeight: true,
      fontSize: 12.5,
      height: 1.32,
      leading: 0,
    );

    const TextHeightBehavior baseTHB = TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
      leadingDistribution: TextLeadingDistribution.proportional,
    );

    final bool isLoading = loading;
    final display = _sanitize(widget.text);

// 未加载：不要再指定 color: fg，让它继承和“加载中”相同的颜色
    Widget body = Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: Text(
        display.isNotEmpty ? display : '…',
        style: baseStyle,                  // 统一
        strutStyle: baseStrut,             // 统一
        textHeightBehavior: baseTHB,       // 统一
      ),
    );

    if (isLoading) {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 80),
          child: _hasOverflow
              ? ShaderMask(
            shaderCallback: (rect) {
              final h = rect.height;
              const double topFade = 12.0;
              const double bottomFade = 28.0;
              final double sTop = (topFade / h).clamp(0.0, 1.0);
              final double sBot = (1.0 - bottomFade / h).clamp(0.0, 1.0);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Color(0x00FFFFFF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: [0.0, sTop, sBot, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
                return false;
              },
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  display.isNotEmpty ? display : '…',
                  style: baseStyle,            // 统一
                  strutStyle: baseStrut,       // 统一
                  textHeightBehavior: baseTHB, // 统一
                ),
              ),
            ),
          )
              : SingleChildScrollView(
            controller: _scroll,
            physics: const NeverScrollableScrollPhysics(),
            child: Text(
              display.isNotEmpty ? display : '…',
              style: baseStyle,            // 统一（原来是 12）
              strutStyle: baseStrut,
              textHeightBehavior: baseTHB,
            ),
          ),
        ),
      );
    }


    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: curve,
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              if (widget.expanded || isLoading) body,
            ],
          ),
        ),
      ),
    );
  }
}

// Lightweight shimmer effect without external dependency
class _Shimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const _Shimmer({required this.child, this.enabled = false});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with TickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    if (widget.enabled) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant _Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_c.isAnimating) _c.repeat();
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value; // 0..1
        return ShaderMask(
          shaderCallback: (rect) {
            final width = rect.width;
            final gradientWidth = width * 0.4;
            final dx = (width + gradientWidth) * t - gradientWidth;
            final shaderRect = Rect.fromLTWH(-dx, 0, width + gradientWidth * 2, rect.height);
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.35),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(shaderRect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Simple marquee that bounces horizontally if text exceeds maxWidth
class _Marquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double maxWidth;
  final Duration duration;
  const _Marquee({
    required this.text,
    required this.style,
    this.maxWidth = 160,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _measure(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.maxWidth;
    final textWidth = _measure(widget.text, widget.style);
    final needScroll = textWidth > w;
    final gap = 32.0;
    final loopWidth = textWidth + gap;
    return SizedBox(
      width: w,
      height: (widget.style.fontSize ?? 13) * 1.35,
      child: ClipRect(
        child: needScroll
            ? AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.linear.transform(_c.value);
            final dx = -loopWidth * t;
            return ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0.0, 0.07, 0.93, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                    SizedBox(width: gap),
                    Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                  ],
                ),
              ),
            );
          },
        )
            : Align(alignment: Alignment.centerLeft, child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false)),
      ),
    );
  }
}

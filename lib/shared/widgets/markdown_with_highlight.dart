import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:gpt_markdown/custom_widgets/markdown_config.dart' show GptMarkdownConfig;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/atom-one-dark-reasonable.dart';
import '../../../icons/lucide_adapter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import '../../utils/sandbox_path_resolver.dart';
import '../../features/chat/pages/image_viewer_page.dart';

/// gpt_markdown with custom code block highlight and inline code styling.
class MarkdownWithCodeHighlight extends StatelessWidget {
  const MarkdownWithCodeHighlight({
    super.key,
    required this.text,
    this.onCitationTap,
  });

  final String text;
  final void Function(String id)? onCitationTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final imageUrls = _extractImageUrls(text);

    final normalized = _preprocessFences(text);
    // Use default text style but avoid forcing color, so HR can use its own color
    final baseTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: null);

    // Replace default HrLine with a softer, shorter one
    final components = List<MarkdownComponent>.from(MarkdownComponent.globalComponents);
    final hrIdx = components.indexWhere((c) => c is HrLine);
    if (hrIdx != -1) components[hrIdx] = SoftHrLine();
    final bqIdx = components.indexWhere((c) => c is BlockQuote);
    if (bqIdx != -1) components[bqIdx] = ModernBlockQuote();
    final cbIdx = components.indexWhere((c) => c is CheckBoxMd);
    if (cbIdx != -1) components[cbIdx] = ModernCheckBoxMd();
    final rbIdx = components.indexWhere((c) => c is RadioButtonMd);
    if (rbIdx != -1) components[rbIdx] = ModernRadioMd();
    return GptMarkdown(
      normalized,
      style: baseTextStyle,
      followLinkColor: true,
      useDollarSignsForLatex: true,
      onLinkTap: (url, title) => _handleLinkTap(context, url),
      components: components,
      imageBuilder: (ctx, url) {
        final imgs = imageUrls.isNotEmpty ? imageUrls : [url];
        final idx = imgs.indexOf(url);
        final initial = idx >= 0 ? idx : 0;
        final provider = _imageProviderFor(url);
        return GestureDetector(
          onTap: () {
            Navigator.of(ctx).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => ImageViewerPage(images: imgs, initialIndex: initial),
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
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
            ));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: provider,
                  width: constraints.maxWidth,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Icon(Icons.broken_image),
                ),
              );
            },
          ),
        );
      },
      linkBuilder: (ctx, span, url, style) {
        final label = span.toPlainText().trim();
        // Special handling: [citation](index:id)
        if (label.toLowerCase() == 'citation') {
          final parts = url.split(':');
          if (parts.length == 2) {
            final indexText = parts[0].trim();
            final id = parts[1].trim();
            final cs = Theme.of(ctx).colorScheme;
            return GestureDetector(
              onTap: () {
                if (onCitationTap != null && id.isNotEmpty) {
                  onCitationTap!(id);
                } else {
                  // Fallback: do nothing
                }
              },
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  indexText,
                  style: const TextStyle(fontSize: 12, height: 1.0),
                ),
              ),
            );
          }
        }
        // Default link appearance
        final cs = Theme.of(ctx).colorScheme;
        return Text(
          span.toPlainText(),
          style: style.copyWith(
            color: cs.primary,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.start,
          textScaler: MediaQuery.of(ctx).textScaler,
        );
      },
      orderedListBuilder: (ctx, no, child, cfg) {
        final style = (cfg.style ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w400, // normal weight
        );
        return Directionality(
          textDirection: cfg.textDirection,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
                child: Text("$no.", style: style),
              ),
              Flexible(child: child),
            ],
          ),
        );
      },
      tableBuilder: (ctx, rows, style, cfg) {
        final cs = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final borderColor = cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.28);
        final headerBg = cs.primary.withOpacity(isDark ? 0.10 : 0.08);
        final headerStyle = (style).copyWith(fontWeight: FontWeight.w600);

        int maxCol = 0;
        for (final r in rows) {
          if (r.fields.length > maxCol) maxCol = r.fields.length;
        }

        Widget cell(String text, TextAlign align, {bool header = false, bool lastCol = false, bool lastRow = false}) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                right: lastCol ? BorderSide.none : BorderSide(color: borderColor, width: 0.5),
                bottom: lastRow ? BorderSide.none : BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: Align(
              alignment: () {
                switch (align) {
                  case TextAlign.center:
                    return Alignment.center;
                  case TextAlign.right:
                    return Alignment.centerRight;
                  default:
                    return Alignment.centerLeft;
                }
              }(),
              child: Text(text, style: header ? headerStyle : style, textAlign: align),
            ),
          );
        }

        final table = Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            if (rows.isNotEmpty)
              TableRow(
                decoration: BoxDecoration(
                  color: headerBg,
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                ),
                children: List.generate(maxCol, (i) {
                  final f = i < rows.first.fields.length ? rows.first.fields[i] : null;
                  final txt = f?.data ?? '';
                  final align = f?.alignment ?? TextAlign.left;
                  return cell(txt, align, header: true, lastCol: i == maxCol - 1, lastRow: false);
                }),
              ),
            for (int r = 1; r < rows.length; r++)
              TableRow(
                children: List.generate(maxCol, (c) {
                  final f = c < rows[r].fields.length ? rows[r].fields[c] : null;
                  final txt = f?.data ?? '';
                  final align = f?.alignment ?? TextAlign.left;
                  return cell(txt, align, lastCol: c == maxCol - 1, lastRow: r == rows.length - 1);
                }),
              ),
          ],
        );

        return Scrollbar(
          thumbVisibility: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surface,
                  border: Border.all(color: borderColor, width: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: table,
              ),
            ),
          ),
        );
      },
      // Inline `code` styling via highlightBuilder in gpt_markdown
      highlightBuilder: (ctx, inline, style) {
        String softened = _softBreakInline(inline);
        final bg = isDark ? Colors.white12 : const Color(0xFFF1F3F5);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.22)),
          ),
          child: Text(
            softened,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.3,
            ).copyWith(color: Theme.of(context).colorScheme.onSurface),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        );
      },
      // Fenced code block styling via codeBuilder
      codeBuilder: (ctx, name, code, closed) {
        final lang = name.trim();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _displayLanguage(context, lang),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.secondary,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isZh(context) ? '已复制代码' : 'Code copied'),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Lucide.Copy,
                      size: 16,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                    tooltip: _isZh(context) ? '复制' : 'Copy',
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HighlightView(
                  code,
                  language: _normalizeLanguage(lang) ?? 'plaintext',
                  theme: _transparentBgTheme(
                    isDark ? atomOneDarkReasonableTheme : githubTheme,
                  ),
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _displayLanguage(BuildContext context, String? raw) {
    final zh = _isZh(context);
    final t = raw?.trim();
    if (t != null && t.isNotEmpty) return t;
    return zh ? '代码' : 'Code';
  }

  static bool _isZh(BuildContext context) => Localizations.localeOf(context).languageCode == 'zh';

  static Map<String, TextStyle> _transparentBgTheme(Map<String, TextStyle> base) {
    final m = Map<String, TextStyle>.from(base);
    final root = base['root'];
    if (root != null) {
      m['root'] = root.copyWith(backgroundColor: Colors.transparent);
    } else {
      m['root'] = const TextStyle(backgroundColor: Colors.transparent);
    }
    return m;
  }

  static String? _normalizeLanguage(String? lang) {
    if (lang == null || lang.trim().isEmpty) return null;
    final l = lang.trim().toLowerCase();
    switch (l) {
      case 'js':
      case 'javascript':
        return 'javascript';
      case 'ts':
      case 'typescript':
        return 'typescript';
      case 'sh':
      case 'zsh':
      case 'bash':
      case 'shell':
        return 'bash';
      case 'yml':
        return 'yaml';
      case 'py':
      case 'python':
        return 'python';
      case 'rb':
      case 'ruby':
        return 'ruby';
      case 'kt':
      case 'kotlin':
        return 'kotlin';
      case 'java':
        return 'java';
      case 'c#':
      case 'cs':
      case 'csharp':
        return 'csharp';
      case 'objc':
      case 'objectivec':
        return 'objectivec';
      case 'swift':
        return 'swift';
      case 'go':
      case 'golang':
        return 'go';
      case 'php':
        return 'php';
      case 'dart':
        return 'dart';
      case 'json':
        return 'json';
      case 'html':
        return 'xml';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'sql':
        return 'sql';
      default:
        return l; // try as-is
    }
  }

  static String _preprocessFences(String input) {
    // 1) Move fenced code from list lines to the next line: "* ```lang" -> "*\n```lang"
    final bulletFence = RegExp(r"^(\s*(?:[*+-]|\d+\.)\s+)```([^\s`]*)\s*$", multiLine: true);
    var out = input.replaceAllMapped(bulletFence, (m) => "${m[1]}\n```${m[2]}" );

    // 2) Dedent opening fences: leading spaces before ```lang
    final dedentOpen = RegExp(r"^[ \t]+```([^\n`]*)\s*$", multiLine: true);
    out = out.replaceAllMapped(dedentOpen, (m) => "```${m[1]}" );

    // 3) Dedent closing fences: leading spaces before ```
    final dedentClose = RegExp(r"^[ \t]+```\s*$", multiLine: true);
    out = out.replaceAllMapped(dedentClose, (m) => "```" );

    // 4) Ensure closing fences are on their own line: transform "} ```" or "}```" into "}\n```"
    final inlineClosing = RegExp(r"([^\r\n`])```(?=\s*(?:\r?\n|$))");
    out = out.replaceAllMapped(inlineClosing, (m) => "${m[1]}\n```");

    return out;
  }

  static String _softBreakInline(String input) {
    // Insert zero-width break for inline code segments with long tokens.
    if (input.length < 60) return input;
    final buf = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buf.write(input[i]);
      if ((i + 1) % 24 == 0) buf.write('\u200B');
    }
    return buf.toString();
  }

  Future<void> _handleLinkTap(BuildContext context, String url) async {
    Uri uri;
    try {
      uri = _normalizeUrl(url);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isZh(context) ? '无效链接' : 'Invalid link')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isZh(context) ? '无法打开链接' : 'Cannot open link')),
      );
    }
  }

  Uri _normalizeUrl(String url) {
    var u = url.trim();
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(u)) {
      u = 'https://'+u;
    }
    return Uri.parse(u);
  }

  static List<String> _extractImageUrls(String md) {
    final re = RegExp(r"!\[[^\]]*\]\(([^)\s]+)\)");
    return re
        .allMatches(md)
        .map((m) => (m.group(1) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static ImageProvider _imageProviderFor(String src) {
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
    final fixed = SandboxPathResolver.fix(src);
    return FileImage(File(fixed));
  }
}

// Softer horizontal rule: shorter width and subtle color
class SoftHrLine extends BlockMd {
  @override
  String get expString => (r"^\s*(?:-{3,}|⸻)\s*$");

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final lineWidth = (width * 0.42).clamp(120.0, 420.0);
    final color = cs.outlineVariant.withOpacity(0.9);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: lineWidth,
          height: 1,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// Modern, app-styled block quote with soft background and accent border
class ModernBlockQuote extends InlineMd {
  @override
  bool get inline => false;

  @override
  RegExp get exp => RegExp(
    r"(?:(?:^)\ *>[^\n]+)(?:(?:\n)\ *>[^\n]+)*",
    dotAll: true,
    multiLine: true,
  );

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text);
    final m = match?[0] ?? '';
    final sb = StringBuffer();
    for (final line in m.split('\n')) {
      if (RegExp(r'^\ *>').hasMatch(line)) {
        var sub = line.trimLeft();
        sub = sub.substring(1); // remove '>'
        if (sub.startsWith(' ')) sub = sub.substring(1);
        sb.writeln(sub);
      } else {
        sb.writeln(line);
      }
    }
    final data = sb.toString().trim();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = cs.primaryContainer.withOpacity(isDark ? 0.18 : 0.12);
    final accent = cs.primary.withOpacity(isDark ? 0.90 : 0.80);

    final inner = TextSpan(children: MarkdownComponent.generate(context, data, config, true));
    final child = Directionality(
      textDirection: config.textDirection,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: config.getRich(inner),
        ),
      ),
    );

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: child,
    );
  }
}

// Modern task checkbox: square with subtle border, primary check on done
class ModernCheckBoxMd extends BlockMd {
  @override
  String get expString => (r"\[((?:\x|\ ))\]\ (\S[^\n]*?)$");

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text.trim());
    final checked = (match?[1] == 'x');
    final content = match?[2] ?? '';
    final cs = Theme.of(context).colorScheme;

    final contentStyle = (config.style ?? const TextStyle()).copyWith(
      decoration: checked ? TextDecoration.lineThrough : null,
      color: (config.style?.color ?? cs.onSurface).withOpacity(checked ? 0.75 : 1.0),
    );

    final child = MdWidget(
      context,
      content,
      false,
      config: config.copyWith(style: contentStyle),
    );

    return Directionality(
      textDirection: config.textDirection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 8),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.8), width: 1),
                color: checked ? cs.primary.withOpacity(0.12) : Colors.transparent,
              ),
              child: checked
                  ? Icon(Icons.check, size: 14, color: cs.primary)
                  : null,
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

// Modern radio (optional): circle with primary dot when selected
class ModernRadioMd extends BlockMd {
  @override
  String get expString => (r"\(((?:\x|\ ))\)\ (\S[^\n]*)$");

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text.trim());
    final selected = (match?[1] == 'x');
    final content = match?[2] ?? '';
    final cs = Theme.of(context).colorScheme;

    final contentStyle = (config.style ?? const TextStyle()).copyWith(
      color: (config.style?.color ?? cs.onSurface).withOpacity(selected ? 0.95 : 1.0),
    );

    final child = MdWidget(
      context,
      content,
      false,
      config: config.copyWith(style: contentStyle),
    );

    return Directionality(
      textDirection: config.textDirection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 8),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.8), width: 1),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

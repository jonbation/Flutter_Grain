import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/search/search_service.dart';
import '../../../icons/lucide_adapter.dart';
import '../pages/search_services_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> showSearchSettingsSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => const _SearchSettingsSheet(),
  );
}

class _SearchSettingsSheet extends StatelessWidget {
  const _SearchSettingsSheet();

  IconData _iconFor(SearchServiceOptions s) {
    if (s is BingLocalOptions) return Lucide.Search;
    if (s is TavilyOptions) return Lucide.Sparkles;
    if (s is ExaOptions) return Lucide.Brain;
    if (s is ZhipuOptions) return Lucide.Languages;
    if (s is SearXNGOptions) return Lucide.Shield;
    if (s is LinkUpOptions) return Lucide.Link2;
    if (s is BraveOptions) return Lucide.Shield;
    if (s is MetasoOptions) return Lucide.Compass;
    return Lucide.Search;
  }

  String _nameOf(BuildContext context, SearchServiceOptions s) {
    final svc = SearchService.getService(s);
    return svc.name;
  }

  String? _statusOf(BuildContext context, SearchServiceOptions s) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    if (s is BingLocalOptions) return null;
    if (s is TavilyOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    if (s is ExaOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    if (s is ZhipuOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    if (s is SearXNGOptions) return s.url.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 URL' : 'URL Required');
    if (s is LinkUpOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    if (s is BraveOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    if (s is MetasoOptions) return s.apiKey.isNotEmpty ? (zh ? '已配置' : 'Configured') : (zh ? '需要 API Key' : 'API Key Required');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final settings = context.watch<SettingsProvider>();
    final services = settings.searchServices;
    final selected = settings.searchServiceSelected.clamp(0, services.isNotEmpty ? services.length - 1 : 0);
    final enabled = settings.searchEnabled;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (ctx, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ListView(
              controller: controller,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    zh ? '搜索设置' : 'Search Settings',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                // Toggle card
                Material(
                  color: enabled ? cs.primary.withOpacity(0.08) : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Lucide.Globe, color: cs.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(zh ? '网络搜索' : 'Web Search', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                zh ? '是否启用网页搜索' : 'Enable web search in chat',
                                style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                        // Settings button -> full search services page
                        IconButton(
                          tooltip: zh ? '打开搜索服务设置' : 'Open search services',
                          icon: Icon(Lucide.Settings, size: 20),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SearchServicesPage()),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: enabled,
                          onChanged: (v) => context.read<SettingsProvider>().setSearchEnabled(v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Services grid (2 per row, larger tiles)
                if (services.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      // Give tiles a bit more height to fit label + tag
                      childAspectRatio: 2.7,
                    ),
                    itemCount: services.length,
                    itemBuilder: (ctx, i) {
                      final s = services[i];
                      // Build connection status label from app-start results
                      final conn = settings.searchConnection[s.id];
                      String status;
                      Color statusBg;
                      Color statusFg;
                      if (conn == true) {
                        status = zh ? '已连接' : 'Connected';
                        statusBg = Colors.green.withOpacity(0.12);
                        statusFg = Colors.green;
                      } else if (conn == false) {
                        status = zh ? '连接失败' : 'Failed';
                        statusBg = Colors.orange.withOpacity(0.12);
                        statusFg = Colors.orange;
                      } else {
                        status = zh ? '未测试' : 'Not tested';
                        statusBg = cs.onSurface.withOpacity(0.06);
                        statusFg = cs.onSurface.withOpacity(0.7);
                      }
                      return _ServiceTileLarge(
                        leading: _BrandBadge.forService(s, size: 20),
                        label: _nameOf(context, s),
                        status: (s is BingLocalOptions) ? null : _TileStatus(text: status, bg: statusBg, fg: statusFg),
                        selected: i == selected,
                        onTap: () => context.read<SettingsProvider>().setSearchServiceSelected(i),
                      );
                    },
                  ),
                ] else ...[
                  Text(
                    zh ? '暂无可用服务，请先在“搜索服务”中添加' : 'No services. Add from Search Services.',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServiceTileLarge extends StatelessWidget {
  const _ServiceTileLarge({
    this.leading,
    required this.label,
    required this.selected,
    this.status,
    required this.onTap,
  });
  final Widget? leading;
  final String label;
  final bool selected;
  final _TileStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected ? cs.primary.withOpacity(isDark ? 0.18 : 0.12) : (isDark ? Colors.white12 : const Color(0xFFF7F7F9));
    final fg = selected ? cs.primary : cs.onSurface.withOpacity(0.85);
    final border = selected ? Border.all(color: cs.primary, width: 1.2) : null;
    final statusBg = status?.bg ?? cs.onSurface.withOpacity(0.06);
    final statusFg = status?.fg ?? cs.onSurface.withOpacity(0.7);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: border),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: fg.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: leading ?? Icon(Lucide.Search, size: 18, color: fg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: fg)),
                    if ((status?.text ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(status!.text, style: TextStyle(fontSize: 11, color: statusFg)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileStatus {
  final String text;
  final Color bg;
  final Color fg;
  const _TileStatus({required this.text, required this.bg, required this.fg});
}

// Brand badge for known services using assets/icons; falls back to letter if unknown
class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.name, this.size = 20});
  final String name;
  final double size;

  static Widget forService(SearchServiceOptions s, {double size = 24}) {
    final n = _nameForService(s);
    return _BrandBadge(name: n, size: size);
  }

  static String _nameForService(SearchServiceOptions s) {
    if (s is BingLocalOptions) return 'Bing';
    if (s is TavilyOptions) return 'Tavily';
    if (s is ExaOptions) return 'Exa';
    if (s is ZhipuOptions) return '智谱';
    if (s is SearXNGOptions) return 'SearXNG';
    if (s is LinkUpOptions) return 'LinkUp';
    if (s is BraveOptions) return 'Brave';
    if (s is MetasoOptions) return 'Metaso';
    return 'Search';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lower = name.toLowerCase();
    String? asset;
    final mapping = <RegExp, String>{
      RegExp(r'bing'): 'bing.png',
      RegExp(r'zhipu|glm|智谱'): 'zhipu-color.svg',
      RegExp(r'tavily'): 'tavily.png',
      RegExp(r'exa'): 'exa.png',
      RegExp(r'linkup'): 'linkup.png',
      RegExp(r'brave'): 'brave-color.svg',
      // SearXNG/Metaso fall back to letter
    };
    for (final e in mapping.entries) {
      if (e.key.hasMatch(lower)) { asset = 'assets/icons/${e.value}'; break; }
    }
    final bg = isDark ? Colors.white10 : cs.primary.withOpacity(0.1);
    if (asset != null) {
      if (asset!.endsWith('.svg')) {
        final isColorful = asset!.contains('color');
        final ColorFilter? tint = (isDark && !isColorful) ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: SvgPicture.asset(asset!, width: size * 0.62, height: size * 0.62, colorFilter: tint),
        );
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Image.asset(asset!, width: size * 0.62, height: size * 0.62, fit: BoxFit.contain),
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name.characters.first.toUpperCase() : '?', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: size * 0.42)),
    );
  }
}

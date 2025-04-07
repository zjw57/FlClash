import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'chip.dart';

class CommonScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final NavigationBarData? navigationBarData;
  final Color? backgroundColor;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool? centerTitle;
  final AppBarEditState? appBarEditState;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.navigationBarData,
    this.backgroundColor,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.appBarEditState,
  });

  CommonScaffold.open({
    Key? key,
    required Widget body,
    required String title,
    required Function onBack,
  }) : this(
          key: key,
          body: body,
          title: title,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () {
              onBack();
            },
          ),
        );

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<NavigationBarData?> _navigationBarDataNotifier =
      ValueNotifier(null);

  final _textController = TextEditingController();

  Function(List<String>)? _onKeywordsUpdate;

  set actions(List<Widget> actions) {
    _appBarState.value = _appBarState.value.copyWith(actions: actions);
  }

  bool get _isSearch {
    return _appBarState.value.searchState?.isSearch == true;
  }

  bool get _isEdit {
    return _appBarState.value.editState?.isEdit == true;
  }

  set onKeywordsUpdate(Function(List<String>)? onKeywordsUpdate) {
    _onKeywordsUpdate = onKeywordsUpdate;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(
        editState: widget.appBarEditState,
      ),
    );
  }

  updateSearchState(
    AppBarSearchState? Function(AppBarSearchState? state) builder,
  ) {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(
        _appBarState.value.searchState,
      ),
    );
  }

  updateEditState(
    AppBarEditState? Function(AppBarEditState? state) builder,
  ) {
    _appBarState.value = _appBarState.value.copyWith(
      editState: builder(
        _appBarState.value.editState,
      ),
    );
  }

  set floatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton.value != floatingActionButton) {
      _floatingActionButton.value = floatingActionButton;
    }
  }

  ThemeData _appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        systemOverlayStyle: colorScheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.inputDecorationTheme.hintStyle,
        border: InputBorder.none,
      ),
    );
  }

  Future<T?> loadingRun<T>(
    Future<T> Function() futureFunction, {
    String? title,
  }) async {
    _loading.value = true;
    try {
      final res = await futureFunction();
      _loading.value = false;
      return res;
    } catch (e) {
      globalState.showMessage(
        title: title ?? appLocalizations.tip,
        message: TextSpan(
          text: e.toString(),
        ),
      );
      _loading.value = false;
      return null;
    }
  }

  _handleClearInput() {
    _textController.text = "";

    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch("");
    }
  }

  _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    updateSearchState(
      (state) => state?.copyWith(
        isSearch: false,
      ),
    );
  }

  _handleExitSearching() {
    _handleClearInput();
    updateSearchState(
      (state) => state?.copyWith(
        isSearch: false,
      ),
    );
  }

  @override
  void dispose() {
    _appBarState.dispose();
    _textController.dispose();
    _floatingActionButton.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _appBarState.value = AppBarState();
      _floatingActionButton.value = null;
      _textController.text = "";
      _keywordsNotifier.value = [];
      _onKeywordsUpdate = null;
    }
    if (oldWidget.appBarEditState != widget.appBarEditState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.appBarEditState,
      );
    }
    if (oldWidget.appBarEditState != widget.appBarEditState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.appBarEditState,
      );
    }
    if (oldWidget.navigationBarData != widget.navigationBarData) {
      _navigationBarDataNotifier.value = widget.navigationBarData;
    }
  }

  addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
  }

  _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
  }

  Widget? _buildLeading() {
    if (_isEdit) {
      return IconButton(
        onPressed: _appBarState.value.editState?.onExit,
        icon: Icon(Icons.close),
      );
    }
    return _isSearch
        ? IconButton(
            onPressed: _handleExitSearching,
            icon: Icon(Icons.arrow_back),
          )
        : widget.leading;
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    return _isSearch
        ? TextField(
            autofocus: true,
            controller: _textController,
            style: context.textTheme.titleLarge,
            onChanged: (value) {
              if (startState != null) {
                startState.onSearch(value);
              }
            },
            decoration: InputDecoration(
              hintText: appLocalizations.search,
            ),
          )
        : Text(
            !_isEdit
                ? widget.title!
                : appLocalizations.selectedCountTitle(
                    "${_appBarState.value.editState?.editCount ?? 0}",
                  ),
          );
  }

  List<Widget> _buildActions(
    bool hasSearch,
    List<Widget> actions,
  ) {
    if (_isSearch) {
      return genActions([
        IconButton(
          onPressed: _handleClear,
          icon: Icon(Icons.close),
        ),
      ]);
    }
    return genActions(
      [
        if (hasSearch)
          IconButton(
            onPressed: () {
              updateSearchState(
                (state) => state?.copyWith(
                  isSearch: true,
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ...actions
      ],
    );
  }

  Widget _buildAppBarWrap(Widget appBar) {
    if (_isEdit) {
      return CommonPopScope(
        onPop: () {
          if (_isEdit) {
            _appBarState.value.editState?.onExit();
            return false;
          }
          return true;
        },
        child: appBar,
      );
    }
    return _isSearch
        ? Theme(
            data: _appBarTheme(context),
            child: CommonPopScope(
              onPop: () {
                if (_isSearch) {
                  _handleExitSearching();
                  return false;
                }
                return true;
              },
              child: appBar,
            ),
          )
        : appBar;
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ValueListenableBuilder<AppBarState>(
            valueListenable: _appBarState,
            builder: (_, state, __) {
              return _buildAppBarWrap(
                AppBar(
                  centerTitle: widget.centerTitle ?? false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    systemNavigationBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    systemNavigationBarColor:
                        context.colorScheme.surfaceContainer,
                    systemNavigationBarDividerColor: Colors.transparent,
                  ),
                  automaticallyImplyLeading: widget.automaticallyImplyLeading,
                  leading: _buildLeading(),
                  title: _buildTitle(state.searchState),
                  actions: _buildActions(
                    state.searchState != null,
                    state.actions.isNotEmpty
                        ? state.actions
                        : widget.actions ?? [],
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _loading,
            builder: (_, value, __) {
              return value == true
                  ? const LinearProgressIndicator()
                  : Container();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.appBar != null || widget.title != null);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _keywordsNotifier,
          builder: (_, keywords, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_onKeywordsUpdate != null) {
                _onKeywordsUpdate!(keywords);
              }
            });
            if (keywords.isEmpty) {
              return SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  for (final keyword in keywords)
                    CommonChip(
                      label: keyword,
                      type: ChipType.delete,
                      onPressed: () {
                        _deleteKeyword(keyword);
                      },
                    ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: widget.body,
        ),
      ],
    );
    return Consumer(
      builder: (_, ref, __) {
        final isMobile = ref.watch(isMobileViewProvider);
        return ValueListenableBuilder(
          valueListenable: _navigationBarDataNotifier,
          builder: (_, navigationBarData, __) {
            return ValueListenableBuilder<Widget?>(
              valueListenable: _floatingActionButton,
              builder: (_, floatingActionButton, __) {
                final scaffold = Scaffold(
                  appBar: widget.appBar ?? _buildAppBar(),
                  body: body,
                  backgroundColor: widget.backgroundColor,
                  floatingActionButton: isMobile ? floatingActionButton : null,
                  bottomNavigationBar: isMobile && navigationBarData != null
                      ? CommonNavigationBar(
                          isMobile: isMobile,
                          navigationData: navigationBarData,
                        )
                      : null,
                );
                if (!isMobile && navigationBarData != null) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonNavigationBar(
                        isMobile: isMobile,
                        fab: floatingActionButton,
                        navigationData: navigationBarData,
                      ),
                      Expanded(
                        flex: 1,
                        child: scaffold,
                      ),
                    ],
                  );
                }
                return scaffold;
              },
            );
          },
        );
      },
    );
  }
}

class CommonNavigationBar extends ConsumerWidget {
  final bool isMobile;
  final NavigationBarData navigationData;
  final Widget? fab;

  const CommonNavigationBar({
    super.key,
    required this.isMobile,
    required this.navigationData,
    this.fab,
  });

  @override
  Widget build(BuildContext context, ref) {
    if (isMobile) {
      return NavigationBarTheme(
        data: _NavigationBarDefaultsM3(context),
        child: NavigationBar(
          destinations: navigationData.items
              .map(
                (e) => NavigationDestination(
                  icon: e.icon,
                  label: Intl.message(e.label.name),
                ),
              )
              .toList(),
          onDestinationSelected: navigationData.onSelected,
          selectedIndex: navigationData.selectedIndex,
        ),
      );
    }
    final showLabel =
        ref.watch(appSettingProvider.select((state) => state.showLabel));
    return Material(
      color: context.colorScheme.surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 12,
              ),
              child: IntrinsicHeight(
                child: NavigationRail(
                  leading: FadeThroughBox(
                    child: fab ??
                        Image.asset(
                          'assets/images/icon.png',
                          width: 56,
                          height: 56,
                        ),
                  ),
                  backgroundColor: context.colorScheme.surfaceContainer,
                  selectedIconTheme: IconThemeData(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  selectedLabelTextStyle:
                      context.textTheme.labelLarge!.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  unselectedLabelTextStyle:
                      context.textTheme.labelLarge!.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  destinations: navigationData.items
                      .map(
                        (e) => NavigationRailDestination(
                          icon: e.icon,
                          label: Text(
                            Intl.message(e.label.name),
                          ),
                        ),
                      )
                      .toList(),
                  onDestinationSelected: navigationData.onSelected,
                  extended: false,
                  selectedIndex: navigationData.selectedIndex,
                  labelType: showLabel
                      ? NavigationRailLabelType.all
                      : NavigationRailLabelType.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          IconButton(
            onPressed: () {
              ref.read(appSettingProvider.notifier).updateState(
                    (state) => state.copyWith(
                      showLabel: !state.showLabel,
                    ),
                  );
            },
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

class _NavigationBarDefaultsM3 extends NavigationBarThemeData {
  _NavigationBarDefaultsM3(this.context)
      : super(
          height: 80.0,
          elevation: 3.0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainer;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.opacity38
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelMedium!;
      return style.apply(
          overflow: TextOverflow.ellipsis,
          color: states.contains(WidgetState.disabled)
              ? _colors.onSurfaceVariant.opacity38
              : states.contains(WidgetState.selected)
                  ? _colors.onSurface
                  : _colors.onSurfaceVariant);
    });
  }
}

List<Widget> genActions(List<Widget> actions, {double? space}) {
  return <Widget>[
    ...actions.separated(
      SizedBox(
        width: space ?? 4,
      ),
    ),
    SizedBox(
      width: 8,
    )
  ];
}

import 'package:flutter/material.dart';
import 'package:assistant_side_bar/assistant_side_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidebar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final OverlaySidebarController _sidebarController;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _sidebarController = OverlaySidebarController(
      initialState: SidebarState.collapsed,
      initialEdge: SidebarEdge.right,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _buildMainContent(),

          // Overlay sidebar
          OverlaySidebar(
            controller: _sidebarController,
            expandedBuilder: _buildExpandedSidebar,
            dismissTargetKey: _fabKey,
            expandedWidth: 280,
            expandedHeight: 380,
            collapsedWidth: 24,
            collapsedHeight: 80,
            edgePadding: 16,
            onStateChanged: (state) {
              debugPrint('Sidebar state: $state');
            },
            onEdgeChanged: (edge) {
              debugPrint('Sidebar edge: $edge');
            },
            onDismissed: () {
              debugPrint('Sidebar dismissed');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: _onFabPressed,
        child: AnimatedBuilder(
          animation: _sidebarController,
          builder: (context, child) {
            final isDismissed =
                _sidebarController.state == SidebarState.dismissed;
            return Icon(isDismissed ? Icons.chat : Icons.add);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Sidebar Demo'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildActionCard(
                'Expand Sidebar',
                'Open the sidebar fully',
                Icons.open_in_full,
                () => _sidebarController.expand(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Collapse Sidebar',
                'Minimize to edge handle',
                Icons.close_fullscreen,
                () => _sidebarController.collapse(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Request Attention',
                'Show attention indicator',
                Icons.notifications_active,
                () => _sidebarController.requestAttention(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Clear Attention',
                'Remove attention indicator',
                Icons.notifications_off,
                () => _sidebarController.clearAttention(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Dismiss Sidebar',
                'Animate to FAB and hide',
                Icons.minimize,
                () => _sidebarController.dismiss(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Show Sidebar',
                'Restore after dismiss',
                Icons.visibility,
                () => _sidebarController.show(),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Switch to Left Edge',
                'Move sidebar to left',
                Icons.arrow_back,
                () => _sidebarController.setEdge(SidebarEdge.left),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Switch to Right Edge',
                'Move sidebar to right',
                Icons.arrow_forward,
                () => _sidebarController.setEdge(SidebarEdge.right),
              ),
              const SizedBox(height: 100), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExpandedSidebar(
    BuildContext context,
    OverlaySidebarController controller,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                const Icon(Icons.assistant, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Assistant',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => controller.dismiss(),
                    tooltip: 'Dismiss',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Drag the sidebar to the edge to collapse it.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Gestures:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('Drag to collapse'),
                  _buildTip('Tap handle to expand'),
                  _buildTip('X to dismiss'),
                ],
              ),
            ),
          ),

          // Footer action
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => controller.collapse(),
                child: const Text('Collapse'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _onFabPressed() {
    if (_sidebarController.state == SidebarState.dismissed) {
      _sidebarController.show();
    } else {
      _sidebarController.expand();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shoescomm/pages/app_drawer.dart';
import 'package:shoescomm/pages/app_bar.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> with TickerProviderStateMixin {
  final List<Map<String, String>> blogs = [
    {
      "title": "Top 10 Trending Sneakers of 2026",
      "category": "Trends",
      "read": "5 min read",
      "date": "Mar 1, 2026",
      "description":
      "Discover the hottest sneaker drops taking the streets by storm this year — from retro revivals to futuristic silhouettes.",
      "color": "0xFFFF4500",
    },
    {
      "title": "How to Style Sneakers for Any Outfit",
      "category": "Style",
      "read": "4 min read",
      "date": "Feb 22, 2026",
      "description":
      "Whether it's casual, smart-casual, or even formal, here's how to pair sneakers boldly with any look.",
      "color": "0xFF2196F3",
    },
    {
      "title": "The Science Behind Comfort Soles",
      "category": "Technology",
      "read": "6 min read",
      "date": "Feb 15, 2026",
      "description":
      "We break down the latest foam and cushioning technologies that make modern athletic shoes so incredibly comfortable.",
      "color": "0xFF4CAF50",
    },
    {
      "title": "Sustainable Sneakers: The Future of Footwear",
      "category": "Eco",
      "read": "3 min read",
      "date": "Feb 8, 2026",
      "description":
      "Eco-friendly materials and ethical production are shaping the next generation of shoes. Meet the brands leading the charge.",
      "color": "0xFF8BC34A",
    },
    {
      "title": "Sneaker Collecting 101: Where to Start",
      "category": "Culture",
      "read": "7 min read",
      "date": "Jan 30, 2026",
      "description":
      "From grails to deadstock, we guide you through the vibrant world of sneaker collecting and how to build your dream collection.",
      "color": "0xFFFF9800",
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All', 'Trends', 'Style', 'Technology', 'Eco', 'Culture'
  ];

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    if (_selectedCategory == 'All') return blogs;
    return blogs
        .where((b) => b['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: buildBarApp(context),
      drawer: const AppDrawer(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Featured post (first blog) ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _FeaturedCard(blog: blogs.first),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Section title + category filter ───────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4500).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.article_outlined,
                                color: Color(0xFFFF6B35), size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Latest Articles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_filtered.length} posts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── Category filter row ────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(colors: [
                              Color(0xFFFF6B35),
                              Color(0xFFFF4500)
                            ])
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.1),
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: const Color(0xFFFF4500)
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Blog list ──────────────────────────────────────
              _filtered.isEmpty
                  ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Icon(Icons.article_outlined,
                            color: Colors.white.withOpacity(0.15),
                            size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No posts in this category',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _BlogCard(
                      blog: _filtered[index],
                      index: index,
                    ),
                    childCount: _filtered.length,
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

// ─── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Map<String, String> blog;

  const _FeaturedCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(blog['color']!));

    return GestureDetector(
      onTap: () => _navigateToDetail(context, blog),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF141414),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    color.withOpacity(0.3),
                    const Color(0xFF141414),
                  ],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 40,
              top: 20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
              ),
            ),

            // Shoe icon
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(Icons.directions_run,
                    color: color.withOpacity(0.35), size: 80),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Text(
                          '✦ FEATURED',
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    blog['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined,
                          color: Colors.white.withOpacity(0.35), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        blog['read']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.calendar_today_outlined,
                          color: Colors.white.withOpacity(0.35), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        blog['date']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: color, size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Card ────────────────────────────────────────────────────────────────
class _BlogCard extends StatelessWidget {
  final Map<String, String> blog;
  final int index;

  const _BlogCard({required this.blog, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(blog['color']!));

    return GestureDetector(
      onTap: () => _navigateToDetail(context, blog),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Color accent bar + icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(Icons.article_outlined, color: color, size: 24),
            ),

            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + read time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          blog['category']!,
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        blog['read']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    blog['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    blog['description']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Detail Page ─────────────────────────────────────────────────────────
void _navigateToDetail(BuildContext context, Map<String, String> blog) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => _BlogDetailPage(blog: blog),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

class _BlogDetailPage extends StatelessWidget {
  final Map<String, String> blog;

  const _BlogDetailPage({required this.blog});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(blog['color']!));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image area
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [color.withOpacity(0.3), const Color(0xFF141414)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(Icons.directions_run,
                          color: color.withOpacity(0.2), size: 120),
                    ),
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + read time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Text(
                            blog['category']!,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.schedule_outlined,
                            color: Colors.white.withOpacity(0.3), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          blog['read']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          blog['date']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      blog['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, Colors.transparent],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      blog['description']! +
                          '\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Pellentesque habitant morbi tristique senectus et netus et malesuada '
                              'fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, '
                              'ultricies eget, tempor sit amet, ante.\n\n'
                              'Donec eu libero sit amet quam egestas semper. Aenean ultricies mi '
                              'vitae est. Mauris placerat eleifend leo. Quisque sit amet est et '
                              'sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 15,
                        height: 1.8,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Share / back
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  const Text('Go Back',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Color(0xFFFF6B35), color]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.share_outlined,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Share',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
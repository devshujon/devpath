import 'package:flutter/material.dart';

import '../models/track_project.dart';

class ProjectsTrackCatalog {
  ProjectsTrackCatalog._();

  static const List<TrackProject> all = [
    _profilePage,
    _recipePage,
    _landingPage,
    _responsivePortfolio,
    _productCard,
    _pricingSection,
    _dashboardUI,
    _weatherAppUI,
    _blogHomepage,
  ];

  static TrackProject? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<TrackProject> byDifficulty(Difficulty d) =>
      all.where((p) => p.difficulty == d).toList();
}

// ─────────────────────────────────────────────
//  Beginner (100 XP each)
// ─────────────────────────────────────────────

const _profilePage = TrackProject(
  id: 'p01_profile',
  title: 'Personal Profile Page',
  description:
      'A single-page profile with photo placeholder, bio, and contact links.',
  difficulty: Difficulty.beginner,
  requiredLessons: ['b01_html', 'b02_css'],
  instructions: [
    'Add a hero section with name and one-line bio.',
    'Show a photo placeholder (a colored circle is fine).',
    'List three contact links (email, twitter, github).',
    'Center the layout and add a soft background color.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<header class="hero">
  <div class="photo"></div>
  <h1>Your Name</h1>
  <p class="tagline">Frontend learner. Building DevPath.</p>
</header>
<section class="links">
  <!-- TODO: three contact links -->
</section>
</body>
</html>''',
  starterCss: '''body {
  font-family: system-ui, sans-serif;
  background: #f7f7fb;
  color: #222;
  margin: 0;
}
.hero { text-align: center; padding: 40px 20px; }
.photo {
  width: 96px;
  height: 96px;
  border-radius: 50%;
  background: #6c5ce7;
  margin: 0 auto 16px;
}
/* TODO: style .links */''',
  starterJs: '',
  xpReward: 100,
  previewIcon: Icons.person_outline,
  previewGradient: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
);

const _recipePage = TrackProject(
  id: 'p02_recipe',
  title: 'Recipe Page',
  description:
      'A single recipe with ingredients list, instructions, and timing info.',
  difficulty: Difficulty.beginner,
  requiredLessons: ['b01_html', 'b02_css', 'html_lists'],
  instructions: [
    'Recipe title and short description.',
    'Ingredients <ul> with at least five items.',
    'Ordered list of cooking steps.',
    'Prep time and cook time in a small metadata row.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<article class="recipe">
  <h1>Recipe Title</h1>
  <p class="desc">Short description of the dish.</p>
  <div class="meta">
    <span>Prep: 10m</span>
    <span>Cook: 20m</span>
  </div>
  <!-- TODO: ingredients + steps -->
</article>
</body>
</html>''',
  starterCss: '''body {
  font-family: Georgia, serif;
  max-width: 640px;
  margin: 0 auto;
  padding: 24px;
  color: #2d2d2d;
}
.meta {
  display: flex;
  gap: 12px;
  color: #888;
  font-size: 13px;
  margin-bottom: 16px;
}
/* TODO: style lists */''',
  starterJs: '',
  xpReward: 100,
  previewIcon: Icons.restaurant_menu_outlined,
  previewGradient: [Color(0xFFFF6B35), Color(0xFFFFB020)],
);

const _landingPage = TrackProject(
  id: 'p03_landing',
  title: 'Landing Page',
  description:
      'A simple SaaS-style landing with headline, subhead, and call-to-action.',
  difficulty: Difficulty.beginner,
  requiredLessons: ['b01_html', 'b02_css', 'css_colors'],
  instructions: [
    'Hero section with bold headline and supporting subtext.',
    'Prominent call-to-action button.',
    'Three feature highlights below the hero.',
    'Footer with copyright text.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<section class="hero">
  <h1>Build Faster With DevTool</h1>
  <p>The shortest path from idea to shipped.</p>
  <a class="cta" href="#">Get started</a>
</section>
<section class="features">
  <!-- TODO: three feature cards -->
</section>
<footer>
  <small>&copy; 2026 Your Company</small>
</footer>
</body>
</html>''',
  starterCss: '''body {
  font-family: system-ui, sans-serif;
  margin: 0;
  color: #1a1a1a;
}
.hero {
  text-align: center;
  padding: 80px 20px;
  background: linear-gradient(180deg, #f4f0ff, #fff);
}
.cta {
  display: inline-block;
  padding: 12px 24px;
  background: #6c5ce7;
  color: #fff;
  border-radius: 8px;
  text-decoration: none;
  margin-top: 16px;
}
/* TODO: layout .features as a row */''',
  starterJs: '',
  xpReward: 100,
  previewIcon: Icons.rocket_launch_outlined,
  previewGradient: [Color(0xFF0984E3), Color(0xFF74B9FF)],
);

// ─────────────────────────────────────────────
//  Intermediate (200 XP each)
// ─────────────────────────────────────────────

const _responsivePortfolio = TrackProject(
  id: 'p04_portfolio',
  title: 'Responsive Portfolio',
  description:
      'A multi-section portfolio that adapts from mobile to desktop.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['b01_html', 'b02_css', 'i01_flexbox', 'a01_responsive'],
  instructions: [
    'Header with name, tagline, and navigation.',
    'Projects grid using flexbox or grid — at least four items.',
    'About section with two-column layout on wider screens.',
    'Media query that collapses to a single column under 600px.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<header class="nav">
  <h1>Your Name</h1>
  <nav><a href="#projects">Projects</a> <a href="#about">About</a></nav>
</header>
<section id="projects" class="grid">
  <!-- TODO: four project cards -->
</section>
<section id="about" class="about">
  <!-- TODO: two-column about -->
</section>
</body>
</html>''',
  starterCss: '''body {
  font-family: system-ui, sans-serif;
  margin: 0;
  color: #222;
}
.nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
}
/* TODO: .grid + .about + media query */''',
  starterJs: '',
  xpReward: 200,
  previewIcon: Icons.web_outlined,
  previewGradient: [Color(0xFF00B894), Color(0xFF55EFC4)],
);

const _productCard = TrackProject(
  id: 'p05_product_card',
  title: 'Product Card',
  description:
      'An e-commerce product card with image, price, and add-to-cart button.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['b01_html', 'b02_css', 'i01_flexbox', 'css_box_model'],
  instructions: [
    'Card with image placeholder on top, content below.',
    'Title, two-line description, and price.',
    'Add-to-cart button with hover state.',
    'Subtle shadow and rounded corners.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<div class="card">
  <div class="image"></div>
  <div class="body">
    <h2>Product Name</h2>
    <p>Short two-line description of what this product is.</p>
    <div class="row">
      <span class="price">\$29</span>
      <button class="add">Add to cart</button>
    </div>
  </div>
</div>
</body>
</html>''',
  starterCss: '''body {
  display: grid;
  place-items: center;
  min-height: 100vh;
  background: #f5f6fa;
  margin: 0;
}
.card {
  width: 280px;
  /* TODO: shadow, radius, white bg */
}
.image {
  height: 160px;
  background: linear-gradient(135deg, #6c5ce7, #a29bfe);
}
/* TODO: .body, .row, .price, .add */''',
  starterJs: '',
  xpReward: 200,
  previewIcon: Icons.shopping_bag_outlined,
  previewGradient: [Color(0xFFE17055), Color(0xFFFAB1A0)],
);

const _pricingSection = TrackProject(
  id: 'p06_pricing',
  title: 'Pricing Section',
  description:
      'Three-tier pricing comparison with feature lists and a highlighted plan.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['b01_html', 'b02_css', 'i01_flexbox'],
  instructions: [
    'Three pricing cards side by side (Basic / Pro / Team).',
    'Each card has plan name, price, feature list, and CTA.',
    'Highlight the middle "Pro" plan visually (color or scale).',
    'Layout collapses to a vertical stack on narrow screens.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<section class="pricing">
  <article class="plan">
    <h3>Basic</h3>
    <p class="price">\$9</p>
    <!-- TODO: features -->
  </article>
  <article class="plan featured">
    <h3>Pro</h3>
    <p class="price">\$19</p>
    <!-- TODO: features -->
  </article>
  <article class="plan">
    <h3>Team</h3>
    <p class="price">\$49</p>
    <!-- TODO: features -->
  </article>
</section>
</body>
</html>''',
  starterCss: '''body {
  font-family: system-ui, sans-serif;
  background: #f7f7fb;
  padding: 24px;
  margin: 0;
}
.pricing { display: flex; gap: 16px; justify-content: center; }
.plan {
  flex: 1;
  max-width: 240px;
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  text-align: center;
}
/* TODO: .featured + media query */''',
  starterJs: '',
  xpReward: 200,
  previewIcon: Icons.local_offer_outlined,
  previewGradient: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
);

// ─────────────────────────────────────────────
//  Advanced (400 XP each)
// ─────────────────────────────────────────────

const _dashboardUI = TrackProject(
  id: 'p07_dashboard',
  title: 'Dashboard UI',
  description:
      'An admin dashboard with sidebar, stats cards, and a data table.',
  difficulty: Difficulty.advanced,
  requiredLessons: [
    'b01_html', 'b02_css', 'i01_flexbox', 'i02_grid', 'a01_responsive',
  ],
  instructions: [
    'Fixed sidebar with navigation items on the left.',
    'Top bar with title and user avatar placeholder.',
    'Four stats cards in a grid (revenue, users, orders, growth).',
    'Recent activity table with five rows.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<div class="app">
  <aside class="sidebar">
    <h2>DevTool</h2>
    <nav>
      <a href="#" class="active">Dashboard</a>
      <a href="#">Users</a>
      <a href="#">Orders</a>
      <a href="#">Settings</a>
    </nav>
  </aside>
  <main class="main">
    <header class="topbar">
      <h1>Overview</h1>
      <div class="avatar"></div>
    </header>
    <section class="stats">
      <!-- TODO: four stat cards -->
    </section>
    <section class="table">
      <!-- TODO: recent activity table -->
    </section>
  </main>
</div>
</body>
</html>''',
  starterCss: '''body {
  font-family: system-ui, sans-serif;
  margin: 0;
  background: #f4f6fb;
  color: #1a1a1a;
}
.app {
  display: grid;
  grid-template-columns: 220px 1fr;
  min-height: 100vh;
}
.sidebar { background: #1a1f28; color: #fff; padding: 24px 16px; }
.sidebar nav { display: flex; flex-direction: column; gap: 8px; margin-top: 16px; }
.sidebar a { color: #c9d1d9; text-decoration: none; padding: 8px 12px; border-radius: 6px; }
.sidebar a.active { background: #6c5ce7; color: #fff; }
/* TODO: .main, .topbar, .stats, .table */''',
  starterJs: '',
  xpReward: 400,
  previewIcon: Icons.dashboard_outlined,
  previewGradient: [Color(0xFF1A1F28), Color(0xFF6C5CE7)],
);

const _weatherAppUI = TrackProject(
  id: 'p08_weather',
  title: 'Weather App UI',
  description:
      'A weather card with current conditions and a five-day forecast row.',
  difficulty: Difficulty.advanced,
  requiredLessons: [
    'b01_html', 'b02_css', 'i01_flexbox', 'b03_js', 'i03_dom',
  ],
  instructions: [
    'Current city, temperature, and condition (sunny / rainy / etc.).',
    'Large weather icon (emoji or styled <div>).',
    'Five-day forecast row at the bottom.',
    'JS swaps the condition text and emoji on a button click.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<div class="weather">
  <header>
    <h2 id="city">Jakarta</h2>
    <button id="swap">Try another day</button>
  </header>
  <div class="now">
    <div class="icon" id="icon">☀️</div>
    <div class="temp"><span id="temp">31</span>°</div>
    <div class="cond" id="cond">Sunny</div>
  </div>
  <div class="forecast">
    <!-- TODO: five forecast cells -->
  </div>
</div>
</body>
</html>''',
  starterCss: '''body {
  display: grid;
  place-items: center;
  min-height: 100vh;
  background: linear-gradient(180deg, #74b9ff, #0984e3);
  margin: 0;
  color: #fff;
  font-family: system-ui, sans-serif;
}
.weather {
  width: 320px;
  background: rgba(255,255,255,0.15);
  border-radius: 16px;
  padding: 20px;
  backdrop-filter: blur(8px);
}
/* TODO: layout .now centered, .forecast row */''',
  starterJs: '''var samples = [
  { icon: '☀️', cond: 'Sunny', temp: 31 },
  { icon: '🌧️', cond: 'Rainy', temp: 24 },
  { icon: '⛅', cond: 'Cloudy', temp: 28 },
];
var i = 0;
document.getElementById('swap').addEventListener('click', function () {
  i = (i + 1) % samples.length;
  document.getElementById('icon').textContent = samples[i].icon;
  document.getElementById('cond').textContent = samples[i].cond;
  document.getElementById('temp').textContent = samples[i].temp;
});''',
  xpReward: 400,
  previewIcon: Icons.wb_sunny_outlined,
  previewGradient: [Color(0xFF74B9FF), Color(0xFF0984E3)],
);

const _blogHomepage = TrackProject(
  id: 'p09_blog',
  title: 'Blog Homepage',
  description:
      'A blog index with featured post, recent posts grid, and sidebar.',
  difficulty: Difficulty.advanced,
  requiredLessons: [
    'b01_html', 'b02_css', 'i01_flexbox', 'i02_grid', 'a01_responsive',
  ],
  instructions: [
    'Top featured post with large image area and excerpt.',
    'Recent posts grid (3 columns desktop, 1 column mobile).',
    'Sidebar with categories list and a search box.',
    'Sticky header that stays visible on scroll.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<header class="topbar">
  <h1>The DevPath Blog</h1>
  <input type="search" placeholder="Search posts" />
</header>
<main class="layout">
  <section class="posts">
    <article class="featured">
      <div class="cover"></div>
      <h2>Featured Post Title</h2>
      <p>Lead-in text for the featured article.</p>
    </article>
    <div class="grid">
      <!-- TODO: six recent post cards -->
    </div>
  </section>
  <aside class="side">
    <!-- TODO: categories list -->
  </aside>
</main>
</body>
</html>''',
  starterCss: '''body {
  font-family: Georgia, serif;
  margin: 0;
  background: #fafafa;
  color: #222;
}
.topbar {
  position: sticky;
  top: 0;
  background: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  border-bottom: 1px solid #eee;
}
/* TODO: .layout grid, .featured, .grid, .side, media query */''',
  starterJs: '',
  xpReward: 400,
  previewIcon: Icons.article_outlined,
  previewGradient: [Color(0xFFFFB020), Color(0xFFFF6B35)],
);

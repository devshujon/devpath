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
    _contactForm,
    _phpFormConcept,
    _phpMysqlCrudConcept,
    _restApiClient,
    _databaseDesignExercise,
    _typescriptValidator,
    _fullStackCapstone,
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

const _contactForm = TrackProject(
  id: 'p10_contact_form',
  title: 'Contact Form UI',
  description:
      'Accessible contact form layout (HTML/CSS/JS). Server processing is conceptual — study PHP lessons separately.',
  difficulty: Difficulty.beginner,
  requiredLessons: ['html_forms', 'b02_css'],
  instructions: [
    'Build name, email, and message fields with labels tied to inputs.',
    'Add client-side required attributes for UX only.',
    'Style focus states and error colors with CSS.',
    'Document in comments where server-side validation must run.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<form class="contact">
  <label>Name <input name="name" required /></label>
  <label>Email <input name="email" type="email" required /></label>
  <label>Message <textarea name="message" required></textarea></label>
  <button type="submit">Send</button>
</form>
</body>
</html>''',
  starterCss: '/* TODO: layout, focus rings */',
  starterJs: '',
  xpReward: 120,
  previewIcon: Icons.mail_outline,
  previewGradient: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
);

const _phpFormConcept = TrackProject(
  id: 'p11_php_form_concept',
  title: 'PHP Form Processing (Concept)',
  description:
      'Read and annotate PHP that sanitizes POST data. No PHP runtime in the app — study offline.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['php_11', 'php_12', 'php_13'],
  instructions: [
    'Review htmlspecialchars on output.',
    'Identify where server validation belongs.',
    'List three fields you would validate on the server.',
  ],
  starterHtml: '<!-- Open PHP track lessons for server-side examples -->',
  starterCss: '',
  starterJs: '',
  xpReward: 150,
  previewIcon: Icons.description_outlined,
  previewGradient: [Color(0xFF777BB4), Color(0xFF4A4A8A)],
);

const _phpMysqlCrudConcept = TrackProject(
  id: 'p12_php_mysql_crud',
  title: 'PHP + MySQL CRUD (Concept)',
  description:
      'Map CREATE/READ/UPDATE/DELETE to prepared statements — design on paper, then quiz yourself.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['php_23', 'php_24', 'sql_10', 'sql_11'],
  instructions: [
    'Sketch tables and primary keys for a simple notes app.',
    'Write pseudo-SQL for each CRUD operation using placeholders.',
    'Note transaction boundaries for multi-step updates.',
  ],
  starterHtml: '',
  starterCss: '',
  starterJs: '',
  xpReward: 200,
  previewIcon: Icons.table_chart_outlined,
  previewGradient: [Color(0xFF00758F), Color(0xFF00A3C4)],
);

const _restApiClient = TrackProject(
  id: 'p13_rest_client',
  title: 'REST API Client Demo',
  description: 'Fetch JSON in JavaScript and render a list — uses playground fetch patterns from JS lessons.',
  difficulty: Difficulty.intermediate,
  requiredLessons: ['a02_apis', 'web_essentials_18'],
  instructions: [
    'fetch() a public JSON placeholder URL.',
    'Handle non-OK status codes.',
    'Render items in the DOM with textContent (not innerHTML with raw data).',
  ],
  starterHtml: '<ul id="list"></ul>',
  starterCss: 'body { font-family: system-ui; padding: 16px; }',
  starterJs: '''const list = document.getElementById('list');
fetch('https://jsonplaceholder.typicode.com/posts?_limit=5')
  .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
  .then(posts => {
    for (const p of posts) {
      const li = document.createElement('li');
      li.textContent = p.title;
      list.appendChild(li);
    }
  })
  .catch(err => { list.textContent = String(err); });''',
  xpReward: 220,
  previewIcon: Icons.cloud_download_outlined,
  previewGradient: [Color(0xFF3178C6), Color(0xFF0984E3)],
);

const _databaseDesignExercise = TrackProject(
  id: 'p14_db_design',
  title: 'Database Design Exercise',
  description: 'Normalize a messy spreadsheet into tables — SQL track practice (no live DB in app).',
  difficulty: Difficulty.advanced,
  requiredLessons: ['sql_21', 'sql_30', 'sql_39'],
  instructions: [
    'Identify entities and relationships.',
    'Choose primary and foreign keys.',
    'Write CREATE TABLE statements on paper or in notes.',
  ],
  starterHtml: '',
  starterCss: '',
  starterJs: '',
  xpReward: 250,
  previewIcon: Icons.account_tree_outlined,
  previewGradient: [Color(0xFF00758F), Color(0xFF6C5CE7)],
);

const _typescriptValidator = TrackProject(
  id: 'p15_ts_validator',
  title: 'TypeScript Data Validator',
  description:
      'Study TypeScript narrowing patterns offline — compile on your computer; playground uses JS subset only.',
  difficulty: Difficulty.advanced,
  requiredLessons: ['typescript_09', 'typescript_15'],
  instructions: [
    'Define an interface for a form payload.',
    'Write a type guard function.',
    'List runtime checks that TypeScript cannot perform alone.',
  ],
  starterHtml: '',
  starterCss: '',
  starterJs: '',
  xpReward: 280,
  previewIcon: Icons.rule_folder_outlined,
  previewGradient: [Color(0xFF3178C6), Color(0xFF6C5CE7)],
);

const _fullStackCapstone = TrackProject(
  id: 'p16_full_stack',
  title: 'Full-Stack Learning Capstone',
  description:
      'Plan a small product: static UI, PHP API sketch, SQL schema, deployment checklist from Web Essentials.',
  difficulty: Difficulty.advanced,
  requiredLessons: ['a04_mini_projects', 'web_essentials_44', 'web_essentials_45'],
  instructions: [
    'Draw architecture: browser, API, database.',
    'List HTTPS, auth, and backup steps before go-live.',
    'Complete at least one HTML/CSS project and one SQL lesson quiz.',
  ],
  starterHtml: '<!-- Use Editor + track lessons; no single starter -->',
  starterCss: '',
  starterJs: '',
  xpReward: 400,
  previewIcon: Icons.hub_outlined,
  previewGradient: [Color(0xFF00B894), Color(0xFF6C5CE7)],
);

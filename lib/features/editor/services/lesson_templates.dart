/// One starter lesson the user can open from the lesson picker.
class LessonTemplate {
  final String id;
  final String title;
  final String description;
  final String html;
  final String css;
  final String js;

  const LessonTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.html,
    required this.css,
    required this.js,
  });
}

/// All bundled starter lessons.
class LessonTemplates {
  LessonTemplates._();

  static const List<LessonTemplate> all = [
    _basicHtmlPage,
    _personalPortfolio,
    _responsiveLanding,
    _loginFormUi,
    _calculator,
    _todoList,
    _productCard,
    _responsiveNavigation,
    _imageGallery,
    _simpleQuizApp,
  ];

  /// Maps saved project / deep-link ids from older app versions.
  static const _legacyIdMap = <String, String>{
    'html_basics': 'basic_html_page',
    'css_basics': 'basic_html_page',
    'buttons': 'calculator',
    'forms': 'login_form_ui',
    'cards': 'product_card',
    'flexbox': 'responsive_navigation',
    'js_basics': 'simple_quiz_app',
  };

  static LessonTemplate? byId(String id) {
    final resolved = _legacyIdMap[id] ?? id;
    for (final l in all) {
      if (l.id == resolved) return l;
    }
    return null;
  }

  // ───────────────────────────────────────────────────
  //  Lesson 1: Basic HTML Page
  // ───────────────────────────────────────────────────
  static const _basicHtmlPage = LessonTemplate(
    id: 'basic_html_page',
    title: 'Basic HTML Page',
    description: 'Structure a page with headings, paragraphs, and links.',
    html: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My First Page</title>
</head>
<body>
  <header>
    <h1>Welcome</h1>
    <p>Build your first web page with semantic HTML.</p>
  </header>
  <main>
    <h2>About</h2>
    <p>Add another section here. Try an unordered list of hobbies.</p>
    <p><a href="#">Learn more</a></p>
  </main>
  <footer>
    <small>&copy; 2026 You</small>
  </footer>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  line-height: 1.5;
  margin: 0;
  padding: 24px;
  max-width: 640px;
}

header {
  margin-bottom: 24px;
}

h1 {
  margin: 0 0 8px 0;
  color: #2d3436;
}

a {
  color: #6c5ce7;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 2: Personal Portfolio
  // ───────────────────────────────────────────────────
  static const _personalPortfolio = LessonTemplate(
    id: 'personal_portfolio',
    title: 'Personal Portfolio',
    description: 'Showcase yourself with a hero, skills, and projects.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <section class="hero">
    <p class="eyebrow">Hello, I'm</p>
    <h1>Your Name</h1>
    <p class="tagline">Aspiring web developer building things on the web.</p>
    <a class="btn" href="#projects">View projects</a>
  </section>
  <section class="skills">
    <h2>Skills</h2>
    <ul>
      <li>HTML &amp; CSS</li>
      <li>JavaScript</li>
      <li>Responsive design</li>
    </ul>
  </section>
  <section id="projects">
    <h2>Projects</h2>
    <article class="project">
      <h3>Project One</h3>
      <p>Short description of something you built.</p>
    </article>
  </section>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  margin: 0;
  padding: 24px;
  background: #f8f9fc;
  color: #2d3436;
}

.hero {
  background: white;
  padding: 32px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.06);
  margin-bottom: 24px;
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 12px;
  color: #6c5ce7;
  margin: 0 0 8px 0;
}

.tagline {
  color: #636e72;
  max-width: 420px;
}

.btn {
  display: inline-block;
  margin-top: 16px;
  padding: 10px 18px;
  background: #6c5ce7;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-size: 14px;
}

.skills ul {
  padding-left: 20px;
}

.project {
  background: white;
  padding: 16px 20px;
  border-radius: 10px;
  border: 1px solid #e4e7ee;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 3: Responsive Landing Page
  // ───────────────────────────────────────────────────
  static const _responsiveLanding = LessonTemplate(
    id: 'responsive_landing',
    title: 'Responsive Landing Page',
    description: 'Hero, features grid, and layout that adapts to screen size.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <header class="top">
    <strong>LaunchPad</strong>
    <button type="button">Get started</button>
  </header>
  <section class="hero">
    <h1>Ship faster with a clean landing page</h1>
    <p>Resize the preview to see the layout respond.</p>
  </section>
  <section class="features">
    <div class="feature">
      <h3>Fast</h3>
      <p>Lightweight markup and CSS.</p>
    </div>
    <div class="feature">
      <h3>Flexible</h3>
      <p>Grid wraps on smaller screens.</p>
    </div>
    <div class="feature">
      <h3>Polished</h3>
      <p>Spacing and type that scale.</p>
    </div>
  </section>
</body>
</html>''',
    css: '''* {
  box-sizing: border-box;
}

body {
  font-family: system-ui, sans-serif;
  margin: 0;
  padding: 16px;
  background: #fafafa;
}

.top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: white;
  border-radius: 10px;
  margin-bottom: 24px;
}

.top button {
  padding: 8px 14px;
  border: 0;
  border-radius: 6px;
  background: #6c5ce7;
  color: white;
  cursor: pointer;
}

.hero {
  text-align: center;
  padding: 40px 16px;
  margin-bottom: 32px;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 16px;
}

.feature {
  background: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}

@media (max-width: 480px) {
  .hero h1 {
    font-size: 1.5rem;
  }
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 4: Login Form UI
  // ───────────────────────────────────────────────────
  static const _loginFormUi = LessonTemplate(
    id: 'login_form_ui',
    title: 'Login Form UI',
    description: 'Email and password fields with validation feedback.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <div class="card">
    <h2>Sign in</h2>
    <form id="login">
      <label>
        Email
        <input type="email" id="email" placeholder="you@example.com" required>
      </label>
      <label>
        Password
        <input type="password" id="password" minlength="6" required>
      </label>
      <button type="submit">Log in</button>
    </form>
    <p id="message" class="message" hidden></p>
  </div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #eef0f5;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0;
  padding: 16px;
}

.card {
  background: white;
  padding: 28px;
  border-radius: 12px;
  width: 100%;
  max-width: 360px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

label {
  display: block;
  font-size: 13px;
  margin-bottom: 14px;
  color: #444;
}

input {
  display: block;
  width: 100%;
  margin-top: 6px;
  padding: 10px 12px;
  border: 1px solid #ccc;
  border-radius: 8px;
  font-size: 15px;
}

button {
  width: 100%;
  padding: 12px;
  border: 0;
  border-radius: 8px;
  background: #00b894;
  color: white;
  font-size: 15px;
  cursor: pointer;
  margin-top: 8px;
}

.message {
  margin-top: 12px;
  font-size: 14px;
  color: #00b894;
}''',
    js: '''document.getElementById('login').addEventListener('submit', function(e) {
  e.preventDefault();
  var msg = document.getElementById('message');
  msg.hidden = false;
  msg.textContent = 'Welcome back!';
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 5: Calculator
  // ───────────────────────────────────────────────────
  static const _calculator = LessonTemplate(
    id: 'calculator',
    title: 'Calculator',
    description: 'Number pad and operators wired with JavaScript.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <div class="calc">
    <input type="text" id="display" readonly value="0">
    <div class="keys">
      <button data-action="clear">C</button>
      <button data-val="/">÷</button>
      <button data-val="*">×</button>
      <button data-val="-">−</button>
      <button data-val="7">7</button>
      <button data-val="8">8</button>
      <button data-val="9">9</button>
      <button data-val="+">+</button>
      <button data-val="4">4</button>
      <button data-val="5">5</button>
      <button data-val="6">6</button>
      <button data-action="eq" class="tall">=</button>
      <button data-val="1">1</button>
      <button data-val="2">2</button>
      <button data-val="3">3</button>
      <button data-val="0" class="wide">0</button>
      <button data-val=".">.</button>
    </div>
  </div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #2d3436;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0;
}

.calc {
  width: 260px;
  background: #1e272e;
  padding: 16px;
  border-radius: 16px;
}

#display {
  width: 100%;
  padding: 16px;
  font-size: 28px;
  text-align: right;
  border: 0;
  border-radius: 8px;
  margin-bottom: 12px;
  background: #dfe6e9;
}

.keys {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.keys button {
  padding: 16px;
  font-size: 18px;
  border: 0;
  border-radius: 8px;
  background: #636e72;
  color: white;
  cursor: pointer;
}

.keys button:hover {
  background: #6c5ce7;
}

.keys .wide {
  grid-column: span 2;
}

.keys .tall {
  grid-row: span 2;
}''',
    js: '''var display = document.getElementById('display');
var current = '0';

function updateDisplay() {
  display.value = current;
}

document.querySelector('.keys').addEventListener('click', function(e) {
  var btn = e.target.closest('button');
  if (!btn) return;
  var val = btn.getAttribute('data-val');
  var action = btn.getAttribute('data-action');
  if (action === 'clear') {
    current = '0';
    updateDisplay();
    return;
  }
  if (action === 'eq') {
    try {
      current = String(eval(current.replace(/×/g, '*').replace(/÷/g, '/')));
    } catch (err) {
      current = 'Error';
    }
    updateDisplay();
    return;
  }
  if (val) {
    current = current === '0' || current === 'Error' ? val : current + val;
    updateDisplay();
  }
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 6: To-Do List
  // ───────────────────────────────────────────────────
  static const _todoList = LessonTemplate(
    id: 'todo_list',
    title: 'To-Do List',
    description: 'Add tasks, mark them done, and remove completed items.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <div class="app">
    <h2>To-Do</h2>
    <form id="add-form">
      <input type="text" id="task-input" placeholder="New task..." required>
      <button type="submit">Add</button>
    </form>
    <ul id="list"></ul>
  </div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #f2f4f8;
  margin: 0;
  padding: 24px;
}

.app {
  max-width: 400px;
  margin: 0 auto;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.06);
}

#add-form {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

#task-input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #ccc;
  border-radius: 8px;
}

#add-form button {
  padding: 10px 16px;
  border: 0;
  border-radius: 8px;
  background: #6c5ce7;
  color: white;
  cursor: pointer;
}

#list {
  list-style: none;
  padding: 0;
  margin: 0;
}

#list li {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid #eee;
}

#list li.done span {
  text-decoration: line-through;
  color: #999;
}

#list button.remove {
  margin-left: auto;
  border: 0;
  background: transparent;
  color: #d63031;
  cursor: pointer;
}''',
    js: '''var form = document.getElementById('add-form');
var input = document.getElementById('task-input');
var list = document.getElementById('list');

form.addEventListener('submit', function(e) {
  e.preventDefault();
  var text = input.value.trim();
  if (!text) return;
  var li = document.createElement('li');
  var check = document.createElement('input');
  check.type = 'checkbox';
  var span = document.createElement('span');
  span.textContent = text;
  var remove = document.createElement('button');
  remove.type = 'button';
  remove.className = 'remove';
  remove.textContent = '×';
  check.addEventListener('change', function() {
    li.classList.toggle('done', check.checked);
  });
  remove.addEventListener('click', function() {
    li.remove();
  });
  li.appendChild(check);
  li.appendChild(span);
  li.appendChild(remove);
  list.appendChild(li);
  input.value = '';
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 7: Product Card
  // ───────────────────────────────────────────────────
  static const _productCard = LessonTemplate(
    id: 'product_card',
    title: 'Product Card',
    description: 'Price, rating, and call-to-action in a card layout.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <article class="product">
    <div class="image">🎧</div>
    <div class="body">
      <p class="brand">AudioCo</p>
      <h3>Wireless Headphones</h3>
      <p class="desc">Comfort fit, 30-hour battery, active noise canceling.</p>
      <div class="meta">
        <span class="price">\$79</span>
        <span class="rating">★ 4.8</span>
      </div>
      <button type="button" id="cart">Add to cart</button>
      <p id="status"></p>
    </div>
  </article>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #f2f4f8;
  padding: 24px;
  margin: 0;
}

.product {
  display: flex;
  gap: 20px;
  max-width: 420px;
  background: white;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
}

.image {
  width: 120px;
  background: linear-gradient(135deg, #6c5ce7, #a29bfe);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
}

.body {
  padding: 16px 16px 16px 0;
  flex: 1;
}

.brand {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #6c5ce7;
  margin: 0;
}

.desc {
  font-size: 14px;
  color: #636e72;
  margin: 8px 0 12px 0;
}

.meta {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
}

.price {
  font-weight: 700;
  font-size: 18px;
}

.rating {
  color: #fdcb6e;
}

#cart {
  width: 100%;
  padding: 10px;
  border: 0;
  border-radius: 8px;
  background: #00b894;
  color: white;
  cursor: pointer;
}

#status {
  font-size: 13px;
  color: #00b894;
  margin: 8px 0 0 0;
  min-height: 18px;
}''',
    js: '''document.getElementById('cart').addEventListener('click', function() {
  document.getElementById('status').textContent = 'Added to cart!';
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 8: Responsive Navigation
  // ───────────────────────────────────────────────────
  static const _responsiveNavigation = LessonTemplate(
    id: 'responsive_navigation',
    title: 'Responsive Navigation',
    description: 'Horizontal nav that stacks and toggles on small screens.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <nav class="navbar">
    <a class="logo" href="#">DevPath</a>
    <button type="button" id="menu-toggle" aria-label="Menu">☰</button>
    <ul id="links">
      <li><a href="#">Home</a></li>
      <li><a href="#">Lessons</a></li>
      <li><a href="#">Projects</a></li>
      <li><a href="#">About</a></li>
    </ul>
  </nav>
  <main>
    <h1>Page content</h1>
    <p>Tap the menu icon on narrow widths to show links.</p>
  </main>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  margin: 0;
}

.navbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: #2d3436;
  color: white;
}

.logo {
  color: white;
  text-decoration: none;
  font-weight: 700;
}

#menu-toggle {
  display: none;
  background: transparent;
  border: 1px solid #636e72;
  color: white;
  font-size: 20px;
  padding: 4px 10px;
  border-radius: 6px;
  cursor: pointer;
}

#links {
  display: flex;
  gap: 20px;
  list-style: none;
  margin: 0;
  padding: 0;
}

#links a {
  color: #dfe6e9;
  text-decoration: none;
}

#links a:hover {
  color: #6c5ce7;
}

main {
  padding: 24px;
}

@media (max-width: 560px) {
  #menu-toggle {
    display: block;
  }

  #links {
    display: none;
    flex-direction: column;
    width: 100%;
    padding-top: 12px;
  }

  #links.open {
    display: flex;
  }
}''',
    js: '''document.getElementById('menu-toggle').addEventListener('click', function() {
  document.getElementById('links').classList.toggle('open');
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 9: Image Gallery
  // ───────────────────────────────────────────────────
  static const _imageGallery = LessonTemplate(
    id: 'image_gallery',
    title: 'Image Gallery',
    description: 'CSS grid gallery with hover captions.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <h2>Gallery</h2>
  <div class="grid">
    <figure>
      <div class="thumb" style="background:#6c5ce7">1</div>
      <figcaption>Sunset</figcaption>
    </figure>
    <figure>
      <div class="thumb" style="background:#00b894">2</div>
      <figcaption>Forest</figcaption>
    </figure>
    <figure>
      <div class="thumb" style="background:#fdcb6e;color:#2d3436">3</div>
      <figcaption>City</figcaption>
    </figure>
    <figure>
      <div class="thumb" style="background:#e17055">4</div>
      <figcaption>Coast</figcaption>
    </figure>
  </div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  padding: 24px;
  margin: 0;
  background: #fafafa;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 16px;
}

figure {
  margin: 0;
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  transition: transform 0.2s;
}

figure:hover {
  transform: translateY(-4px);
}

.thumb {
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 700;
  color: white;
}

figcaption {
  padding: 10px 12px;
  font-size: 14px;
  text-align: center;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 10: Simple Quiz App
  // ───────────────────────────────────────────────────
  static const _simpleQuizApp = LessonTemplate(
    id: 'simple_quiz_app',
    title: 'Simple Quiz App',
    description: 'Multiple-choice questions with score tracking.',
    html: '''<!DOCTYPE html>
<html lang="en">
<body>
  <div class="quiz">
    <h2>Quick Quiz</h2>
    <p id="question"></p>
    <div id="choices"></div>
    <p class="score">Score: <span id="score">0</span> / <span id="total">0</span></p>
    <button type="button" id="next" hidden>Next</button>
  </div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #eef0f5;
  margin: 0;
  padding: 24px;
}

.quiz {
  max-width: 420px;
  margin: 0 auto;
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

#choices button {
  display: block;
  width: 100%;
  text-align: left;
  padding: 12px 14px;
  margin-bottom: 8px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  font-size: 15px;
}

#choices button:hover {
  border-color: #6c5ce7;
}

#choices button.correct {
  background: #d4edda;
  border-color: #00b894;
}

#choices button.wrong {
  background: #fdecea;
  border-color: #d63031;
}

#next {
  margin-top: 12px;
  padding: 10px 18px;
  border: 0;
  border-radius: 8px;
  background: #6c5ce7;
  color: white;
  cursor: pointer;
}

.score {
  margin-top: 16px;
  font-size: 14px;
  color: #636e72;
}''',
    js: '''var questions = [
  { q: 'What does HTML stand for?', choices: ['HyperText Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language'], answer: 0 },
  { q: 'Which property makes text bold?', choices: ['font-weight', 'text-bold', 'font-style'], answer: 0 },
  { q: 'How do you select an element by id in CSS?', choices: ['#id', '.id', 'id()'], answer: 0 }
];

var index = 0;
var score = 0;
var answered = false;

document.getElementById('total').textContent = questions.length;

function render() {
  answered = false;
  document.getElementById('next').hidden = true;
  var item = questions[index];
  document.getElementById('question').textContent = item.q;
  var box = document.getElementById('choices');
  box.innerHTML = '';
  item.choices.forEach(function(label, i) {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.textContent = label;
    btn.addEventListener('click', function() {
      if (answered) return;
      answered = true;
      if (i === item.answer) {
        btn.classList.add('correct');
        score++;
        document.getElementById('score').textContent = score;
      } else {
        btn.classList.add('wrong');
      }
      document.getElementById('next').hidden = false;
    });
    box.appendChild(btn);
  });
}

document.getElementById('next').addEventListener('click', function() {
  index++;
  if (index >= questions.length) {
    document.getElementById('question').textContent = 'Done! Final score: ' + score + ' / ' + questions.length;
    document.getElementById('choices').innerHTML = '';
    document.getElementById('next').hidden = true;
    return;
  }
  render();
});

render();''',
  );
}

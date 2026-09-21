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
    _htmlBasics,
    _cssBasics,
    _buttons,
    _forms,
    _cards,
    _flexbox,
    _jsBasics,
  ];

  static LessonTemplate? byId(String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }

  // ───────────────────────────────────────────────────
  //  Lesson 1: HTML Basics
  // ───────────────────────────────────────────────────
  static const _htmlBasics = LessonTemplate(
    id: 'html_basics',
    title: 'HTML Basics',
    description: 'Structure your first web page with headings and paragraphs.',
    html: '''<!DOCTYPE html>
<html>
<body>
<h1>HTML Basics</h1>
<p>This is a paragraph. Add another one below.</p>
<!-- Try adding an <h2> and another <p> here -->
</body>
</html>''',
    css: '',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 2: CSS Basics
  // ───────────────────────────────────────────────────
  static const _cssBasics = LessonTemplate(
    id: 'css_basics',
    title: 'CSS Basics',
    description: 'Add colors, fonts, and spacing to your HTML.',
    html: '''<!DOCTYPE html>
<html>
<body>
<h1>Style Me</h1>
<p>Change my color, font, and background.</p>
</body>
</html>''',
    css: '''body {
  background: #fafafa;
  font-family: system-ui, sans-serif;
  padding: 24px;
}

h1 {
  color: #6c5ce7;
}

p {
  color: #444;
  line-height: 1.5;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 3: Buttons
  // ───────────────────────────────────────────────────
  static const _buttons = LessonTemplate(
    id: 'buttons',
    title: 'Buttons',
    description: 'Style buttons and make them respond to clicks.',
    html: '''<!DOCTYPE html>
<html>
<body>
<h2>Click the button</h2>
<button id="action">Tap me</button>
<p id="status">Nothing happened yet.</p>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  padding: 24px;
}

button {
  padding: 12px 20px;
  font-size: 15px;
  border: 0;
  border-radius: 8px;
  background: #6c5ce7;
  color: white;
  cursor: pointer;
}

button:hover {
  background: #5847d4;
}''',
    js: '''document.getElementById('action').addEventListener('click', function() {
  document.getElementById('status').textContent = 'You clicked it!';
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 4: Forms
  // ───────────────────────────────────────────────────
  static const _forms = LessonTemplate(
    id: 'forms',
    title: 'Forms',
    description: 'Capture user input and react to submissions.',
    html: '''<!DOCTYPE html>
<html>
<body>
<h2>Sign up</h2>
<form id="signup">
  <label>Name <input type="text" id="name" required></label>
  <label>Email <input type="email" id="email" required></label>
  <button type="submit">Submit</button>
</form>
<p id="result"></p>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  padding: 24px;
  max-width: 360px;
}

label {
  display: block;
  margin-bottom: 12px;
  font-size: 14px;
}

input {
  display: block;
  width: 100%;
  padding: 8px 10px;
  margin-top: 4px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
}

button {
  padding: 10px 18px;
  background: #00b894;
  color: white;
  border: 0;
  border-radius: 6px;
  cursor: pointer;
}''',
    js: '''document.getElementById('signup').addEventListener('submit', function(e) {
  e.preventDefault();
  var name = document.getElementById('name').value;
  document.getElementById('result').textContent = 'Welcome, ' + name + '!';
});''',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 5: Cards
  // ───────────────────────────────────────────────────
  static const _cards = LessonTemplate(
    id: 'cards',
    title: 'Cards',
    description: 'Build a card component with shadow and rounded corners.',
    html: '''<!DOCTYPE html>
<html>
<body>
<div class="card">
  <h3>Card Title</h3>
  <p>A short description that explains what this card is about.</p>
  <button>Action</button>
</div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  background: #f2f4f8;
  padding: 24px;
}

.card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  max-width: 320px;
}

.card h3 {
  margin: 0 0 8px 0;
}

.card p {
  margin: 0 0 16px 0;
  color: #555;
}

.card button {
  padding: 8px 14px;
  background: #6c5ce7;
  color: white;
  border: 0;
  border-radius: 6px;
  cursor: pointer;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 6: Flexbox
  // ───────────────────────────────────────────────────
  static const _flexbox = LessonTemplate(
    id: 'flexbox',
    title: 'Flexbox',
    description: 'Arrange items in rows and columns with flexbox.',
    html: '''<!DOCTYPE html>
<html>
<body>
<div class="row">
  <div class="box">1</div>
  <div class="box">2</div>
  <div class="box">3</div>
</div>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  padding: 24px;
}

.row {
  display: flex;
  gap: 12px;
  justify-content: space-between;
}

.box {
  flex: 1;
  background: #6c5ce7;
  color: white;
  padding: 24px;
  text-align: center;
  border-radius: 8px;
  font-size: 18px;
  font-weight: 600;
}''',
    js: '',
  );

  // ───────────────────────────────────────────────────
  //  Lesson 7: JavaScript Basics
  // ───────────────────────────────────────────────────
  static const _jsBasics = LessonTemplate(
    id: 'js_basics',
    title: 'JavaScript Basics',
    description: 'Variables, functions, and DOM updates.',
    html: '''<!DOCTYPE html>
<html>
<body>
<h2>Counter</h2>
<p>Count: <span id="count">0</span></p>
<button onclick="increment()">+1</button>
<button onclick="reset()">Reset</button>
</body>
</html>''',
    css: '''body {
  font-family: system-ui, sans-serif;
  padding: 24px;
}

button {
  padding: 8px 16px;
  margin-right: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
  background: white;
  cursor: pointer;
}''',
    js: '''var count = 0;

function increment() {
  count = count + 1;
  document.getElementById('count').textContent = count;
}

function reset() {
  count = 0;
  document.getElementById('count').textContent = count;
}''',
  );
}

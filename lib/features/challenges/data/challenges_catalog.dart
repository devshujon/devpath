import '../models/challenge.dart';

class ChallengesCatalog {
  ChallengesCatalog._();

  static const List<Challenge> all = [
    _c1RoundedButton,
    _c2ClickMessage,
    _c3CardShadow,
    _c4Counter,
    _c5FlexNavbar,
    _c6ToggleVisibility,
  ];

  static Challenge? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<Challenge> byDifficulty(Difficulty d) =>
      all.where((c) => c.difficulty == d).toList();
}

// ─────────────────────────────────────────────
//  1. Style a button with rounded corners
// ─────────────────────────────────────────────
const _c1RoundedButton = Challenge(
  id: 'c01_rounded_button',
  title: 'Rounded Button',
  description: 'Make a button with rounded corners and padding.',
  difficulty: Difficulty.beginner,
  instructions: [
    'Add a <button> element with the text "Click me".',
    'Give it border-radius and padding via CSS.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<!-- Add your button here -->
</body>
</html>''',
  starterCss: '/* Style your button here */',
  starterJs: '',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlTag, value: 'button'),
      Rule(type: Rule.htmlText, value: 'Click me'),
    ],
    css: [
      Rule(type: Rule.cssProperty, value: 'border-radius'),
      Rule(type: Rule.cssProperty, value: 'padding'),
    ],
  ),
  xpReward: 30,
  hint:
      'In HTML: <button>Click me</button>. In CSS: target the button selector and set border-radius and padding.',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button>Click me</button>
</body>
</html>''',
    'css': '''button {
  padding: 12px 20px;
  border-radius: 8px;
  border: 0;
  background: #6c5ce7;
  color: white;
  cursor: pointer;
}''',
    'js': '',
  },
);

// ─────────────────────────────────────────────
//  2. Click button to show a message
// ─────────────────────────────────────────────
const _c2ClickMessage = Challenge(
  id: 'c02_click_message',
  title: 'Click to Show Message',
  description: 'Wire a button to display a welcome message.',
  difficulty: Difficulty.beginner,
  instructions: [
    'Add a <button> with onclick="showMessage()".',
    'Add a <div id="output"></div> to hold the message.',
    'Define a function showMessage() that sets output.innerHTML.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<!-- Add your button and output div -->
</body>
</html>''',
  starterCss: '',
  starterJs: '// Define showMessage() here',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlTag, value: 'button'),
      Rule(
        type: Rule.htmlAttribute,
        value: 'onclick',
        onTag: 'button',
      ),
    ],
    js: [
      Rule(type: Rule.jsFunction, value: 'showMessage'),
      Rule(type: Rule.jsDom, value: 'getElementById'),
    ],
  ),
  xpReward: 50,
  hint:
      'Wire the button with onclick="showMessage()". Inside showMessage, call document.getElementById("output") and set its innerHTML.',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button onclick="showMessage()">Greet me</button>
<div id="output"></div>
</body>
</html>''',
    'css': '',
    'js': '''function showMessage() {
  document.getElementById('output').innerHTML = 'Welcome to DevPath!';
}''',
  },
);

// ─────────────────────────────────────────────
//  3. Card with shadow
// ─────────────────────────────────────────────
const _c3CardShadow = Challenge(
  id: 'c03_card_shadow',
  title: 'Card with Shadow',
  description: 'Build a card component with rounded corners and a drop shadow.',
  difficulty: Difficulty.beginner,
  instructions: [
    'Create a <div class="card"> with a heading and paragraph inside.',
    'Style .card with border-radius, padding, and box-shadow.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<!-- Build a card -->
</body>
</html>''',
  starterCss: '/* Style .card */',
  starterJs: '',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlAttribute, value: 'class'),
    ],
    css: [
      Rule(type: Rule.cssSelector, value: '.card'),
      Rule(type: Rule.cssProperty, value: 'box-shadow'),
      Rule(type: Rule.cssProperty, value: 'border-radius'),
    ],
  ),
  xpReward: 50,
  hint:
      'CSS selector for a class is ".card". box-shadow takes offsets, blur, and color: e.g. 0 2px 8px rgba(0,0,0,0.1).',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="card">
  <h2>Card Title</h2>
  <p>Some description text.</p>
</div>
</body>
</html>''',
    'css': '''.card {
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  max-width: 320px;
  background: white;
}''',
    'js': '',
  },
);

// ─────────────────────────────────────────────
//  4. Counter
// ─────────────────────────────────────────────
const _c4Counter = Challenge(
  id: 'c04_counter',
  title: 'Click Counter',
  description: 'A button that increments a count each time it is clicked.',
  difficulty: Difficulty.intermediate,
  instructions: [
    'Add a <span id="count">0</span>.',
    'Add a <button> that calls increment() on click.',
    'Define increment() that updates count.textContent.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<p>Count: <span id="count">0</span></p>
<!-- Add a button that calls increment() -->
</body>
</html>''',
  starterCss: '',
  starterJs: '''var count = 0;

// Define increment() here''',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlTag, value: 'button'),
      Rule(type: Rule.htmlAttribute, value: 'onclick', onTag: 'button'),
    ],
    js: [
      Rule(type: Rule.jsFunction, value: 'increment'),
      Rule(type: Rule.jsDom, value: 'getElementById'),
    ],
  ),
  xpReward: 60,
  hint:
      'Inside increment(): count++; then document.getElementById("count").textContent = count.',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<p>Count: <span id="count">0</span></p>
<button onclick="increment()">+1</button>
</body>
</html>''',
    'css': '',
    'js': '''var count = 0;

function increment() {
  count++;
  document.getElementById('count').textContent = count;
}''',
  },
);

// ─────────────────────────────────────────────
//  5. Flexbox Navbar
// ─────────────────────────────────────────────
const _c5FlexNavbar = Challenge(
  id: 'c05_flex_navbar',
  title: 'Flexbox Navbar',
  description: 'A horizontal navigation bar using flexbox.',
  difficulty: Difficulty.intermediate,
  instructions: [
    'Create a <nav class="nav"> with three <a> links inside.',
    'Use display: flex on .nav.',
    'Add gap between items.',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<!-- Build the navbar -->
</body>
</html>''',
  starterCss: '/* Style the navbar */',
  starterJs: '',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlTag, value: 'nav'),
      Rule(type: Rule.htmlTag, value: 'a'),
    ],
    css: [
      Rule(type: Rule.cssSelector, value: '.nav'),
      Rule(type: Rule.cssProperty, value: 'display'),
      Rule(type: Rule.cssProperty, value: 'gap'),
    ],
  ),
  xpReward: 70,
  hint:
      '.nav { display: flex; gap: 16px; } and three <a href="#">Item</a> elements inside <nav class="nav">.',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<nav class="nav">
  <a href="#">Home</a>
  <a href="#">About</a>
  <a href="#">Contact</a>
</nav>
</body>
</html>''',
    'css': '''.nav {
  display: flex;
  gap: 16px;
  padding: 12px 16px;
  background: #f5f5f5;
}

.nav a {
  text-decoration: none;
  color: #333;
}''',
    'js': '',
  },
);

// ─────────────────────────────────────────────
//  6. Toggle Visibility
// ─────────────────────────────────────────────
const _c6ToggleVisibility = Challenge(
  id: 'c06_toggle_visibility',
  title: 'Toggle Visibility',
  description: 'Show or hide a paragraph when a button is clicked.',
  difficulty: Difficulty.intermediate,
  instructions: [
    'Add a <button> with onclick="toggle()".',
    'Add a <p id="msg"> with some text.',
    'Define toggle() that flips msg.style.display between "block" and "none".',
  ],
  starterHtml: '''<!DOCTYPE html>
<html>
<body>
<!-- Add button + paragraph -->
</body>
</html>''',
  starterCss: '',
  starterJs: '// Define toggle()',
  expectedRules: ExpectedRules(
    html: [
      Rule(type: Rule.htmlTag, value: 'button'),
      Rule(type: Rule.htmlAttribute, value: 'onclick', onTag: 'button'),
    ],
    js: [
      Rule(type: Rule.jsFunction, value: 'toggle'),
      Rule(type: Rule.jsDom, value: 'getElementById'),
    ],
  ),
  xpReward: 70,
  hint:
      'Check msg.style.display: if it equals "none", set it to "block", otherwise set it to "none".',
  solution: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button onclick="toggle()">Toggle</button>
<p id="msg">Hello, I can be hidden.</p>
</body>
</html>''',
    'css': '',
    'js': '''function toggle() {
  var el = document.getElementById('msg');
  el.style.display = el.style.display === 'none' ? 'block' : 'none';
}''',
  },
);

import '../models/lesson.dart';

/// All lessons available in the app. Sequential within difficulty;
/// difficulty gating enforced by the provider.
///
/// Ordering rationale: within each difficulty, lessons are INTERLEAVED
/// by track (HTML → CSS → JS, repeating) so the sequential-unlock rule
/// in [LearningProgressProvider._isLocked] forces breadth before depth
/// rather than locking the user into one language before they see the
/// next. Catalog index drives unlock order.
class LessonsCatalog {
  LessonsCatalog._();

  static const List<Lesson> all = [
    // ───────── Beginner — h1_heading is the gold-standard first lesson ──
    _h1Heading,            // html (inserted first; completed lessons stay unlocked)
    // ───────── Beginner (12) — 4 HTML / 4 CSS / 4 JS, interleaved ─────────
    _b01HtmlIntro,         // html
    _b02CssIntro,          // css
    _b03JsIntro,           // js
    _htmlLinks,            // html
    _cssSelectors,         // css
    _jsOperators,          // js
    _htmlLists,            // html
    _cssBoxModel,          // css
    _jsConditionals,       // js
    _htmlImages,           // html
    _cssColors,            // css
    _jsLoops,              // js

    // ───────── Intermediate (12) — 4 HTML / 4 CSS / 4 JS, interleaved ─────
    _htmlSemantic,         // html
    _i01Flexbox,           // css
    _jsFunctions,          // js
    _htmlForms,            // html
    _i02Grid,              // css
    _jsArrays,             // js
    _htmlInputs,           // html
    _cssTypography,        // css
    _jsObjects,            // js
    _htmlTables,           // html
    _cssPositioning,       // css
    _i03Dom,               // js

    // ───────── Advanced (12) — 4 HTML / 4 CSS / 4 JS, interleaved ─────────
    _htmlValidation,       // html
    _a01Responsive,        // css
    _i04Events,            // js
    _htmlMeta,             // html
    _cssTransitions,       // css
    _a02Apis,              // js
    _htmlAccessibility,    // html
    _cssAnimations,        // css
    _a03AsyncJs,           // js
    _htmlMedia,            // html
    _cssVariables,         // css
    _jsErrors,             // js

    // ───────── Capstone — counts toward Graduate cert only ─────────
    _a04MiniProjects,
  ];

  static Lesson? byId(String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }

  static List<Lesson> byDifficulty(Difficulty d) =>
      all.where((l) => l.difficulty == d).toList();

  /// Lessons in a curriculum track (HTML, CSS, JS, capstone). Used to
  /// build certificate eligibility — DO NOT hardcode lesson IDs at
  /// certificate definition sites; query this instead.
  static List<Lesson> byTrack(LessonTrack t) =>
      all.where((l) => l.track == t).toList();

  /// Set of lesson IDs in a track. Convenience wrapper.
  static Set<String> idsByTrack(LessonTrack t) =>
      byTrack(t).map((l) => l.id).toSet();

  /// Ordered list of unique module names within a difficulty, in the
  /// order they first appear in [all].
  static List<String> modulesIn(Difficulty d) {
    final seen = <String>{};
    final out = <String>[];
    for (final l in byDifficulty(d)) {
      if (seen.add(l.module)) out.add(l.module);
    }
    return out;
  }
}

// ─────────────────────────────────────────────────────────
//  BEGINNER
// ─────────────────────────────────────────────────────────

const _h1Heading = Lesson(
  id: 'h1_heading',
  title: 'The H1 Heading',
  description:
      'What an H1 is, why pages need one, and how browsers, search, and screen readers use it.',
  module: 'HTML',
  difficulty: Difficulty.beginner,
  track: LessonTrack.html,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h1>Welcome to my site</h1>
<h2>About me</h2>
<p>I am learning to build web pages.</p>
</body>
</html>''',
    'css': '''body {
  font-family: system-ui, sans-serif;
  padding: 20px;
  line-height: 1.5;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which tag marks the most important heading on a page?',
      options: ['<h1>', '<h6>', '<head>', '<title>'],
      correctIndex: 0,
      explanation:
          '<h1> is the top of the heading outline. <title> lives in <head> and labels the browser tab.',
    ),
    QuizQuestion(
      question: 'Why do heading tags exist?',
      options: [
        'Only to make text look bigger',
        'To give the page machine-readable structure',
        'To replace the <title> tag',
        'To load CSS faster',
      ],
      correctIndex: 1,
      explanation:
          'Size is CSS. Headings carry meaning for browsers, search engines, and assistive tech.',
    ),
    QuizQuestion(
      question: 'How many <h1> elements should a typical page have?',
      options: ['As many as look like titles', 'None', 'One', 'Exactly six'],
      correctIndex: 2,
      explanation:
          'One <h1> names the page topic. HTML5 technically allows more, but one is the safest convention.',
    ),
  ],
);

const _b01HtmlIntro = Lesson(
  id: 'b01_html',
  title: 'HTML Basics',
  description:
      'Learn how every web page is structured. Headings, paragraphs, and links.',
  module: 'HTML',
  difficulty: Difficulty.beginner,
  track: LessonTrack.html,
  estimatedMinutes: 8,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h1>My Page</h1>
<p>This is a paragraph.</p>
<a href="#">Click me</a>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which tag is used for the largest heading?',
      options: ['<h1>', '<h6>', '<head>', '<heading>'],
      correctIndex: 0,
      explanation: '<h1> is the largest. Headings range from h1 to h6.',
    ),
    QuizQuestion(
      question: 'Where does the visible page content go?',
      options: ['<head>', '<title>', '<body>', '<meta>'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which attribute defines a link target?',
      options: ['src', 'href', 'to', 'url'],
      correctIndex: 1,
    ),
  ],
);

const _b02CssIntro = Lesson(
  id: 'b02_css',
  title: 'CSS Basics',
  description: 'Style your HTML with colors, fonts, and spacing.',
  module: 'CSS',
  difficulty: Difficulty.beginner,
  track: LessonTrack.css,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h1>Style me</h1>
<p>Make this blue.</p>
</body>
</html>''',
    'css': '''body {
  font-family: system-ui, sans-serif;
  padding: 20px;
}

/* Try changing the color */
p {
  color: black;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which property changes text color?',
      options: ['text-color', 'color', 'font-color', 'foreground'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you write a CSS comment?',
      options: ['// comment', '<!-- comment -->', '/* comment */', '# comment'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which selector targets an id="hero"?',
      options: ['.hero', '#hero', 'hero', '*hero'],
      correctIndex: 1,
    ),
  ],
);

const _b03JsIntro = Lesson(
  id: 'b03_js',
  title: 'JavaScript Basics',
  description: 'Variables, functions, and printing to the console.',
  module: 'JavaScript',
  difficulty: Difficulty.beginner,
  track: LessonTrack.js,
  estimatedMinutes: 12,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h2>Open the preview console</h2>
</body>
</html>''',
    'css': '',
    'js': '''const name = 'Alice';
let age = 25;
console.log('Hello, ' + name);
console.log('Age:', age);''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which keyword declares a value that cannot be reassigned?',
      options: ['let', 'var', 'const', 'static'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How do you print to the developer console?',
      options: ['print()', 'echo()', 'console.log()', 'System.out()'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: "What's the result of: 2 + '2'?",
      options: ['4', "'22'", 'NaN', 'Error'],
      correctIndex: 1,
      explanation: "JavaScript coerces 2 to a string then concatenates → '22'.",
    ),
  ],
);

// ─────────────────────────────────────────────────────────
//  INTERMEDIATE
// ─────────────────────────────────────────────────────────

const _i01Flexbox = Lesson(
  id: 'i01_flexbox',
  title: 'Flexbox',
  description: 'Arrange items in rows and columns with flexbox.',
  module: 'Flexbox',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.css,
  estimatedMinutes: 15,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="row">
  <div class="box">1</div>
  <div class="box">2</div>
  <div class="box">3</div>
</div>
</body>
</html>''',
    'css': '''.row {
  display: flex;
  gap: 12px;
}

.box {
  flex: 1;
  background: #6c5ce7;
  color: white;
  padding: 20px;
  text-align: center;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which property turns an element into a flex container?',
      options: ['display: flex', 'flex: 1', 'position: flex', 'layout: flex'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'Which property distributes items along the main axis?',
      options: ['align-items', 'justify-content', 'flex-direction', 'gap'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Default flex-direction value?',
      options: ['column', 'row', 'row-reverse', 'inherit'],
      correctIndex: 1,
    ),
  ],
);

const _i02Grid = Lesson(
  id: 'i02_grid',
  title: 'CSS Grid',
  description: 'Two-dimensional layouts with rows and columns.',
  module: 'Grid',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.css,
  estimatedMinutes: 15,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="grid">
  <div>A</div><div>B</div><div>C</div>
  <div>D</div><div>E</div><div>F</div>
</div>
</body>
</html>''',
    'css': '''.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.grid > div {
  background: #00b894;
  color: white;
  padding: 24px;
  text-align: center;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which property defines column structure?',
      options: ['grid-cols', 'grid-template-columns', 'columns', 'col-span'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does "1fr" mean?',
      options: [
        '1 pixel',
        '1 fraction of available space',
        '1 fragment',
        '1 free row',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you create 4 equal columns?',
      options: [
        'grid-template-columns: 4',
        'columns: 1fr 1fr 1fr 1fr',
        'grid-template-columns: repeat(4, 1fr)',
        'grid-cols: 4',
      ],
      correctIndex: 2,
    ),
  ],
);

const _i03Dom = Lesson(
  id: 'i03_dom',
  title: 'DOM Manipulation',
  description: 'Read and update elements with JavaScript.',
  module: 'DOM',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.js,
  estimatedMinutes: 15,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h2 id="title">Original title</h2>
<button onclick="changeTitle()">Change it</button>
</body>
</html>''',
    'css': '',
    'js': '''function changeTitle() {
  document.getElementById('title').textContent = 'New title!';
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'How do you select an element by id="hero"?',
      options: [
        "document.find('hero')",
        "document.getElementById('hero')",
        "document.select('#hero')",
        "document.id('hero')",
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which property changes element text safely?',
      options: ['innerHTML', 'textContent', 'innerText', 'all are identical'],
      correctIndex: 1,
      explanation: 'textContent avoids HTML injection from user input.',
    ),
    QuizQuestion(
      question: 'How do you add a CSS class via JS?',
      options: [
        "el.class.add('x')",
        "el.classList.add('x')",
        "el.addClass('x')",
        "el.className = 'x'",
      ],
      correctIndex: 1,
    ),
  ],
);

const _i04Events = Lesson(
  id: 'i04_events',
  title: 'Events',
  description: 'Respond to clicks, input, and other user actions.',
  module: 'Events',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.js,
  estimatedMinutes: 12,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<input id="name" placeholder="Type your name">
<p>Hello, <span id="out">stranger</span></p>
</body>
</html>''',
    'css': 'input { padding: 8px; font-size: 14px; }',
    'js': '''document.getElementById('name').addEventListener('input', function(e) {
  document.getElementById('out').textContent = e.target.value || 'stranger';
});''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'How do you listen for a click event?',
      options: [
        "el.onClick(fn)",
        "el.addEventListener('click', fn)",
        "el.on('click', fn)",
        "el.click = fn",
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which event fires while a user types in an input?',
      options: ['input', 'keydown', 'change', 'paste'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'What does event.preventDefault() do?',
      options: [
        'Cancels the event handler',
        'Stops the default browser action',
        'Removes the listener',
        'Pauses event propagation',
      ],
      correctIndex: 1,
    ),
  ],
);

// ─────────────────────────────────────────────────────────
//  ADVANCED
// ─────────────────────────────────────────────────────────

const _a01Responsive = Lesson(
  id: 'a01_responsive',
  title: 'Responsive Design',
  description: 'Make pages look good on phones, tablets, and desktops.',
  module: 'Responsive Design',
  difficulty: Difficulty.advanced,
  track: LessonTrack.css,
  estimatedMinutes: 18,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<head><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body>
<div class="container">
  <div class="box">A</div>
  <div class="box">B</div>
</div>
</body>
</html>''',
    'css': '''.container { display: flex; gap: 12px; padding: 12px; }
.box { flex: 1; background: #6c5ce7; color: white; padding: 24px; text-align: center; }

@media (max-width: 480px) {
  .container { flex-direction: column; }
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which meta tag enables proper mobile scaling?',
      options: [
        '<meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width,initial-scale=1">',
        '<meta name="mobile">',
        '<meta http-equiv="mobile">',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you apply CSS only on small screens?',
      options: [
        '@small',
        '@media (max-width: 480px)',
        '@screen (max-width: 480px)',
        'screen-max: 480px',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which CSS unit scales with the viewport width?',
      options: ['px', 'vw', 'em', 'pt'],
      correctIndex: 1,
    ),
  ],
);

const _a02Apis = Lesson(
  id: 'a02_apis',
  title: 'APIs and fetch',
  description: 'Talk to remote servers with the Fetch API.',
  module: 'APIs',
  difficulty: Difficulty.advanced,
  track: LessonTrack.js,
  estimatedMinutes: 15,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button onclick="loadJoke()">Random joke</button>
<p id="out"></p>
</body>
</html>''',
    'css': '',
    'js': '''function loadJoke() {
  fetch('https://icanhazdadjoke.com/', {
    headers: { 'Accept': 'application/json' },
  })
    .then(r => r.json())
    .then(data => {
      document.getElementById('out').textContent = data.joke;
    })
    .catch(err => {
      document.getElementById('out').textContent = 'Error: ' + err.message;
    });
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'What does fetch() return?',
      options: ['A string', 'A Promise', 'A callback', 'JSON directly'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you parse a JSON response body?',
      options: [
        'response.parse()',
        'response.json()',
        'JSON.parse(response)',
        'response.body.json',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you handle a failed request?',
      options: ['try/catch only', '.catch() on the Promise', '.fail()', 'onerror'],
      correctIndex: 1,
    ),
  ],
);

const _a03AsyncJs = Lesson(
  id: 'a03_async',
  title: 'async / await',
  description: 'Cleaner asynchronous code than .then() chains.',
  module: 'Async JS',
  difficulty: Difficulty.advanced,
  track: LessonTrack.js,
  estimatedMinutes: 15,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button onclick="run()">Wait 1 second</button>
<p id="out">Click the button.</p>
</body>
</html>''',
    'css': '',
    'js': '''function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function run() {
  document.getElementById('out').textContent = 'Waiting...';
  await wait(1000);
  document.getElementById('out').textContent = 'Done!';
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'A function must be marked ____ to use await inside it.',
      options: ['async', 'await', 'promise', 'defer'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'What does await do?',
      options: [
        'Blocks the entire thread',
        'Pauses the async function until the Promise resolves',
        'Throws if the Promise rejects',
        'Both B and C',
      ],
      correctIndex: 3,
    ),
    QuizQuestion(
      question: 'What does an async function return?',
      options: ['Nothing', 'The first return value', 'A Promise', 'A generator'],
      correctIndex: 2,
    ),
  ],
);

const _a04MiniProjects = Lesson(
  id: 'a04_mini_projects',
  title: 'Mini Projects',
  description: 'Put it together: build a small interactive component.',
  module: 'Mini Projects',
  difficulty: Difficulty.advanced,
  track: LessonTrack.capstone,
  estimatedMinutes: 30,
  xpReward: 150,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h2>Todo</h2>
<input id="entry" placeholder="What needs done?">
<button onclick="addItem()">Add</button>
<ul id="list"></ul>
</body>
</html>''',
    'css': '''body { font-family: system-ui, sans-serif; padding: 24px; }
input { padding: 8px; font-size: 14px; }
button { padding: 8px 14px; margin-left: 6px; }
li { padding: 4px 0; }''',
    'js': '''function addItem() {
  const input = document.getElementById('entry');
  const text = input.value.trim();
  if (!text) return;
  const li = document.createElement('li');
  li.textContent = text;
  li.addEventListener('click', () => li.remove());
  document.getElementById('list').appendChild(li);
  input.value = '';
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'How do you create a new <li> element in JS?',
      options: [
        "new Element('li')",
        "document.createElement('li')",
        "document.new('li')",
        "<li/>",
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you append a child to <ul>?',
      options: [
        'ul.add(li)',
        'ul.appendChild(li)',
        'ul.push(li)',
        'ul.insert(li)',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you remove an element from the DOM?',
      options: ['el.delete()', 'el.remove()', 'el.kill()', 'el.destroy()'],
      correctIndex: 1,
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════════
//  HTML TRACK — added lessons (11)
// ═════════════════════════════════════════════════════════════════════

const _htmlLinks = Lesson(
  id: 'html_links',
  title: 'Links and Anchors',
  description:
      'Connect pages together with anchor tags and internal navigation.',
  module: 'HTML Links',
  difficulty: Difficulty.beginner,
  track: LessonTrack.html,
  estimatedMinutes: 8,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h1>Useful Links</h1>
<a href="https://example.com">External site</a>
<a href="#section">Jump to section</a>
<a href="mailto:hi@example.com">Email me</a>
<h2 id="section">Target section</h2>
<p>You jumped here.</p>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which attribute opens a link in a new tab?',
      options: ['new="true"', 'target="_blank"', 'open="new"', 'rel="new"'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you link to an element with id="top"?',
      options: ['href="top"', 'href="#top"', 'href=".top"', 'href="@top"'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which protocol opens an email client?',
      options: ['email:', 'mail:', 'mailto:', 'send:'],
      correctIndex: 2,
    ),
  ],
);

const _htmlLists = Lesson(
  id: 'html_lists',
  title: 'Lists',
  description: 'Ordered, unordered, and description lists for grouped content.',
  module: 'HTML Lists',
  difficulty: Difficulty.beginner,
  track: LessonTrack.html,
  estimatedMinutes: 8,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h2>Shopping</h2>
<ul>
  <li>Milk</li>
  <li>Bread</li>
  <li>Coffee</li>
</ul>
<h2>Recipe steps</h2>
<ol>
  <li>Boil water</li>
  <li>Add coffee grounds</li>
  <li>Steep 4 minutes</li>
</ol>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which tag creates an unordered (bulleted) list?',
      options: ['<ol>', '<ul>', '<list>', '<dl>'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which tag wraps each item inside a list?',
      options: ['<item>', '<li>', '<entry>', '<row>'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which list type is best for step-by-step instructions?',
      options: ['<ul>', '<ol>', '<dl>', '<menu>'],
      correctIndex: 1,
      explanation: 'Ordered lists imply sequence; unordered lists imply grouping.',
    ),
  ],
);

const _htmlImages = Lesson(
  id: 'html_images',
  title: 'Images',
  description: 'Embed images with proper alt text and sizing.',
  module: 'HTML Images',
  difficulty: Difficulty.beginner,
  track: LessonTrack.html,
  estimatedMinutes: 8,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h2>My photo</h2>
<img src="https://via.placeholder.com/200" alt="Placeholder image" width="200">
<figure>
  <img src="https://via.placeholder.com/300x150" alt="Chart of monthly sales">
  <figcaption>Monthly sales, Q1 2026</figcaption>
</figure>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which attribute defines the image source URL?',
      options: ['href', 'src', 'url', 'link'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Why is the alt attribute important?',
      options: [
        'It speeds up loading',
        'It is required by browsers',
        'Screen readers and search engines use it',
        'It encrypts the URL',
      ],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which tag groups an image with a caption?',
      options: ['<group>', '<figure>', '<caption>', '<media>'],
      correctIndex: 1,
    ),
  ],
);

const _htmlSemantic = Lesson(
  id: 'html_semantic',
  title: 'Semantic HTML',
  description:
      'Use header, nav, main, section, article, and footer to give pages meaning.',
  module: 'Semantic HTML',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.html,
  estimatedMinutes: 12,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<header>
  <h1>My blog</h1>
  <nav>
    <a href="#">Home</a>
    <a href="#">Posts</a>
  </nav>
</header>
<main>
  <article>
    <h2>Article title</h2>
    <p>Article body.</p>
  </article>
</main>
<footer>&copy; 2026</footer>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which tag wraps the main, unique content of a page?',
      options: ['<body>', '<main>', '<section>', '<content>'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which tag groups navigation links?',
      options: ['<menu>', '<links>', '<nav>', '<navigate>'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which tag represents a self-contained piece like a blog post?',
      options: ['<section>', '<article>', '<aside>', '<post>'],
      correctIndex: 1,
      explanation:
          '<article> is for content that could stand alone (post, comment, card). '
          '<section> is a thematic grouping inside a larger page.',
    ),
  ],
);

const _htmlForms = Lesson(
  id: 'html_forms',
  title: 'Forms basics',
  description:
      'Collect user input with form, label, and submit-button essentials.',
  module: 'HTML Forms',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.html,
  estimatedMinutes: 12,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<form>
  <label for="name">Name</label>
  <input id="name" name="name" type="text">

  <label for="msg">Message</label>
  <textarea id="msg" name="msg"></textarea>

  <button type="submit">Send</button>
</form>
</body>
</html>''',
    'css': 'label, input, textarea, button { display: block; margin: 6px 0; }',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which attribute connects a <label> to an input?',
      options: ['name', 'id', 'for', 'ref'],
      correctIndex: 2,
      explanation: 'label for="x" links to input id="x".',
    ),
    QuizQuestion(
      question: 'Which button type submits the form?',
      options: ['type="send"', 'type="submit"', 'type="post"', 'type="form"'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which element creates a multi-line text input?',
      options: ['<input multi>', '<textarea>', '<textbox>', '<input lines="multi">'],
      correctIndex: 1,
    ),
  ],
);

const _htmlInputs = Lesson(
  id: 'html_inputs',
  title: 'Input types',
  description: 'Email, number, date, password, color, range, and more.',
  module: 'HTML Inputs',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.html,
  estimatedMinutes: 10,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<form>
  <input type="email" placeholder="Email">
  <input type="number" placeholder="Age" min="0" max="120">
  <input type="date">
  <input type="color">
  <input type="range" min="0" max="100">
</form>
</body>
</html>''',
    'css': 'input { display: block; margin: 8px 0; }',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which input type shows a calendar picker on mobile?',
      options: ['type="time"', 'type="date"', 'type="cal"', 'type="when"'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which input type masks characters as the user types?',
      options: ['type="hidden"', 'type="secret"', 'type="password"', 'type="masked"'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which attributes constrain a numeric input range?',
      options: ['from + to', 'min + max', 'low + high', 'start + end'],
      correctIndex: 1,
    ),
  ],
);

const _htmlTables = Lesson(
  id: 'html_tables',
  title: 'Tables',
  description: 'Display tabular data with thead, tbody, tr, th, and td.',
  module: 'HTML Tables',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.html,
  estimatedMinutes: 10,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<table>
  <thead>
    <tr><th>Name</th><th>Score</th></tr>
  </thead>
  <tbody>
    <tr><td>Alice</td><td>92</td></tr>
    <tr><td>Bob</td><td>87</td></tr>
  </tbody>
</table>
</body>
</html>''',
    'css': '''table { border-collapse: collapse; }
th, td { border: 1px solid #ccc; padding: 6px 12px; }''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which tag represents a table header cell?',
      options: ['<thead>', '<th>', '<td>', '<header>'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which tag groups the table body rows?',
      options: ['<body>', '<tbody>', '<rows>', '<group>'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which CSS property merges adjacent table borders?',
      options: ['border-merge', 'border-collapse', 'border-join', 'table-borders'],
      correctIndex: 1,
    ),
  ],
);

const _htmlValidation = Lesson(
  id: 'html_validation',
  title: 'Form validation',
  description: 'Built-in browser validation with required, pattern, and type.',
  module: 'HTML Validation',
  difficulty: Difficulty.advanced,
  track: LessonTrack.html,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<form>
  <input type="text" name="user" required minlength="3" placeholder="Username (min 3)">
  <input type="email" name="email" required placeholder="Email">
  <input type="text" name="zip" pattern="\\d{5}" placeholder="5-digit ZIP">
  <button type="submit">Submit</button>
</form>
</body>
</html>''',
    'css': 'input { display: block; margin: 6px 0; padding: 6px; }',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which attribute marks a field as mandatory?',
      options: ['mandatory', 'required', 'must', 'needed'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which attribute lets you specify a regex constraint?',
      options: ['regex', 'match', 'pattern', 'format'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What does type="email" do for validation?',
      options: [
        'Nothing — it is cosmetic',
        'Sends mail directly',
        'Rejects values without an @ symbol',
        'Encrypts the value',
      ],
      correctIndex: 2,
    ),
  ],
);

const _htmlMeta = Lesson(
  id: 'html_meta',
  title: 'Meta tags and SEO',
  description: 'Title, description, viewport, and Open Graph tags.',
  module: 'HTML Meta',
  difficulty: Difficulty.advanced,
  track: LessonTrack.html,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>My Page Title</title>
  <meta name="description" content="A short summary of the page.">
  <meta property="og:title" content="My Page Title">
  <meta property="og:image" content="https://example.com/preview.png">
</head>
<body>
<h1>Hello</h1>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Where do <meta> tags belong?',
      options: ['Inside <body>', 'Inside <head>', 'Inside <main>', 'Anywhere'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which meta name controls search-result snippets?',
      options: ['summary', 'description', 'snippet', 'preview'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which prefix is used for social-sharing preview tags?',
      options: ['social:', 'og:', 'share:', 'meta:'],
      correctIndex: 1,
      explanation: 'og: stands for Open Graph, originally a Facebook spec, now broadly supported.',
    ),
  ],
);

const _htmlAccessibility = Lesson(
  id: 'html_accessibility',
  title: 'Accessibility (a11y)',
  description: 'Aria attributes, labels, alt text, and focus order.',
  module: 'HTML Accessibility',
  difficulty: Difficulty.advanced,
  track: LessonTrack.html,
  estimatedMinutes: 14,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button aria-label="Close dialog">×</button>
<img src="chart.png" alt="Quarterly revenue by region">
<nav aria-label="Primary">
  <a href="#">Home</a>
  <a href="#">About</a>
</nav>
<input type="search" aria-label="Search posts">
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'When should you use aria-label?',
      options: [
        'For every element',
        'When the element has no visible text label',
        'Only on links',
        'Only on form controls',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What is appropriate alt text for a purely decorative image?',
      options: ['alt="decoration"', 'alt=""', 'alt="image"', 'omit the alt attribute'],
      correctIndex: 1,
      explanation:
          'Empty alt tells screen readers to skip the image; omitting it makes them read the filename.',
    ),
    QuizQuestion(
      question: 'Which HTML element is already focusable without tabindex?',
      options: ['<div>', '<button>', '<span>', '<p>'],
      correctIndex: 1,
    ),
  ],
);

const _htmlMedia = Lesson(
  id: 'html_media',
  title: 'Audio and Video',
  description: 'Embed playable media with controls and fallback content.',
  module: 'HTML Media',
  difficulty: Difficulty.advanced,
  track: LessonTrack.html,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<video controls width="320">
  <source src="movie.mp4" type="video/mp4">
  Your browser does not support video.
</video>

<audio controls>
  <source src="song.mp3" type="audio/mpeg">
  Your browser does not support audio.
</audio>
</body>
</html>''',
    'css': '',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which attribute shows the default play/pause UI?',
      options: ['ui', 'controls', 'show-ui', 'play'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What is the purpose of multiple <source> children inside <video>?',
      options: [
        'Play them in sequence',
        'Offer browsers a choice of formats to pick a supported one',
        'Show them side-by-side',
        'Decorative only',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which attribute makes a video start playing automatically?',
      options: ['auto', 'autoplay', 'start', 'play="auto"'],
      correctIndex: 1,
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════════
//  CSS TRACK — added lessons (8)
// ═════════════════════════════════════════════════════════════════════

const _cssSelectors = Lesson(
  id: 'css_selectors',
  title: 'Selectors deep dive',
  description: 'Combinators, attribute selectors, pseudo-classes, and specificity.',
  module: 'CSS Selectors',
  difficulty: Difficulty.beginner,
  track: LessonTrack.css,
  estimatedMinutes: 12,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<nav>
  <a href="#" class="active">Home</a>
  <a href="https://example.com">Docs</a>
  <a href="#">About</a>
</nav>
</body>
</html>''',
    'css': '''a { color: #555; }
a.active { font-weight: bold; }
a[href^="https"] { color: #0984e3; }
nav a:hover { text-decoration: underline; }''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which selector targets links whose href starts with "https"?',
      options: [
        'a:starts("https")',
        'a[href^="https"]',
        'a[href*="https"]',
        'a[href="https"]',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which selector has higher specificity?',
      options: ['div p', '#header', '.title', 'p'],
      correctIndex: 1,
      explanation: 'ID selectors have higher specificity than class or element selectors.',
    ),
    QuizQuestion(
      question: 'Which pseudo-class targets a hovered element?',
      options: [':hover', ':over', ':active', ':focus'],
      correctIndex: 0,
    ),
  ],
);

const _cssBoxModel = Lesson(
  id: 'css_box_model',
  title: 'Box model',
  description: 'Content, padding, border, and margin — and box-sizing.',
  module: 'CSS Box Model',
  difficulty: Difficulty.beginner,
  track: LessonTrack.css,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="card">A card</div>
</body>
</html>''',
    'css': '''* { box-sizing: border-box; }
.card {
  width: 200px;
  padding: 20px;
  border: 2px solid #6c5ce7;
  margin: 16px;
  background: #fafafa;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'What does box-sizing: border-box do?',
      options: [
        'Removes borders',
        'Makes width include padding and border',
        'Disables padding',
        'Hides the box',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which layer is OUTSIDE the border?',
      options: ['Padding', 'Content', 'Margin', 'Outline only'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Which property adds space INSIDE the border?',
      options: ['margin', 'padding', 'gap', 'spacing'],
      correctIndex: 1,
    ),
  ],
);

const _cssColors = Lesson(
  id: 'css_colors',
  title: 'Colors and backgrounds',
  description: 'Hex, rgb, hsl, named colors, gradients, and backgrounds.',
  module: 'CSS Colors',
  difficulty: Difficulty.beginner,
  track: LessonTrack.css,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="a">Hex</div>
<div class="b">RGB</div>
<div class="c">HSL</div>
<div class="d">Gradient</div>
</body>
</html>''',
    'css': '''div { color: white; padding: 16px; margin: 6px; }
.a { background: #6c5ce7; }
.b { background: rgb(0, 184, 148); }
.c { background: hsl(200, 80%, 50%); }
.d { background: linear-gradient(90deg, #ff6b35, #ffb020); }''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which is a valid hex color for pure red?',
      options: ['#FF0000', '#00FF00', '#0000FF', '#FFFFFF'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'What does the H in HSL stand for?',
      options: ['Hex', 'Hue', 'Height', 'Highlight'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which property creates a fading two-color background?',
      options: [
        'background-fade',
        'linear-gradient() inside background',
        'transition',
        'opacity',
      ],
      correctIndex: 1,
    ),
  ],
);

const _cssTypography = Lesson(
  id: 'css_typography',
  title: 'Typography',
  description: 'Font sizing, line height, weight, family, and web fonts.',
  module: 'CSS Typography',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.css,
  estimatedMinutes: 12,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<h1>Headline</h1>
<p>This is a paragraph with adjusted line height and font weight.</p>
</body>
</html>''',
    'css': '''body {
  font-family: system-ui, -apple-system, sans-serif;
  font-size: 16px;
  line-height: 1.6;
  color: #1a1a1a;
}
h1 { font-size: 2rem; font-weight: 700; letter-spacing: -0.02em; }
p { max-width: 60ch; }''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'What does the rem unit refer to?',
      options: [
        'Pixels',
        "Root element's font size",
        'Parent element font size',
        'Viewport width',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which line-height value gives comfortable paragraph spacing?',
      options: ['0.8', '1.0', '1.5–1.7', '3.0'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What does max-width: 60ch limit?',
      options: [
        'Character count',
        'Line width to roughly 60 characters',
        'Word count',
        'Element height',
      ],
      correctIndex: 1,
      explanation: 'ch is the width of "0" in the current font — useful for readable line lengths.',
    ),
  ],
);

const _cssPositioning = Lesson(
  id: 'css_positioning',
  title: 'Position and z-index',
  description: 'Static, relative, absolute, fixed, sticky — and stacking order.',
  module: 'CSS Positioning',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.css,
  estimatedMinutes: 14,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="wrap">
  <div class="card">Card</div>
  <div class="badge">NEW</div>
</div>
</body>
</html>''',
    'css': '''.wrap { position: relative; width: 240px; margin: 40px; }
.card { padding: 40px; background: #fafafa; border: 1px solid #ddd; }
.badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #e17055;
  color: white;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  z-index: 1;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'An absolutely-positioned child is offset relative to…',
      options: [
        'The viewport',
        'Its document',
        'Its nearest positioned ancestor',
        'Its parent (always)',
      ],
      correctIndex: 2,
      explanation: 'Nearest ancestor with position other than static (relative/absolute/fixed/sticky).',
    ),
    QuizQuestion(
      question: 'Which position keeps an element at the top of the viewport while scrolling?',
      options: ['relative', 'absolute', 'sticky', 'fixed'],
      correctIndex: 3,
    ),
    QuizQuestion(
      question: 'Higher z-index values…',
      options: ['Sit further back', 'Sit further forward', 'Are invisible', 'Disable position'],
      correctIndex: 1,
    ),
  ],
);

const _cssTransitions = Lesson(
  id: 'css_transitions',
  title: 'Transitions',
  description: 'Smoothly interpolate property changes on state change.',
  module: 'CSS Transitions',
  difficulty: Difficulty.advanced,
  track: LessonTrack.css,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<button class="btn">Hover me</button>
</body>
</html>''',
    'css': '''.btn {
  padding: 12px 24px;
  background: #6c5ce7;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: transform 200ms ease, background 200ms ease;
}
.btn:hover {
  transform: translateY(-2px);
  background: #5d4ed6;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which property declares which CSS properties animate?',
      options: ['animate', 'transition', 'change', 'morph'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which value of transition-timing-function starts slow then speeds up?',
      options: ['ease-in', 'ease-out', 'linear', 'ease-in-out'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'Can you transition between display: none and display: block?',
      options: ['Yes', 'No — display is not animatable', 'Only with opacity', 'Only with JS'],
      correctIndex: 1,
    ),
  ],
);

const _cssAnimations = Lesson(
  id: 'css_animations',
  title: 'Animations',
  description: '@keyframes and the animation shorthand for looping motion.',
  module: 'CSS Animations',
  difficulty: Difficulty.advanced,
  track: LessonTrack.css,
  estimatedMinutes: 14,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body>
<div class="dot"></div>
</body>
</html>''',
    'css': '''@keyframes pulse {
  0%   { transform: scale(1);   opacity: 1; }
  50%  { transform: scale(1.4); opacity: 0.5; }
  100% { transform: scale(1);   opacity: 1; }
}
.dot {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #e17055;
  margin: 60px auto;
  animation: pulse 1.5s ease-in-out infinite;
}''',
    'js': '',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which at-rule defines an animation keyframe sequence?',
      options: ['@animation', '@keyframes', '@frames', '@motion'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which value makes an animation loop forever?',
      options: ['loop', 'forever', 'infinite', 'continuous'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Inside @keyframes, what does 50% refer to?',
      options: [
        'Half the element size',
        'Halfway through the animation duration',
        '50% opacity',
        'Half the viewport',
      ],
      correctIndex: 1,
    ),
  ],
);

const _cssVariables = Lesson(
  id: 'css_variables',
  title: 'CSS Variables',
  description: 'Custom properties with var() and runtime theme switching.',
  module: 'CSS Variables',
  difficulty: Difficulty.advanced,
  track: LessonTrack.css,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html>
<body class="theme-light">
<button onclick="toggleTheme()">Toggle theme</button>
<div class="card">Themed card</div>
</body>
</html>''',
    'css': ''':root {
  --bg: #ffffff;
  --fg: #1a1a1a;
  --accent: #6c5ce7;
}
.theme-dark {
  --bg: #1a1f28;
  --fg: #e4e7ee;
  --accent: #a29bfe;
}
body { background: var(--bg); color: var(--fg); padding: 20px; }
.card { padding: 20px; border: 2px solid var(--accent); margin-top: 10px; }''',
    'js': '''function toggleTheme() {
  document.body.classList.toggle('theme-dark');
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'How do you declare a CSS custom property?',
      options: ['var color: red;', '\$color: red;', '--color: red;', '@color: red;'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How do you read a custom property in CSS?',
      options: ['get(--color)', 'var(--color)', 'use(--color)', '\$(--color)'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Where should you declare app-wide variables?',
      options: ['body', '*', ':root', 'html *'],
      correctIndex: 2,
      explanation: ':root has slightly higher specificity than html and is the conventional location.',
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════════
//  JAVASCRIPT TRACK — added lessons (7)
// ═════════════════════════════════════════════════════════════════════

const _jsOperators = Lesson(
  id: 'js_operators',
  title: 'Operators and comparison',
  description: 'Arithmetic, comparison, logical, and the strict equality gotcha.',
  module: 'JS Operators',
  difficulty: Difficulty.beginner,
  track: LessonTrack.js,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''console.log(10 + 3);          // 13
console.log(10 / 3);          // 3.333
console.log(10 % 3);          // 1 (remainder)
console.log(2 ** 8);          // 256 (exponent)
console.log(5 == '5');        // true  (loose equality coerces)
console.log(5 === '5');       // false (strict equality checks type)
console.log(true && false);   // false
console.log(true || false);   // true''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which operator returns the remainder of a division?',
      options: ['/', '%', '#', 'mod'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does === check that == does not?',
      options: [
        'Strict reference identity only',
        'Type equality in addition to value',
        'Both operands are truthy',
        'Nothing different',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does 2 ** 3 return?',
      options: ['6', '8', '5', '23'],
      correctIndex: 1,
    ),
  ],
);

const _jsConditionals = Lesson(
  id: 'js_conditionals',
  title: 'Conditionals',
  description: 'if / else if / else, switch, and the ternary operator.',
  module: 'JS Conditionals',
  difficulty: Difficulty.beginner,
  track: LessonTrack.js,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''const score = 82;
let grade;
if (score >= 90)      grade = 'A';
else if (score >= 80) grade = 'B';
else if (score >= 70) grade = 'C';
else                  grade = 'F';
console.log(grade);

const label = score >= 60 ? 'pass' : 'fail';
console.log(label);''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'What does a ternary expression look like?',
      options: [
        'if (a) b else c',
        'a ? b : c',
        'a -> b -> c',
        'a && b || c',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which keyword exits a switch case early?',
      options: ['exit', 'stop', 'break', 'return'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Are { } curly braces required around a single-statement if body?',
      options: ['Yes always', 'No, but recommended for clarity', 'Only in strict mode', 'Only for else'],
      correctIndex: 1,
    ),
  ],
);

const _jsLoops = Lesson(
  id: 'js_loops',
  title: 'Loops',
  description: 'for, while, for-of, and forEach.',
  module: 'JS Loops',
  difficulty: Difficulty.beginner,
  track: LessonTrack.js,
  estimatedMinutes: 10,
  xpReward: 50,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''for (let i = 0; i < 3; i++) console.log('classic for', i);

let n = 0;
while (n < 3) { console.log('while', n); n++; }

const fruits = ['apple', 'banana', 'cherry'];
for (const f of fruits) console.log('for-of', f);

fruits.forEach((f, i) => console.log('forEach', i, f));''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which loop is best for iterating array VALUES directly?',
      options: ['for (let i = 0; ...)', 'for-of', 'for-in', 'do-while'],
      correctIndex: 1,
      explanation: 'for-in iterates KEYS; for-of iterates values.',
    ),
    QuizQuestion(
      question: 'What does break do inside a loop?',
      options: ['Skips to next iteration', 'Exits the loop entirely', 'Throws an error', 'Pauses the loop'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does continue do inside a loop?',
      options: [
        'Exits the loop',
        'Skips to the next iteration',
        'Restarts from index 0',
        'Throws an error',
      ],
      correctIndex: 1,
    ),
  ],
);

const _jsFunctions = Lesson(
  id: 'js_functions',
  title: 'Functions deep dive',
  description: 'Declarations, expressions, arrow functions, defaults, and rest.',
  module: 'JS Functions',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.js,
  estimatedMinutes: 14,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''function greet(name = 'friend') { return 'Hi ' + name; }
const double = (n) => n * 2;
const sum = (...nums) => nums.reduce((a, b) => a + b, 0);

console.log(greet());          // Hi friend
console.log(greet('Alice'));   // Hi Alice
console.log(double(5));        // 10
console.log(sum(1, 2, 3, 4));  // 10''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'How do you give a parameter a default value?',
      options: [
        'function f(a default=1) {}',
        'function f(a = 1) {}',
        'function f(a) { a = a || 1 } — required',
        'function f(a:1) {}',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does the …args rest parameter do?',
      options: [
        'Throws on unknown args',
        'Collects remaining args into an array',
        'Pauses execution',
        'Spreads an array out',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do arrow functions differ from regular functions?',
      options: [
        'Faster execution',
        'They do not bind their own this',
        'They cannot take parameters',
        'They cannot return values',
      ],
      correctIndex: 1,
    ),
  ],
);

const _jsArrays = Lesson(
  id: 'js_arrays',
  title: 'Arrays',
  description: 'push, map, filter, reduce, find, and spread.',
  module: 'JS Arrays',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.js,
  estimatedMinutes: 14,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''const nums = [1, 2, 3, 4, 5];

const doubled = nums.map(n => n * 2);            // [2,4,6,8,10]
const evens   = nums.filter(n => n % 2 === 0);   // [2,4]
const total   = nums.reduce((a, b) => a + b, 0); // 15
const found   = nums.find(n => n > 3);           // 4
const combo   = [...nums, 6, 7];                  // spread

console.log({ doubled, evens, total, found, combo });''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which array method returns a NEW array of transformed values?',
      options: ['forEach', 'map', 'filter', 'reduce'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which array method returns a NEW array of items passing a predicate?',
      options: ['find', 'filter', 'map', 'some'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What does [...arr, x] do?',
      options: [
        'Throws — invalid syntax',
        'Creates a new array with arr expanded plus x appended',
        'Mutates arr to add x',
        'Pops x off arr',
      ],
      correctIndex: 1,
    ),
  ],
);

const _jsObjects = Lesson(
  id: 'js_objects',
  title: 'Objects',
  description: 'Keys, values, destructuring, spread, and shorthand.',
  module: 'JS Objects',
  difficulty: Difficulty.intermediate,
  track: LessonTrack.js,
  estimatedMinutes: 14,
  xpReward: 80,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''const user = { name: 'Alice', age: 30, city: 'Tokyo' };

const { name, age } = user;                  // destructure
const older = { ...user, age: age + 1 };     // spread + override
const keys  = Object.keys(user);             // ['name','age','city']

console.log(name, age, older, keys);''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'What does const { a } = obj do?',
      options: [
        'Copies obj into a',
        "Pulls the 'a' property out of obj into a variable a",
        'Creates an array',
        'Errors at runtime',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you copy and override one property?',
      options: [
        'obj.copy({age: 1})',
        '{ ...obj, age: 1 }',
        'Object.replace(obj, {age:1})',
        'obj.age = 1 — same thing',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How do you get an array of an object\'s keys?',
      options: ['obj.keys()', 'Object.keys(obj)', 'keys(obj)', 'obj.getKeys()'],
      correctIndex: 1,
    ),
  ],
);

const _jsErrors = Lesson(
  id: 'js_errors',
  title: 'Error handling',
  description: 'try / catch / finally and throwing custom errors.',
  module: 'JS Errors',
  difficulty: Difficulty.advanced,
  track: LessonTrack.js,
  estimatedMinutes: 12,
  xpReward: 120,
  starterCode: {
    'html': '''<!DOCTYPE html>
<html><body><h2>Check console</h2></body></html>''',
    'css': '',
    'js': '''function divide(a, b) {
  if (b === 0) throw new Error('Cannot divide by zero');
  return a / b;
}

try {
  console.log(divide(10, 2));   // 5
  console.log(divide(10, 0));   // throws
} catch (e) {
  console.log('Caught:', e.message);
} finally {
  console.log('Always runs');
}''',
  },
  quizQuestions: [
    QuizQuestion(
      question: 'Which block runs whether or not an error was thrown?',
      options: ['try', 'catch', 'finally', 'always'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How do you raise an error manually?',
      options: ['raise Error()', 'throw new Error("msg")', 'error("msg")', 'panic("msg")'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What property holds the human-readable text of an Error?',
      options: ['text', 'msg', 'message', 'description'],
      correctIndex: 2,
    ),
  ],
);

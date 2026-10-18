/// Hand-authored quizzes and curriculum for high-value lessons.
/// Applied by [generate_learning_tracks.dart]; IDs must stay stable.

class PriorityQuiz {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const PriorityQuiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class PriorityLessonOverride {
  final List<PriorityQuiz> quizzes;
  final Map<String, dynamic>? curriculum;

  const PriorityLessonOverride({
    required this.quizzes,
    this.curriculum,
  });
}

/// Lesson IDs with topic-specific assessment (not generator templates).
final priorityLessonOverrides = <String, PriorityLessonOverride>{
  'php_22': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Why should a simple PHP API return JSON with an appropriate HTTP status code?',
        options: [
          'So browsers can skip TLS',
          'So clients can distinguish success from client/server errors programmatically',
          'So SQL runs faster',
          'So HTML forms are not needed',
        ],
        correctIndex: 1,
        explanation:
            'REST-style APIs use status codes (200, 400, 404, 500) plus structured JSON so clients handle errors predictably.',
      ),
      PriorityQuiz(
        question: 'Which approach is unsafe for passing user input into SQL from an API?',
        options: [
          'Prepared statements with bound parameters',
          'String concatenation: "SELECT * FROM users WHERE id = \$id"',
          'PDO with placeholders',
          'Validating input type before binding',
        ],
        correctIndex: 1,
        explanation: 'Never build SQL by concatenating raw user input — use parameterized queries.',
      ),
      PriorityQuiz(
        question: 'Where should authentication for a private API endpoint be enforced?',
        options: [
          'Only in CSS',
          'On the server before business logic runs',
          'Only in localStorage on the client',
          'In a README file',
        ],
        correctIndex: 1,
        explanation: 'Clients can be forged; authorization must be verified server-side on every request.',
      ),
      PriorityQuiz(
        question: 'A POST endpoint creates a resource. A duplicate submit arrives. A safe pattern is to…',
        options: [
          'Disable all logging',
          'Use idempotency keys or deduplicate with server-side checks where appropriate',
          'Return HTTP 200 with empty body always',
          'Store passwords in the JSON body in plain text',
        ],
        correctIndex: 1,
        explanation: 'Design APIs for retries: idempotency keys or natural uniqueness constraints prevent double creates.',
      ),
    ],
    curriculum: _phpApiCurriculum,
  ),
  'php_23': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'What does PDO provide in PHP database access?',
        options: [
          'A way to style HTML tables only',
          'A consistent interface to talk to databases with prepared statements support',
          'Automatic frontend bundling',
          'Plaintext password storage',
        ],
        correctIndex: 1,
        explanation:
            'PDO (PHP Data Objects) abstracts database drivers and supports prepared statements across MySQL and others.',
      ),
      PriorityQuiz(
        question: 'Why set PDO error mode to exceptions in development?',
        options: [
          'To hide all failures in production logs',
          'To fail visibly during development so connection/SQL bugs are caught early',
          'To disable prepared statements',
          'To allow SQL injection',
        ],
        correctIndex: 1,
        explanation: 'PDO::ERRMODE_EXCEPTION helps you debug; still handle errors safely for users in production.',
      ),
      PriorityQuiz(
        question: 'Database credentials in PHP should live…',
        options: [
          'In a public GitHub repo',
          'In environment variables or a non-web-readable config outside version control',
          'In JavaScript sent to the browser',
          'In HTML comments',
        ],
        correctIndex: 1,
        explanation: 'Secrets belong in environment configuration, not client code or committed files.',
      ),
    ],
    curriculum: _phpPdoCurriculum,
  ),
  'php_24': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Prepared statements primarily protect against…',
        options: [
          'Slow CSS animations',
          'SQL injection by separating SQL structure from user-supplied data',
          'Missing semicolons in HTML',
          'Large image uploads only',
        ],
        correctIndex: 1,
        explanation: 'Bound parameters ensure user input is treated as data, not executable SQL.',
      ),
      PriorityQuiz(
        question: 'Which PDO usage is correct for a user-supplied email lookup?',
        options: [
          r'$pdo->query("SELECT * FROM users WHERE email = $email")',
          r'$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?"); $stmt->execute([$email]);',
          r'echo $_GET["email"] inside the SQL string',
          'Use addslashes() instead of binding',
        ],
        correctIndex: 1,
        explanation: 'Placeholders (?) or named params with execute([...]) is the safe pattern.',
      ),
      PriorityQuiz(
        question: 'Client-side form validation alone is…',
        options: [
          'Sufficient for security',
          'Helpful for UX but must be repeated on the server',
          'Required to disable HTTPS',
          'A replacement for password hashing',
        ],
        correctIndex: 1,
        explanation: 'Attackers can bypass the browser; always validate and parameterize on the server.',
      ),
      PriorityQuiz(
        question: 'After execute(), how should you read rows from a SELECT prepared statement?',
        options: [
          'Mix user input back into the SQL string',
          'Use fetch()/fetchAll() on the statement object',
          r'Print raw $_POST to the page',
          'Disable error reporting permanently',
        ],
        correctIndex: 1,
        explanation: 'Fetch from the prepared statement result set — do not rebuild the query with user data.',
      ),
    ],
    curriculum: _phpPreparedCurriculum,
  ),
  'php_37': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Defense in depth for a small PHP backend means…',
        options: [
          'Only validating in the browser',
          'Layering HTTPS, server validation, parameterized SQL, auth, and least-privilege DB users',
          'Storing API keys in frontend code',
          'Disabling all logging',
        ],
        correctIndex: 1,
        explanation: 'Multiple controls overlap so one failure does not expose the whole system.',
      ),
      PriorityQuiz(
        question: 'The database account used by a web app should…',
        options: [
          'Have root privileges for convenience',
          'Have only the minimum permissions needed (e.g. CRUD on one schema)',
          'Be shared with all developers in chat',
          'Use an empty password on localhost only in production',
        ],
        correctIndex: 1,
        explanation: 'Least privilege limits damage if the app is compromised.',
      ),
      PriorityQuiz(
        question: 'When logging errors in production you should…',
        options: [
          'Include full credit card numbers',
          'Log internally without exposing stack traces or secrets to end users',
          'Email passwords to admins',
          'Return database passwords in JSON error messages',
        ],
        correctIndex: 1,
        explanation: 'Users get safe messages; operators get detailed logs stored securely.',
      ),
    ],
    curriculum: _phpSecureBackendCurriculum,
  ),
  'sql_17': PriorityLessonOverride(
    quizzes: _sqlJoinQuizzes('INNER JOIN', 'Only rows with matches in both tables are returned'),
    curriculum: _sqlInnerJoinCurriculum,
  ),
  'sql_18': PriorityLessonOverride(
    quizzes: _sqlJoinQuizzes('LEFT JOIN', 'All rows from the left table appear; unmatched right columns are NULL'),
    curriculum: _sqlLeftJoinCurriculum,
  ),
  'sql_19': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'A foreign key enforces…',
        options: [
          'Font colors in CSS',
          'Referential integrity between related tables',
          'HTTP caching',
          'JavaScript hoisting',
        ],
        correctIndex: 1,
        explanation: 'FKs ensure child rows reference existing parent rows (or defined ON DELETE behavior).',
      ),
      PriorityQuiz(
        question: 'A one-to-many relationship (author → posts) is modeled by…',
        options: [
          'Duplicating the author name in every post with no key',
          'A posts.author_id referencing authors.id',
          'Storing posts inside a VARCHAR on authors',
          'Using only HTML ids',
        ],
        correctIndex: 1,
        explanation: 'The “many” side holds the foreign key to the “one” side.',
      ),
      PriorityQuiz(
        question: 'In MySQL, defining relationships in the schema helps…',
        options: [
          'Replace the need for prepared statements',
          'Document and enforce valid links between entities',
          'Disable indexes',
          'Run PHP in the browser',
        ],
        correctIndex: 1,
        explanation: 'Constraints catch invalid data at insert time and clarify design for teammates.',
      ),
    ],
    curriculum: _sqlFkCurriculum,
  ),
  'sql_20': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'A PRIMARY KEY constraint ensures…',
        options: [
          'Duplicate rows are allowed',
          'Each row is uniquely identifiable and NOT NULL',
          'All columns must be text',
          'The table has no indexes',
        ],
        correctIndex: 1,
        explanation: 'Primary keys uniquely identify rows; MySQL clusters InnoDB tables on the PK.',
      ),
      PriorityQuiz(
        question: 'UNIQUE on email means…',
        options: [
          'Email can appear twice',
          'No two rows may share the same email value (NULL handling depends on engine)',
          'Email is optional on every table',
          'Email is hashed automatically',
        ],
        correctIndex: 1,
        explanation: 'UNIQUE prevents duplicate business keys like email or slug.',
      ),
      PriorityQuiz(
        question: 'CHECK constraints (where supported) are used to…',
        options: [
          'Validate row data against a rule (e.g. price >= 0)',
          'Replace foreign keys',
          'Speed up DNS',
          'Compile TypeScript',
        ],
        correctIndex: 1,
        explanation: 'CHECK adds server-side rules at the database layer; still validate in app code too.',
      ),
    ],
    curriculum: _sqlConstraintsCurriculum,
  ),
  'sql_36': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'SQL injection happens when…',
        options: [
          'CSS is minified',
          'Untrusted input is concatenated into SQL and interpreted as code',
          'HTTPS certificates expire',
          'Images lack alt text',
        ],
        correctIndex: 1,
        explanation: 'Attackers craft input that alters query structure — parameterization prevents this.',
      ),
      PriorityQuiz(
        question: 'The safest fix for dynamic WHERE clauses is…',
        options: [
          'Blacklisting the word DROP',
          'Prepared statements / bound parameters with a fixed SQL template',
          'Base64-encoding passwords only',
          'Hiding errors from users only',
        ],
        correctIndex: 1,
        explanation: 'Binding separates structure from data; blacklists are brittle.',
      ),
      PriorityQuiz(
        question: 'Escaping strings manually with mysqli_real_escape_string is…',
        options: [
          'Preferable to prepared statements in all cases',
          'Legacy-prone; prepared statements are the default recommendation',
          'Unnecessary when using HTTPS',
          'A substitute for authorization checks',
        ],
        correctIndex: 1,
        explanation: 'Parameter binding avoids context mistakes; escaping is error-prone across encodings.',
      ),
      PriorityQuiz(
        question: 'Least privilege for SQL injection defense includes…',
        options: [
          'Using the DB root user in the web app',
          'Granting the app DB user only required tables/operations',
          'Disabling all indexes',
          'Storing SQL in cookies',
        ],
        correctIndex: 1,
        explanation: 'Even if injection occurs, limited grants reduce blast radius.',
      ),
    ],
    curriculum: _sqlInjectionCurriculum,
  ),
  'typescript_09': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Type narrowing lets TypeScript…',
        options: [
          'Remove the need for runtime checks entirely',
          'Refine a union type inside a branch after a typeof/in/instanceof check',
          'Execute SQL on the phone',
          'Disable strict mode',
        ],
        correctIndex: 1,
        explanation: 'Control-flow analysis learns tighter types after guards — still validate at runtime for external data.',
      ),
      PriorityQuiz(
        question: 'After `if (typeof value === "string")`, inside the block value is…',
        options: ['number', 'string', 'unknown', 'any always'],
        correctIndex: 1,
        explanation: 'typeof guard narrows unknown/union members to string in that branch.',
      ),
      PriorityQuiz(
        question: 'Parsing JSON from an API, the first safe step is often…',
        options: [
          'Cast with `as MyType` and trust it',
          'Treat as unknown and narrow/validate field by field',
          'Store in innerHTML',
          'Skip error handling',
        ],
        correctIndex: 1,
        explanation: 'External JSON is untrusted; validate before trusting the shape.',
      ),
    ],
    curriculum: _tsNarrowingCurriculum,
  ),
  'typescript_10': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Generics in TypeScript let you…',
        options: [
          'Write functions/types that work with many types while preserving type relationships',
          'Run code without types',
          'Replace interfaces entirely',
          'Compile to PHP automatically',
        ],
        correctIndex: 0,
        explanation: 'Generics parameterize types, e.g. ApiResponse<T> keeps payload type linked to the caller.',
      ),
      PriorityQuiz(
        question: 'function first<T>(items: T[]): T | undefined { return items[0]; } — T means…',
        options: [
          'T is always string',
          'T is inferred from the argument (e.g. number[] → number)',
          'T disables checking',
          'T is only for classes',
        ],
        correctIndex: 1,
        explanation: 'Call-site inference connects input and output types.',
      ),
      PriorityQuiz(
        question: 'Generic constraints (`T extends HasId`) are used to…',
        options: [
          'Allow any operation on T',
          'Limit T to types that satisfy a required shape',
          'Remove compile errors without fixing them',
          'Speed up MySQL',
        ],
        correctIndex: 1,
        explanation: 'extends ensures T has the fields your function needs.',
      ),
    ],
    curriculum: _tsGenericsCurriculum,
  ),
  'web_essentials_23': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'An API returns HTTP 422 with a JSON errors object. The client should…',
        options: [
          'Assume success',
          'Surface field-level messages and avoid retrying the same invalid payload',
          'Disable HTTPS',
          'Concatenate errors into SQL',
        ],
        correctIndex: 1,
        explanation: '4xx client errors mean fix the request; structured errors guide the user.',
      ),
      PriorityQuiz(
        question: 'For HTTP 503 Service Unavailable, a reasonable client strategy is…',
        options: [
          'Infinite tight loop with no backoff',
          'Limited retries with exponential backoff and a user-visible message',
          'Clear local storage always',
          'Ignore status codes',
        ],
        correctIndex: 1,
        explanation: 'Transient server issues may resolve; backoff avoids hammering the API.',
      ),
      PriorityQuiz(
        question: 'When fetch() rejects due to network failure you should…',
        options: [
          'Show a generic crash dump with secrets',
          'Distinguish offline/network errors from HTTP error bodies when possible',
          'Assume 200 OK',
          'Disable CORS in production arbitrarily',
        ],
        correctIndex: 1,
        explanation: 'Network errors have no response object; HTTP errors do — handle both paths.',
      ),
    ],
    curriculum: _webApiErrorCurriculum,
  ),
  'web_essentials_28': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Server-side input validation is required because…',
        options: [
          'Browsers always enforce HTML5 attributes',
          'Clients can send arbitrary HTTP requests bypassing your UI',
          'CSS validates email format',
          'DNS blocks SQL injection',
        ],
        correctIndex: 1,
        explanation: 'Never trust the channel — validate type, length, and allowed values on the server.',
      ),
      PriorityQuiz(
        question: 'Allow-list validation means…',
        options: [
          'Reject only known-bad strings',
          'Accept only known-good values/patterns (e.g. enum roles)',
          'Skip validation for admins',
          'Validate only in Git',
        ],
        correctIndex: 1,
        explanation: 'Allow-lists fail closed; block-lists miss novel attacks.',
      ),
      PriorityQuiz(
        question: 'Validating a file upload should include…',
        options: [
          'Trusting the client file extension only',
          'Server checks on size, type, and storage location outside the web root',
          'Embedding uploads in SQL strings',
          'Returning the storage path to anonymous users',
        ],
        correctIndex: 1,
        explanation: 'MIME/extension can lie; enforce limits and safe storage server-side.',
      ),
    ],
    curriculum: _webValidationCurriculum,
  ),
};

List<PriorityQuiz> _sqlJoinQuizzes(String joinName, String behavior) => [
      PriorityQuiz(
        question: "What does $joinName return?",
        options: [
          behavior,
          'Only rows from the right table with no left matches',
          'Cartesian product of all tables always',
          'HTTP response headers',
        ],
        correctIndex: 0,
        explanation: behavior,
      ),
      PriorityQuiz(
        question: 'The ON clause in a join specifies…',
        options: [
          'CSS breakpoints',
          'Which columns relate the two tables (e.g. orders.user_id = users.id)',
          'PHP session names',
          'Git branch names',
        ],
        correctIndex: 1,
        explanation: 'ON expresses the relationship predicate between tables.',
      ),
      PriorityQuiz(
        question: 'Why alias tables (FROM orders o JOIN users u)?',
        options: [
          'To hide SQL from teammates',
          'To shorten queries and disambiguate column names',
          'To disable indexes',
          'To prevent prepared statements',
        ],
        correctIndex: 1,
        explanation: 'Aliases clarify which table a column comes from in complex joins.',
      ),
    ];

// ── Curriculum JSON fragments (merged over generator base) ──

final _phpPdoCurriculum = {
  'summary':
      'PDO connects PHP to MySQL (and other databases) through one API. Use it with exceptions in development and **never** embed credentials in source control.',
  'objectives': [
    'Create a PDO instance with a DSN',
    'Set safe error handling modes',
    'Understand why credentials belong in environment config',
  ],
  'content': [
    {
      'type': 'prose',
      'md':
          'PDO separates **connection** from **queries**. A DSN like `mysql:host=127.0.0.1;dbname=app;charset=utf8mb4` selects the driver and database. User/password come from environment variables loaded on the server.',
    },
    {
      'type': 'code',
      'lang': 'php',
      'runnable': false,
      'caption': 'Study offline — run on your computer, not in DevPath.',
      'code':
          "<?php\n\$dsn = 'mysql:host=127.0.0.1;dbname=shop;charset=utf8mb4';\n\$user = getenv('DB_USER');\n\$pass = getenv('DB_PASS');\n\$pdo = new PDO(\$dsn, \$user, \$pass, [\n  PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,\n  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,\n]);\n",
    },
    {
      'type': 'callout',
      'variant': 'warning',
      'md':
          'Do **not** commit real passwords. Use `.env` locally (gitignored) and secret managers in production.',
    },
  ],
};

final _phpPreparedCurriculum = {
  'summary':
      'Prepared statements send SQL structure and data separately so user input cannot change query meaning — the core defense against SQL injection in PHP.',
  'objectives': [
    'Prepare once, execute many with bound values',
    'Contrast safe binding with string concatenation',
    'Pair with server-side validation',
  ],
  'content': [
    {
      'type': 'prose',
      'md':
          'An attacker should not be able to turn a login lookup into `OR 1=1`. Placeholders (`?` or `:email`) keep their input in the **data channel** only.',
    },
    {
      'type': 'code',
      'lang': 'php',
      'runnable': false,
      'code':
          "<?php\n\$stmt = \$pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');\n\$stmt->execute([\$email]);\n\$user = \$stmt->fetch();\n",
    },
    {
      'type': 'callout',
      'variant': 'warning',
      'md':
          r'Never concatenate: "SELECT ... WHERE id = " . $_GET["id"]. Always bind parameters.',
    },
  ],
};

final _phpApiCurriculum = {
  'summary':
      'A minimal PHP endpoint validates input, talks to the database with PDO, and returns JSON plus the correct HTTP status.',
  'objectives': [
    'Map HTTP methods to safe handlers',
    'Return structured JSON errors',
    'Keep secrets and SQL off the client',
  ],
  'content': [
    {
      'type': 'prose',
      'md':
          'Start with routing (even a single `api/posts.php`), set `Content-Type: application/json`, validate method, then use prepared statements. Use **400** for bad input, **404** for missing resources, **500** only for unexpected failures (log details server-side).',
    },
  ],
};

final _phpSecureBackendCurriculum = {
  'summary':
      'Secure backends combine transport security (HTTPS), validation, parameterized SQL, authentication, authorization, and least-privilege infrastructure.',
  'objectives': [
    'List layers of defense for a small API',
    'Apply least privilege to DB credentials',
    'Handle errors without leaking secrets',
  ],
  'content': [
    {
      'type': 'prose',
      'md':
          'Treat every request as untrusted. Validate, authenticate, authorize, then access data with bound parameters under a DB user that cannot DROP SCHEMA.',
    },
  ],
};

final _sqlInnerJoinCurriculum = {
  'summary': 'INNER JOIN returns rows where the join condition matches in **both** tables — ideal for required relationships.',
  'content': [
    {
      'type': 'code',
      'lang': 'sql',
      'runnable': false,
      'code':
          '-- MySQL\nSELECT o.id, u.email\nFROM orders o\nINNER JOIN users u ON u.id = o.user_id\nWHERE o.status = \'paid\';\n',
    },
  ],
};

final _sqlLeftJoinCurriculum = {
  'summary':
      'LEFT JOIN keeps every row from the left table even when there is no match on the right (NULLs fill unmatched columns).',
  'content': [
    {
      'type': 'code',
      'lang': 'sql',
      'runnable': false,
      'code':
          'SELECT u.email, COUNT(o.id) AS order_count\nFROM users u\nLEFT JOIN orders o ON o.user_id = u.id\nGROUP BY u.id;\n',
    },
  ],
};

final _sqlFkCurriculum = {
  'summary': 'Foreign keys document relationships and prevent orphan rows in MySQL/InnoDB.',
  'content': [
    {
      'type': 'code',
      'lang': 'sql',
      'runnable': false,
      'code':
          'CREATE TABLE posts (\n  id INT PRIMARY KEY AUTO_INCREMENT,\n  author_id INT NOT NULL,\n  FOREIGN KEY (author_id) REFERENCES authors(id)\n);\n',
    },
  ],
};

final _sqlConstraintsCurriculum = {
  'summary': 'PRIMARY KEY, UNIQUE, NOT NULL, and FOREIGN KEY constraints keep data trustworthy at the schema layer.',
  'content': [
    {
      'type': 'prose',
      'md': 'Constraints complement — not replace — application validation and prepared statements.',
    },
  ],
};

final _sqlInjectionCurriculum = {
  'summary':
      'SQL injection exploits dynamic string building. Parameterized queries and least-privilege DB users reduce risk.',
  'content': [
    {
      'type': 'callout',
      'variant': 'warning',
      'md': 'Example attack input: `\' OR \'1\'=\'1` in a concatenated login query — prepared statements neutralize this class of attack.',
    },
  ],
};

final _tsNarrowingCurriculum = {
  'summary': 'Narrowing refines types after guards — essential before using API or JSON data safely in TypeScript.',
  'content': [
    {
      'type': 'code',
      'lang': 'typescript',
      'runnable': false,
      'code':
          'function parseId(value: unknown): number | null {\n  if (typeof value !== "number" || !Number.isInteger(value)) return null;\n  return value;\n}\n',
    },
  ],
};

final _tsGenericsCurriculum = {
  'summary': 'Generics let you reuse logic while keeping types precise — common in API clients and data stores.',
  'content': [
    {
      'type': 'code',
      'lang': 'typescript',
      'runnable': false,
      'code':
          r'type ApiResult<T> = { ok: true; data: T } | { ok: false; error: string };'
          '\n\nasync function getJson<T>(url: string): Promise<ApiResult<T>> {\n'
          r'  const res = await fetch(url);'
          '\n  if (!res.ok) return { ok: false, error: "HTTP " + res.status };\n'
          r'  return { ok: true, data: (await res.json()) as T };'
          '\n}\n',
    },
  ],
};

final _webApiErrorCurriculum = {
  'summary':
      'Clients should branch on HTTP status, parse structured error bodies, and retry transient failures responsibly.',
  'content': [
    {
      'type': 'prose',
      'md':
          'Distinguish **4xx** (fix request) from **5xx** (server/transient). Use backoff for 503/timeouts; never log tokens in client console in production builds.',
    },
  ],
};

final _webValidationCurriculum = {
  'summary':
      'Validate on the server with allow-lists; treat browser checks as convenience only.',
  'content': [
    {
      'type': 'prose',
      'md': 'Full-stack safety: HTML forms → PHP validation → parameterized SQL → escaped output.',
    },
  ],
};

String _dartSingleQuoted(String value) {
  return "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";
}

String priorityQuizzesToDart(String lessonId) {
  final o = priorityLessonOverrides[lessonId];
  if (o == null) return '';
  final buf = StringBuffer();
  for (final q in o.quizzes) {
    final opts = q.options.map(_dartSingleQuoted).join(', ');
    buf.writeln('      QuizQuestion(');
    buf.writeln('        question: ${_dartSingleQuoted(q.question)},');
    buf.writeln('        options: [$opts],');
    buf.writeln('        correctIndex: ${q.correctIndex},');
    buf.writeln('        explanation: ${_dartSingleQuoted(q.explanation)},');
    buf.writeln('      ),');
  }
  return buf.toString().trimRight();
}

Map<String, dynamic>? priorityCurriculumFor(String lessonId) =>
    priorityLessonOverrides[lessonId]?.curriculum;

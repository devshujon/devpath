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
  'php_36': PriorityLessonOverride(
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
  'php_37': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'PHPUnit-style tests for PHP are primarily used to…',
        options: [
          'Replace password hashing',
          'Automate checks that functions and classes behave as expected after changes',
          'Execute JavaScript in the browser',
          'Disable SQL prepared statements',
        ],
        correctIndex: 1,
        explanation: 'Automated tests catch regressions when you refactor auth, SQL, or API code.',
      ),
      PriorityQuiz(
        question: 'A good first PHP test for a login helper would…',
        options: [
          'Assert plaintext passwords match',
          'Cover expected success and failure paths using test fixtures, not production data',
          'Hit the live production database',
          'Skip authorization cases',
        ],
        correctIndex: 1,
        explanation: 'Tests should be isolated, repeatable, and never depend on real user passwords.',
      ),
      PriorityQuiz(
        question: 'When testing code that uses PDO you should…',
        options: [
          'Use a disposable test database or mocks, not customer data',
          'Commit production credentials to the test file',
          'Only test CSS output',
          'Avoid testing error paths',
        ],
        correctIndex: 0,
        explanation: 'Isolate tests with fixtures/transactions rollbacks; protect real data.',
      ),
    ],
    curriculum: _phpTestingCurriculum,
  ),
  'php_13': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Using filter_var with FILTER_VALIDATE_EMAIL in PHP is…',
        options: [
          'A substitute for prepared SQL',
          'A server-side format check — still validate business rules separately',
          'Only for CSS',
          'Unsafe in all cases',
        ],
        correctIndex: 1,
        explanation: 'Built-in filters help format validation; authorization and SQL safety are separate steps.',
      ),
      PriorityQuiz(
        question: 'trim() on user input helps prevent…',
        options: [
          'SQL injection by itself',
          'Accidental leading/trailing whitespace breaking lookups or uniqueness checks',
          'HTTPS downgrade',
          'XSS in all contexts',
        ],
        correctIndex: 1,
        explanation: 'Normalize input, then validate allow-lists and encode output appropriately.',
      ),
      PriorityQuiz(
        question: 'HTML form required attributes…',
        options: [
          'Replace server validation',
          'Improve UX only — attackers can bypass the browser',
          'Hash passwords automatically',
          'Enable SQL transactions',
        ],
        correctIndex: 1,
        explanation: 'Always re-validate on the server before database or file operations.',
      ),
    ],
    curriculum: _phpInputValidationCurriculum,
  ),
  'php_18': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'PHP session cookies should ideally be configured with…',
        options: [
          'HttpOnly and Secure flags on HTTPS sites',
          'JavaScript-readable access for all scripts',
          'Infinite lifetime with no rotation',
          'Plaintext session data in URLs',
        ],
        correctIndex: 0,
        explanation: 'HttpOnly reduces XSS token theft; Secure limits transmission to HTTPS.',
      ),
      PriorityQuiz(
        question: 'session_regenerate_id(true) after login helps mitigate…',
        options: [
          'CSS specificity bugs',
          'Session fixation attacks',
          'SQL indexing issues',
          'DNS cache poisoning alone',
        ],
        correctIndex: 1,
        explanation: 'Issuing a new session ID on privilege change prevents reuse of a fixed ID.',
      ),
      PriorityQuiz(
        question: r'Storing a shopping cart in $_SESSION is appropriate when…',
        options: [
          'You need server-side state tied to the session cookie',
          'You want to expose cart data in every URL without a cookie',
          'You never need expiration',
          'You want to skip HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Sessions hold server-side state; keep sensitive fields out of client-visible storage.',
      ),
    ],
    curriculum: _phpSessionsCurriculum,
  ),
  'php_25': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'password_hash() in PHP is preferred over md5/sha1 because…',
        options: [
          'It uses adaptive hashing designed for passwords',
          'It stores reversible encryption',
          'It removes the need for HTTPS',
          'It validates email addresses',
        ],
        correctIndex: 0,
        explanation: 'PASSWORD_DEFAULT (bcrypt/argon) is slow and salted — appropriate for password storage.',
      ),
      PriorityQuiz(
        question: 'password_verify() should be used…',
        options: [
          'When comparing a login attempt to a stored hash',
          'To encrypt API keys into JavaScript',
          'Instead of prepared statements',
          'To validate SQL JOIN syntax',
        ],
        correctIndex: 0,
        explanation: 'Constant-time aware verification compares plaintext to the stored hash safely.',
      ),
      PriorityQuiz(
        question: 'You should never…',
        options: [
          'Store user passwords in plaintext or reversible encoding',
          'Use HTTPS on login pages',
          'Rate-limit repeated login failures',
          'Log authentication failures internally',
        ],
        correctIndex: 0,
        explanation: 'Plaintext storage exposes users if the database leaks — hash with password_hash instead.',
      ),
    ],
    curriculum: _phpPasswordCurriculum,
  ),
  'php_26': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Authentication answers the question…',
        options: [
          '“What may this user do?”',
          '“Who is this user?”',
          '“Which CSS framework?”',
          '“Which DNS server?”',
        ],
        correctIndex: 1,
        explanation: 'Authentication verifies identity (login); authorization decides permissions afterward.',
      ),
      PriorityQuiz(
        question: 'A session-based login flow should regenerate the session ID…',
        options: [
          'Never',
          'After successful authentication',
          'Only on logout',
          'Before validating the password',
        ],
        correctIndex: 1,
        explanation: 'Regenerate on login to reduce fixation risk.',
      ),
      PriorityQuiz(
        question: 'Multi-factor authentication adds…',
        options: [
          'Another independent proof factor beyond the password',
          'Plaintext password storage',
          'SQL concatenation',
          'Public session files',
        ],
        correctIndex: 0,
        explanation: 'MFA requires something you know/have/are — reducing stolen-password impact.',
      ),
    ],
    curriculum: _phpAuthCurriculum,
  ),
  'php_27': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Authorization checks should occur…',
        options: [
          'Only in CSS',
          'On the server for every protected action, even if the UI hides buttons',
          'Only once at registration',
          'In client localStorage only',
        ],
        correctIndex: 1,
        explanation: 'UI hiding is not security — enforce permissions in server handlers.',
      ),
      PriorityQuiz(
        question: 'Role-based access control (RBAC) maps…',
        options: [
          'Users to roles and roles to permissions',
          'Passwords to MD5',
          'SQL to HTML',
          'DNS to TLS certificates',
        ],
        correctIndex: 0,
        explanation: 'Roles group permissions so you do not hardcode checks per user everywhere.',
      ),
      PriorityQuiz(
        question: 'Returning HTTP 403 Forbidden means…',
        options: [
          'The user is unknown',
          'The user is known but not allowed to perform this action',
          'The server is offline forever',
          'SQL injection succeeded',
        ],
        correctIndex: 1,
        explanation: '401 often signals missing/invalid auth; 403 signals failed authorization.',
      ),
    ],
    curriculum: _phpAuthorizationCurriculum,
  ),
  'php_28': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Database passwords in PHP projects should be loaded from…',
        options: [
          'Environment variables or secret stores, not Git',
          'A public JavaScript bundle',
          'HTML comments in templates',
          'User-uploaded images',
        ],
        correctIndex: 0,
        explanation: 'Keep secrets out of version control and client-delivered assets.',
      ),
      PriorityQuiz(
        question: 'A .env file on a developer laptop should…',
        options: [
          'Be gitignored and differ from production values',
          'Be committed with production credentials',
          'Replace HTTPS',
          'Store user session files publicly',
        ],
        correctIndex: 0,
        explanation: 'Local config holds dev secrets; production uses platform env injection.',
      ),
      PriorityQuiz(
        question: 'display_errors in production should generally be…',
        options: [
          'Off for end users, with errors logged server-side',
          'On with full stack traces shown to everyone',
          'Replaced by storing errors in cookies',
          'Sent to all API clients by default',
        ],
        correctIndex: 0,
        explanation: 'Verbose errors leak paths and logic — log internally instead.',
      ),
    ],
    curriculum: _phpSecretsCurriculum,
  ),
  'php_35': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'PDO transactions are used when…',
        options: [
          'Several SQL steps must succeed or fail together',
          'You want to skip prepared statements',
          'You need faster CSS',
          'You store passwords in plaintext',
        ],
        correctIndex: 0,
        explanation: 'BEGIN/COMMIT/ROLLBACK keeps data consistent across multi-step updates.',
      ),
      PriorityQuiz(
        question: 'If an exception occurs mid-transaction you should…',
        options: [
          'rollBack() and avoid leaving partial commits',
          'Commit anyway',
          'Disable HTTPS',
          'Echo SQL errors to the user with secrets',
        ],
        correctIndex: 0,
        explanation: 'Rollback restores consistency; handle errors safely for clients.',
      ),
      PriorityQuiz(
        question: 'Transferring money between accounts is a classic case for…',
        options: [
          'A single transaction with debit and credit steps',
          'Two unrelated autocommit updates with no rollback plan',
          'Client-side validation only',
          'Storing balances in session cookies unencrypted',
        ],
        correctIndex: 0,
        explanation: 'Both legs must succeed — transactions prevent half-applied transfers.',
      ),
    ],
    curriculum: _phpTransactionsCurriculum,
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
  'sql_26': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'In MySQL (InnoDB), START TRANSACTION begins…',
        options: [
          'An isolated unit of work you COMMIT or ROLLBACK',
          'A CSS animation',
          'A PHP session file',
          'An unlogged DELETE without WHERE',
        ],
        correctIndex: 0,
        explanation: 'Transactions group changes; COMMIT makes them permanent, ROLLBACK discards them.',
      ),
      PriorityQuiz(
        question: 'Why wrap an order insert + inventory update in one transaction?',
        options: [
          'So partial updates cannot leave inconsistent stock counts',
          'To skip foreign keys',
          'To disable indexes',
          'To allow SQL injection',
        ],
        correctIndex: 0,
        explanation: 'Both statements succeed or neither does — critical for inventory and payments.',
      ),
      PriorityQuiz(
        question: 'Autocommit mode means…',
        options: [
          'Each statement commits immediately unless inside an explicit transaction',
          'Transactions are impossible',
          'Only SELECT runs',
          'HTTPS is disabled',
        ],
        correctIndex: 0,
        explanation: 'Explicit transactions override autocommit for multi-step operations.',
      ),
    ],
    curriculum: _sqlTransactionsCurriculum,
  ),
  'sql_27': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Atomicity in ACID means…',
        options: [
          'All steps in a transaction complete or none do',
          'All queries return identical rows',
          'Only one user may use the database',
          'Data is always encrypted at rest',
        ],
        correctIndex: 0,
        explanation: 'Atomicity prevents half-applied business operations.',
      ),
      PriorityQuiz(
        question: 'Isolation levels control…',
        options: [
          'How concurrent transactions see each other\'s in-progress changes',
          'CSS z-index stacking',
          'Git branch merges',
          'TLS cipher suites only',
        ],
        correctIndex: 0,
        explanation: 'Isolation trades consistency visibility vs concurrency (READ COMMITTED, REPEATABLE READ, etc.).',
      ),
      PriorityQuiz(
        question: 'Durability guarantees that…',
        options: [
          'Committed data survives crashes once the commit succeeds',
          'DELETE without WHERE is safe',
          'Indexes are unnecessary',
          'Plaintext passwords are stored',
        ],
        correctIndex: 0,
        explanation: 'After COMMIT, InnoDB ensures recovery can restore committed work.',
      ),
    ],
    curriculum: _sqlAcidCurriculum,
  ),
  'sql_31': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'A B-tree index on users(email) primarily speeds up…',
        options: [
          'Lookups filtering or sorting by email',
          'All columns automatically',
          'PHP rendering',
          'Git pushes',
        ],
        correctIndex: 0,
        explanation: 'Indexes help predicates on indexed columns; they are not free on writes.',
      ),
      PriorityQuiz(
        question: 'EXPLAIN (or EXPLAIN ANALYZE in MySQL 8+) helps you…',
        options: [
          'See how the optimizer plans to read rows',
          'Hash passwords',
          'Validate HTML',
          'Disable foreign keys',
        ],
        correctIndex: 0,
        explanation: 'Execution plans reveal full table scans vs index usage.',
      ),
      PriorityQuiz(
        question: 'Adding indexes on every column is…',
        options: [
          'Usually wasteful — index columns used in WHERE/JOIN/ORDER BY',
          'Required for prepared statements',
          'A substitute for normalization',
          'Unsafe with HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Each index adds write overhead; index selectively for real query patterns.',
      ),
    ],
    curriculum: _sqlIndexPerfCurriculum,
  ),
  'sql_32': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'A composite index (last_name, first_name) is most helpful when queries…',
        options: [
          'Filter or sort by last_name, or both columns in left-to-right order',
          'Only filter by first_name alone without last_name',
          'Never use WHERE',
          'Only SELECT COUNT(*)',
        ],
        correctIndex: 0,
        explanation: 'Composite indexes follow left-prefix rules — column order matters.',
      ),
      PriorityQuiz(
        question: 'Covering an index means…',
        options: [
          'The index contains all columns needed so the engine avoids table lookups',
          'The index replaces foreign keys',
          'The index stores plaintext passwords',
          'The index disables transactions',
        ],
        correctIndex: 0,
        explanation: 'Covering indexes can satisfy queries from the index alone (index-only access).',
      ),
      PriorityQuiz(
        question: 'Duplicate indexes on the same columns…',
        options: [
          'Waste space and slow writes without benefit',
          'Always improve security',
          'Prevent SQL injection',
          'Replace EXPLAIN',
        ],
        correctIndex: 0,
        explanation: 'Audit indexes periodically and drop redundant ones.',
      ),
    ],
    curriculum: _sqlCompositeIndexCurriculum,
  ),
  'typescript_06': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'A TypeScript interface describes…',
        options: [
          'The shape of an object — property names and types',
          'Runtime encryption for passwords',
          'MySQL transaction isolation',
          'Android layout dp',
        ],
        correctIndex: 0,
        explanation: 'Interfaces document expected object structures at compile time.',
      ),
      PriorityQuiz(
        question: 'interface User { id: number; name: string } lets you…',
        options: [
          'Catch missing or mistyped properties when building User objects',
          'Execute PHP on device',
          'Skip JSON parsing',
          'Disable HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Type errors surface in the editor before runtime — still validate external JSON.',
      ),
      PriorityQuiz(
        question: 'Interfaces vs type aliases: interfaces are often used for…',
        options: [
          'Object shapes that may be extended or implemented by classes',
          'Replacing all runtime checks',
          'Storing secrets in the client bundle',
          'SQL indexing only',
        ],
        correctIndex: 0,
        explanation: 'Both describe types; interfaces excel at object contracts and extension.',
      ),
    ],
    curriculum: _tsInterfacesCurriculum,
  ),
  'typescript_13': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'async/await in TypeScript primarily helps you…',
        options: [
          'Write asynchronous code that reads like sequential logic',
          'Remove the need for HTTP status checks',
          'Execute PHP on Android',
          'Disable JSON parsing',
        ],
        correctIndex: 0,
        explanation: 'await pauses within an async function until a Promise settles — still handle errors.',
      ),
      PriorityQuiz(
        question: 'When awaiting fetch(), you should still…',
        options: [
          'Check res.ok and handle network failures',
          'Assume the body is always valid JSON',
          'Insert HTML with innerHTML without escaping',
          'Skip HTTPS in production',
        ],
        correctIndex: 0,
        explanation: 'async/await does not replace HTTP or validation logic.',
      ),
      PriorityQuiz(
        question: 'An async function always returns…',
        options: [
          'A Promise (even if you return a plain value)',
          'A synchronous SQL result set',
          'A PHP session array',
          'Nothing — async forbids return',
        ],
        correctIndex: 0,
        explanation: 'Async functions wrap return values in Promises; use try/catch for rejected awaits.',
      ),
    ],
    curriculum: _tsAsyncCurriculum,
  ),
  'typescript_14': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Typing an API response as ApiResult<User> helps…',
        options: [
          'Document expected JSON fields where the response is consumed',
          'Guarantee the server is honest',
          'Remove need for HTTP status codes',
          'Run SQL safely without binding',
        ],
        correctIndex: 0,
        explanation: 'Generics link endpoint payloads to call sites — validate at runtime for external APIs.',
      ),
      PriorityQuiz(
        question: 'When fetch returns non-OK status, typed code should…',
        options: [
          'Handle the error branch before assuming parsed data matches T',
          'Cast JSON to T without checks',
          'Store tokens in innerHTML',
          'Disable CORS in production',
        ],
        correctIndex: 0,
        explanation: 'Parse error bodies separately; success types apply only after res.ok.',
      ),
      PriorityQuiz(
        question: 'Unknown is preferred over any for JSON because…',
        options: [
          'It forces narrowing/validation before use',
          'It runs faster on Android',
          'It encrypts payloads',
          'It replaces interfaces',
        ],
        correctIndex: 0,
        explanation: 'any disables checking; unknown requires deliberate validation.',
      ),
    ],
    curriculum: _tsApiResponseCurriculum,
  ),
  'typescript_15': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Type-safe application design means…',
        options: [
          'Model domains with types and validate external boundaries',
          'Trust all API JSON via assertion only',
          'Never use interfaces',
          'Store passwords in localStorage typed as string',
        ],
        correctIndex: 0,
        explanation: 'Strong types inside the app; guards at IO edges (HTTP, storage, forms).',
      ),
      PriorityQuiz(
        question: 'A boundary function parseUser(json: unknown): User | null should…',
        options: [
          'Validate fields before returning User',
          'Return json as User unconditionally',
          'Execute SQL strings',
          'Skip null checks',
        ],
        correctIndex: 0,
        explanation: 'Parsers encode validation rules once and reuse them.',
      ),
      PriorityQuiz(
        question: 'Discriminated unions like success vs error results help…',
        options: [
          'Exhaustive switch handling of success vs failure',
          'Remove HTTP',
          'Disable TypeScript strict mode',
          'Avoid error messages',
        ],
        correctIndex: 0,
        explanation: 'Tagged unions make control-flow narrowing explicit and safer.',
      ),
      PriorityQuiz(
        question: 'Compile TypeScript for production on…',
        options: [
          'Your computer or CI — DevPath playground runs HTML/CSS/JS only',
          'Inside DevPath PHP runtime',
          'MySQL server directly',
          'Without any type checking',
        ],
        correctIndex: 0,
        explanation: 'Offline lesson examples are studied in-app; TS tooling runs outside DevPath.',
      ),
    ],
    curriculum: _tsTypeSafeCurriculum,
  ),
  'python_05': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Which Python collection is mutable and ordered?',
        options: ['tuple', 'list', 'str', 'frozenset'],
        correctIndex: 1,
        explanation: 'Lists are ordered and mutable; tuples are ordered but immutable.',
      ),
      PriorityQuiz(
        question: 'A dict maps…',
        options: [
          'Keys to values for fast lookup by key',
          'Only integers to CSS colors',
          'SQL tables to PHP files',
          'HTTPS certificates to DNS',
        ],
        correctIndex: 0,
        explanation: 'Dictionaries are hash maps — ideal for records and counts.',
      ),
      PriorityQuiz(
        question: 'Before using external input as a dict key or list index you should…',
        options: [
          'Validate and sanitize — DevPath does not run Python here; practice on your computer',
          'Assume it is always an integer',
          'Skip bounds checks',
          'Convert everything with eval()',
        ],
        correctIndex: 0,
        explanation: 'Never eval untrusted strings; validate types and ranges in real scripts.',
      ),
    ],
    curriculum: _pythonCollectionsCurriculum,
  ),
  'python_09': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'def greet(name: str) -> str: defines…',
        options: [
          'A reusable function with typed parameters (hints are not enforced at runtime)',
          'A MySQL index',
          'A PHP session',
          'An HTML semantic tag',
        ],
        correctIndex: 0,
        explanation: 'Functions encapsulate logic; type hints help tooling — validate inputs in code.',
      ),
      PriorityQuiz(
        question: 'Default argument values should avoid…',
        options: [
          'Mutable defaults like [] shared across calls',
          'Keyword arguments',
          'Docstrings',
          'Return statements',
        ],
        correctIndex: 0,
        explanation: 'Use None as default then assign a new list inside the function body.',
      ),
      PriorityQuiz(
        question: 'When processing user-provided text in Python scripts you should…',
        options: [
          'Treat it as untrusted and validate before file/network operations',
          'Pass it to os.system() directly',
          'Disable exceptions',
          'Store it in plaintext passwords',
        ],
        correctIndex: 0,
        explanation: 'Safe automation validates paths and arguments — run such scripts outside DevPath.',
      ),
    ],
    curriculum: _pythonFunctionsCurriculum,
  ),
  'python_12': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'try/except in Python is for…',
        options: [
          'Handling expected errors without crashing the whole program',
          'Replacing input validation entirely',
          'Speeding up SQL indexes',
          'Enabling SQL injection',
        ],
        correctIndex: 0,
        explanation: 'Catch specific exceptions; still validate inputs and fail safely.',
      ),
      PriorityQuiz(
        question: 'except Exception: that swallows all errors…',
        options: [
          'Can hide bugs — catch specific types and log context',
          'Is always best practice',
          'Replaces finally blocks',
          'Hashes passwords',
        ],
        correctIndex: 0,
        explanation: 'Broad catches make debugging hard; prefer targeted handling.',
      ),
      PriorityQuiz(
        question: 'Raising ValueError for bad user input…',
        options: [
          'Signals invalid data to callers who should handle or display safe messages',
          'Executes PHP',
          'Commits SQL transactions automatically',
          'Disables HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Validate early; use exceptions for exceptional paths, not normal control flow.',
      ),
    ],
    curriculum: _pythonExceptionsCurriculum,
  ),
  'web_essentials_22': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Authentication in web apps proves…',
        options: [
          'Identity (who the user is)',
          'Which CSS grid to use',
          'DNS TTL values',
          'SQL index order',
        ],
        correctIndex: 0,
        explanation: 'Login/MFA establishes identity before authorization decisions.',
      ),
      PriorityQuiz(
        question: 'Bearer tokens in Authorization headers should be…',
        options: [
          'Sent only over HTTPS and stored with care (not logged in URLs)',
          'Embedded in every image src',
          'Committed to public Git repos',
          'Shared in chat for debugging forever',
        ],
        correctIndex: 0,
        explanation: 'Treat tokens like passwords in transit and storage.',
      ),
      PriorityQuiz(
        question: 'Session cookies differ from JWTs in that sessions often…',
        options: [
          'Store state server-side with a session ID in the cookie',
          'Never expire',
          'Replace server validation',
          'Eliminate HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Both patterns are valid — understand where state and verification live.',
      ),
    ],
    curriculum: _webAuthConceptsCurriculum,
  ),
  'web_essentials_31': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Authorization decides…',
        options: [
          'What an authenticated user may do',
          'Which TLS cipher to use',
          'How to compile TypeScript',
          'Git merge strategy',
        ],
        correctIndex: 0,
        explanation: 'After authentication, authorization checks permissions on each action.',
      ),
      PriorityQuiz(
        question: 'Checking isAdmin on the client only…',
        options: [
          'Is insufficient — enforce permissions on the server',
          'Is fully secure',
          'Replaces SQL constraints',
          'Prevents XSS',
        ],
        correctIndex: 0,
        explanation: 'Attackers can call APIs directly; server must authorize every mutation.',
      ),
      PriorityQuiz(
        question: 'Principle of least privilege means…',
        options: [
          'Grant only the permissions required for a role',
          'Give every user admin access',
          'Disable logging',
          'Store secrets in HTML',
        ],
        correctIndex: 0,
        explanation: 'Limit roles to minimum necessary access.',
      ),
    ],
    curriculum: _webAuthzCurriculum,
  ),
  'web_essentials_32': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'API keys and DB passwords should…',
        options: [
          'Live in environment variables or secret managers, not client bundles',
          'Be hard-coded in JavaScript for convenience',
          'Appear in public GitHub README files',
          'Be emailed unencrypted',
        ],
        correctIndex: 0,
        explanation: 'Secrets on the server only; rotate if leaked.',
      ),
      PriorityQuiz(
        question: 'Client-side .env files bundled into a SPA…',
        options: [
          'Expose any embedded secrets to all users',
          'Are always private',
          'Replace HTTPS',
          'Encrypt the database automatically',
        ],
        correctIndex: 0,
        explanation: 'Anything shipped to the browser is public — never embed private keys.',
      ),
      PriorityQuiz(
        question: 'Logging in production should…',
        options: [
          'Redact tokens, passwords, and PII where possible',
          'Include full Authorization headers by default',
          'Print stack traces to all API clients',
          'Disable access controls',
        ],
        correctIndex: 0,
        explanation: 'Logs are sensitive — scrub secrets and personal data.',
      ),
    ],
    curriculum: _webSecretsCurriculum,
  ),
  'web_essentials_43': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Environment variables separate…',
        options: [
          'Configuration from code so dev/staging/prod differ safely',
          'HTML from CSS only',
          'Git from GitHub',
          'SQL from MySQL entirely',
        ],
        correctIndex: 0,
        explanation: 'Same codebase, different env config — no production secrets in Git.',
      ),
      PriorityQuiz(
        question: 'NODE_ENV=production or APP_DEBUG=false typically…',
        options: [
          'Disables verbose errors and enables production-safe defaults',
          'Removes need for HTTPS',
          'Allows SQL injection',
          'Stores passwords in cookies',
        ],
        correctIndex: 0,
        explanation: 'Environment flags toggle logging, caching, and error detail.',
      ),
      PriorityQuiz(
        question: 'Twelve-factor style config means…',
        options: [
          'Store config in the environment, not in the image',
          'Commit .env.production to the repo',
          'Hard-code API URLs in 20 places',
          'Skip backups',
        ],
        correctIndex: 0,
        explanation: 'Inject config at deploy time per environment.',
      ),
    ],
    curriculum: _webEnvConfigCurriculum,
  ),
  'web_essentials_26': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Stored XSS persists because…',
        options: [
          'Malicious script is saved on the server and served to other users',
          'It only affects the attacker\'s browser once',
          'HTTPS disables all script execution',
          'Prepared statements prevent XSS',
        ],
        correctIndex: 0,
        explanation: 'Stored XSS hits every viewer of tainted data — escaping on output is required.',
      ),
      PriorityQuiz(
        question: 'Reflected XSS typically needs…',
        options: [
          'A victim to open a crafted link containing injected script',
          'A database migration',
          'CSRF tokens only',
          'SQL JOIN syntax',
        ],
        correctIndex: 0,
        explanation: 'Reflected payloads echo immediately in the response — still validate and encode output.',
      ),
      PriorityQuiz(
        question: 'Content Security Policy (CSP) can reduce XSS impact by…',
        options: [
          'Restricting which script sources may execute',
          'Replacing all input validation',
          'Eliminating the need for HTTPS',
          'Hashing passwords in HTML',
        ],
        correctIndex: 0,
        explanation: 'CSP is defense in depth — it does not replace encoding or sanitization.',
      ),
      PriorityQuiz(
        question: 'Inserting untrusted JSON into innerHTML is unsafe because…',
        options: [
          'HTML parsing can execute embedded scripts in many contexts',
          'JSON is always plain text',
          'CSS cannot style JSON',
          'It speeds up SQL queries',
        ],
        correctIndex: 0,
        explanation: 'Prefer textContent or framework-safe bindings; encode for HTML context.',
      ),
    ],
    curriculum: _webXssCurriculum,
  ),
  'web_essentials_27': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'CSRF tricks a victim\'s browser into…',
        options: [
          'Sending an authenticated request the user did not intend',
          'Running SQL inside MySQL without login',
          'Disabling TLS certificates',
          'Replacing Git history',
        ],
        correctIndex: 0,
        explanation: 'The browser attaches cookies automatically — the server must verify intent.',
      ),
      PriorityQuiz(
        question: 'A synchronizer CSRF token should be…',
        options: [
          'Unpredictable, tied to the session, and validated server-side on state-changing requests',
          'Hard-coded in JavaScript for all users',
          'Sent only in URLs for sharing',
          'Omitted when using HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Tokens prove the form/post originated from your app — not a third-party site.',
      ),
      PriorityQuiz(
        question: 'SameSite=Lax or Strict on cookies helps mitigate CSRF by…',
        options: [
          'Limiting when cookies are sent on cross-site requests',
          'Encrypting password hashes',
          'Preventing all XSS',
          'Replacing authorization checks',
        ],
        correctIndex: 0,
        explanation: 'SameSite is helpful but not a solo fix — use tokens and proper HTTP methods too.',
      ),
      PriorityQuiz(
        question: 'GET requests that change server state…',
        options: [
          'Are unsafe and should not perform mutations',
          'Are ideal for CSRF protection alone',
          'Replace POST entirely for logins',
          'Disable session cookies',
        ],
        correctIndex: 0,
        explanation: 'Use POST/PUT/PATCH/DELETE with CSRF protection for state changes.',
      ),
    ],
    curriculum: _webCsrfCurriculum,
  ),
  'web_essentials_29': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Context-aware escaping means…',
        options: [
          'Encode output differently for HTML, attribute, URL, and JavaScript contexts',
          'Use one generic escape for every layer',
          'Skip encoding when using HTTPS',
          'Only escape CSS colors',
        ],
        correctIndex: 0,
        explanation: 'HTML escaping does not protect inside script URLs or JS string literals.',
      ),
      PriorityQuiz(
        question: 'In HTML text nodes, user nicknames should be inserted via…',
        options: [
          'textContent or escaped templates — not raw innerHTML',
          'Unescaped innerHTML for speed',
          'SQL concatenation',
          'Plaintext password fields',
        ],
        correctIndex: 0,
        explanation: 'textContent treats input as text, not markup.',
      ),
      PriorityQuiz(
        question: 'htmlspecialchars() in PHP is appropriate when…',
        options: [
          'Emitting dynamic strings into HTML body/attributes (with correct flags/encoding)',
          'Building SQL WHERE clauses',
          'Hashing passwords',
          'Replacing CSRF tokens',
        ],
        correctIndex: 0,
        explanation: 'Use the right encoder for the sink — HTML, URL, JS each differ.',
      ),
      PriorityQuiz(
        question: 'Output encoding alone…',
        options: [
          'Does not stop SQL injection or CSRF by itself',
          'Solves every web vulnerability',
          'Removes need for prepared statements',
          'Eliminates authentication',
        ],
        correctIndex: 0,
        explanation: 'Layer defenses: validate input, encode output, CSRF tokens, parameterized SQL.',
      ),
    ],
    curriculum: _webEscapingCurriculum,
  ),
  'web_essentials_33': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'User-uploaded files should be stored…',
        options: [
          'Outside the web root with controlled download endpoints',
          'Directly in public_html with original attacker-chosen names',
          'Inside SQL VARCHAR columns as executable PHP',
          'In JavaScript localStorage',
        ],
        correctIndex: 0,
        explanation: 'Prevents direct URL execution of uploaded scripts.',
      ),
      PriorityQuiz(
        question: 'Validating uploads requires server checks on…',
        options: [
          'Size limits, allowed types, and safe filenames — not client extension alone',
          'Only the browser accept attribute',
          'CSS color contrast',
          'Git branch names',
        ],
        correctIndex: 0,
        explanation: 'Attackers forge Content-Type and extensions — verify server-side.',
      ),
      PriorityQuiz(
        question: 'Path traversal (../) in filenames should be blocked by…',
        options: [
          'Stripping/normalizing paths and using basenames before storage',
          'Trusting user input paths',
          'Disabling HTTPS',
          'Using MD5 for passwords only',
        ],
        correctIndex: 0,
        explanation: 'Never concatenate raw filenames onto base directories.',
      ),
    ],
    curriculum: _webSecureFilesCurriculum,
  ),
  'web_essentials_34': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Production error pages shown to users should…',
        options: [
          'Be generic while detailed diagnostics go to secure logs',
          'Include stack traces and SQL queries',
          'Print database passwords for debugging',
          'Disable all logging',
        ],
        correctIndex: 0,
        explanation: 'Verbose errors aid attackers — log internally, respond safely.',
      ),
      PriorityQuiz(
        question: 'When debugging XSS, error messages in the console…',
        options: [
          'May reveal script paths — fix the root encoding issue, do not expose secrets to users',
          'Should include API keys for convenience',
          'Replace CSRF tokens',
          'Prove SQL injection succeeded',
        ],
        correctIndex: 0,
        explanation: 'Use devtools locally; never ship secret values in client-visible errors.',
      ),
      PriorityQuiz(
        question: 'HTTP 500 responses to clients should…',
        options: [
          'Avoid leaking implementation details while operators investigate logs',
          'Always include raw PDO connection strings',
          'Return full phpinfo() output',
          'Skip authentication',
        ],
        correctIndex: 0,
        explanation: 'Pair safe user messages with operator observability.',
      ),
    ],
    curriculum: _webErrorMessagesCurriculum,
  ),
  'web_essentials_35': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Browser DevTools Network tab helps you inspect…',
        options: [
          'Request methods, headers, cookies, and response status for API debugging',
          'MySQL query plans inside InnoDB',
          'PHP opcache on the server disk',
          'Git remotes without HTTP',
        ],
        correctIndex: 0,
        explanation: 'See what the browser actually sent — useful for CSRF/cookie issues (local testing).',
      ),
      PriorityQuiz(
        question: 'When reproducing XSS locally, DevTools Elements panel shows…',
        options: [
          'Whether untrusted input became live DOM/script context',
          'Prepared statement bindings',
          'Database foreign keys',
          'Composer autoload maps',
        ],
        correctIndex: 0,
        explanation: 'Inspect sinks where encoding failed — fix before production.',
      ),
      PriorityQuiz(
        question: 'DevTools should never be used to…',
        options: [
          'Justify skipping server-side validation because you can tamper with client requests',
          'View response JSON during development',
          'Check Content-Type headers',
          'Measure page load timing',
        ],
        correctIndex: 0,
        explanation: 'Anything you change in DevTools is attacker-equivalent — server must enforce rules.',
      ),
    ],
    curriculum: _webDevtoolsCurriculum,
  ),
  'php_20': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'move_uploaded_file() should target…',
        options: [
          'A non-executable directory outside public web roots when possible',
          'The same folder as index.php with .php extension preserved',
          'A SQL table as binary always',
          'Client localStorage',
        ],
        correctIndex: 0,
        explanation: 'Uploaded content must not become runnable code via URL.',
      ),
      PriorityQuiz(
        question: r'Checking $_FILES upload error codes ensures…',
        options: [
          'PHP reports a successful upload before you process the temp file',
          'The file is virus-free automatically',
          'SQL injection is impossible',
          'CSRF cannot occur',
        ],
        correctIndex: 0,
        explanation: 'Handle upload errors explicitly; still validate type/size/content server-side.',
      ),
      PriorityQuiz(
        question: 'MIME type sent by the browser…',
        options: [
          'Can be spoofed — verify with server-side checks (size, extension allow-list, content sniffing cautiously)',
          'Is always trustworthy',
          'Replaces password_hash',
          'Disables sessions',
        ],
        correctIndex: 0,
        explanation: 'Never trust client metadata alone for security decisions.',
      ),
    ],
    curriculum: _phpUploadCurriculum,
  ),
  'php_34': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'RESTful design typically maps GET to…',
        options: [
          'Safe, read-only retrieval without side effects',
          'Password changes without auth',
          'Deleting all database rows',
          'Uploading executables anonymously',
        ],
        correctIndex: 0,
        explanation: 'GET must not mutate state; use POST/PUT/PATCH/DELETE with auth for changes.',
      ),
      PriorityQuiz(
        question: 'Versioned paths like /api/v1/users help…',
        options: [
          'Evolve APIs without breaking existing clients abruptly',
          'Remove need for HTTPS',
          'Store secrets in URLs',
          'Skip JSON encoding',
        ],
        correctIndex: 0,
        explanation: 'Contract clarity — still validate input and authorize every route.',
      ),
      PriorityQuiz(
        question: 'An API returning 201 Created should…',
        options: [
          'Include Location or body identifying the new resource when appropriate',
          'Return plaintext passwords',
          'Disable CSRF for all browsers globally',
          'Echo raw SQL errors to clients',
        ],
        correctIndex: 0,
        explanation: 'Use meaningful status codes and structured JSON — log details server-side.',
      ),
      PriorityQuiz(
        question: 'Rate limiting login APIs helps mitigate…',
        options: [
          'Credential stuffing and brute force attempts',
          'All XSS attacks automatically',
          'DNS propagation delay',
          'Foreign key violations',
        ],
        correctIndex: 0,
        explanation: 'Combine with lockouts/MFA — rate limits are one layer, not a complete fix.',
      ),
    ],
    curriculum: _phpRestCurriculum,
  ),
  'sql_30': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'Normalizing to 3NF generally reduces…',
        options: [
          'Redundant duplicated data and update anomalies',
          'Need for any indexes',
          'Requirement for primary keys',
          'Use of HTTPS',
        ],
        correctIndex: 0,
        explanation: 'Normalization improves integrity; denormalize selectively for measured performance needs.',
      ),
      PriorityQuiz(
        question: 'A junction table resolves…',
        options: [
          'Many-to-many relationships with composite keys to two entity tables',
          'XSS in HTML forms',
          'PHP session fixation',
          'Git merge conflicts',
        ],
        correctIndex: 0,
        explanation: 'Example: students_courses links students and courses with FKs.',
      ),
      PriorityQuiz(
        question: 'Choosing primary keys that are stable and meaningful to the business…',
        options: [
          'Simplifies joins and referential integrity',
          'Eliminates need for prepared statements',
          'Allows DELETE without WHERE',
          'Disables transactions',
        ],
        correctIndex: 0,
        explanation: 'Surrogate keys (AUTO_INCREMENT) are common — document relationships clearly.',
      ),
    ],
    curriculum: _sqlDesignCurriculum,
  ),
  'sql_39': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'In a blog schema, posts.author_id referencing users.id is…',
        options: [
          'A foreign key enforcing valid authors',
          'A CSS selector',
          'A CSRF token',
          'A PHP session name',
        ],
        correctIndex: 0,
        explanation: 'Model real projects with explicit FKs and indexes on join columns.',
      ),
      PriorityQuiz(
        question: 'Soft deletes (deleted_at column) require…',
        options: [
          'Queries that filter active rows and indexes that match access patterns',
          'Removing all WHERE clauses',
          'Plaintext password columns',
          'Storing uploads in SQL strings',
        ],
        correctIndex: 0,
        explanation: 'Design queries consciously — partial indexes/filters may help at scale.',
      ),
      PriorityQuiz(
        question: 'Before production launch you should…',
        options: [
          'Review schema, backups, least-privilege DB users, and migration plan',
          'Grant root to the web app for convenience',
          'Disable foreign keys permanently',
          'Commit production passwords to Git',
        ],
        correctIndex: 0,
        explanation: 'Design + operations together — DevPath studies schemas offline.',
      ),
    ],
    curriculum: _sqlRealProjectCurriculum,
  ),
  'python_13': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'json.loads() on untrusted strings should be followed by…',
        options: [
          'Schema validation before using fields — run scripts on your computer, not in DevPath',
          'eval() for convenience',
          'Storing results in innerHTML',
          'Skipping type checks',
        ],
        correctIndex: 0,
        explanation: 'JSON can be malformed or maliciously large — validate and limit input.',
      ),
      PriorityQuiz(
        question: 'json.dumps() with ensure_ascii=False…',
        options: [
          'Emits Unicode characters — still treat output as untrusted when embedding in HTML',
          'Encrypts passwords',
          'Prevents SQL injection in MySQL',
          'Disables HTTP',
        ],
        correctIndex: 0,
        explanation: 'Serialization ≠ sanitization for web contexts.',
      ),
      PriorityQuiz(
        question: 'Reading JSON config files for automation scripts…',
        options: [
          'Should use explicit paths and never execute code embedded in JSON',
          'Should use pickle for unknown files',
          'Should run as root always',
          'Should ignore file size limits',
        ],
        correctIndex: 0,
        explanation: 'Treat config as data; practice offline on a trusted machine.',
      ),
    ],
    curriculum: _pythonJsonCurriculum,
  ),
  'python_14': PriorityLessonOverride(
    quizzes: [
      PriorityQuiz(
        question: 'The requests library over HTTPS should…',
        options: [
          'Verify TLS certificates (default) and check response status codes',
          'Disable certificate verification in production',
          'Send passwords in query strings for caching',
          'Trust any redirect to file:// URLs',
        ],
        correctIndex: 0,
        explanation: 'Run HTTP examples on your computer — DevPath does not execute Python network code.',
      ),
      PriorityQuiz(
        question: 'Hard-coded API secrets in Python scripts should be…',
        options: [
          'Loaded from environment variables, not committed to Git',
          'Embedded in JSON sent to browsers',
          'Logged on every request',
          'Shared in chat for debugging forever',
        ],
        correctIndex: 0,
        explanation: 'Same secret hygiene as PHP/Web Essentials lessons.',
      ),
      PriorityQuiz(
        question: 'When calling external APIs, timeouts prevent…',
        options: [
          'Hung automation jobs from blocking forever',
          'All CSRF attacks',
          'Need for JSON parsing',
          'Use of virtual environments',
        ],
        correctIndex: 0,
        explanation: 'Set timeouts/retries thoughtfully; validate response payloads.',
      ),
    ],
    curriculum: _pythonHttpCurriculum,
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

final _phpTestingCurriculum = {
  'summary': 'Automated PHP tests guard auth, SQL, and API regressions — run on your computer, not in DevPath.',
  'content': [
    {
      'type': 'prose',
      'md': 'Use isolated databases or transactions rolled back after tests. Never point tests at production data.',
    },
  ],
};

final _phpInputValidationCurriculum = {
  'summary': 'Normalize and validate input on the server before SQL, files, or sessions.',
  'content': [
    {
      'type': 'callout',
      'variant': 'info',
      'md': 'Browser `required` attributes improve UX only — they are not a security control.',
    },
  ],
};

final _phpSessionsCurriculum = {
  'summary': 'Sessions tie requests to server-side state; harden cookies and rotate IDs on login.',
  'content': [
    {
      'type': 'prose',
      'md': 'Configure cookie flags (HttpOnly, Secure, SameSite) and avoid putting secrets in session IDs exposed in URLs.',
    },
  ],
};

final _phpPasswordCurriculum = {
  'summary': 'Use password_hash/password_verify — never store reversible or plaintext passwords.',
  'content': [
    {
      'type': 'code',
      'lang': 'php',
      'runnable': false,
      'code': r'$hash = password_hash($password, PASSWORD_DEFAULT);'
          '\n// store hash only\n'
          r'password_verify($password, $hash);',
    },
  ],
};

final _phpAuthCurriculum = {
  'summary': 'Authentication verifies identity before sessions or tokens are issued.',
  'content': [
    {'type': 'prose', 'md': 'Pair credential checks with rate limiting and secure session handling.'},
  ],
};

final _phpAuthorizationCurriculum = {
  'summary': 'Authorization runs on the server for every sensitive action.',
  'content': [
    {'type': 'prose', 'md': 'Map roles to permissions; return 403 when identity is known but action is denied.'},
  ],
};

final _phpSecretsCurriculum = {
  'summary': 'Load secrets from the environment; keep them out of Git and client bundles.',
  'content': [
    {'type': 'callout', 'variant': 'warning', 'md': 'Rotate credentials if they ever appear in logs or commits.'},
  ],
};

final _phpTransactionsCurriculum = {
  'summary': 'PDO transactions keep multi-step database changes consistent.',
  'content': [
    {
      'type': 'code',
      'lang': 'php',
      'runnable': false,
      'code':
          r'$pdo->beginTransaction(); try { /* updates */ $pdo->commit(); } catch (Throwable $e) { $pdo->rollBack(); throw $e; }',
    },
  ],
};

final _sqlTransactionsCurriculum = {
  'summary': 'Use transactions when multiple SQL statements must succeed together (MySQL InnoDB).',
  'content': [
    {
      'type': 'code',
      'lang': 'sql',
      'runnable': false,
      'code': 'START TRANSACTION;\nUPDATE accounts SET balance = balance - 100 WHERE id = 1;\nUPDATE accounts SET balance = balance + 100 WHERE id = 2;\nCOMMIT;',
    },
  ],
};

final _sqlAcidCurriculum = {
  'summary': 'ACID properties explain why transactions matter under concurrency and failures.',
  'content': [
    {'type': 'prose', 'md': 'Atomicity, Consistency, Isolation, Durability — know which layer enforces each.'},
  ],
};

final _sqlIndexPerfCurriculum = {
  'summary': 'Indexes speed reads but cost writes — inspect plans with EXPLAIN.',
  'content': [
    {'type': 'prose', 'md': 'MySQL-specific: EXPLAIN ANALYZE shows actual row counts in 8.0+.'},
  ],
};

final _sqlCompositeIndexCurriculum = {
  'summary': 'Composite indexes follow left-prefix rules — order columns to match queries.',
  'content': [
    {'type': 'prose', 'md': 'Example: INDEX (status, created_at) helps WHERE status = ? ORDER BY created_at.'},
  ],
};

final _tsInterfacesCurriculum = {
  'summary': 'Interfaces document object contracts — still validate external JSON at runtime.',
  'content': [
    {
      'type': 'code',
      'lang': 'typescript',
      'runnable': false,
      'code': 'interface Product { id: string; title: string; priceCents: number; }',
    },
  ],
};

final _tsApiResponseCurriculum = {
  'summary': 'Model API payloads with generics; handle HTTP errors before trusting parsed data.',
  'content': [
    {'type': 'prose', 'md': 'Compile TypeScript on your computer — DevPath playground runs HTML/CSS/JS only.'},
  ],
};

final _tsTypeSafeCurriculum = {
  'summary': 'Validate at boundaries; use strong types inside the application core.',
  'content': [
    {'type': 'prose', 'md': 'Parsers from unknown → domain types centralize security-relevant checks.'},
  ],
};

final _pythonCollectionsCurriculum = {
  'summary': 'Lists, dicts, sets, and tuples structure data — practice scripts run outside the app.',
  'content': [
    {'type': 'prose', 'md': 'Do not use eval() on untrusted input when automating files or APIs locally.'},
  ],
};

final _pythonFunctionsCurriculum = {
  'summary': 'Functions organize Python logic; validate arguments for automation scripts.',
  'content': [
    {'type': 'prose', 'md': 'DevPath shows examples offline — execute Python on a trusted machine.'},
  ],
};

final _pythonExceptionsCurriculum = {
  'summary': 'Handle specific exceptions and pair with input validation for safe automation.',
  'content': [
    {'type': 'prose', 'md': 'Log errors without leaking secrets; fail closed on unknown failures.'},
  ],
};

final _webAuthConceptsCurriculum = {
  'summary': 'Authentication establishes identity — always over HTTPS with protected tokens or sessions.',
  'content': [
    {'type': 'prose', 'md': 'Connects to PHP session lessons and API Authorization headers.'},
  ],
};

final _webAuthzCurriculum = {
  'summary': 'Authorization enforces what authenticated users may do — server-side on every request.',
  'content': [
    {'type': 'prose', 'md': 'Complements authentication lessons in PHP and Web Essentials tracks.'},
  ],
};

final _webSecretsCurriculum = {
  'summary': 'Secrets never belong in Git, URLs, or client-delivered JavaScript.',
  'content': [
    {'type': 'callout', 'variant': 'warning', 'md': 'Rotate keys immediately if exposed in logs or repos.'},
  ],
};

final _webEnvConfigCurriculum = {
  'summary': 'Per-environment configuration via env vars keeps production credentials out of code.',
  'content': [
    {'type': 'prose', 'md': 'Pair with deployment lessons: inject config at release, not bake into artifacts.'},
  ],
};

final _tsAsyncCurriculum = {
  'summary': 'async/await structures Promise-based I/O — compile and run TypeScript on your computer, not in DevPath.',
  'content': [
    {'type': 'prose', 'md': 'Always pair await fetch() with status checks and safe JSON parsing (unknown → validated types).'},
  ],
};

final _webXssCurriculum = {
  'summary': 'XSS injects script into pages users trust — encode output, CSP, and safe DOM APIs are layered defenses.',
  'content': [
    {
      'type': 'callout',
      'variant': 'warning',
      'md': 'No single header or filter stops every XSS variant — combine encoding, CSP, and safe frameworks.',
    },
  ],
};

final _webCsrfCurriculum = {
  'summary': 'CSRF abuses automatic cookie sending — use tokens, SameSite cookies, and correct HTTP verbs together.',
  'content': [
    {'type': 'prose', 'md': 'HTTPS alone does not stop CSRF; verify intent on every state-changing request.'},
  ],
};

final _webEscapingCurriculum = {
  'summary': 'Escape for the sink: HTML text, attribute, URL, and JavaScript contexts differ.',
  'content': [
    {'type': 'prose', 'md': 'Output encoding complements input validation — neither replaces parameterized SQL or CSRF tokens.'},
  ],
};

final _webSecureFilesCurriculum = {
  'summary': 'Treat uploads as untrusted files — storage location and validation matter as much as MIME checks.',
  'content': [
    {'type': 'prose', 'md': 'Connects to PHP upload lessons; study offline — DevPath does not accept uploads in lessons.'},
  ],
};

final _webErrorMessagesCurriculum = {
  'summary': 'Safe user-facing errors, detailed operator logs — never leak secrets or stack traces publicly.',
  'content': [
    {'type': 'prose', 'md': 'Use DevTools during local debugging; production users see generic failure messages.'},
  ],
};

final _webDevtoolsCurriculum = {
  'summary': 'DevTools help inspect requests and DOM sinks during development on your machine or device browser.',
  'content': [
    {'type': 'prose', 'md': 'Tampering in DevTools mimics attackers — server rules must hold regardless.'},
  ],
};

final _phpUploadCurriculum = {
  'summary': 'Secure uploads: validate, rename, store outside web root, and never execute user content.',
  'content': [
    {'type': 'code', 'lang': 'php', 'runnable': false, 'code': r'// Study offline — is_uploaded_file() + move_uploaded_file() to a safe path'},
  ],
};

final _phpRestCurriculum = {
  'summary': 'REST maps HTTP methods to resources with consistent JSON and status codes — authorize every route.',
  'content': [
    {'type': 'prose', 'md': 'Design idempotent PUT/PATCH where appropriate; never expose secrets in URLs or error JSON.'},
  ],
};

final _sqlDesignCurriculum = {
  'summary': 'Model entities, relationships, and keys before indexing — MySQL InnoDB FKs enforce integrity.',
  'content': [
    {'type': 'prose', 'md': 'Sketch ER diagrams on paper; validate with normalized tables and realistic queries.'},
  ],
};

final _sqlRealProjectCurriculum = {
  'summary': 'Production schemas combine normalization, indexes, migrations, backups, and least-privilege access.',
  'content': [
    {'type': 'prose', 'md': 'Align with sql_30 design basics — no live database runs inside DevPath.'},
  ],
};

final _pythonJsonCurriculum = {
  'summary': 'Parse JSON safely in scripts you run locally — validate shapes before acting on data.',
  'content': [
    {'type': 'prose', 'md': 'DevPath does not execute Python; use venv + tests on your computer.'},
  ],
};

final _pythonHttpCurriculum = {
  'summary': 'HTTP client scripts need TLS verification, timeouts, and secret hygiene — practice offline.',
  'content': [
    {'type': 'prose', 'md': 'Never disable certificate checks in production automation.'},
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

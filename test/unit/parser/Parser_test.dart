@TestOn("vm")
library test.unit.lexer;

import 'dart:io';
import 'package:test/test.dart';

import 'package:logging/logging.dart';
import 'package:console_log_handler/print_log_handler.dart';
import 'package:l10n/parser.dart';
import 'package:l10n/pot.dart';

class _TestPrintVisitor extends Visitor {
  final Logger _logger = new Logger('test.unit.lexer._TestVisitor');
    
  final String filename;

  _TestPrintVisitor(this.filename);

  @override
  void visitComment(final CommentStatement statement) {
      final List<String> lines = statement.comment.split(new RegExp(r"\n"));
      lines.forEach((final String line) => _logger.fine("#. ${line.trimLeft()}"));
  }

  @override
  void visitL10n(final L10NStatement statement) {
    _logger.fine("#: ${filename}:${statement.line}");
    
    _logger.fine('msgid "${statement.msgid}"');
    if(statement.params.length > 1) {
        _logger.fine('msgid_plural "${statement.params[1]}"');
    }

    _logger.fine('msgstr ""');
    _logger.fine('');
  }
}


main() async {
    // final Logger _logger = new Logger("test.unit.parser");

    // If you want to see some log outptut set "defaultLogLevel:"
    // to Level.FINE or Level.FINER
    configLogging(show: Level.INFO);

    final String source = new File("test/unit/_resources/test-l10n-login.dart").readAsStringSync();

    group('Lexer', () {
        setUp(() { });

        test('> Scan', () {
            final Lexer lexer = new Lexer();
            final List<Token> tokens = lexer.scan(source);

            _logTokes(tokens);
            final int nrOfComments = tokens.where((final Token token) =>
                token.type == TokenType.COMMENT).length;

            final int nrOfFunctions = tokens.where((final Token token) =>
            token.type == TokenType.L10N).length;

            expect(nrOfComments, equals(20));
            // 14 - but one is a function declaration!
            expect(nrOfFunctions, equals(14));

            final int nrOfLeftBracket = tokens.where((final Token token) =>
            token.type == TokenType.LEFT_BRACKET).length;

            final int nrOfRightBracket = tokens.where((final Token token) =>
            token.type == TokenType.RIGHT_BRACKET).length;

            expect(nrOfLeftBracket, nrOfRightBracket);

            final int nrOfScopeBegin = tokens.where((final Token token) =>
            token.type == TokenType.SCOPE_BEGIN).length;

            final int nrOfScopeEnd = tokens.where((final Token token) =>
            token.type == TokenType.SCOPE_END).length;

            expect(nrOfScopeBegin, nrOfScopeEnd);

        }); // end of 'Test' test
    });
    // End of 'Parser' group

    group('Parser', () {
        setUp(() {});

        test('> Parse', () {
            final String filename = "test.dart";
            final Lexer lexer = new Lexer();
            final Parser parser = new Parser();

            final List<Token> tokens = lexer.scan(source);
            _logTokes(tokens);
            
            final List<Statement> ast = parser.parse(filename, tokens);
            _logStatements(ast);

            expect(ast.where((final Statement statement)
                => !(statement is NewLineStatement)).length, equals(33));

            final Visitor visitor = new _TestPrintVisitor(filename);

            // A "block" means:
            // #. HTML-Kommentar
            // #: test.dart:103
            // msgid "Test 10: 12345678aA16#"
            // msgstr ""
            //
            final List<POTBlock> blocks = collectPOTBlocks(ast);
            expect(blocks.length, 13);

            expect(blocks[12].comments.length, 0);
            expect(blocks[12].statement.msgid, "Test 13: Sign in");

            // Prints all the blocks if logging is set to 'FINE'
            blocks.forEach((final POTBlock block) {
                block.comments.forEach((final CommentStatement comment) => comment.accept(visitor));
                block.statement.accept(visitor);
            });

        }); // end of 'Parse' test

    }); // End of '' group

    group('HTML', () {
        setUp(() {});

        test('> extract only HTML-Part', () {
            final startTag = r'<div class="mdl-dialog login-dialog1">';
            final endTag = r'</div>';

            // [\\s\\S] matches anything including newline
            final re = RegExp("${startTag}[\\s\\S]*${endTag}",
                multiLine: true, caseSensitive: false);

            expect(re.hasMatch(source), isTrue);
            expect(re.firstMatch(source).group(0).split("\n").length,35);

            final Lexer lexer = new Lexer();
            final Parser parser = new Parser();

            final filename = "test.dart";
            final htmlSource = re.firstMatch(source).group(0);

            final List<Token> tokens = lexer.scan(htmlSource);
            final List<Statement> ast = parser.parse(filename, tokens);
            _logStatements(ast, onlyIf: (final Statement statement) => statement is L10NStatement);
            
            expect(ast.where((final Statement statement)
                => (statement is L10NStatement)).length, equals(6));
        }); // end of 'extract only HTML-Part' test

    }); // End of '' group
}

void _logTokes(final List<Token> tokens) {
    final Logger _logger = new Logger("test.unit.parser._logTokes");

    tokens.forEach((final Token token) {
        switch(token.type) {

            case TokenType.L10N:
            case TokenType.COMMENT:
                _logger.fine("${token.type.toString().padRight(20)} -> Text: ${token.text}");
                break;

            default:
                _logger.finer("${token.type.toString().padRight(25)} -> Text: ${token.text}");
                break;
        }
    });
}

void _logStatements(final List<Statement> ast, { bool onlyIf(final Statement statement)}) {
    final Logger _logger = new Logger("test.unit.parser._logStatements");

    onlyIf ??= (final Statement statement) => !(statement is NewLineStatement);

    ast.where(onlyIf).forEach( (final Statement statement) {
            if(statement is CommentStatement) {
                _logger.fine(statement.comment);
            }
            else if(statement is L10NStatement) {
                final params = List<String>();
                statement.params.forEach((final String key, final value) {
                    params.add("$key:$value");
                });
                if(params.isEmpty) {
                    _logger.fine("l10n('${statement.msgid}')");
                } else {
                    _logger.fine("l10n('${statement.msgid}',{ ${params.join(", ")} })");
                }
            }
            else {
                _logger.fine(statement);
            }
        });
}
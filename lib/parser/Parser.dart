/*
 * Copyright (c) 2017, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
part of l10n.parser;

/**
 * The parser takes in a sequence of tokens
 * and generates an abstract syntax tree.
 */
class Parser {
    final List<Token> _tokens = new List<Token>();

    /// Current Token-Position
    int _offset = 0;

    /**
     * The top-level function to start parsing. This will keep consuming
     * tokens and routing to the other parse functions for the different
     * grammar syntax until we run out of code to parse.
     *
     * We need a [filename] to print out filenames and linenumbers
     * The [tokens] to parse
     */
    List<Statement> parse(final String filename, final List<Token> tokens) {
        final List<Statement> statements = new List<Statement>();

        // Reset in case of reuse
        _offset = 0;

        this._tokens.clear();
        this._tokens.addAll(tokens);

        int line = 1;
        try {
            for (Optional<Token> oToken = _peek(); oToken.isPresent && _offset < _tokens.length;
            oToken = _peek()) {
                Token token = oToken.value;

                switch (token.type) {
                    case TokenType.COMMENT:
                        statements.add(new CommentStatement(line, token.text));
                        line += math.max(1, token.text
                            .split("\n")
                            .length);
                        _read();
                        break;

                    case TokenType.L10N:
                    // Singular: l10n("My name is Mike")
                        if (_isNext(
                            [TokenType.LEFT_BRACKET, TokenType.STRING, TokenType.RIGHT_BRACKET])) {
                            token = _read(skip: 1).value;
                            statements.add(new L10NStatement(filename, line, token.text));
                            _read(expect: TokenType.RIGHT_BRACKET);
                        }
                        // With Param: l10n("My name is {name}",{ "name" : "Mike" })
                        else if (_isNext([
                            TokenType.LEFT_BRACKET,
                            TokenType.STRING,
                            TokenType.COMMA,
                            TokenType.SCOPE_BEGIN
                        ])) {
                            final String msgid = _read(skip: 1).value.text; // String
                            final params = Map<String, dynamic>();

                            // Comma, {
                            _read(expect: TokenType.COMMA);
                            _read(expect: TokenType.SCOPE_BEGIN);

                            do {
                                final String key = _read().value.text;
                                _read(expect: TokenType.COLON); // Colon

                                final valueToken = _read();
                                var value;
                                if (valueToken.value.type == TokenType.STRING) {
                                    value = valueToken.value.text;
                                }
                                else {
                                    value = num.parse(valueToken.value.text);
                                }
                                params.putIfAbsent(key, () => value);
                                if (_isNext([ TokenType.COMMA])) {
                                    _read(expect: TokenType.COMMA);
                                }
                            } while (!_isNext([ TokenType.SCOPE_END]));
                            _read(expect: TokenType.SCOPE_END); // }

                            statements.add(
                                new L10NStatement(filename, line, msgid, params: params));
                            _read(expect: TokenType.RIGHT_BRACKET);
                        }
                        // l10n-Function call e.g. l10n(value)
                        // No further processing - we ignore function calls
                        else if(_isNext([TokenType.LEFT_BRACKET, TokenType.WORD, TokenType.RIGHT_BRACKET])) {
                            _read(skip: 2, expect: TokenType.RIGHT_BRACKET);
                        } else {
                            throw ParserError("Syntax error! Unexpected l10n-Function-call on line $line!",
                                filename, line);
                        }
                        break;

                    case TokenType.LINE:
                        statements.add(new NewLineStatement(line));
                        line++;
                        _read();
                        break;

                    default:
                        _read();
                }
            };
        } on InvalidTokenException catch(e) {
            throw ParserError("Invalid Token! Expected: ${e.expectedToken} but found: ${e.found}",
                filename, line, e);
        }
        return statements;
    }

    // - private -----------------------------------------------------------------------------------

    /// Peek the current [Token]
    /// Avoiding null - so [Optional] is a good option
    Optional<Token> _peek() => _offset < _tokens.length ?
        new Optional.of(_tokens[_offset]) : new Optional.empty();

    /// Returns the next [Token]
    ///
    /// In case of EOF it returns an empty [Optional]
    Optional<Token>  _read({final int skip = 0, final TokenType expect  }) {
        _offset += 1 + skip;
        if (_offset < _tokens.length) {
            final found = _tokens[_offset].type;
            if(expect != null && found != expect) {
                throw InvalidTokenException(expect,found);
            }
            return new Optional.of(_tokens[_offset]);
        }
        if(expect != null) {
            throw InvalidTokenException(expect,null);
        }
        return new Optional.empty();
    }

    /// Compares the next tokens
    bool _isNext(final List<TokenType> types) {
        Validate.notEmpty(types);

        final int endPosition = _offset + 1 + types.length;
        if(endPosition >= _tokens.length) {
            return false;
        }
        for(int index = 0;(index + _offset + 1) < endPosition; index++) {
            if(types[index] != _tokens[(index + _offset + 1)].type) {
                //print("T1 ${types[index]}, T2 ${_tokens[(index + _offset + 1)].type}");
                return false;
            }
        }
        return true;
    }
}
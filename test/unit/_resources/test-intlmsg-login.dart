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

import 'dart:html' as dom;
import 'package:intl/intl.dart';

//@Component
class LoginDialog /* extends MaterialDialog*/ {

    static const String _DEFAULT_SUBMIT_BUTTON = "Submit";
    static const String _DEFAULT_CANCEL_BUTTON = "Cancel";

    String title = "";
    String yesButton = _DEFAULT_SUBMIT_BUTTON;
    String noButton = _DEFAULT_CANCEL_BUTTON;

    final String username = '';
    final String password = '';

    /// Zeigt den LoginDialog an
    ///
    /// Wenn [undoPossible] auf true gesetzt ist kann der User
    /// den Dialog beenden und kehrt zu seinem vorhergehenden Login zurück
    /// [undoPossible] wird eingeschaltet wenn der User eingeloggt ist
    LoginDialog({final bool undoPossible: false });

    LoginDialog call({ final String title: "",
                         final String yesButton: _DEFAULT_SUBMIT_BUTTON,
                         final String noButton: _DEFAULT_CANCEL_BUTTON }) {

        this.title = title;
        this.yesButton = yesButton;
        this.noButton = noButton;

        return this;
    }

    bool get hasTitle => (title != null && title.isNotEmpty);

    // - EventHandler -----------------------------------------------------------------------------

    void onLogin(final dom.Event event) {
        event.preventDefault();
        //close(MdlDialogStatus.OK);

        message1() => Intl.message("Test 1");
        print(message1());

        // Params-Test
        message2(final String name) => Intl.message(
            "Test 2 - Plural Name: $name",
            name: "message2",
            args: [ name ]
        );
        print(message2("Mike"));

        /// Dart Kommentar II
        message3() => Intl.message( "Test 3" );
        print(message3());

        /* Dart Kommentar III */
        message4() => Intl.message("Test \"4\"");
        print(message4());

        message5() => Intl.message("Test (5)");
        print(message5());

        message6() => Intl.message('Test 6');
        print("Hallo ${message6()} --!");
    }

    // Must not appear in scan
    String tr(final String value) => Intl.message(value);

    // - private ----------------------------------------------------------------------------------

    // - template ----------------------------------------------------------------------------------

    //@override
    String template = """
        <div class="mdl-dialog login-dialog1">
            <form method="post" class="right mdl-form mdl-form-registration demo-registration">
                <h5 class="mdl-form__title" translate='yes'>
                <!-- Multi line
                    HTML Kommentar -->
                tr('Test 7')</h5>
                <div class="mdl-form__content">
                    <div class="mdl-textfield">
                        <input class="mdl-textfield__input" type="email" id="email" mdl-model="username" required autofocus>
                        <label class="mdl-textfield__label" for="email" translate='yes'>_('Test 8')</label>
                        <span class="mdl-textfield__error" translate='yes'>_('Test 9: This is not a valid eMail-Address')</span>
                    </div>
                    <div class="mdl-textfield">
                        <input class="mdl-textfield__input" type=password id="password" mdl-model="password"
                               pattern="((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#\$%?]).{8,15})" required>
                               
                            <label class="mdl-textfield__label" for="password" translate='yes'>_('Test 10: Password')</label>
                            <span class="mdl-textfield__error" translate='yes'>
                                <!-- HTML-Kommentar -->
                                _('Test 11: 12345678aA16#')
                            </span>    
                    </div>
                    <div class="mdl-form__hint">
                        <a href="#" target="_blank" translate='yes'>_('Test 12: Forgot your password?')</a>
                    </div>
                </div>
                <div class="mdl-form__actions">
                    <button id="submit" class="mdl-button mdl-button--submit
                        mdl-button--raised mdl-button--primary"
                        data-mdl-click="onLogin(\$event)" translate='yes'>
                        _('Test 13: Sign in')
                    </button>
                </div>
            </form>
        </div>
        """;
}
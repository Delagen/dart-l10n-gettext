l10n / (gettext-oriented) PO-File Generator
-------------------------------------------
####Helps to localize your application####

[![Screenshot][1])](http://www.youtube.com/watch?v=vPfl-xPTjs0)

###Install###
If Dart 1.6 is out then
```bash
$ pub global activate mkl10nlocale.dart
```
should work...

You can run the script from any local directory.
```bash
$ pub global run mkl10nlocale.dart --help
```

For now (at least I think) you have to clone the script from GH
As you can see I have a symlink to bin/mkl10nlocale.dart

###How to use it###

```dart
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:l10n/l10n.dart';

// This file will be generated by the framework (l10n)
// Uncomment in Step 3
//import 'package:<your package>/locale/messages.dart';

void main(List<String> arguments) {
    final Application application = new Application();

    findSystemLocale().then((final String locale) {
        // Uncomment in Step 3
        // translate.locale = Intl.shortLocale(locale);

        // Step 1 - sourround your text with l10n(...)
        // Try this: print(l10n("This is a test").message);
        print(l10n("This is a test"));  
               
        // Step 2 - run mkl10nlocale -l de,en example/
        
        // Step 3 - add the import-statement for locale/messages.dart
        // + set the locale
        
        // Step 4 - add 'translate' to your print statement
        print(translate(l10n("This is a test")));  
        
        // Step 5 - Translate the entry in your 
        // PO (for example local/de/messages.po
        
        // Step 6 - run mkl10nlocale -l de,en
        
        // Step 7 - run your program 
    });
}
```

```bash
$ dart mini.dart 
SystemLocale: de_AT
Dies ist ein TEST!
```

###System requirements###
* xgettext
* msginit
* msgmerge

These programs are on your system if you are working on Mac or Linux.

(only if you want to generate PO/POT files)

###If you have problems###
* [Issues][2]

###History ###
* 0.9.0 - Released on pub

###License###

    Copyright 2014 Michael Mitterer (office@mikemitterer.at), 
    IT-Consulting and Development Limited, Austrian Branch

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, 
    software distributed under the License is distributed on an 
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
    either express or implied. See the License for the specific language 
    governing permissions and limitations under the License.
    
    
If this plugin is helpful for you - please [(Circle)](http://gplus.mikemitterer.at/) me.

[1]: https://raw.githubusercontent.com/MikeMitterer/dart-l10n-gettext/master/doc/_resources/screenshot.png
[2]: https://github.com/MikeMitterer/dart-l10n-gettext/issues


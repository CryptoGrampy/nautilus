// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a sl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'sl';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Račun"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("Vnesite ime"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Izberite ime računa"),
        "accounts": MessageLookupByLibrary.simpleMessage("Računi"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Ste prepričani, da ste varno shranili vaš skrivni niz ali zasebni ključ?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Aktivno sporočilo"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Dodaj račun"),
        "addAddress": MessageLookupByLibrary.simpleMessage("Dodajte naslov"),
        "addBlocked":
            MessageLookupByLibrary.simpleMessage("Blokiraj uporabnika"),
        "addContact": MessageLookupByLibrary.simpleMessage("Dodaj stik"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Dodaj Favorite"),
        "addUser": MessageLookupByLibrary.simpleMessage("Dodajte uporabnika"),
        "addWatchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Dodaj račun samo za ogled"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Napaka pri dodajanju računa samo za ogled: račun je bil ničelni"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Uspešno ustvarjen račun samo za gledanje!"),
        "address": MessageLookupByLibrary.simpleMessage("Naslov"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Naslov skopiran"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Vnesite naslov"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Prosim vnesite naslov"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Vnesite uporabniško ime ali naslov"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Deli naslov"),
        "aliases": MessageLookupByLibrary.simpleMessage("Vzdevki"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Razdeljeni znesek ne sme biti večji od darilnega stanja"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Prosim vnesite znesek"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Opazili smo, da ste kliknili povezavo, ki vsebuje nano, ali želite preskočiti postopek namestitve? Pozneje lahko vedno spremenite stvari.\n\n Če pa imate obstoječe seme, ki ga želite uvoziti, izberite ne."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "Zaprosili bomo za dovoljenje za \"sledenje\", to se uporablja *strogo* za dodeljevanje povezav/napotitev in manjše analitike (stvari, kot so število namestitev, katera različica aplikacije itd.) Menimo, da ste upravičeni do svoje zasebnosti in nas ne zanimajo nobeni vaši osebni podatki, potrebujemo le dovoljenje, da lahko pripisovanje povezav deluje pravilno."),
        "asked": MessageLookupByLibrary.simpleMessage("Na vprašanje"),
        "authConfirm":
            MessageLookupByLibrary.simpleMessage("Preverjanje pristnosti"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Med preverjanjem pristnosti je prišlo do napake. Poskusi znova kasneje."),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Način avtentikacije"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Preverjanje pristnosti"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Samodejni uvoz"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Samodejno zakleni"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Varno shranjeno"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Backup Secret Phrase"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Shrani ključ"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Ste prepričani, da ste shranili zasebni ključ?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Shrani zasebni ključ"),
        "biometricsMethod":
            MessageLookupByLibrary.simpleMessage("Prstni odtis"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("Blok Explorer"),
        "blockExplorerHeader":
            MessageLookupByLibrary.simpleMessage("Blok Explorer Informacije"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Kateri raziskovalec blokov uporabiti za prikaz informacij o transakcijah"),
        "blockUser":
            MessageLookupByLibrary.simpleMessage("Blokiraj tega uporabnika"),
        "blockedAdded":
            MessageLookupByLibrary.simpleMessage("% 1 uspešno blokiran."),
        "blockedExists":
            MessageLookupByLibrary.simpleMessage("Uporabnik je že blokiran!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("Blokiran"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Blokirajte uporabnika po katerem koli znanem vzdevku ali naslovu. Vsa sporočila, transakcije ali zahteve od njih bodo prezrte."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blokirane informacije"),
        "blockedNameExists":
            MessageLookupByLibrary.simpleMessage("Ime Nick že uporablja!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Izberite Nick Nick Name"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 je bil odblokiran!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "Zdi se, da ne moremo doseči vmesnika Branch API, običajno je to posledica neke vrste težave z omrežjem ali VPN, ki blokira povezavo.\n\n Aplikacijo bi morali še vedno uporabljati kot običajno, vendar pošiljanje in prejemanje darilnih kartic morda ne bo delovalo."),
        "branchConnectErrorShortDesc":
            MessageLookupByLibrary.simpleMessage("Napaka: Branch API ni mogoč"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Opozorilo o povezavi"),
        "cancel": MessageLookupByLibrary.simpleMessage("Prekliči"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "Da bi preprečili zlorabo, zahtevamo, da rešite captcha, da prevzamete darilno kartico na naslednji strani."),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Spremeni valuto"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Spremeni dnevnik"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Zamenjaj predstavnika"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Zamenjaj"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Vnesite novega predstavnika"),
        "changeRepSame":
            MessageLookupByLibrary.simpleMessage("To je že vaš predstavnik!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Predstavnik uspešno zamenjan"),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Preverite razpoložljivost"),
        "close": MessageLookupByLibrary.simpleMessage("Zapri"),
        "confirm": MessageLookupByLibrary.simpleMessage("Potrdi"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Confirm the password"),
        "confirmPinHint": MessageLookupByLibrary.simpleMessage("Potrdite pin"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Connecting"),
        "connectionWarning": MessageLookupByLibrary.simpleMessage(
            "Ni mogoče vzpostaviti povezave"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Zdi se, da se ne moremo povezati z zaledjem, to je lahko samo vaša povezava ali če se težava ponovi, je zaledje morda nedosegljivo zaradi vzdrževanja ali celo izpada. Če je minilo več kot eno uro in imate še vedno težave, pošljite poročilo v #bug-reports v strežniku discord @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Zdi se, da se ne moremo povezati z zaledjem, to je lahko samo vaša povezava ali če se težava ponovi, je zaledje morda nedosegljivo zaradi vzdrževanja ali celo izpada. Če je minilo več kot eno uro in imate še vedno težave, pošljite poročilo v #bug-reports v strežniku discord @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Zdi se, da se ne moremo povezati z zaledjem"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 dodan stikom."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Stik že obstaja"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Stik"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Neveljavno ime"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Vnesite ime @"),
        "contactNameMissing":
            MessageLookupByLibrary.simpleMessage("Izberite ime za ta stik"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 je bil odstranjen iz stikov!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Stiki"),
        "contactsImportErr":
            MessageLookupByLibrary.simpleMessage("Ni možno uvoziti stikov"),
        "contactsImportSuccess":
            MessageLookupByLibrary.simpleMessage("Uspešen uvoz %1 stikov."),
        "copied": MessageLookupByLibrary.simpleMessage("Skopirano"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopiraj"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Kopiraj naslov"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Kopiraj povezavo"),
        "copyMessage":
            MessageLookupByLibrary.simpleMessage("Kopiraj sporočilo"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Kopiraj ključ"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Kopirajte naslov denarnice v odložišče"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Create a password."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Ustvarite darilno kartico"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Ustvarite darilno kartico"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "You can create a password to add additional security to your wallet."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Create a password"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Password is optional, and your wallet will be protected with your PIN or biometrics regardless."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Ustvari"),
        "createPinHint":
            MessageLookupByLibrary.simpleMessage("Ustvarite žebljiček"),
        "createQR": MessageLookupByLibrary.simpleMessage("Ustvarite QR kodo"),
        "created": MessageLookupByLibrary.simpleMessage("ustvarili"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Ustvarjanje darilne kartice"),
        "currency": MessageLookupByLibrary.simpleMessage("Valuta"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Valutni način"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage(
            "Informacije o valutnem načinu"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Izberite, v kateri enoti želite prikazati zneske.\n1 nyano = 0,000001 NANO, ali \n1.000.000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Trenutni predstavnik"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("Pred enim dnevom"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Napaka dešifriranja!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Glavni račun"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Oglejte si Nautilus! Poslal sem ti nekaj nano s to povezavo:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Račun %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Izbriši"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Disable"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Password has been disabled"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Disable Wallet Password"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Zavrni"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Neveljavno ime domene"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Donirajte"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Podprite projekt"),
        "edit": MessageLookupByLibrary.simpleMessage("Uredi"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Omogoči obvestila"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Omogoči sledenje"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Failed to set a wallet password"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Vnesite naslov"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Vnesite znesek"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Vnesite darilno opombo"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("Vnesite višino"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Vnesite sporočilo"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Vnesite naslov XMR"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Enter your password"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Vnesite delni znesek"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage(
            "Vnesite uporabnika ali naslov"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Vnesite uporabniško ime"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Med obdelavo te darilne kartice je prišlo do napake. Morda ni veljavna, je potekla ali je prazna."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("od nekoga"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Dobrodošli v Nautilus. Ko boste prejeli NANO, bodo transakcije prikazane takole:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("nekaj"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("več"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("nekomu"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Srečen rojstni dan!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "Ko pošljete ali prejmete zahtevo za plačilo, se bodo tukaj prikazali takole z barvo in oznako kartice, ki označujeta stanje. \n\nZelena označuje, da je bila zahteva plačana.\nRumena označuje zahteva/beležka ni bila plačana/branje.\nRdeča označuje, da zahteva ni bila prebrana ali prejeta.\n\n Nevtralne barvne kartice brez zneska so le sporočila."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled":
            MessageLookupByLibrary.simpleMessage("Nekateri"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Suši"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "Ko pošljete ali prejmete zahtevo za plačilo, se bodo prikazali tukaj:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Hej, kaj se dogaja?"),
        "examplePaymentReceivable":
            MessageLookupByLibrary.simpleMessage("Veliko"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Najemnina"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Plinski denar"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("Menjava NANO"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Izvozne transakcije"),
        "failed": MessageLookupByLibrary.simpleMessage("neuspelo"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("Nautilus Odklopljen"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Zdi se, da so strežniki Nautilus prekinjeni. Pošiljanje in prejemanje (brez beležk) bi moralo biti še vedno operativno, vendar zahtevki za plačilo\n\n Vrnite se pozneje ali znova zaženite aplikacijo, da poskusite znova"),
        "favoriteExists":
            MessageLookupByLibrary.simpleMessage("Najljubši že obstaja"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("Najljubši"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Neveljavno priljubljeno ime"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Vnesite Nick Nick Name"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Izberite ime za to najljubšo"),
        "favoriteRemoved": MessageLookupByLibrary.simpleMessage(
            "% 1 je bil odstranjen iz priljubljenih!"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("Priljubljene"),
        "featured": MessageLookupByLibrary.simpleMessage("Predstavljen"),
        "fewDaysAgo": MessageLookupByLibrary.simpleMessage("Pred nekaj dnevi"),
        "fewHoursAgo": MessageLookupByLibrary.simpleMessage("Pred nekaj urami"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("Pred nekaj minutami"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("Pred nekaj sekundami"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Avtenticiraj za shranitev ključa."),
        "from": MessageLookupByLibrary.simpleMessage("Od"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("izpolnjeno"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Banner za financiranje"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("financiranje"),
        "getNano": MessageLookupByLibrary.simpleMessage("Pridobite NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("Imate darilo!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Prazno darilo"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Znesek darila"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Med poskusom ustvarjanja povezave do darilne kartice je prišlo do napake"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Med poskusom ustvarjanja darilne kartice je prišlo do napake, POVEZAVA DO DARILNE KARTICE ALI SEME JE BILO KOPIRANO V VAŠE ODLOŽIŠČE, VAŠA SREDSTVA SO MORDA V NJEM, GLEDE NA TO, KAJ JE ŠLO NAROBE."),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Darilo Od"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Naložite digitalno darilno kartico z NANO! Nastavite znesek in izbirno sporočilo, da bo prejemnik videl, kdaj ga odpre!\n\nKo ustvarite, boste dobili povezavo, ki jo lahko pošljete vsakomur, ki bo ob odprtju samodejno razdelila sredstva prejemniku po namestitvi Nautilusa!\n\nČe je prejemnik že uporabnik Nautilusa, bo ob odprtju povezave dobil poziv za prenos sredstev na svoj račun"),
        "giftMessage":
            MessageLookupByLibrary.simpleMessage("Darilno sporočilo"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "Med obdelavo te darilne kartice je prišlo do napake. Morda preverite svojo povezavo in poskusite znova klikniti povezavo za darilo."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Darilo je uspešno prejeto, lahko traja nekaj trenutkov, da se prikaže v vaši denarnici."),
        "giftRefundSuccess": MessageLookupByLibrary.simpleMessage(
            "Darilo je bilo uspešno vrnjeno!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Go Back"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Pojdi na QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Razumem!"),
        "handoff": MessageLookupByLibrary.simpleMessage("Roke stran"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Nekaj je šlo narobe med poskusom blokiranja predaje!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "Podprte metode predaje ni bilo mogoče najti!"),
        "hide": MessageLookupByLibrary.simpleMessage("Skrij"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Skrij račun?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Ali ste prepričani, da želite skriti prazne račune?\n\nS tem boste skrili vse račune s stanjem natanko 0 (razen naslovov samo za opazovanje in vašega glavnega računa), vendar jih lahko kadar koli znova dodate pozneje, tako da tapnete gumb »Dodaj račun«."),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Skrij račune?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Skrij prazne račune"),
        "home": MessageLookupByLibrary.simpleMessage("Domov"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("Pred uro"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("I Understand the Risks"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignoriraj"),
        "imSure": MessageLookupByLibrary.simpleMessage("Prepričan sem"),
        "import": MessageLookupByLibrary.simpleMessage("Uvozi"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "Povezava, ki ste jo kliknili, vsebuje nekaj nano, jo želite uvoziti v to denarnico ali vrniti tistemu, ki jo je poslal?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Videti je, da ste kliknili povezavo, ki vsebuje nekaj NANO. Da bi prejeli ta sredstva, potrebujete le, da dokončate nastavitev svoje denarnice."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Povezava, ki ste jo kliknili, vsebuje nekaj NANO, ali bi ga radi uvozili v to denarnico?"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Uvozi skrivni niz"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Spodaj vnesite vaš skrivni 24-besedni niz. Vsaka beseda naj bo ločena s presledkom."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Uvozi ključ"),
        "importSeedHint":
            MessageLookupByLibrary.simpleMessage("Spodaj vnesite ključ."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Uvozi zasebni ključ"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Uvozi denarnico"),
        "instantly": MessageLookupByLibrary.simpleMessage("Takoj"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Premalo na računu"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Preskočili smo uvodni postopek, da bi vam prihranili čas, vendar morate takoj varnostno kopirati svoje novo ustvarjeno seme.\n\nČe izgubite svoje seme, boste izgubili dostop do svojih sredstev.\n\nPoleg tega je vaše geslo nastavljeno na »000000«, ki ga prav tako takoj spremenite."),
        "introSkippedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Varnostno kopirajte svoje seme!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Naslov je neveljaven"),
        "invalidHeight":
            MessageLookupByLibrary.simpleMessage("Neveljavna višina"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Invalid Password"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Neveljaven PIN"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "Zaradi smernic in omejitev trgovine iOS App Store vas ne moremo povezati z našo stranjo za donacije. Če želite podpreti projekt, razmislite o pošiljanju na naslov vozlišča nautilus."),
        "language": MessageLookupByLibrary.simpleMessage("Jezik"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Povezava Kopirana"),
        "loaded": MessageLookupByLibrary.simpleMessage("Naložen"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Naložen v"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Avtenticiraj ob zagonu"),
        "locked": MessageLookupByLibrary.simpleMessage("Zaklenjeno"),
        "logout": MessageLookupByLibrary.simpleMessage("Odjava"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Izbriši ključ in odjava"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Ste prepričani?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Odjava bo izbrisala zasebni ključ in vse podatke v povezavi z aplikacijo Nautilus. Če zasebnega ključa niste shranili, ne boste imeli več dostopa do vašega računa."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Dokler imate shranjen zasebni ključ, ste lahko brez skrbi."),
        "manage": MessageLookupByLibrary.simpleMessage("Upravljaj"),
        "mantaError":
            MessageLookupByLibrary.simpleMessage("Couldn\'t Verify Request"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Ročni vnos"),
        "markAsPaid":
            MessageLookupByLibrary.simpleMessage("Označi kot plačano"),
        "markAsUnpaid":
            MessageLookupByLibrary.simpleMessage("Označi kot neplačano"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo ponovno poslana! Če še vedno ni potrjena, je naprava prejemnika morda brez povezave."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("Sporočilo kopirano"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Sporočilo"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Minimalni znesek za pošiljanje je% 1% 2"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("Pred minuto"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 ni veljavna beseda"),
        "mnemonicPhrase": MessageLookupByLibrary.simpleMessage("Besedna fraza"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Skrivni niz lahko vsebuje samo 24 besed"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Mesečni stroški strežnika"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("Več nastavitev"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Denarnica Nautilus"),
        "nearby": MessageLookupByLibrary.simpleMessage("V bližini"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "Ta funkcija zahteva daljšo zgodovino transakcij, da preprečite neželeno pošto.\n\nLahko pa prikažete tudi QR kodo, ki jo lahko nekdo skenira."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Potrebno preverjanje"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "To je vaš nov račun. Ko boste prejeli NANO, bodo transakcije prikazane takole:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Nova denarnica"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Next"),
        "no": MessageLookupByLibrary.simpleMessage("Ne"),
        "noContactsExport":
            MessageLookupByLibrary.simpleMessage("Ni stikov za izvoz."),
        "noContactsImport":
            MessageLookupByLibrary.simpleMessage("Ni novih stikov za uvoz."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("Ni rezultatov iskanja!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("No, Skip"),
        "noTXDataExport":
            MessageLookupByLibrary.simpleMessage("Ni transakcij za izvoz."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Stanje vozlišča"),
        "notSent": MessageLookupByLibrary.simpleMessage("ni poslano"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Odpri Nautilus za ogled transakcije"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Dotik za ogled"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "Da bi ta funkcija delovala pravilno, morajo biti omogočena obvestila"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Prejeto %1 NANO"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Obvestila onemogočena"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Zahtevki za plačilo, opombe in sporočila zahtevajo, da so obvestila omogočena, da lahko pravilno delujejo, saj za zagotavljanje dostave sporočil uporabljajo storitev obvestil FCM.\n\nObvestila lahko omogočite s spodnjim gumbom ali opustite to kartico, če ne želite uporabljati teh funkcij."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Zahtevki za plačilo, beležke in sporočila ne bodo delovali pravilno."),
        "notifications": MessageLookupByLibrary.simpleMessage("Opozorila"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "off": MessageLookupByLibrary.simpleMessage("Izklopi"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("Vklopi"),
        "onboard": MessageLookupByLibrary.simpleMessage("Povabi nekoga"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Na vkrcanje"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Odprto"),
        "paid": MessageLookupByLibrary.simpleMessage("plačan"),
        "paperWallet":
            MessageLookupByLibrary.simpleMessage("Papirna denarnica"),
        "passwordBlank":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "You will not need a password to open Nautilus anymore."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "This password will be required to open Nautilus."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "pay": MessageLookupByLibrary.simpleMessage("Plačajte"),
        "payRequest":
            MessageLookupByLibrary.simpleMessage("Plačajte to zahtevo"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Nekdo je od vas zahteval plačilo! preverite stran za plačila za več informacij."),
        "payments": MessageLookupByLibrary.simpleMessage("Plačila"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Izberi iz seznama"),
        "pinBlank":
            MessageLookupByLibrary.simpleMessage("Pin ne sme biti prazen"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("PIN se ne ujema"),
        "pinConfirmTitle": MessageLookupByLibrary.simpleMessage("Potrdi PIN"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Ustvari 6-mestni PIN"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Vnesite PIN"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("Neveljaven PIN"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Vnesite PIN za spremembo predstavnika."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Vnesite PIN za shranitev ključa"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Zatiči se ne ujemajo"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "To NI isti žebljiček, ki ste ga uporabili za ustvarjanje denarnice. Za več informacij pritisnite gumb info."),
        "plausibleInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Verjetne informacije o zanikanju"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Nastavite sekundarni pin za verjeten način zanikanja.\n\nČe je vaša denarnica odklenjena s tem sekundarnim zatičem, bo vaše seme nadomeščeno z zgoščeno vrednostjo obstoječega semena. To je varnostna funkcija, namenjena uporabi v primeru, da ste prisiljeni odpreti denarnico.\n\nTa zatič bo deloval kot običajen (pravilen) zatič, RAZEN pri odklepanju vaše denarnice, ko se bo aktiviral verjeten način zanikanja.\n\nVaša sredstva BODO IZGUBLJENA, ko vstopite v verjeten način zanikanja, če niste varnostno kopirali svojega semena!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Splošno"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Zasebnost"),
        "promotionalLink":
            MessageLookupByLibrary.simpleMessage("Brezplačni NANO"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Nakup Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid destination"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Please Grant Camera Permissions to scan QR Codes"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR koda ne vsebuje veljavnega zasebnega ključa"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR koda ne vsebuje veljavnega skrivnega niza"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Could not Read QR Code"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp":
            MessageLookupByLibrary.simpleMessage("Ocenite aplikacijo"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Surov ključ"),
        "readMore": MessageLookupByLibrary.simpleMessage("Preberi več"),
        "receivable": MessageLookupByLibrary.simpleMessage("terjatev"),
        "receive": MessageLookupByLibrary.simpleMessage("Prejmi"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Prejemanje minimalnega"),
        "receiveMinimumHeader": MessageLookupByLibrary.simpleMessage(
            "Prejemanje minimalnih informacij"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "Minimalni znesek za prejemanje. Če prejmete plačilo ali zahtevo z zneskom, manjšim od tega, bo to prezrto."),
        "received": MessageLookupByLibrary.simpleMessage("Prejeto"),
        "refund": MessageLookupByLibrary.simpleMessage("Vračilo"),
        "registerFor": MessageLookupByLibrary.simpleMessage("za"),
        "registerUsername": MessageLookupByLibrary.simpleMessage(
            "Registrirajte uporabniško ime"),
        "registerUsernameHeader": MessageLookupByLibrary.simpleMessage(
            "Registrirajte uporabniško ime"),
        "registering": MessageLookupByLibrary.simpleMessage("Registracija"),
        "remove": MessageLookupByLibrary.simpleMessage("Odstrani"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Ste prepričani, da hočete skriti ta račun? Lahko ga ponovno dodate kasneje s pritiskom na gumb \"%1\""),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Odblokiraj"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Ali ste prepričani, da želite odblokirati odblokiranje% 1?"),
        "removeContact": MessageLookupByLibrary.simpleMessage("Odstrani stik"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Ste prepričani, da hočete izbrisati %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Odstrani najljubše"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Predstavnik je račun, ki glasuje za konsenz omrežja. Moč glasovanja je odvisna od zneska na računu, kateremu lahko prispevate svoj znesek za povečanje teže. Vaš predstavnik ne more upravljati z vašim zneskom. Izberite predstavnika, ki je prisoten večino časa in je zaupanja vreden."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Kaj je predstavnik?"),
        "reply": MessageLookupByLibrary.simpleMessage("Odgovori"),
        "representatives": MessageLookupByLibrary.simpleMessage("Predstavniki"),
        "request": MessageLookupByLibrary.simpleMessage("Zahteva"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Zahtevite% 1% 2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Zahteva ni uspela: Zdi se, da ta uporabnik nima nameščenega Nautilusa ali da so obvestila onemogočena."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Zahtevaj od"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Zahtevajte plačilo"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Napaka pri pošiljanju zahteve za plačilo, prejemnikova naprava je morda brez povezave ali ni na voljo."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Zahteva ponovno poslana! Če še vedno ni potrjena, je naprava prejemnika morda brez povezave."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Zahtevajte plačilo s šifriranimi sporočili od konca do konca!\n\nZahtevke za plačilo, opombe in sporočila bodo lahko prejeli samo drugi uporabniki nautilusa, vendar jih lahko uporabite za lastno vodenje evidence, tudi če prejemnik ne uporablja nautilusa."),
        "requestSheetInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Zahtevaj informacije o listu"),
        "requested": MessageLookupByLibrary.simpleMessage("Zahtevano"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Zahtevano od"),
        "requesting": MessageLookupByLibrary.simpleMessage("Zahteva"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Require a password to open Nautilus?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Za prevzem darilne kartice zahtevajte CAPTCHA"),
        "resendMemo":
            MessageLookupByLibrary.simpleMessage("Ponovno pošljite to beležko"),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Ponastavite zbirko podatkov"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Ali ste prepričani, da želite ponastaviti notranjo bazo podatkov? \n\nTo lahko odpravi težave, povezane s posodabljanjem aplikacije, izbriše pa tudi vse shranjene nastavitve. To NE bo izbrisalo semena denarnice. Če imate težave, morate varnostno kopirati seme, znova namestiti aplikacijo in če težava še vedno obstaja, vas prosimo, da pripravite poročilo o napaki o githubu ali nesoglasju."),
        "retry": MessageLookupByLibrary.simpleMessage("Poskusite znova"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "It appears your device is \"rooted\", \"jailbroken\", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Zajemi Nano \nnaslov QR kodo"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("Pošlji prek NFC"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Zajemi QR kodo"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Poiščite karkoli"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Na naslednjem zaslonu boste videli vaš skrivni niz. Ta niz je geslo za dostop do vašega računa. Nujno je, da ga varno shranite in ne delite z nikomur."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Najprej varnost!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Skrivni niz"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Skrivni niz skopiran"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Kopiraj skrivni niz"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Če izgubite napravo ali odstranite aplikacijo, boste potrebovali vaš skrivni niz ali zasebni ključ za ponoven dostop do računa!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Varnost"),
        "seed": MessageLookupByLibrary.simpleMessage("Zasebni ključ"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Spodaj je prikazan zasebni ključ denarnice. Obvezno ga shranite, vendar nikoli v navadni tekstovni obliki ali s posnetkom zaslona."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Zasebni ključ skopiran\nMožno prilepiti v 2 minutah."),
        "seedCopiedShort":
            MessageLookupByLibrary.simpleMessage("Ključ skopiran"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Zasebni ključ vsebuje iste informacije kot skrivni niz, vendar v obliki, ki ga lahko bere naprava. Dokler imate vsaj enega od njiju varno shranjenega, boste imeli dostop do vašega računa."),
        "seedInvalid":
            MessageLookupByLibrary.simpleMessage("Zasebni ključ je neveljaven"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Ne morem zahtevati od sebe"),
        "send": MessageLookupByLibrary.simpleMessage("Pošlji"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Pošlji %1 NANO"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Pošlji zneske"),
        "sendError":
            MessageLookupByLibrary.simpleMessage("Napaka. Poskusite kasneje."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Pošlji iz"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Pošiljanje beležke s transakcijo ni uspelo, morda niso uporabnik Nautilusa."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Pošiljanje sporočila"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Ponovno pošlji zahtevo"),
        "sendRequests":
            MessageLookupByLibrary.simpleMessage("Pošiljanje zahtev"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Pošljite ali zahtevajte plačilo s šifriranimi sporočili od konca do konca!\n\nZahteve za plačilo, beležke in sporočila bodo terjali samo drugi uporabniki Nautilusa.\n\nZa pošiljanje ali prejemanje zahtevkov za plačilo vam ni treba imeti uporabniškega imena in jih lahko uporabite za lastno vodenje evidenc, tudi če ne uporabljajo nautilusa."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Pošlji informacije o listu"),
        "sending": MessageLookupByLibrary.simpleMessage("Pošiljam"),
        "sent": MessageLookupByLibrary.simpleMessage("Poslano"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Poslano"),
        "set": MessageLookupByLibrary.simpleMessage("Set"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Set Password"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Password has been set successfully"),
        "setPin": MessageLookupByLibrary.simpleMessage("Set Pin"),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage(
            "Pin je bil uspešno nastavljen"),
        "setPlausibleDeniabilityPin": MessageLookupByLibrary.simpleMessage(
            "Nastavite verjeten žebljiček"),
        "setRestoreHeight":
            MessageLookupByLibrary.simpleMessage("Nastavite višino obnovitve"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Set Wallet Password"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Nastavite višino obnovitve XMR"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Nastavitve"),
        "settingsTransfer": MessageLookupByLibrary.simpleMessage(
            "Naloži iz papirnate denarnice"),
        "share": MessageLookupByLibrary.simpleMessage("Deliti"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Delite povezavo"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("Deli sporočilo"),
        "shareNautilus": MessageLookupByLibrary.simpleMessage("Deli Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Preveri Nautilus! Uradna mobilna Nano denarnica!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Delite besedilo"),
        "show": MessageLookupByLibrary.simpleMessage("Prikaži"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Informacije o računu"),
        "showAccountQR":
            MessageLookupByLibrary.simpleMessage("Prikaži QR kodo računa"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Pokaži stike"),
        "showFunding":
            MessageLookupByLibrary.simpleMessage("Pokaži pasico financiranja"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Prikaži možnosti povezave"),
        "showLinkQR":
            MessageLookupByLibrary.simpleMessage("Prikaži povezavo QR"),
        "showMoneroHeader":
            MessageLookupByLibrary.simpleMessage("Prikaži Monero"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Omogoči razdelek Monero"),
        "showQR": MessageLookupByLibrary.simpleMessage("Prikaži kodo QR"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Neodprto opozorilo"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simpleks"),
        "social": MessageLookupByLibrary.simpleMessage("Socialno"),
        "someone": MessageLookupByLibrary.simpleMessage("nekdo"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Porabite NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Razdeljeni račun"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Razdeli račun"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Pošljite kup zahtevkov za plačilo hkrati! Poenostavi na primer razdelitev računa v restavraciji."),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Informacije o razdeljenem računu"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Razdeli po"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment":
            MessageLookupByLibrary.simpleMessage("Pomoč Podpora razvoju"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Podpora razvijalcu"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Zamenjaj XMR"),
        "swapXMRHeader":
            MessageLookupByLibrary.simpleMessage("Zamenjaj Monero"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero je kriptovaluta, osredotočena na zasebnost, zaradi katere je zelo težko ali celo nemogoče slediti transakcijam. Medtem je NANO kriptovaluta, osredotočena na plačila, ki je hitra in brez provizij. Skupaj zagotavljajo nekaj najbolj uporabnih vidikov kriptovalut!\n\nUporabite to stran za preprosto zamenjavo NANO za XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Zamenjava"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Preklopi na zasebni ključ"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Sistemski"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Tapnite sporočilo za urejanje"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Pritisnite za skrivanje"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Pritisnite za ogled"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Tema"),
        "to": MessageLookupByLibrary.simpleMessage("Na"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Preveč neuspešnih poizkusov."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Pooblastilo za sledenje"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Sledenje onemogočeno"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Funkcionalnost darilne kartice je lahko zmanjšana ali pa sploh ne deluje, če je sledenje onemogočeno. To dovoljenje uporabljamo IZKLJUČNO za to funkcijo. Popolnoma nobeni vaši podatki se ne prodajajo, zbirajo ali spremljajo v ozadju za namene, ki niso potrebni"),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Povezave do darilnih kartic ne bodo pravilno delovale"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transakcije"),
        "transfer": MessageLookupByLibrary.simpleMessage("Prenesi"),
        "transferClose":
            MessageLookupByLibrary.simpleMessage("Pritisni kjerkoli za izhod."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO uspešno prenešenih v vašo Nautilus denarnico.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Denarnica z zneskom %1 NANO je bila zaznana.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Pritisni za prenos zneska.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Prenos lahko traja nekaj sekund."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Napaka med prenosom. Poskusite kasneje."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Prenesi znesek"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Postopek bo prenesel znesek iz papirnate denarnice v vašo Nautilus denarnico.\n\nPritisnite \"%1\" gumb za začetek."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "Ta postopek bo prenesel sredstva iz papirnate denarnice v vašo Nautilus denarnico."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Prenašam"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Spodaj vnesite ključ."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Ključ ne vsebuje nobenega NANO zneska."),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "QR koda ne vsebuje veljavnega ključa."),
        "transferQrScanHint":
            MessageLookupByLibrary.simpleMessage("Zajemi Nano \nključ"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("nepriznano"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("nepotrjeno"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("neizpolnjena"),
        "unlock": MessageLookupByLibrary.simpleMessage("Odkleni"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Avtenticiraj za odklep Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Vnesite PIN za odklep Nautilus"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Pokaži neodprto opozorilo"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Pokažite opozorilo, ko pošiljate sredstva na neodprt račun. To je uporabno, ker imajo naslovi, na katere pošiljate, večinoma stanje, pošiljanje na nov naslov pa je lahko posledica tipkarske napake."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Ste prepričani, da je to pravi naslov?\nZdi se, da ta račun ni odprt\n\nTo opozorilo lahko onemogočite v predalu z nastavitvami pod \"Neodprto opozorilo\""),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Račun neodprt"),
        "unpaid": MessageLookupByLibrary.simpleMessage("neplačana"),
        "unread": MessageLookupByLibrary.simpleMessage("neprebrano"),
        "uptime": MessageLookupByLibrary.simpleMessage("prisotnost"),
        "useNano": MessageLookupByLibrary.simpleMessage("Uporabite NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError":
            MessageLookupByLibrary.simpleMessage("Uporabnik je že dodan!"),
        "userNotFound": MessageLookupByLibrary.simpleMessage(
            "Uporabnik ni bilo mogoče najti!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "Že imate registrirano uporabniško ime! Trenutno ni mogoče spremeniti uporabniškega imena, vendar lahko registrirate novega pod drugim naslovom."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Uporabniško ime na voljo!"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage(
            "Prosimo, vnesite uporabniško ime"),
        "usernameError":
            MessageLookupByLibrary.simpleMessage("Napaka uporabniškega imena"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Izberite edinstveno @username, da bi bilo enostavno za prijatelje in družino, da vas najdejo!\n\nUporabniško ime Nautilus globalno posodobi uporabniški vmesnik, da odraža vaš novi ročaj."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Neveljavno uporabniško ime"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Uporabniško ime na voljo"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Uporabniška imena Nautilus so centralizirana storitev, ki jo ponuja Nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("Uporaba"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Podrobnosti"),
        "viewTX": MessageLookupByLibrary.simpleMessage("Ogled transakcije"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("teža glasovanja"),
        "warning": MessageLookupByLibrary.simpleMessage("Opozorilo"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Račun je že dodan!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Račun samo za ogled"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Pošiljanje je onemogočeno na naslovih samo za gledanje"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("Pred enim tednom"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Dobrodošli v Nautilus. Za začetek ustvarite novo denarnico ali uvozite že obstoječo."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Dobrodošli v Nautilusu. Za začetek ustvarite novo denarnico ali uvozite obstoječo."),
        "withAddress": MessageLookupByLibrary.simpleMessage("Z naslovom"),
        "withFee": MessageLookupByLibrary.simpleMessage("S honorarjem"),
        "withMessage": MessageLookupByLibrary.simpleMessage("S sporočilom"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Po %1 minuti"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Po %1 minutah"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Povezovanje"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Napaka"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("nalaganje"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Sinhronizirano"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Sinhronizacija"),
        "yes": MessageLookupByLibrary.simpleMessage("Da"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Yes")
      };
}

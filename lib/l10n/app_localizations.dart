import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @settingsPageBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get settingsPageBackButton;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsPageDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsPageDarkMode;

  /// No description provided for @settingsPageLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsPageLightMode;

  /// No description provided for @settingsPageSystemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsPageSystemMode;

  /// No description provided for @settingsPageWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Some services are not configured; features may be limited.'**
  String get settingsPageWarningMessage;

  /// No description provided for @settingsPageGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsPageGeneralSection;

  /// No description provided for @settingsPageColorMode.
  ///
  /// In en, this message translates to:
  /// **'Color Mode'**
  String get settingsPageColorMode;

  /// No description provided for @settingsPageDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsPageDisplay;

  /// No description provided for @settingsPageDisplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance and text size'**
  String get settingsPageDisplaySubtitle;

  /// No description provided for @settingsPageAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get settingsPageAssistant;

  /// No description provided for @settingsPageAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default assistant and style'**
  String get settingsPageAssistantSubtitle;

  /// No description provided for @settingsPageModelsServicesSection.
  ///
  /// In en, this message translates to:
  /// **'Models & Services'**
  String get settingsPageModelsServicesSection;

  /// No description provided for @settingsPageDefaultModel.
  ///
  /// In en, this message translates to:
  /// **'Default Model'**
  String get settingsPageDefaultModel;

  /// No description provided for @settingsPageProviders.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get settingsPageProviders;

  /// No description provided for @settingsPageSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settingsPageSearch;

  /// No description provided for @settingsPageTts.
  ///
  /// In en, this message translates to:
  /// **'TTS'**
  String get settingsPageTts;

  /// No description provided for @settingsPageMcp.
  ///
  /// In en, this message translates to:
  /// **'MCP'**
  String get settingsPageMcp;

  /// No description provided for @settingsPageDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsPageDataSection;

  /// No description provided for @settingsPageBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsPageBackup;

  /// No description provided for @settingsPageChatStorage.
  ///
  /// In en, this message translates to:
  /// **'Chat Storage'**
  String get settingsPageChatStorage;

  /// No description provided for @settingsPageCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get settingsPageCalculating;

  /// No description provided for @settingsPageFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files · {size}'**
  String settingsPageFilesCount(int count, String size);

  /// No description provided for @settingsPageAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsPageAboutSection;

  /// No description provided for @settingsPageAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsPageAbout;

  /// No description provided for @settingsPageDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get settingsPageDocs;

  /// No description provided for @settingsPageSponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get settingsPageSponsor;

  /// No description provided for @settingsPageShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get settingsPageShare;

  /// No description provided for @languageDisplaySimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageDisplaySimplifiedChinese;

  /// No description provided for @languageDisplayEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageDisplayEnglish;

  /// No description provided for @languageDisplayTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageDisplayTraditionalChinese;

  /// No description provided for @languageDisplayJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageDisplayJapanese;

  /// No description provided for @languageDisplayKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageDisplayKorean;

  /// No description provided for @languageDisplayFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageDisplayFrench;

  /// No description provided for @languageDisplayGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageDisplayGerman;

  /// No description provided for @languageDisplayItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageDisplayItalian;

  /// No description provided for @languageSelectSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Translation Language'**
  String get languageSelectSheetTitle;

  /// No description provided for @languageSelectSheetClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Translation'**
  String get languageSelectSheetClearButton;

  /// No description provided for @homePageClearContext.
  ///
  /// In en, this message translates to:
  /// **'Clear Context'**
  String get homePageClearContext;

  /// No description provided for @homePageClearContextWithCount.
  ///
  /// In en, this message translates to:
  /// **'Clear Context ({actual}/{configured})'**
  String homePageClearContextWithCount(String actual, String configured);

  /// No description provided for @homePageDefaultAssistant.
  ///
  /// In en, this message translates to:
  /// **'Default Assistant'**
  String get homePageDefaultAssistant;

  /// No description provided for @homePageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get homePageDeleteMessage;

  /// No description provided for @homePageDeleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message? This cannot be undone.'**
  String get homePageDeleteMessageConfirm;

  /// No description provided for @homePageCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homePageCancel;

  /// No description provided for @homePageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homePageDelete;

  /// No description provided for @homePageSelectMessagesToShare.
  ///
  /// In en, this message translates to:
  /// **'Please select messages to share'**
  String get homePageSelectMessagesToShare;

  /// No description provided for @homePageDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homePageDone;

  /// No description provided for @assistantEditPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantEditPageTitle;

  /// No description provided for @assistantEditPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Assistant not found'**
  String get assistantEditPageNotFound;

  /// No description provided for @assistantEditPageBasicTab.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get assistantEditPageBasicTab;

  /// No description provided for @assistantEditPagePromptsTab.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get assistantEditPagePromptsTab;

  /// No description provided for @assistantEditPageMcpTab.
  ///
  /// In en, this message translates to:
  /// **'MCP'**
  String get assistantEditPageMcpTab;

  /// No description provided for @assistantEditPageCustomTab.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get assistantEditPageCustomTab;

  /// No description provided for @assistantEditCustomHeadersTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Headers'**
  String get assistantEditCustomHeadersTitle;

  /// No description provided for @assistantEditCustomHeadersAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Header'**
  String get assistantEditCustomHeadersAdd;

  /// No description provided for @assistantEditCustomHeadersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No headers added'**
  String get assistantEditCustomHeadersEmpty;

  /// No description provided for @assistantEditCustomBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Body'**
  String get assistantEditCustomBodyTitle;

  /// No description provided for @assistantEditCustomBodyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Body'**
  String get assistantEditCustomBodyAdd;

  /// No description provided for @assistantEditCustomBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No body items added'**
  String get assistantEditCustomBodyEmpty;

  /// No description provided for @assistantEditHeaderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Header Name'**
  String get assistantEditHeaderNameLabel;

  /// No description provided for @assistantEditHeaderValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Header Value'**
  String get assistantEditHeaderValueLabel;

  /// No description provided for @assistantEditBodyKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Key'**
  String get assistantEditBodyKeyLabel;

  /// No description provided for @assistantEditBodyValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Value (JSON)'**
  String get assistantEditBodyValueLabel;

  /// No description provided for @assistantEditDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assistantEditDeleteTooltip;

  /// No description provided for @assistantEditAssistantNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Assistant Name'**
  String get assistantEditAssistantNameLabel;

  /// No description provided for @assistantEditUseAssistantAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Assistant Avatar'**
  String get assistantEditUseAssistantAvatarTitle;

  /// No description provided for @assistantEditUseAssistantAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use assistant avatar/name instead of model'**
  String get assistantEditUseAssistantAvatarSubtitle;

  /// No description provided for @assistantEditChatModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Model'**
  String get assistantEditChatModelTitle;

  /// No description provided for @assistantEditChatModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default chat model for this assistant (fallback to global)'**
  String get assistantEditChatModelSubtitle;

  /// No description provided for @assistantEditTemperatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Controls randomness, range 0–2'**
  String get assistantEditTemperatureDescription;

  /// No description provided for @assistantEditTopPDescription.
  ///
  /// In en, this message translates to:
  /// **'Do not change unless you know what you are doing'**
  String get assistantEditTopPDescription;

  /// No description provided for @assistantEditParameterDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled (uses provider default)'**
  String get assistantEditParameterDisabled;

  /// No description provided for @assistantEditContextMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Context Messages'**
  String get assistantEditContextMessagesTitle;

  /// No description provided for @assistantEditContextMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'How many recent messages to keep in context'**
  String get assistantEditContextMessagesDescription;

  /// No description provided for @assistantEditStreamOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Stream Output'**
  String get assistantEditStreamOutputTitle;

  /// No description provided for @assistantEditStreamOutputDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable streaming responses'**
  String get assistantEditStreamOutputDescription;

  /// No description provided for @assistantEditThinkingBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking Budget'**
  String get assistantEditThinkingBudgetTitle;

  /// No description provided for @assistantEditConfigureButton.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get assistantEditConfigureButton;

  /// No description provided for @assistantEditMaxTokensTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get assistantEditMaxTokensTitle;

  /// No description provided for @assistantEditMaxTokensDescription.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for unlimited'**
  String get assistantEditMaxTokensDescription;

  /// No description provided for @assistantEditMaxTokensHint.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get assistantEditMaxTokensHint;

  /// No description provided for @assistantEditChatBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Background'**
  String get assistantEditChatBackgroundTitle;

  /// No description provided for @assistantEditChatBackgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a background image for this assistant'**
  String get assistantEditChatBackgroundDescription;

  /// No description provided for @assistantEditChooseImageButton.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get assistantEditChooseImageButton;

  /// No description provided for @assistantEditClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get assistantEditClearButton;

  /// No description provided for @assistantEditAvatarChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get assistantEditAvatarChooseImage;

  /// No description provided for @assistantEditAvatarChooseEmoji.
  ///
  /// In en, this message translates to:
  /// **'Choose Emoji'**
  String get assistantEditAvatarChooseEmoji;

  /// No description provided for @assistantEditAvatarEnterLink.
  ///
  /// In en, this message translates to:
  /// **'Enter Link'**
  String get assistantEditAvatarEnterLink;

  /// No description provided for @assistantEditAvatarImportQQ.
  ///
  /// In en, this message translates to:
  /// **'Import from QQ'**
  String get assistantEditAvatarImportQQ;

  /// No description provided for @assistantEditAvatarReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get assistantEditAvatarReset;

  /// No description provided for @assistantEditEmojiDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Emoji'**
  String get assistantEditEmojiDialogTitle;

  /// No description provided for @assistantEditEmojiDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste any emoji'**
  String get assistantEditEmojiDialogHint;

  /// No description provided for @assistantEditEmojiDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assistantEditEmojiDialogCancel;

  /// No description provided for @assistantEditEmojiDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get assistantEditEmojiDialogSave;

  /// No description provided for @assistantEditImageUrlDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Image URL'**
  String get assistantEditImageUrlDialogTitle;

  /// No description provided for @assistantEditImageUrlDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. https://example.com/avatar.png'**
  String get assistantEditImageUrlDialogHint;

  /// No description provided for @assistantEditImageUrlDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assistantEditImageUrlDialogCancel;

  /// No description provided for @assistantEditImageUrlDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get assistantEditImageUrlDialogSave;

  /// No description provided for @assistantEditQQAvatarDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from QQ'**
  String get assistantEditQQAvatarDialogTitle;

  /// No description provided for @assistantEditQQAvatarDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter QQ number (5-12 digits)'**
  String get assistantEditQQAvatarDialogHint;

  /// No description provided for @assistantEditQQAvatarRandomButton.
  ///
  /// In en, this message translates to:
  /// **'Random One'**
  String get assistantEditQQAvatarRandomButton;

  /// No description provided for @assistantEditQQAvatarFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch random QQ avatar. Please try again.'**
  String get assistantEditQQAvatarFailedMessage;

  /// No description provided for @assistantEditQQAvatarDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assistantEditQQAvatarDialogCancel;

  /// No description provided for @assistantEditQQAvatarDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get assistantEditQQAvatarDialogSave;

  /// No description provided for @assistantEditGalleryErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to open gallery. Try entering an image URL.'**
  String get assistantEditGalleryErrorMessage;

  /// No description provided for @assistantEditGeneralErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try entering an image URL.'**
  String get assistantEditGeneralErrorMessage;

  /// No description provided for @assistantEditSystemPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get assistantEditSystemPromptTitle;

  /// No description provided for @assistantEditSystemPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter system prompt…'**
  String get assistantEditSystemPromptHint;

  /// No description provided for @assistantEditAvailableVariables.
  ///
  /// In en, this message translates to:
  /// **'Available variables:'**
  String get assistantEditAvailableVariables;

  /// No description provided for @assistantEditVariableDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get assistantEditVariableDate;

  /// No description provided for @assistantEditVariableTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get assistantEditVariableTime;

  /// No description provided for @assistantEditVariableDatetime.
  ///
  /// In en, this message translates to:
  /// **'Datetime'**
  String get assistantEditVariableDatetime;

  /// No description provided for @assistantEditVariableModelId.
  ///
  /// In en, this message translates to:
  /// **'Model ID'**
  String get assistantEditVariableModelId;

  /// No description provided for @assistantEditVariableModelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get assistantEditVariableModelName;

  /// No description provided for @assistantEditVariableLocale.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get assistantEditVariableLocale;

  /// No description provided for @assistantEditVariableTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get assistantEditVariableTimezone;

  /// No description provided for @assistantEditVariableSystemVersion.
  ///
  /// In en, this message translates to:
  /// **'System Version'**
  String get assistantEditVariableSystemVersion;

  /// No description provided for @assistantEditVariableDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get assistantEditVariableDeviceInfo;

  /// No description provided for @assistantEditVariableBatteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get assistantEditVariableBatteryLevel;

  /// No description provided for @assistantEditVariableNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get assistantEditVariableNickname;

  /// No description provided for @assistantEditMessageTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Template'**
  String get assistantEditMessageTemplateTitle;

  /// No description provided for @assistantEditVariableRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get assistantEditVariableRole;

  /// No description provided for @assistantEditVariableMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get assistantEditVariableMessage;

  /// No description provided for @assistantEditPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get assistantEditPreviewTitle;

  /// No description provided for @assistantEditSampleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get assistantEditSampleUser;

  /// No description provided for @assistantEditSampleMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello there'**
  String get assistantEditSampleMessage;

  /// No description provided for @assistantEditSampleReply.
  ///
  /// In en, this message translates to:
  /// **'Hello, how can I help you?'**
  String get assistantEditSampleReply;

  /// No description provided for @assistantEditMcpNoServersMessage.
  ///
  /// In en, this message translates to:
  /// **'No running MCP servers'**
  String get assistantEditMcpNoServersMessage;

  /// No description provided for @assistantEditMcpConnectedTag.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get assistantEditMcpConnectedTag;

  /// No description provided for @assistantEditMcpToolsCountTag.
  ///
  /// In en, this message translates to:
  /// **'Tools: {enabled}/{total}'**
  String assistantEditMcpToolsCountTag(String enabled, String total);

  /// No description provided for @assistantEditModelUseGlobalDefault.
  ///
  /// In en, this message translates to:
  /// **'Use global default'**
  String get assistantEditModelUseGlobalDefault;

  /// No description provided for @assistantSettingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant Settings'**
  String get assistantSettingsPageTitle;

  /// No description provided for @assistantSettingsDefaultTag.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get assistantSettingsDefaultTag;

  /// No description provided for @assistantSettingsDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assistantSettingsDeleteButton;

  /// No description provided for @assistantSettingsEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get assistantSettingsEditButton;

  /// No description provided for @assistantSettingsAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant Name'**
  String get assistantSettingsAddSheetTitle;

  /// No description provided for @assistantSettingsAddSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get assistantSettingsAddSheetHint;

  /// No description provided for @assistantSettingsAddSheetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assistantSettingsAddSheetCancel;

  /// No description provided for @assistantSettingsAddSheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get assistantSettingsAddSheetSave;

  /// No description provided for @assistantSettingsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Assistant'**
  String get assistantSettingsDeleteDialogTitle;

  /// No description provided for @assistantSettingsDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this assistant? This action cannot be undone.'**
  String get assistantSettingsDeleteDialogContent;

  /// No description provided for @assistantSettingsDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assistantSettingsDeleteDialogCancel;

  /// No description provided for @assistantSettingsDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assistantSettingsDeleteDialogConfirm;

  /// No description provided for @mcpAssistantSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get mcpAssistantSheetTitle;

  /// No description provided for @mcpAssistantSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Servers enabled for this assistant'**
  String get mcpAssistantSheetSubtitle;

  /// No description provided for @mcpAssistantSheetSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get mcpAssistantSheetSelectAll;

  /// No description provided for @mcpAssistantSheetClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mcpAssistantSheetClearAll;

  /// No description provided for @backupPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupPageTitle;

  /// No description provided for @backupPageWebDavTab.
  ///
  /// In en, this message translates to:
  /// **'WebDAV'**
  String get backupPageWebDavTab;

  /// No description provided for @backupPageImportExportTab.
  ///
  /// In en, this message translates to:
  /// **'Import/Export'**
  String get backupPageImportExportTab;

  /// No description provided for @backupPageWebDavServerUrl.
  ///
  /// In en, this message translates to:
  /// **'WebDAV Server URL'**
  String get backupPageWebDavServerUrl;

  /// No description provided for @backupPageUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get backupPageUsername;

  /// No description provided for @backupPagePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupPagePassword;

  /// No description provided for @backupPagePath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get backupPagePath;

  /// No description provided for @backupPageChatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get backupPageChatsLabel;

  /// No description provided for @backupPageFilesLabel.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get backupPageFilesLabel;

  /// No description provided for @backupPageTestDone.
  ///
  /// In en, this message translates to:
  /// **'Test done'**
  String get backupPageTestDone;

  /// No description provided for @backupPageTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get backupPageTestConnection;

  /// No description provided for @backupPageRestartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get backupPageRestartRequired;

  /// No description provided for @backupPageRestartContent.
  ///
  /// In en, this message translates to:
  /// **'Restore completed. Please restart the app.'**
  String get backupPageRestartContent;

  /// No description provided for @backupPageOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get backupPageOK;

  /// No description provided for @backupPageRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupPageRestore;

  /// No description provided for @backupPageBackupUploaded.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded'**
  String get backupPageBackupUploaded;

  /// No description provided for @backupPageBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupPageBackup;

  /// No description provided for @backupPageExportToFile.
  ///
  /// In en, this message translates to:
  /// **'Export to File'**
  String get backupPageExportToFile;

  /// No description provided for @backupPageExportToFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export app data to a file'**
  String get backupPageExportToFileSubtitle;

  /// No description provided for @backupPageImportBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Import Backup File'**
  String get backupPageImportBackupFile;

  /// No description provided for @backupPageImportBackupFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a local backup file'**
  String get backupPageImportBackupFileSubtitle;

  /// No description provided for @backupPageImportFromOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Import from Other Apps'**
  String get backupPageImportFromOtherApps;

  /// No description provided for @backupPageImportFromRikkaHub.
  ///
  /// In en, this message translates to:
  /// **'Import from RikkaHub'**
  String get backupPageImportFromRikkaHub;

  /// No description provided for @backupPageNotSupportedYet.
  ///
  /// In en, this message translates to:
  /// **'Not supported yet'**
  String get backupPageNotSupportedYet;

  /// No description provided for @backupPageRemoteBackups.
  ///
  /// In en, this message translates to:
  /// **'Remote Backups'**
  String get backupPageRemoteBackups;

  /// No description provided for @backupPageNoBackups.
  ///
  /// In en, this message translates to:
  /// **'No backups'**
  String get backupPageNoBackups;

  /// No description provided for @backupPageRestoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupPageRestoreTooltip;

  /// No description provided for @backupPageDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get backupPageDeleteTooltip;

  /// No description provided for @chatHistoryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistoryPageTitle;

  /// No description provided for @chatHistoryPageSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chatHistoryPageSearchTooltip;

  /// No description provided for @chatHistoryPageDeleteAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get chatHistoryPageDeleteAllTooltip;

  /// No description provided for @chatHistoryPageDeleteAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Conversations'**
  String get chatHistoryPageDeleteAllDialogTitle;

  /// No description provided for @chatHistoryPageDeleteAllDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all conversations? This cannot be undone.'**
  String get chatHistoryPageDeleteAllDialogContent;

  /// No description provided for @chatHistoryPageCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatHistoryPageCancel;

  /// No description provided for @chatHistoryPageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatHistoryPageDelete;

  /// No description provided for @chatHistoryPageDeletedAllSnackbar.
  ///
  /// In en, this message translates to:
  /// **'All conversations deleted'**
  String get chatHistoryPageDeletedAllSnackbar;

  /// No description provided for @chatHistoryPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get chatHistoryPageSearchHint;

  /// No description provided for @chatHistoryPageNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get chatHistoryPageNoConversations;

  /// No description provided for @chatHistoryPagePinnedSection.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get chatHistoryPagePinnedSection;

  /// No description provided for @chatHistoryPagePin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get chatHistoryPagePin;

  /// No description provided for @chatHistoryPagePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get chatHistoryPagePinned;

  /// No description provided for @messageEditPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get messageEditPageTitle;

  /// No description provided for @messageEditPageSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get messageEditPageSave;

  /// No description provided for @messageEditPageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter message…'**
  String get messageEditPageHint;

  /// No description provided for @selectCopyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select & Copy'**
  String get selectCopyPageTitle;

  /// No description provided for @selectCopyPageCopyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get selectCopyPageCopyAll;

  /// No description provided for @selectCopyPageCopiedAll.
  ///
  /// In en, this message translates to:
  /// **'Copied all'**
  String get selectCopyPageCopiedAll;

  /// No description provided for @bottomToolsSheetCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get bottomToolsSheetCamera;

  /// No description provided for @bottomToolsSheetPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get bottomToolsSheetPhotos;

  /// No description provided for @bottomToolsSheetUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get bottomToolsSheetUpload;

  /// No description provided for @bottomToolsSheetClearContext.
  ///
  /// In en, this message translates to:
  /// **'Clear Context'**
  String get bottomToolsSheetClearContext;

  /// No description provided for @bottomToolsSheetLearningMode.
  ///
  /// In en, this message translates to:
  /// **'Learning Mode'**
  String get bottomToolsSheetLearningMode;

  /// No description provided for @bottomToolsSheetLearningModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Help you learn step by step'**
  String get bottomToolsSheetLearningModeDescription;

  /// No description provided for @bottomToolsSheetConfigurePrompt.
  ///
  /// In en, this message translates to:
  /// **'Configure prompt'**
  String get bottomToolsSheetConfigurePrompt;

  /// No description provided for @bottomToolsSheetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get bottomToolsSheetPrompt;

  /// No description provided for @bottomToolsSheetPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt for learning mode'**
  String get bottomToolsSheetPromptHint;

  /// No description provided for @bottomToolsSheetResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get bottomToolsSheetResetDefault;

  /// No description provided for @bottomToolsSheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get bottomToolsSheetSave;

  /// No description provided for @messageMoreSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'More Actions'**
  String get messageMoreSheetTitle;

  /// No description provided for @messageMoreSheetSelectCopy.
  ///
  /// In en, this message translates to:
  /// **'Select & Copy'**
  String get messageMoreSheetSelectCopy;

  /// No description provided for @messageMoreSheetRenderWebView.
  ///
  /// In en, this message translates to:
  /// **'Render Web View'**
  String get messageMoreSheetRenderWebView;

  /// No description provided for @messageMoreSheetNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not yet implemented'**
  String get messageMoreSheetNotImplemented;

  /// No description provided for @messageMoreSheetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get messageMoreSheetEdit;

  /// No description provided for @messageMoreSheetShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get messageMoreSheetShare;

  /// No description provided for @messageMoreSheetCreateBranch.
  ///
  /// In en, this message translates to:
  /// **'Create Branch'**
  String get messageMoreSheetCreateBranch;

  /// No description provided for @messageMoreSheetDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get messageMoreSheetDelete;

  /// No description provided for @reasoningBudgetSheetOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reasoningBudgetSheetOff;

  /// No description provided for @reasoningBudgetSheetAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get reasoningBudgetSheetAuto;

  /// No description provided for @reasoningBudgetSheetLight.
  ///
  /// In en, this message translates to:
  /// **'Light Reasoning'**
  String get reasoningBudgetSheetLight;

  /// No description provided for @reasoningBudgetSheetMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Reasoning'**
  String get reasoningBudgetSheetMedium;

  /// No description provided for @reasoningBudgetSheetHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy Reasoning'**
  String get reasoningBudgetSheetHeavy;

  /// No description provided for @reasoningBudgetSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reasoning Chain Strength'**
  String get reasoningBudgetSheetTitle;

  /// No description provided for @reasoningBudgetSheetCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level: {level}'**
  String reasoningBudgetSheetCurrentLevel(String level);

  /// No description provided for @reasoningBudgetSheetOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off reasoning, answer directly'**
  String get reasoningBudgetSheetOffSubtitle;

  /// No description provided for @reasoningBudgetSheetAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let the model decide reasoning level automatically'**
  String get reasoningBudgetSheetAutoSubtitle;

  /// No description provided for @reasoningBudgetSheetLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use light reasoning to answer questions'**
  String get reasoningBudgetSheetLightSubtitle;

  /// No description provided for @reasoningBudgetSheetMediumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use moderate reasoning to answer questions'**
  String get reasoningBudgetSheetMediumSubtitle;

  /// No description provided for @reasoningBudgetSheetHeavySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use heavy reasoning for complex questions'**
  String get reasoningBudgetSheetHeavySubtitle;

  /// No description provided for @reasoningBudgetSheetCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Reasoning Budget (tokens)'**
  String get reasoningBudgetSheetCustomLabel;

  /// No description provided for @reasoningBudgetSheetCustomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2048 (-1 auto, 0 off)'**
  String get reasoningBudgetSheetCustomHint;

  /// No description provided for @chatMessageWidgetFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found: {fileName}'**
  String chatMessageWidgetFileNotFound(String fileName);

  /// No description provided for @chatMessageWidgetCannotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot open file: {message}'**
  String chatMessageWidgetCannotOpenFile(String message);

  /// No description provided for @chatMessageWidgetOpenFileError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open file: {error}'**
  String chatMessageWidgetOpenFileError(String error);

  /// No description provided for @chatMessageWidgetCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get chatMessageWidgetCopiedToClipboard;

  /// No description provided for @chatMessageWidgetResendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get chatMessageWidgetResendTooltip;

  /// No description provided for @chatMessageWidgetMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get chatMessageWidgetMoreTooltip;

  /// No description provided for @chatMessageWidgetThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get chatMessageWidgetThinking;

  /// No description provided for @chatMessageWidgetTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get chatMessageWidgetTranslation;

  /// No description provided for @chatMessageWidgetTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get chatMessageWidgetTranslating;

  /// No description provided for @chatMessageWidgetCitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Citation source not found'**
  String get chatMessageWidgetCitationNotFound;

  /// No description provided for @chatMessageWidgetCannotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Cannot open link: {url}'**
  String chatMessageWidgetCannotOpenUrl(String url);

  /// No description provided for @chatMessageWidgetOpenLinkError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open link'**
  String get chatMessageWidgetOpenLinkError;

  /// No description provided for @chatMessageWidgetCitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Citations ({count})'**
  String chatMessageWidgetCitationsTitle(int count);

  /// No description provided for @chatMessageWidgetRegenerateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get chatMessageWidgetRegenerateTooltip;

  /// No description provided for @chatMessageWidgetStopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chatMessageWidgetStopTooltip;

  /// No description provided for @chatMessageWidgetSpeakTooltip.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get chatMessageWidgetSpeakTooltip;

  /// No description provided for @chatMessageWidgetTranslateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get chatMessageWidgetTranslateTooltip;

  /// No description provided for @chatMessageWidgetBuiltinSearchHideNote.
  ///
  /// In en, this message translates to:
  /// **'Hide builtin search tool cards'**
  String get chatMessageWidgetBuiltinSearchHideNote;

  /// No description provided for @chatMessageWidgetDeepThinking.
  ///
  /// In en, this message translates to:
  /// **'Deep Thinking'**
  String get chatMessageWidgetDeepThinking;

  /// No description provided for @chatMessageWidgetCreateMemory.
  ///
  /// In en, this message translates to:
  /// **'Create Memory'**
  String get chatMessageWidgetCreateMemory;

  /// No description provided for @chatMessageWidgetEditMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get chatMessageWidgetEditMemory;

  /// No description provided for @chatMessageWidgetDeleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete Memory'**
  String get chatMessageWidgetDeleteMemory;

  /// No description provided for @chatMessageWidgetWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Web Search: {query}'**
  String chatMessageWidgetWebSearch(String query);

  /// No description provided for @chatMessageWidgetBuiltinSearch.
  ///
  /// In en, this message translates to:
  /// **'Built-in Search'**
  String get chatMessageWidgetBuiltinSearch;

  /// No description provided for @chatMessageWidgetToolCall.
  ///
  /// In en, this message translates to:
  /// **'Tool Call: {name}'**
  String chatMessageWidgetToolCall(String name);

  /// No description provided for @chatMessageWidgetToolResult.
  ///
  /// In en, this message translates to:
  /// **'Tool Result: {name}'**
  String chatMessageWidgetToolResult(String name);

  /// No description provided for @chatMessageWidgetNoResultYet.
  ///
  /// In en, this message translates to:
  /// **'(No result yet)'**
  String get chatMessageWidgetNoResultYet;

  /// No description provided for @chatMessageWidgetArguments.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get chatMessageWidgetArguments;

  /// No description provided for @chatMessageWidgetResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get chatMessageWidgetResult;

  /// No description provided for @chatMessageWidgetCitationsCount.
  ///
  /// In en, this message translates to:
  /// **'Citations ({count})'**
  String chatMessageWidgetCitationsCount(int count);

  /// No description provided for @messageExportSheetAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get messageExportSheetAssistant;

  /// No description provided for @messageExportSheetDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get messageExportSheetDefaultTitle;

  /// No description provided for @messageExportSheetExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get messageExportSheetExporting;

  /// No description provided for @messageExportSheetExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String messageExportSheetExportFailed(String error);

  /// No description provided for @messageExportSheetExportedAs.
  ///
  /// In en, this message translates to:
  /// **'Exported as {filename}'**
  String messageExportSheetExportedAs(String filename);

  /// No description provided for @messageExportSheetFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get messageExportSheetFormatTitle;

  /// No description provided for @messageExportSheetMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get messageExportSheetMarkdown;

  /// No description provided for @messageExportSheetSingleMarkdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export this message as a Markdown file'**
  String get messageExportSheetSingleMarkdownSubtitle;

  /// No description provided for @messageExportSheetBatchMarkdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export selected messages as a Markdown file'**
  String get messageExportSheetBatchMarkdownSubtitle;

  /// No description provided for @messageExportSheetExportImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get messageExportSheetExportImage;

  /// No description provided for @messageExportSheetSingleExportImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Render this message to a PNG image'**
  String get messageExportSheetSingleExportImageSubtitle;

  /// No description provided for @messageExportSheetBatchExportImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Render selected messages to a PNG image'**
  String get messageExportSheetBatchExportImageSubtitle;

  /// No description provided for @messageExportSheetDateTimeWithSecondsPattern.
  ///
  /// In en, this message translates to:
  /// **'yyyy-MM-dd HH:mm:ss'**
  String get messageExportSheetDateTimeWithSecondsPattern;

  /// No description provided for @sideDrawerMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get sideDrawerMenuRename;

  /// No description provided for @sideDrawerMenuPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get sideDrawerMenuPin;

  /// No description provided for @sideDrawerMenuUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get sideDrawerMenuUnpin;

  /// No description provided for @sideDrawerMenuRegenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Title'**
  String get sideDrawerMenuRegenerateTitle;

  /// No description provided for @sideDrawerMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sideDrawerMenuDelete;

  /// No description provided for @sideDrawerDeleteSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\"'**
  String sideDrawerDeleteSnackbar(String title);

  /// No description provided for @sideDrawerRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get sideDrawerRenameHint;

  /// No description provided for @sideDrawerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sideDrawerCancel;

  /// No description provided for @sideDrawerOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sideDrawerOK;

  /// No description provided for @sideDrawerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get sideDrawerSave;

  /// No description provided for @sideDrawerGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get sideDrawerGreetingMorning;

  /// No description provided for @sideDrawerGreetingNoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 👋'**
  String get sideDrawerGreetingNoon;

  /// No description provided for @sideDrawerGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 👋'**
  String get sideDrawerGreetingAfternoon;

  /// No description provided for @sideDrawerGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 👋'**
  String get sideDrawerGreetingEvening;

  /// No description provided for @sideDrawerDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sideDrawerDateToday;

  /// No description provided for @sideDrawerDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get sideDrawerDateYesterday;

  /// No description provided for @sideDrawerDateShortPattern.
  ///
  /// In en, this message translates to:
  /// **'MMM d'**
  String get sideDrawerDateShortPattern;

  /// No description provided for @sideDrawerDateFullPattern.
  ///
  /// In en, this message translates to:
  /// **'MMM d, yyyy'**
  String get sideDrawerDateFullPattern;

  /// No description provided for @sideDrawerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chat history'**
  String get sideDrawerSearchHint;

  /// No description provided for @sideDrawerUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'New version: {version}'**
  String sideDrawerUpdateTitle(String version);

  /// No description provided for @sideDrawerUpdateTitleWithBuild.
  ///
  /// In en, this message translates to:
  /// **'New version: {version} ({build})'**
  String sideDrawerUpdateTitleWithBuild(String version, int build);

  /// No description provided for @sideDrawerLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get sideDrawerLinkCopied;

  /// No description provided for @sideDrawerPinnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get sideDrawerPinnedLabel;

  /// No description provided for @sideDrawerHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sideDrawerHistory;

  /// No description provided for @sideDrawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sideDrawerSettings;

  /// No description provided for @sideDrawerChooseAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Assistant'**
  String get sideDrawerChooseAssistantTitle;

  /// No description provided for @sideDrawerChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get sideDrawerChooseImage;

  /// No description provided for @sideDrawerChooseEmoji.
  ///
  /// In en, this message translates to:
  /// **'Choose Emoji'**
  String get sideDrawerChooseEmoji;

  /// No description provided for @sideDrawerEnterLink.
  ///
  /// In en, this message translates to:
  /// **'Enter Link'**
  String get sideDrawerEnterLink;

  /// No description provided for @sideDrawerImportFromQQ.
  ///
  /// In en, this message translates to:
  /// **'Import from QQ'**
  String get sideDrawerImportFromQQ;

  /// No description provided for @sideDrawerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get sideDrawerReset;

  /// No description provided for @sideDrawerEmojiDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Emoji'**
  String get sideDrawerEmojiDialogTitle;

  /// No description provided for @sideDrawerEmojiDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste any emoji'**
  String get sideDrawerEmojiDialogHint;

  /// No description provided for @sideDrawerImageUrlDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Image URL'**
  String get sideDrawerImageUrlDialogTitle;

  /// No description provided for @sideDrawerImageUrlDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. https://example.com/avatar.png'**
  String get sideDrawerImageUrlDialogHint;

  /// No description provided for @sideDrawerQQAvatarDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from QQ'**
  String get sideDrawerQQAvatarDialogTitle;

  /// No description provided for @sideDrawerQQAvatarInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter QQ number (5-12 digits)'**
  String get sideDrawerQQAvatarInputHint;

  /// No description provided for @sideDrawerQQAvatarFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch random QQ avatar. Please try again.'**
  String get sideDrawerQQAvatarFetchFailed;

  /// No description provided for @sideDrawerRandomQQ.
  ///
  /// In en, this message translates to:
  /// **'Random QQ'**
  String get sideDrawerRandomQQ;

  /// No description provided for @sideDrawerGalleryOpenError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open gallery. Try entering an image URL.'**
  String get sideDrawerGalleryOpenError;

  /// No description provided for @sideDrawerGeneralImageError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try entering an image URL.'**
  String get sideDrawerGeneralImageError;

  /// No description provided for @sideDrawerSetNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Nickname'**
  String get sideDrawerSetNicknameTitle;

  /// No description provided for @sideDrawerNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get sideDrawerNicknameLabel;

  /// No description provided for @sideDrawerNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new nickname'**
  String get sideDrawerNicknameHint;

  /// No description provided for @sideDrawerRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get sideDrawerRename;

  /// No description provided for @chatInputBarHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message for AI'**
  String get chatInputBarHint;

  /// No description provided for @chatInputBarSelectModelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get chatInputBarSelectModelTooltip;

  /// No description provided for @chatInputBarOnlineSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Online Search'**
  String get chatInputBarOnlineSearchTooltip;

  /// No description provided for @chatInputBarReasoningStrengthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reasoning Strength'**
  String get chatInputBarReasoningStrengthTooltip;

  /// No description provided for @chatInputBarMcpServersTooltip.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get chatInputBarMcpServersTooltip;

  /// No description provided for @chatInputBarMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get chatInputBarMoreTooltip;

  /// No description provided for @mcpPageBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mcpPageBackTooltip;

  /// No description provided for @mcpPageAddMcpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add MCP'**
  String get mcpPageAddMcpTooltip;

  /// No description provided for @mcpPageNoServers.
  ///
  /// In en, this message translates to:
  /// **'No MCP servers'**
  String get mcpPageNoServers;

  /// No description provided for @mcpPageErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get mcpPageErrorDialogTitle;

  /// No description provided for @mcpPageErrorNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No details'**
  String get mcpPageErrorNoDetails;

  /// No description provided for @mcpPageClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mcpPageClose;

  /// No description provided for @mcpPageReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get mcpPageReconnect;

  /// No description provided for @mcpPageStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get mcpPageStatusConnected;

  /// No description provided for @mcpPageStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get mcpPageStatusConnecting;

  /// No description provided for @mcpPageStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get mcpPageStatusDisconnected;

  /// No description provided for @mcpPageStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get mcpPageStatusDisabled;

  /// No description provided for @mcpPageToolsCount.
  ///
  /// In en, this message translates to:
  /// **'Tools: {enabled}/{total}'**
  String mcpPageToolsCount(int enabled, int total);

  /// No description provided for @mcpPageConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get mcpPageConnectionFailed;

  /// No description provided for @mcpPageDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get mcpPageDetails;

  /// No description provided for @mcpPageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mcpPageDelete;

  /// No description provided for @mcpPageConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get mcpPageConfirmDeleteTitle;

  /// No description provided for @mcpPageConfirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This can be undone via Undo. Delete?'**
  String get mcpPageConfirmDeleteContent;

  /// No description provided for @mcpPageServerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Server deleted'**
  String get mcpPageServerDeleted;

  /// No description provided for @mcpPageUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get mcpPageUndo;

  /// No description provided for @mcpPageCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mcpPageCancel;

  /// No description provided for @mcpConversationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get mcpConversationSheetTitle;

  /// No description provided for @mcpConversationSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select servers enabled for this conversation'**
  String get mcpConversationSheetSubtitle;

  /// No description provided for @mcpConversationSheetSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get mcpConversationSheetSelectAll;

  /// No description provided for @mcpConversationSheetClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mcpConversationSheetClearAll;

  /// No description provided for @mcpConversationSheetNoRunning.
  ///
  /// In en, this message translates to:
  /// **'No running MCP servers'**
  String get mcpConversationSheetNoRunning;

  /// No description provided for @mcpConversationSheetConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get mcpConversationSheetConnected;

  /// No description provided for @mcpConversationSheetToolsCount.
  ///
  /// In en, this message translates to:
  /// **'Tools: {enabled}/{total}'**
  String mcpConversationSheetToolsCount(int enabled, int total);

  /// No description provided for @mcpServerEditSheetEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get mcpServerEditSheetEnabledLabel;

  /// No description provided for @mcpServerEditSheetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mcpServerEditSheetNameLabel;

  /// No description provided for @mcpServerEditSheetTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get mcpServerEditSheetTransportLabel;

  /// No description provided for @mcpServerEditSheetSseRetryHint.
  ///
  /// In en, this message translates to:
  /// **'If SSE fails, try a few times'**
  String get mcpServerEditSheetSseRetryHint;

  /// No description provided for @mcpServerEditSheetUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get mcpServerEditSheetUrlLabel;

  /// No description provided for @mcpServerEditSheetCustomHeadersTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Headers'**
  String get mcpServerEditSheetCustomHeadersTitle;

  /// No description provided for @mcpServerEditSheetHeaderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Header Name'**
  String get mcpServerEditSheetHeaderNameLabel;

  /// No description provided for @mcpServerEditSheetHeaderNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Authorization'**
  String get mcpServerEditSheetHeaderNameHint;

  /// No description provided for @mcpServerEditSheetHeaderValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Header Value'**
  String get mcpServerEditSheetHeaderValueLabel;

  /// No description provided for @mcpServerEditSheetHeaderValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bearer xxxxxx'**
  String get mcpServerEditSheetHeaderValueHint;

  /// No description provided for @mcpServerEditSheetRemoveHeaderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mcpServerEditSheetRemoveHeaderTooltip;

  /// No description provided for @mcpServerEditSheetAddHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Header'**
  String get mcpServerEditSheetAddHeader;

  /// No description provided for @mcpServerEditSheetTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit MCP'**
  String get mcpServerEditSheetTitleEdit;

  /// No description provided for @mcpServerEditSheetTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add MCP'**
  String get mcpServerEditSheetTitleAdd;

  /// No description provided for @mcpServerEditSheetSyncToolsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync Tools'**
  String get mcpServerEditSheetSyncToolsTooltip;

  /// No description provided for @mcpServerEditSheetTabBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get mcpServerEditSheetTabBasic;

  /// No description provided for @mcpServerEditSheetTabTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get mcpServerEditSheetTabTools;

  /// No description provided for @mcpServerEditSheetNoToolsHint.
  ///
  /// In en, this message translates to:
  /// **'No tools, tap refresh to sync'**
  String get mcpServerEditSheetNoToolsHint;

  /// No description provided for @mcpServerEditSheetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mcpServerEditSheetCancel;

  /// No description provided for @mcpServerEditSheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mcpServerEditSheetSave;

  /// No description provided for @mcpServerEditSheetUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter server URL'**
  String get mcpServerEditSheetUrlRequired;

  /// No description provided for @defaultModelPageBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get defaultModelPageBackTooltip;

  /// No description provided for @defaultModelPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Model'**
  String get defaultModelPageTitle;

  /// No description provided for @defaultModelPageChatModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Model'**
  String get defaultModelPageChatModelTitle;

  /// No description provided for @defaultModelPageChatModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Global default chat model'**
  String get defaultModelPageChatModelSubtitle;

  /// No description provided for @defaultModelPageTitleModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title Summary Model'**
  String get defaultModelPageTitleModelTitle;

  /// No description provided for @defaultModelPageTitleModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for summarizing conversation titles; prefer fast & cheap models'**
  String get defaultModelPageTitleModelSubtitle;

  /// No description provided for @defaultModelPageTranslateModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Translation Model'**
  String get defaultModelPageTranslateModelTitle;

  /// No description provided for @defaultModelPageTranslateModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for translating message content; prefer fast & accurate models'**
  String get defaultModelPageTranslateModelSubtitle;

  /// No description provided for @defaultModelPagePromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get defaultModelPagePromptLabel;

  /// No description provided for @defaultModelPageTitlePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt template for title summarization'**
  String get defaultModelPageTitlePromptHint;

  /// No description provided for @defaultModelPageTranslatePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt template for translation'**
  String get defaultModelPageTranslatePromptHint;

  /// No description provided for @defaultModelPageResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get defaultModelPageResetDefault;

  /// No description provided for @defaultModelPageSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get defaultModelPageSave;

  /// No description provided for @defaultModelPageTitleVars.
  ///
  /// In en, this message translates to:
  /// **'Vars: content: {contentVar}, locale: {localeVar}'**
  String defaultModelPageTitleVars(String contentVar, String localeVar);

  /// No description provided for @defaultModelPageTranslateVars.
  ///
  /// In en, this message translates to:
  /// **'Variables: source text: {sourceVar}, target language: {targetVar}'**
  String defaultModelPageTranslateVars(String sourceVar, String targetVar);

  /// No description provided for @modelDetailSheetAddModel.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get modelDetailSheetAddModel;

  /// No description provided for @modelDetailSheetEditModel.
  ///
  /// In en, this message translates to:
  /// **'Edit Model'**
  String get modelDetailSheetEditModel;

  /// No description provided for @modelDetailSheetBasicTab.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get modelDetailSheetBasicTab;

  /// No description provided for @modelDetailSheetAdvancedTab.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get modelDetailSheetAdvancedTab;

  /// No description provided for @modelDetailSheetModelIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Model ID'**
  String get modelDetailSheetModelIdLabel;

  /// No description provided for @modelDetailSheetModelIdHint.
  ///
  /// In en, this message translates to:
  /// **'Required, suggest lowercase/digits/hyphens'**
  String get modelDetailSheetModelIdHint;

  /// No description provided for @modelDetailSheetModelIdDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'{modelId}'**
  String modelDetailSheetModelIdDisabledHint(String modelId);

  /// No description provided for @modelDetailSheetModelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelDetailSheetModelNameLabel;

  /// No description provided for @modelDetailSheetModelTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Type'**
  String get modelDetailSheetModelTypeLabel;

  /// No description provided for @modelDetailSheetChatType.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get modelDetailSheetChatType;

  /// No description provided for @modelDetailSheetEmbeddingType.
  ///
  /// In en, this message translates to:
  /// **'Embedding'**
  String get modelDetailSheetEmbeddingType;

  /// No description provided for @modelDetailSheetInputModesLabel.
  ///
  /// In en, this message translates to:
  /// **'Input Modes'**
  String get modelDetailSheetInputModesLabel;

  /// No description provided for @modelDetailSheetOutputModesLabel.
  ///
  /// In en, this message translates to:
  /// **'Output Modes'**
  String get modelDetailSheetOutputModesLabel;

  /// No description provided for @modelDetailSheetAbilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get modelDetailSheetAbilitiesLabel;

  /// No description provided for @modelDetailSheetTextMode.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get modelDetailSheetTextMode;

  /// No description provided for @modelDetailSheetImageMode.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get modelDetailSheetImageMode;

  /// No description provided for @modelDetailSheetToolsAbility.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get modelDetailSheetToolsAbility;

  /// No description provided for @modelDetailSheetReasoningAbility.
  ///
  /// In en, this message translates to:
  /// **'Reasoning'**
  String get modelDetailSheetReasoningAbility;

  /// No description provided for @modelDetailSheetProviderOverrideDescription.
  ///
  /// In en, this message translates to:
  /// **'Provider overrides: customize provider for a specific model.'**
  String get modelDetailSheetProviderOverrideDescription;

  /// No description provided for @modelDetailSheetAddProviderOverride.
  ///
  /// In en, this message translates to:
  /// **'Add Provider Override'**
  String get modelDetailSheetAddProviderOverride;

  /// No description provided for @modelDetailSheetCustomHeadersTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Headers'**
  String get modelDetailSheetCustomHeadersTitle;

  /// No description provided for @modelDetailSheetAddHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Header'**
  String get modelDetailSheetAddHeader;

  /// No description provided for @modelDetailSheetCustomBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Body'**
  String get modelDetailSheetCustomBodyTitle;

  /// No description provided for @modelDetailSheetAddBody.
  ///
  /// In en, this message translates to:
  /// **'Add Body'**
  String get modelDetailSheetAddBody;

  /// No description provided for @modelDetailSheetBuiltinToolsDescription.
  ///
  /// In en, this message translates to:
  /// **'Built-in tools currently support limited APIs (e.g., Gemini).'**
  String get modelDetailSheetBuiltinToolsDescription;

  /// No description provided for @modelDetailSheetSearchTool.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get modelDetailSheetSearchTool;

  /// No description provided for @modelDetailSheetSearchToolDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable Google Search integration'**
  String get modelDetailSheetSearchToolDescription;

  /// No description provided for @modelDetailSheetUrlContextTool.
  ///
  /// In en, this message translates to:
  /// **'URL Context'**
  String get modelDetailSheetUrlContextTool;

  /// No description provided for @modelDetailSheetUrlContextToolDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable URL content ingestion'**
  String get modelDetailSheetUrlContextToolDescription;

  /// No description provided for @modelDetailSheetCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get modelDetailSheetCancelButton;

  /// No description provided for @modelDetailSheetAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get modelDetailSheetAddButton;

  /// No description provided for @modelDetailSheetConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get modelDetailSheetConfirmButton;

  /// No description provided for @modelDetailSheetInvalidIdError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid model ID (>=2 chars, no spaces)'**
  String get modelDetailSheetInvalidIdError;

  /// No description provided for @modelDetailSheetModelIdExistsError.
  ///
  /// In en, this message translates to:
  /// **'Model ID already exists'**
  String get modelDetailSheetModelIdExistsError;

  /// No description provided for @modelDetailSheetHeaderKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Header Key'**
  String get modelDetailSheetHeaderKeyHint;

  /// No description provided for @modelDetailSheetHeaderValueHint.
  ///
  /// In en, this message translates to:
  /// **'Header Value'**
  String get modelDetailSheetHeaderValueHint;

  /// No description provided for @modelDetailSheetBodyKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Body Key'**
  String get modelDetailSheetBodyKeyHint;

  /// No description provided for @modelDetailSheetBodyJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Body JSON'**
  String get modelDetailSheetBodyJsonHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

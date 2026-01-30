// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Synapse Care';

  @override
  String get brandTagline =>
      'Plateforme intelligente pour la gestion des soins et le suivi des patients.';

  @override
  String get welcomeHeadline => 'Bienvenue sur Synapse Care';

  @override
  String get welcomeBody =>
      'La plateforme intelligente pour la gestion des soins et le suivi des patients.';

  @override
  String get accessSpace => 'Accéder à l\'application';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get notFoundTitle => 'Page introuvable';

  @override
  String get notFoundBody => 'L\'URL demandée n\'existe pas.';

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String get accessDeniedTitle => 'Accès refusé';

  @override
  String get accessDeniedBody =>
      'Vous n\'avez pas l\'autorisation d\'accéder à cette page.';

  @override
  String get backHomeCta => 'Retour à l\'accueil';

  @override
  String get login => 'Se connecter';

  @override
  String get signup => 'S\'inscrire';

  @override
  String get emailHint => 'Adresse e-mail';

  @override
  String get nameHint => 'Nom complet';

  @override
  String get specialtyHint => 'Spécialité';

  @override
  String get nameEmptyError => 'Veuillez saisir votre nom complet';

  @override
  String get emailEmptyError => 'Veuillez saisir votre adresse e-mail';

  @override
  String get emailInvalidError => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get specialtyEmptyError => 'Veuillez saisir votre spécialité';

  @override
  String get passwordEmptyError => 'Veuillez saisir votre mot de passe';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginInvalid => 'Adresse e-mail ou mot de passe incorrect';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get loginNetworkError =>
      'Impossible d\'accéder au serveur, veuillez vérifier votre connexion Internet.';

  @override
  String get timeoutTitle => 'Session expirée';

  @override
  String get timeoutBody =>
      'Vous serez redirigé vers la page de connexion dans 5 secondes.';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get confirmPasswordHint => 'Confirmer le mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get passwordNeedSpecial =>
      'Le mot de passe doit contenir . , + * ou ?';

  @override
  String get passwordNeedUpper => 'Le mot de passe doit contenir une majuscule';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get continueCta => 'Continuer';

  @override
  String get quickSms => 'Connexion rapide et sécurisée par SMS';

  @override
  String get newHere => 'Nouveau sur Synapse Care ? ';

  @override
  String get haveAccount => 'Déjà un compte ? ';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get signIn => 'Se connecter';

  @override
  String get patient => 'Patient';

  @override
  String get doctor => 'Docteur';

  @override
  String get cabinetSearchTitle => 'Trouvez votre cabinet médical';

  @override
  String get cabinetSearchHint => 'Rechercher votre cabinet médical';

  @override
  String get cabinetSearchHelper => 'Recherchez par nom, ville ou spécialité.';

  @override
  String get cabinetSearchEmpty => 'Aucun cabinet trouvé.';

  @override
  String get cabinetAddSuccess => 'Cabinet ajouté avec succès.';

  @override
  String get cabinetAddExists => 'Cabinet déjà ajouté.';

  @override
  String get cabinetAddFailed => 'Impossible d\'ajouter le cabinet.';

  @override
  String get cabinetSelectTitle => 'Choisissez votre cabinet';

  @override
  String get cabinetSelectBody =>
      'Sélectionnez le cabinet médical auquel vous êtes affilié.';

  @override
  String get cabinetSelectSampleSpecialty => 'Médecine générale';

  @override
  String get cabinetSelectEmpty => 'Aucun cabinet affilié trouvé.';

  @override
  String get cabinetSelectUnnamed => 'Cabinet sans nom';

  @override
  String get cabinetSelectAdd => 'Ajouter un cabinet';

  @override
  String get cabinetSelectFind => 'Trouver un cabinet';

  @override
  String get homeSearchHint => 'Rechercher...';

  @override
  String get homeMenuConsultation => 'Consultation';

  @override
  String get homeMenuHistory => 'Historique';

  @override
  String get homeMenuCaisse => 'Caisse';

  @override
  String get homeMenuSettings => 'Paramètres';

  @override
  String get homeMenuData => 'Données';

  @override
  String get homeMenuAbout => 'À propos';

  @override
  String get homeMenuToday => 'Aujourd\'hui';

  @override
  String get homeMenuRdvTake => 'Prise RDV';

  @override
  String get homeMenuRdvList => 'Liste RDV';

  @override
  String get homeMenuProfile => 'Mon profil';

  @override
  String get homeMenuChangeClinic => 'Changer de cabinet';

  @override
  String get homeMenuLogout => 'Se déconnecter';

  @override
  String get phoneHint => 'Numéro de téléphone';

  @override
  String get phoneEmptyError => 'Veuillez entrer un numéro de téléphone';

  @override
  String get phoneInvalidPrefixError =>
      'Le numéro doit commencer par 5, 6 ou 7';

  @override
  String otpSend(Object phone) {
    return 'Envoi du code OTP à $phone';
  }

  @override
  String otpValidDemo(Object phone) {
    return 'Ce $phone est valide pour la démonstration.';
  }
}

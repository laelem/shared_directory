# Annuaire partagé

Cette application a été développé dans le but de monter en compétence sur les technologies Ruby on Rails et d'en faire la démonstration. Basé sur un cahier des charges fourni lors d'une formation en entreprise, elle couvre de nombreux besoins actuels de clients.

En voici les accès :
[http://laelem-shared-directory.herokuapp.com](http://laelem-shared-directory.herokuapp.com)
Simple utilisateur : simple_user@example.com / foobar
Administrateur : (me demander par mail)


## Description fonctionnelle

### Présentation

Il s'agit d'un intranet permettant la gestion de divers ressources à travers 3 modules :
* Gestion des postes
* Gestion des utilisateurs
* Gestion des contacts

Chaque module présente notamment les fonctionnalités suivantes :
* Présentation tabulaire des données
* Pagination
* Choix du nombre d'item affiché par page persistant en session
* Tri des colonnes persistant en session
* Possibilité d'ajout, de modification, d'activation et de suppression avec confirmation de chaque item

Le module "Contacts", plus complexe, inclut les fonctionnalités additionnelles suivantes :
* Développement de différents types de filtres cumulatifs et persistant en session permettant le filtrage des données de la liste
* Page de visualisation du contact
* Gestion de nombreux type de champs : date, select multiple, textarea, radiobox...
* Gestion d'un champ upload développé à la main avec contrôle de la taille, du type-mime et de l'extension du fichier

### Authentification et rôles

Il existe également une gestion des rôles et des accès aux différentes parties du site :
* L'administrateur a accès à toute l'application
* Le simple utilisateur n'a accès qu'au module "Contacts" en mode visualisation
La gestion de l'authentification a été réalisée sans outil particulier.

### Intégration

Bien que l'aspect graphique soit très sobre, un soin particulier a été donné à l'intégration et à l'accessibilité. Une longue auto-formation m'a donc permis de créer un contenu sémantique qui respecte les standards W3C, tout en intégrant les nombreux avantages des outils tels que Haml et Sass.


## Description technique

L'application a été développé avec Ruby 2 et Rails 4, géré avec RVM.
Hébergement : Heroku
Base de données : PostgreSQL
Tests : Rspec, FactoryGirl, Faker
Intégration : Haml, Sass
Gestion des images : MimeMagic, RMagick


## TODO

* Internationalisation pour inclure le français
* Possibilité de supprimer la photo dans le formulaire d'édition du contact
* Reprise des tests sur les modèles et développement de tests controllers/views/integration
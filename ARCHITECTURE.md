# Architecture DEMS-STORE - Application Flutter avec Firebase

## 📁 Structure des dossiers

```
lib/
├── main.dart                          # Point d'entrée avec gestion des rôles
├── models/                            # Modèles de données
│   ├── user_model.dart               # Modèle utilisateur avec rôles
│   ├── product_model.dart            # Modèle produit
│   ├── cart_item_model.dart          # Modèle article panier
│   └── order_model.dart              # Modèle commande
├── services/                          # Services Firebase
│   ├── auth_service.dart             # Service d'authentification
│   ├── product_service.dart          # Service CRUD produits
│   ├── cart_service.dart             # Service gestion panier
│   └── order_service.dart            # Service gestion commandes
├── screens/                           # Écrans de l'application
│   ├── admin/                        # Interface administrateur
│   │   ├── admin_dashboard.dart      # Tableau de bord admin
│   │   ├── add_product.dart          # Ajouter un produit
│   │   ├── edit_product.dart         # Modifier un produit
│   │   └── orders_list.dart          # Liste des commandes
│   └── client/                       # Interface client
│       ├── client_home.dart          # Accueil client
│       ├── cart.dart                 # Panier
│       ├── checkout.dart             # Finalisation commande
│       └── orders.dart               # Commandes client
├── pages/                            # Pages existantes (legacy)
│   ├── auth/                         # Authentification
│   │   ├── auth.dart                 # Connexion
│   │   └── registre.dart             # Inscription
│   └── homepage.dart                 # Page d'accueil (legacy)
└── widgets/                          # Composants réutilisables
    ├── product_card.dart             # Carte produit
    ├── custom_button.dart            # Boutons personnalisés
    └── loading_widget.dart           # Widgets de chargement
```

## 🔐 Gestion des rôles

### Rôles disponibles
- **Admin** : Gestion complète des produits et commandes
- **Client** : Achat et gestion des commandes

### Redirection automatique
- Après connexion, l'utilisateur est redirigé selon son rôle
- Les admins accèdent au tableau de bord admin
- Les clients accèdent à l'interface d'achat

## 🛠️ Services Firebase

### AuthService
- Connexion/déconnexion
- Inscription avec rôle
- Vérification des rôles
- Gestion des données utilisateur

### ProductService
- CRUD produits
- Recherche et filtrage
- Gestion des catégories
- Mise à jour du stock

### CartService
- Ajout/suppression d'articles
- Mise à jour des quantités
- Calcul du total
- Stream en temps réel

### OrderService
- Création de commandes
- Suivi des statuts
- Statistiques admin
- Gestion des annulations

## 📱 Interfaces

### Interface Admin
- **Dashboard** : Statistiques et actions rapides
- **Gestion produits** : CRUD complet avec filtres
- **Commandes** : Suivi et mise à jour des statuts
- **Statistiques** : Chiffre d'affaires et métriques

### Interface Client
- **Catalogue** : Navigation par catégories et recherche
- **Panier** : Gestion des articles et quantités
- **Commande** : Processus de finalisation
- **Historique** : Suivi des commandes passées

## 🔄 Flux de données

### Connexion
1. Utilisateur saisit email/mot de passe
2. Firebase Auth authentifie
3. AuthService récupère les données utilisateur
4. Redirection selon le rôle (admin/client)

### Achat
1. Client parcourt le catalogue
2. Ajout d'articles au panier
3. Finalisation de la commande
4. Création de la commande en base
5. Vidage du panier

### Gestion Admin
1. Admin accède au dashboard
2. Gestion des produits (CRUD)
3. Suivi des commandes
4. Mise à jour des statuts

## 🗄️ Collections Firebase

### users
```json
{
  "id": "string",
  "nom": "string",
  "prenom": "string", 
  "address": "string",
  "email": "string",
  "role": "admin|client",
  "dateCreation": "timestamp"
}
```

### products
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "imageUrl": "string",
  "category": "string",
  "stock": "number",
  "isAvailable": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### carts
```json
{
  "userId": "string",
  "items": [
    {
      "productId": "string",
      "quantity": "number"
    }
  ],
  "updatedAt": "timestamp"
}
```

### orders
```json
{
  "id": "string",
  "userId": "string",
  "items": "array",
  "totalAmount": "number",
  "status": "pending|confirmed|shipped|delivered|cancelled",
  "shippingAddress": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🚀 Fonctionnalités

### Admin
- ✅ Dashboard avec statistiques
- ✅ CRUD produits complet
- ✅ Gestion des commandes
- ✅ Filtres et recherche
- ✅ Mise à jour des statuts
- ✅ Gestion du stock

### Client
- ✅ Catalogue de produits
- ✅ Panier d'achat
- ✅ Processus de commande
- ✅ Suivi des commandes
- ✅ Recherche et filtres
- ✅ Interface responsive

## 🔧 Configuration

### Dépendances principales
- `firebase_core`: Configuration Firebase
- `firebase_auth`: Authentification
- `cloud_firestore`: Base de données
- `flutter`: Framework UI

### Règles de sécurité Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are readable by all authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Cart is user-specific
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Orders are user-specific for read, admin can read all
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📝 Notes d'implémentation

1. **Gestion des rôles** : Les rôles sont stockés dans Firestore et vérifiés côté client
2. **Sécurité** : Les règles Firestore protègent les données sensibles
3. **Performance** : Utilisation de streams pour les mises à jour en temps réel
4. **UX** : Interface responsive avec feedback utilisateur
5. **Modularité** : Code organisé en services et widgets réutilisables

## 🎯 Prochaines étapes

- [ ] Tests unitaires et d'intégration
- [ ] Notifications push
- [ ] Système de paiement
- [ ] Gestion des images
- [ ] Analytics et métriques
- [ ] Mode hors ligne

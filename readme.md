				Trame de présentation

Phase 1


1- Namespaces & deployments

kubectl get namespaces

kubectl get all -n cloudshop-ns


2- Taints & Affinity: Vérifie que la DB est sur le bon nœud

kubectl get pod -n cloudshop-ns -l app=database -o wide


3- Vérification de l’ingress

kubectl get ingress -n cloudshop-ns


4- Service account

kubectl get pods -n cloudshop-ns -o custom-columns="backend-6fb947c84b-4zdvm:.metadata.name,SERVICE_ACCOUNT:.spec.serviceAccount
Name"


Phase 2

Scénario 1:  Accès & Ingress 

L'application est accessible via un Ingress Controller qui gère le routage par hôte (Host-based) et le TLS. 

Frontend
curl -k https://cloudshop.local/

Backend
curl -k https://cloudshop.local/api


Scénario 2 : Rolling Update "Zero Downtime"

Je vais mettre à jour le frontend. Kubernetes va créer les nouveaux pods avant de tuer les anciens pour garantir qu'il n'y a aucune coupure de service.

Terminal 1: le Témoin
kubectl get pods -n cloudshop-ns -w


Terminal 2: Mise à jour de l’image
kubectl set image deployment/frontend frontend=nginx:1.19 -n cloudshop-ns

Scénario 3: Persistance des données (Storage PVC)

Si la base de données crash, elle est remplacée automatiquement. Grâce au PVC (Persistent Volume Claim), elle se reconnecte au même disque et aucune donnée n'est perdue

Terminal 1: le Témoin
kubectl get pods -n cloudshop-ns -w

Terminal 2: Suppression de la database
kubectl delete pod -n cloudshop-ns -l app=database



Phase 3: les preuves techniques

Test de la NetworkPolicy:

Preuve que le Frontend n'a PAS le droit de parler à la DB

Insertion dans le pod frontend
kubectl exec -it -n cloudshop-ns deploy/frontend -- /bin/sh


Test de contact avec la base de donnée (test d’ouverture d’une connexion TCP brute)
curl -v telnet://database-service:5432


Test du RBAC:

Preuve que le Backend a le droit de lire les secrets, mais pas le Frontend.

Backend
kubectl auth can-i list secrets --as=system:serviceaccount:cloudshop-ns:backend-sa -n cloudshop-ns

Frontend
kubectl auth can-i list secrets --as=system:serviceaccount:cloudshop-ns:frontend-sa -n cloudshop-ns

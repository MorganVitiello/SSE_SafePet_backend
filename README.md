# 🐾 SSE_SafePet_backend

da aggiornare con info su sustainable

## 📚 Indice
* [Overview backend](#overview-backend)
  * [Componenti del backend](#Componenti-del-backend)
* [Tecnologie usate](#tecnologie-usate)
* [Avvio backend](#Avvio-backend)

---

## 💡 Overview backend
Il backend di SafePet, sviluppato con **Spring Boot** su **Java**, costituisce il nucleo operativo e logico della piattaforma, gestendo l'elaborazione dei dati, la sicurezza e la persistenza.
Il suo ruolo principale è orchestrare tutte le funzioni del sistema:
* **Logica di Business:** Eseguire tutti i requisiti funzionali (RF) relativi a utenti, animali, pazienti, veterinari ed emergenze.
* **Sicurezza e Controllo Accessi:** Gestire in modo sicuro l'autenticazione degli utenti e l'autorizzazione alle risorse, proteggendo i dati sensibili tramite la cifratura delle password.
* **Persistenza Dati:** Gestire la connessione e l'interazione con il database **MySQL** per la memorizzazione e il recupero di tutte le informazioni del sistema (cartelle cliniche, profili, ecc.).
* **Integrazioni Esterne:** Fungerere da punto di controllo per la comunicazione con servizi esterni, in particolare il **Modulo AI** per le analisi dermatologiche e il **Sistema di Geolocalizzazione** per la Mappa Real Time.

### 🧱 Componenti del backend 
* Controller: espone le API REST verso il frontend. Riceve le richieste HTTP, valida i dati in ingresso e li inoltra al livello di servizio. È l’unico punto di accesso del frontend al backend. Restituisce le risposte in formato JSON. 
* Services: contiene la logica di business dell’applicazione. Implementa le regole e i processi che definiscono il comportamento del sistema (es. validazione dei dati, calcolo percorsi, gestione utenti). Sfrutta i repository per accedere al DB. 
* Repository: Si occupa dell’accesso ai dati persistenti, astratto rispetto al database fisico. Utilizza Spring Data JPA o Hibernate per interagire con MySQL tramite le entity del modello e fornisce le operazioni CRUD.
---

## ⚙️ Tecnologie usate
* Spring Framework e Spring Boot (v. 3.5.7): Framework Java open-source (basato su Java 21) utilizzato per la logica di business e la realizzazione di un sistema scalabile e modulare. 
* Hibernate e Spring Data JPA: Framework ORM (Object-Relational Mapping) utilizzato per la persistenza dei dati e l'interazione con il database tramite entità Java. 
* MySQL: Sistema di gestione di database relazionale per la memorizzazione dei dati. 
* MySQL Connector J: Driver utilizzato per la comunicazione tra il Backend e il database MySQL. 
* JJWT (Java JWT): Libreria per la gestione (generazione, validazione e parsing) dei token JWT per l'autenticazione. 
* Spring Security Crypto: Modulo per la gestione sicura dell'hashing e della cifratura delle password.
---

## ☕ Avvio backend

Per eseguire il backend è necessario seguire i seguenti passaggi:
1.  **Avviare Intellij** e clonare la repository del progetto:
    * `https://github.com/Progetto-SafePet/SafePet_backend.git`
2.  **Aprire Docker**.
3.  Tramite il terminale di Intellij digitare:
    * `docker compose up -d`
4.  Eseguire `clean` e `install` di Maven.
5.  Runnare `BackendApplication.java`.

---

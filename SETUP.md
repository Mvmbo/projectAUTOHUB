# AutoHUB – Guida di installazione e avvio

## Requisiti

| Componente | Versione richiesta |
|---|---|
| JDK | 21 |
| Apache Tomcat | 11.x |
| MySQL | 8.0+ |
| Maven | 3.8+ |
| Browser moderno | Per Bootstrap, Leaflet e risorse CDN |

Il progetto produce un file WAR ed usa Jakarta Servlet 6.1, JSP/JSTL e MySQL Connector/J 9.1.0. I sorgenti importano `jakarta.servlet.*`, quindi non sono compatibili con Tomcat 9 o precedente.

## 1. Preparare il database

### Installazione da zero

Eseguire dalla radice del repository:

```powershell
mysql -u root -p < sql\autohub.sql
```

In alternativa, con phpMyAdmin, importare il file `sql/autohub.sql`. Lo script crea il database `autohub` con codifica `utf8mb4`, le tabelle `users`, `products`, `orders`, `order_items`, `rental_vehicles` e `rentals`, oltre ai dati dimostrativi.

### Aggiornare un database già esistente

Se il database è stato creato con una versione precedente del progetto, eseguire anche le migrazioni seguenti, solo se le relative colonne non sono già presenti:

```powershell
mysql -u root -p autohub < sql\dealer-owner-migration.sql
mysql -u root -p autohub < sql\dealer-coordinates-migration.sql
```

Le migrazioni aggiungono `dealer_id` a prodotti e veicoli a noleggio, e le coordinate geografiche dei concessionari (`latitude`, `longitude`) in `users`.

### Account iniziali

| Ruolo | Username | Password |
|---|---|---|
| Amministratore | `admin` | `admin123` |
| Concessionario Milano | `dealer_milano` | `admin123` |
| Concessionario Roma | `dealer_roma` | `admin123` |
| Altri concessionari seed | `dealer_napoli`, `dealer_firenze`, `dealer_torino`, `dealer_bologna`, `dealer_verona`, `dealer_bari` | `admin123` |

Gli utenti cliente possono essere creati dalla pagina di registrazione. Per ragioni di sicurezza, cambiare le credenziali di esempio prima di usare l'applicazione in un ambiente esposto.

## 2. Configurare il datasource Tomcat

Il progetto include già [context.xml](C:\Users\rosal\Desktop\projectAUTOHUB\src\main\webapp\META-INF\context.xml), che definisce la risorsa JNDI `jdbc/autohub` per MySQL locale. Aggiornare i campi `username` e `password` se l'utente MySQL non è `root` senza password.

```xml
<Resource
  name="jdbc/autohub"
  auth="Container"
  type="javax.sql.DataSource"
  driverClassName="com.mysql.cj.jdbc.Driver"
  url="jdbc:mysql://localhost:3306/autohub?useSSL=false&amp;serverTimezone=UTC&amp;allowPublicKeyRetrieval=true&amp;useUnicode=true&amp;characterEncoding=UTF-8&amp;connectionCollation=utf8mb4_unicode_ci"
  username="root"
  password=""
  maxTotal="20"
  maxIdle="10"
  maxWaitMillis="10000"
  validationQuery="SELECT 1"
  testOnBorrow="true"
/>
```

Il driver MySQL deve essere disponibile al classloader di Tomcat. Copiare il JAR `mysql-connector-j-9.1.0.jar` (o una versione compatibile) in:

```text
%CATALINA_HOME%\lib\
```

Riavviare Tomcat dopo ogni modifica al driver o al datasource.

## 3. Configurare HTTPS

Il file [web.xml](C:\Users\rosal\Desktop\projectAUTOHUB\src\main\webapp\WEB-INF\web.xml) applica `CONFIDENTIAL` a tutte le rotte. Configurare quindi un connettore HTTPS in Tomcat, altrimenti le richieste HTTP possono essere rifiutate o reindirizzate a una porta SSL non configurata.

Per lo sviluppo locale, configurare un connettore SSL in `%CATALINA_HOME%\conf\server.xml` e accedere con `https://localhost:<porta>`. Per una prova esclusivamente in HTTP, rimuovere temporaneamente il blocco `security-constraint` da `web.xml`; non farlo in ambienti pubblici.

## 4. Importare ed eseguire con IntelliJ IDEA

1. Aprire in IntelliJ la cartella `C:\Users\rosal\Desktop\projectAUTOHUB`, quella che contiene `pom.xml`.
2. Importare il progetto come Maven e impostare Project SDK e language level su JDK 21.
3. Creare una configurazione **Tomcat Server > Local** con Tomcat 11.
4. In **Deployment**, aggiungere l'artifact `autohub:war exploded`.
5. Impostare il context path su `/autohub` (oppure `/` per la root) e avviare.

## 5. Build e deploy manuale su Windows

Prima del deploy, completare le sezioni sul database, datasource e HTTPS. I comandi seguenti assumono che Tomcat sia installato in `C:\Tomcat11` e che il terminale sia aperto nella cartella che contiene `pom.xml`.

### 1. Generare il file WAR

```powershell
mvn clean package
```

Il comando:

- `clean` elimina la precedente cartella `target`, evitando di distribuire file prodotti da una build vecchia;
- `package` compila il progetto, esegue le fasi di build configurate da Maven e crea il pacchetto WAR;
- genera il file da distribuire: `target\autohub.war`.

### 2. Copiare il WAR nella cartella di deploy

```powershell
Copy-Item .\target\autohub.war C:\Tomcat11\webapps\autohub.war -Force
```

Il comando copia il WAR in `webapps` con il nome `autohub.war`. L'opzione `-Force` sovrascrive il precedente WAR, se presente. Tomcat usa il nome del file per il context path: `autohub.war` corrisponde a `/autohub`.

Se si sta aggiornando una versione già avviata, fermare prima Tomcat e rimuovere la vecchia cartella estratta, così non restano file obsoleti:

```powershell
C:\Tomcat11\bin\shutdown.bat
# Arresta Tomcat e libera i file dell'applicazione.

Remove-Item -LiteralPath C:\Tomcat11\webapps\autohub -Recurse -Force
# Elimina soltanto la directory estratta del deploy precedente.

Copy-Item .\target\autohub.war C:\Tomcat11\webapps\autohub.war -Force
# Copia il nuovo pacchetto da distribuire.
```

### 3. Avviare Tomcat

```powershell
C:\Tomcat11\bin\startup.bat
```

`startup.bat` avvia il server Tomcat. Durante l'avvio, Tomcat rileva `webapps\autohub.war`, lo estrae in `webapps\autohub\` e pubblica automaticamente l'applicazione. I log di avvio sono disponibili in `C:\Tomcat11\logs\`.

### 4. Aprire l'applicazione

Con un connettore HTTPS configurato sulla porta 8443, aprire:

```text
https://localhost:8443/autohub/home
```

Il progetto richiede HTTPS in [web.xml](C:\Users\rosal\Desktop\projectAUTOHUB\src\main\webapp\WEB-INF\web.xml). Se si rimuove temporaneamente il vincolo `CONFIDENTIAL` soltanto in sviluppo, l'URL HTTP diventa:

```text
http://localhost:8080/autohub/home
```

Se `mvn` non è riconosciuto, installare Maven e aggiungere la cartella `bin` alla variabile d'ambiente `PATH`, quindi riaprire il terminale.

## 6. URL principali

Con context path `/autohub` e HTTPS configurato:

| Funzione | URL |
|---|---|
| Home | `https://localhost:8443/autohub/home` |
| Catalogo vendita | `https://localhost:8443/autohub/catalog` |
| Catalogo noleggi | `https://localhost:8443/autohub/rentals` |
| Login | `https://localhost:8443/autohub/login` |
| Login amministratore | `https://localhost:8443/autohub/admin/login` |
| Area concessionario | `https://localhost:8443/autohub/dealer/dashboard` |

La welcome page reindirizza a `/home`. Le JSP sono sotto `WEB-INF/view` e pertanto non sono raggiungibili direttamente dal browser.

## 7. Note operative

- Il carrello è memorizzato nella sessione; checkout, ordini e noleggi richiedono login. La sessione dura 30 minuti.
- La registrazione permette di scegliere un account cliente o concessionario. Per i concessionari l'applicazione tenta di geocodificare l'indirizzo tramite il servizio Nominatim di OpenStreetMap; se il servizio non risponde, la registrazione resta valida ma senza coordinate.
- Amministratori e concessionari caricano da 3 a 5 immagini per veicolo. Le immagini vengono salvate dal server in `src/main/webapp/images/products/` durante l'esecuzione in ambiente di sviluppo; assicurarsi che la directory di deploy sia scrivibile da Tomcat.
- La mappa dei noleggi nel pannello admin usa Leaflet, tile CARTO e risorse caricate da CDN. Sono quindi necessarie connessioni internet per font, icone, Bootstrap, Leaflet e mappa.
- Il video della home è incluso in `src/main/webapp/videos/hero-cars.mp4`.

## Risoluzione dei problemi

### `mvn` non riconosciuto

Maven non è installato oppure la sua cartella `bin` non è nel `PATH`. Installare Maven, configurare `MAVEN_HOME`/`PATH` secondo il sistema operativo e aprire un nuovo terminale.

### Errore di connessione MySQL o JNDI

1. Verificare che MySQL sia attivo e che esista il database `autohub`.
2. Controllare credenziali e URL nel `context.xml` incluso nel progetto.
3. Verificare che MySQL Connector/J sia in `%CATALINA_HOME%\lib`.
4. Riavviare Tomcat.

### HTTP 403, redirect HTTPS non funzionante o pagina irraggiungibile

Configurare un connettore HTTPS in Tomcat, perché `web.xml` richiede trasporto confidenziale per tutte le richieste. Controllare anche la porta HTTPS indicata nel connettore e usarla nell'URL.

### Errore durante il caricamento immagini

Controllare i permessi di scrittura di Tomcat sulla directory di deploy `images/products/`, il limite di 5 MB per singolo file e il limite di 25 MB per la richiesta multipart.

### Pagine JSP in 404

È previsto: le viste sono protette da `WEB-INF`. Accedere sempre tramite le servlet, ad esempio `/catalog`, `/rentals` o `/admin/dashboard`.


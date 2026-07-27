# AutoHUB – Setup and Deployment Guide

## Prerequisites

| Tool | Version |
|------|---------|
| JDK | 17 (required) |
| Apache Tomcat | 11.x (Jakarta EE 11 compatible) |
| MySQL | 8.0+ |
| phpMyAdmin | 5+ (optional, GUI alternative) |
| Maven | 3.8+ |
| IntelliJ IDEA | 2023.x+ (recommended) |

> **Important:** Tomcat 11 requires Jakarta EE 11 (Jakarta Servlet API 6.1.0). All servlets use `jakarta.servlet.*` imports (not `javax.servlet.*`).

---

## Step 1 – Database Setup

### Option A: Using phpMyAdmin

1. Open phpMyAdmin in your browser (usually `http://localhost/phpmyadmin`).
2. Click **SQL** in the top menu.
3. Paste the entire contents of `sql/autohub.sql` and click **Go**.

This will:
- Create the `autohub` database
- Create `users`, `products`, `orders`, `order_items` tables
- Insert the default admin user (`admin` / `admin123`)
- Insert 10 sample products

### Option B: Using MySQL CLI

```bash
mysql -u root -p < sql/autohub.sql
```

---

## Step 2 – Tomcat DataSource Configuration

### 2.1 Add the MySQL JDBC Driver to Tomcat

Download **MySQL Connector/J 8.3.x** and place the JAR in Tomcat's `lib/` folder:

```
$CATALINA_HOME/lib/mysql-connector-j-8.3.0.jar
```

Download from: https://dev.mysql.com/downloads/connector/j/

### 2.2 Configure the DataSource

Edit `$CATALINA_HOME/conf/context.xml` and add inside `<Context>`:

```xml
<Resource
  name="jdbc/autohub"
  auth="Container"
  type="javax.sql.DataSource"
  driverClassName="com.mysql.cj.jdbc.Driver"
  url="jdbc:mysql://localhost:3306/autohub?useSSL=false&amp;serverTimezone=UTC&amp;allowPublicKeyRetrieval=true"
  username="root"
  password="YOUR_MYSQL_PASSWORD"
  maxTotal="20"
  maxIdle="10"
  maxWaitMillis="10000"
/>
```

Replace `YOUR_MYSQL_PASSWORD` with your actual MySQL root password (leave empty if no password).

> **Note:** The project's own `src/main/webapp/META-INF/context.xml` provides the same configuration and is automatically used by Tomcat when the WAR is deployed. You only need to edit the global `conf/context.xml` if you prefer a server-level setup.

---

## Step 3 – IntelliJ IDEA Setup

### 3.1 Import the Project

1. Open IntelliJ IDEA.
2. Choose **File → Open** and select the `projectAUTOHUB/project/` folder (containing `pom.xml`).
3. IntelliJ will detect the Maven project and import it automatically. If prompted, click **Trust Project**.

### 3.2 Fix the JDK (resolves "JDK isn't specified" error)

**Fix A – Project SDK:**

1. Go to **File → Project Structure → Project**.
2. Under **SDK**, select **JDK 17** from the dropdown. If not listed, click **Add SDK → JDK** and point it to your JDK 17 installation.
3. Set **Language Level** to **17**.
4. Click **Apply → OK**.

**Fix B – Module SDK:**

1. Go to **File → Project Structure → Modules**.
2. Select the `autohub` module.
3. In the **Dependencies** tab, set the **Module SDK** to **JDK 17**.
4. Click **Apply → OK**.

**Fix C – Maven Reload:**

1. Open the **Maven** tool window (right side panel, or View → Tool Windows → Maven).
2. Click the **Reload All Maven Projects** button (circular arrow icon).

### 3.3 Configure Tomcat in IntelliJ

1. Go to **Run → Edit Configurations → + → Tomcat Server → Local**.
2. Set the **Application server** to your Tomcat 11 installation.
3. Click the **Deployment** tab → **+ → Artifact**.
4. Select `autohub:war exploded`.
5. Set the **Application context** to `/autohub` (or `/` for root).
6. Click **Apply → Run**.

---

## Step 4 – Build and Deploy

### Build with Maven

```bash
cd projectAUTOHUB/project
mvn clean package
```

This produces `target/autohub.war`.

### Deploy to Tomcat (manual)

```bash
cp target/autohub.war $CATALINA_HOME/webapps/
```

Start Tomcat:

```bash
$CATALINA_HOME/bin/startup.sh    # Linux/Mac
$CATALINA_HOME\bin\startup.bat   # Windows
```

---

## Step 5 – Access the Application

| Page | URL |
|------|-----|
| Customer site | `http://localhost:8080/autohub/` |
| Admin panel | `http://localhost:8080/autohub/admin/login` |

### Default Admin Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin123` |

---

## Project Structure

```
projectAUTOHUB/project/
├── pom.xml                          # Maven – groupId: com.autohub, artifactId: autohub, Java 17
├── sql/
│   └── autohub.sql                  # MySQL schema + seed data
└── src/main/
    ├── java/
    │   ├── control/                 # Servlets (MVC Controller layer)
    │   ├── model/                   # Model classes
    │   ├── dao/                     # DAO layer (DBUtil uses jdbc/autohub JNDI)
    │   └── filter/                  # Servlet Filters (Auth, AdminAuth, Encoding)
    └── webapp/
        ├── WEB-INF/
        │   ├── web.xml              # Declares jdbc/autohub resource-ref, filters
        │   └── view/                # JSPs (not directly accessible)
        ├── META-INF/
        │   └── context.xml          # MySQL DataSource definition
        ├── styles/                  # External CSS (main.css, admin.css)
        └── scripts/                 # External JS (cart.js, validation.js, catalog.js)
```

---

## Troubleshooting

### "JDK isn't specified for module 'autohub'"

Follow Step 3.2 above (set SDK to JDK 17 in Project Structure → Modules).

### MySQL Connection Refused

- Ensure MySQL is running: `mysqladmin -u root -p status`
- Verify the database exists: `mysql -u root -p -e "SHOW DATABASES;"`
- Check username/password in `context.xml`

### JNDI Lookup Fails (ClassNotFoundException or NamingException)

- Confirm `mysql-connector-j-*.jar` is in `$CATALINA_HOME/lib/` (not in `WEB-INF/lib/`)
- Restart Tomcat after adding the JAR

### 404 on JSP URLs

JSPs are inside `WEB-INF/view/` to prevent direct access. All access must go through the servlets.

### Session / Login Issues

- Session timeout is 30 minutes (configurable in `web.xml`).
- Make sure browser cookies are enabled.

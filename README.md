# CatalogPriceBookSync — MuleSoft Integration Project

Automated, API-Led catalog and price synchronization from MySQL ERP database to Salesforce Sales Cloud (`Product2` and `PricebookEntry`).

Designed for the Cognizant MuleSoft Hackathon.

---

## 1. Project Prerequisites

* **Operating System**: Windows 10/11 or Linux
* **Java Development Kit (JDK)**: Eclipse Adoptium JDK 17 (tested with `jdk-17.0.20.101-hotspot`)
* **Anypoint Studio**: Version 7.18+ or 8.x
* **Mule Runtime**: Mule Enterprise Runtime 4.12.1 (minimum Mule 4.4+)
* **Apache Maven**: Version 3.9+
* **Database**: MySQL 8.0+ running on `localhost:3306`
* **Salesforce**: Developer Edition or Sandbox org with Administrator / Standard User access with `Product2`, `Pricebook2`, `PricebookEntry`, and `Case` permissions.

---

## 2. Connectors & Module Versions

Configured in [`pom.xml`](file:///C:/AnypointStudio/salesforce/pom.xml):
* `mule-http-connector`: 1.11.3
* `mule-sockets-connector`: 1.2.7
* `mule-db-connector`: 1.16.1
* `mysql-connector-j`: 8.0.33 (shared library)
* `mule-salesforce-connector`: 12.0.4
* `mule-apikit-module`: 1.12.0
* `mule-objectstore-connector`: 1.2.2
* `mule-file-connector`: 1.5.5
* `mule-vm-connector`: 2.0.1
* `mule-email-connector`: 1.8.0
* `munit-maven-plugin`: 3.7.3
* `munit-runner` / `munit-tools`: 3.7.3

---

## 3. Configuration & Secrets Management

* **Active Configuration**: [`src/main/resources/config.yaml`](file:///C:/AnypointStudio/salesforce/src/main/resources/config.yaml)
* **Placeholder Template**: [`src/main/resources/config-example.yaml`](file:///C:/AnypointStudio/salesforce/src/main/resources/config-example.yaml)
* **Security Notice**: Never commit live passwords, security tokens, or encryption keys to version control. Keep `.gitignore` active.

### Setting Up Secure Properties
To encrypt credentials using Mule Secure Properties Tool:
```powershell
java -jar secure-properties-tool.jar string encrypt Blowfish CBC "YourKey" "YourPassword"
```
Configure in XML using `<secure-properties:config key="${encryption.key}" file="config-secure.yaml" />`.

---

## 4. MySQL Database Setup

Ensure MySQL is running on `127.0.0.1:3306` with database `catalog_sync_db`:
```sql
CREATE DATABASE IF NOT EXISTS catalog_sync_db;
USE catalog_sync_db;

CREATE TABLE IF NOT EXISTS product_master (
    erp_code VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    description TEXT,
    family VARCHAR(50),
    uom VARCHAR(20),
    status VARCHAR(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_price (
    erp_code VARCHAR(50) PRIMARY KEY,
    unit_price DECIMAL(12,2),
    currency VARCHAR(10) DEFAULT 'INR',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (erp_code) REFERENCES product_master(erp_code)
);

CREATE TABLE IF NOT EXISTS sync_run (
    run_id VARCHAR(50) PRIMARY KEY,
    trigger_type VARCHAR(30),
    requested_by VARCHAR(100),
    scope VARCHAR(20),
    watermark_from TIMESTAMP NULL,
    watermark_to TIMESTAMP NULL,
    records_read INT DEFAULT 0,
    created_count INT DEFAULT 0,
    updated_count INT DEFAULT 0,
    deactivated_count INT DEFAULT 0,
    retried_count INT DEFAULT 0,
    failed_count INT DEFAULT 0,
    run_status VARCHAR(30),
    rejects_file VARCHAR(255),
    sf_case_number VARCHAR(50),
    email_status VARCHAR(50),
    correlation_id VARCHAR(100),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS product_sync_log (
    log_seq BIGINT AUTO_INCREMENT PRIMARY KEY,
    run_id VARCHAR(50),
    erp_code VARCHAR(50),
    operation VARCHAR(50),
    salesforce_id VARCHAR(50),
    pricebook_entry_id VARCHAR(50),
    record_status VARCHAR(30),
    error_code VARCHAR(50),
    error_message TEXT,
    retry_count INT DEFAULT 0,
    correlation_id VARCHAR(100),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_run_product UNIQUE (run_id, erp_code, operation),
    FOREIGN KEY (run_id) REFERENCES sync_run(run_id)
);
```

---

## 5. Salesforce Setup

1. **Custom External ID Field**:
   * Object: `Product2`
   * Field Name: `ERP_Product_Code__c`
   * Type: `Text(50)`, Unique, External ID.
2. **Price Book Setup**:
   * Create standard Price Book and an active custom Price Book named `ERP Catalog Price Book`.
3. **Permissions**:
   * User requires Read/Write permissions on `Product2`, `Pricebook2`, `PricebookEntry`, and `Case`.

---

## 6. How to Run in Anypoint Studio

1. Open **Anypoint Studio**.
2. Go to **File $\rightarrow$ Import $\rightarrow$ Anypoint Studio $\rightarrow$ Anypoint Studio project from File System**.
3. Select root directory `C:\AnypointStudio\salesforce`.
4. Right-click the project $\rightarrow$ **Run As $\rightarrow$ Mule Application**.
5. Verify console logs indicate:
   ```
   **********************************************************************
   * Started app 'salesforce'                                           *
   **********************************************************************
   ```

---

## 7. How to Call the API in Postman

* **Base URL**: `http://localhost:8081/api`
* **APIKit Console**: `http://localhost:8081/console`

### Request 1: Trigger Catalog Synchronization
* **Method**: `POST`
* **URL**: `http://localhost:8081/api/catalog/sync`
* **Headers**:
  * `Content-Type`: `application/json`
  * `X-Correlation-ID`: `corr-postman-001`
* **Body** (Raw JSON):
```json
{
  "requestedBy": "tester@cognizant.com",
  "fullSync": false,
  "productCodes": ["PRD-AUT-140"]
}
```
* **Expected Response**: `HTTP 202 Accepted`
```json
{
  "runId": "RUN-20261013-100000",
  "triggerType": "MANUAL_API",
  "scope": "PARTIAL",
  "status": "RUNNING",
  "correlationId": "corr-postman-001",
  "recordsProcessed": 0
}
```

### Request 2: Check Run Status
* **Method**: `GET`
* **URL**: `http://localhost:8081/api/catalog/runs/RUN-20261013-100000`
* **Expected Response**: `HTTP 200 OK` (or `404 Not Found` if run ID does not exist).

---

## 8. How to Run MUnit Tests

Run via command line using the configured Maven wrapper:
```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
mvn test
```
* **MUnit Test Results**: 26/26 passing (100% Pass Rate - 0 Failures, 0 Errors, 0 Skipped).
* **Application Coverage**: **85.19%** (138 out of 162 total processors covered, exceeding the 80% requirement).
* **Coverage Report**: View HTML report at `target/site/munit/coverage/summary.html`.

---

## 9. Verification in Salesforce and MySQL

### In Salesforce
* Navigate to **App Launcher $\rightarrow$ Products**.
* Verify `ERP_Product_Code__c = PRD-AUT-140` has `IsActive = true` and custom price book entry.
* Verify `ERP_Product_Code__c = PRD-AUT-090` has `IsActive = false` (Discontinued).
* Navigate to **App Launcher $\rightarrow$ Cases**.
* Verify Case with subject `[ALERT] CatalogPriceBookSync Failures - Run ...` exists when rejections occur.

### In MySQL
```sql
SELECT * FROM sync_run ORDER BY started_at DESC LIMIT 5;
SELECT * FROM product_sync_log ORDER BY log_seq DESC LIMIT 10;
```

---

## 10. Known Limitations & Architecture Notes

1. **Mule Domain Application**: Not required. The application runs as a standalone deployment managing its own listener configuration on `http://0.0.0.0:8081` without port sharing requirements.
2. **API Autodiscovery**: Configured with `api.autodiscovery.id` in `salesforce.xml`. Active synchronization requires cloud Anypoint Platform client credentials.
3. **SMTP Delivery**: Reusable HTML summary is compiled by `run-summary-email.dwl`. Delivery is disabled (`email.smtp.enabled: false`) until valid host credentials are provided.

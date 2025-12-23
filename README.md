# FaceRecognition Service (M346)

Dieses Projekt wurde im Rahmen des Moduls **346 – Cloudlösungen konzipieren und realisieren** erstellt.  
Es demonstriert einen vollständig automatisierten Cloud-Service zur Gesichtserkennung bekannter Persönlichkeiten in AWS.

---

## Inhaltsverzeichnis

- [FaceRecognition Service (M346)](#facerecognition-service-m346)
  - [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [1. Einleitung](#1-einleitung)
  - [2. Architektur](#2-architektur)
    - [2.1 Architekturdiagramm](#21-architekturdiagramm)
  - [3. Ressourcenplanung und Konfiguration](#3-ressourcenplanung-und-konfiguration)
  - [4. Inbetriebnahme](#4-inbetriebnahme)
    - [Voraussetzungen](#voraussetzungen)
    - [Schritte](#schritte)
  - [5. Verwendung und Tests](#5-verwendung-und-tests)

---

## 1. Einleitung

Der Service ermöglicht es, Bilder über einen S3-Bucket hochzuladen, diese automatisch mittels einer serverlosen Architektur (AWS Lambda & Amazon Rekognition) zu analysieren und die Ergebnisse strukturiert als JSON-Datei zu speichern.

Das Ziel des Projekts ist die vollständige Automatisierung der Infrastruktur (Infrastructure as Code Ansatz via CLI) sowie eine lückenlose Dokumentation und Versionierung im Git-Repository.

---

## 2. Architektur

Der Service nutzt eine ereignisgesteuerte Architektur:

- **Client / Test-Script:** Lädt Bilder hoch und lädt Ergebnisse herunter.
- **S3 In-Bucket:** Speichert Bilder und löst bei jedem Upload im Ordner `uploads/` ein **S3-Event** aus.
- **AWS Lambda-Funktion:** Wird durch das Event gestartet, liest das Bild ein und ruft den Rekognition-Dienst auf.
- **Amazon Rekognition:** Identifiziert Prominente (Recognizing celebrities) und liefert Namen sowie Confidence-Werte.
- **S3 Out-Bucket:** Speichert das Analyseergebnis als JSON-Datei im Ordner `results/`.
- **CloudWatch Logs:** Protokolliert die Ausführungen der Lambda-Funktion zur Fehlerdiagnose.

### 2.1 Architekturdiagramm

![Architekturdiagramm](image-1.png)

---

## 3. Ressourcenplanung und Konfiguration

Folgende Ressourcen werden durch das `init.sh` Skript vollautomatisch im AWS Learner-Lab erstellt:

- **S3 Buckets**
  - In-Bucket: `m346-face-recognition-in-[ACCOUNT-ID]`
  - Out-Bucket: `m346-face-recognition-out-[ACCOUNT-ID]`
- **Lambda-Funktion**
  - Name: `m346-face-recognition`
  - Runtime: **Python 3.9**
  - Trigger: S3 `ObjectCreated:*` mit Prefix `uploads/`
- **IAM-Berechtigungen**
  - Verwendung der `LabRole` für den Zugriff auf S3 und Rekognition

---

## 4. Inbetriebnahme

Die Bereitstellung erfolgt vollständig über die Kommandozeile.

### Voraussetzungen

- AWS Learner Lab mit gültigen Credentials.
- Konfigurierte AWS CLI (`aws configure`).
- Bash-kompatible Umgebung (Linux, macOS oder WSL).

### Schritte

1. Repository klonen und in das Verzeichnis wechseln:

   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Initialisierungs-Script ausführbar machen und ausführen:
   ```bash
   chmod +x scripts/init.sh
   ./scripts/init.sh
   ```

Das Script installiert alle Komponenten, setzt Berechtigungen und konfiguriert den S3-Trigger vollautomatisiert.

## 5. Verwendung und Tests

Ein automatisierter Test prüft die Funktionsfähigkeit des Dienstes:

1. Ein Testbild einer bekannten Person unter `test/test.jpg` bereitstellen.
2. Test-Script starten:
   ```bash
   chmod +x scripts/test.sh
   ./scripts/test.sh
   ```

Das Script lädt die Datei hoch, wartet auf die Verarbeitung durch AWS Rekognition (Polling) und lädt das Ergebnis als JSON-Datei herunter.
Detaillierte Protokolle und Screenshots finden sich in der Datei [testing.md](docs/testing.md).

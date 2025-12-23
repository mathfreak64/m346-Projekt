# FaceRecognition Service (M346)

Dieses Projekt wurde im Rahmen des Moduls **346 – Cloudlösungen konzipieren und realisieren** erstellt.  
Es demonstriert einen vollständig automatisierten Cloud-Service zur Gesichtserkennung bekannter Persönlichkeiten in AWS.

---

## Inhaltsverzeichnis

- [FaceRecognition Service (M346)](#facerecognition-service-m346)
  - [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [1. Einleitung](#1-einleitung)

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

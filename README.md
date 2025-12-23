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

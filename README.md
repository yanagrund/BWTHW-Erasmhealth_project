# BWTHW – Erasmhealth Project

A mobile health-tracking app built for the BWTHW (Biomedical Wearable Technologies for Healthcare and Wellbeing) course at Unipd. The app connects to the [IMPACT](https://impact.dei.unipd.it/bwthw/) platform to retrieve wearable health data, computes a personal wellness score, and helps users understand how lifestyle choices affect their recovery.

## Repository contents

| Path | Description |
|---|---|
| `application_erasmhealth/` | Flutter mobile application (main deliverable) |
| `credentials.xls` | Test account credentials for the IMPACT API |
| `data_score.dart` | Scratch file for score formula exploration |

## Quick start

See [`application_erasmhealth/README.md`](application_erasmhealth/README.md) for setup and run instructions.

## Course context

The IMPACT API provides real wearable data (sleep, heart rate, resting heart rate, step count) for a set of test patients. The app reads this data, computes a 0–100 wellness score, and presents it in a way that encourages healthy behaviour — particularly around alcohol consumption, sleep, and physical activity.

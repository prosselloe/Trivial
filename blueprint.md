# Trivial de la Ciberseguretat - Blueprint

## Visió General

L'objectiu d'aquest projecte és replicar fidelment l'aplicació "Trivial de la Ciberseguretat", originalment creada amb App Inventor, a un projecte Flutter. L'aplicació és un joc de trivial amb preguntes sobre ciberseguretat, dividides en categories.

Aquest document servirà com a guia central per al desenvolupament, assegurant que la versió de Flutter sigui una còpia exacta de l'original d'App Inventor, respectant l'estructura, els recursos i la lògica de l'aplicació.

## Arquitectura i Disseny

L'aplicació seguirà una arquitectura senzilla a Flutter, centrada en la gestió de l'estat per a les preguntes, puntuacions i navegació entre pantalles.

*   **Estructura del Projecte:**
    *   `lib/`: Codi font de Dart.
        *   `main.dart`: Punt d'entrada de l'aplicació.
        *   `screens/`: Widgets que representen cada pantalla de l'App Inventor.
        *   `models/`: Classes per a les dades (p. ex., `Question`).
        *   `services/`: Lògica de negoci (p. ex., carregar preguntes, gestionar el joc).
        *   `widgets/`: Widgets reutilitzables.
    *   `assets/`: Recursos de l'aplicació.
        *   `images/`: Imatges del joc.
        *   `audio/`: Arxius de so.
        *   `data/`: Arxius CSV amb les preguntes.

## Pla de Desenvolupament Actual

**Tasca Actual: Anàlisi del projecte i creació del pla de desenvolupament**

El primer pas és analitzar a fons el projecte original d'App Inventor per entendre'n l'estructura i la funcionalitat.

1.  **Analitzar els fitxers `.scm` i `.bky`:** Revisar els 14 fitxers de pantalla a `src/` per entendre el disseny de la interfície d'usuari (components, disposició) i la lògica de programació (events, variables, funcions).
2.  **Identificar les pantalles:** Crear una llista de totes les pantalles i la seva funció.
3.  **Model de dades:** Definir l'estructura de les dades de les preguntes a partir dels arxius CSV.
4.  **Flux de navegació:** Dibuixar el flux de navegació entre les diferents pantalles.
5.  **Recursos:** Catalogar totes les imatges i sons utilitzats.
6.  **Crear el pla de treball:** Detallar les passes per a la implementació de cada pantalla i funcionalitat a Flutter.
7.  **Presentar el pla:** Presentar el pla a l'usuari per a la seva validació abans de començar a codificar.

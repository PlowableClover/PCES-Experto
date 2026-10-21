# Asistente de pre-evaluación PCES

Sistema experto en **SWI-Prolog**, con interfaz web, que estima el nivel de certificación que alcanzaría una edificación en el **Programa de Certificación de Edificaciones Sustentables (PCES)** de la Ciudad de México, en la etapa de diseño y construcción. Además indica qué criterios obligatorios le faltan y qué criterios voluntarios le ayudarían a subir de nivel.

Práctica integradora del primer parcial · Paradigmas de Programación · ESCOM-IPN
Autor: Martínez Díaz Ian Arath (3BM2)

- **Aplicación publicada:** _(pegar aquí la URL de Render)_
- **Fuente normativa:** PCES, Gaceta Oficial de la Ciudad de México (2020), tablas 1, 2 y 3.

> Herramienta educativa. No sustituye la evaluación de un implementador acreditado por la SEDEMA.

## Arquitectura

```
Navegador (public/: HTML, CSS, JS)
        │  HTTP + JSON
        ▼
servidor.pl  (SWI-Prolog: http/thread_httpd, http_json)
        │  consultas controladas
        ▼
base_conocimiento.pl  (hechos y reglas del sistema experto)
```

- `base_conocimiento.pl`: hechos (criterios, puntos, rubros, umbrales) y reglas de inferencia. Toda la lógica del sistema está aquí.
- `servidor.pl`: servicio web. Valida los datos recibidos, llama a los predicados de la base de conocimientos y devuelve JSON. No contiene reglas del dominio.
- `public/`: interfaz. Solo envía la selección del usuario y muestra lo que responde Prolog.
- `Dockerfile`: imagen basada en la oficial `swipl`, usada para el despliegue.

Todo corre en un solo servicio (alternativa C de los requerimientos), empaquetado con Docker y publicado en Render.

### API

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/criterios` | Catálogo de criterios (`criterio/4`) para construir el formulario |
| POST | `/api/evaluar` | Recibe `{"cumplidos": ["id1", "id2"]}` y devuelve nivel, puntos, faltantes, recomendaciones y puntos por rubro |
| GET | `/api/salud` | Comprobación de que el servicio está activo |

El servidor solo acepta identificadores que existan en `criterio/4`; nunca ejecuta texto enviado por el usuario como código Prolog.

### Predicados que el servidor consulta

| Predicado | Uso |
|---|---|
| `criterio(Id, Rubro, Puntos, Tipo)` | Catálogo de criterios |
| `nombre_criterio(Id, Texto)` | (opcional) Nombre legible del criterio |
| `nivel(Cumplidos, Nivel, Puntos)` | Nivel de certificación inferido |
| `faltante(Cumplidos, Id)` | Criterios obligatorios faltantes (todas las soluciones por backtracking) |
| `recomendacion(Cumplidos, Id)` | Criterios voluntarios recomendados |
| `puntos_rubro(Cumplidos, Rubro, Puntos)` | Puntos obtenidos por rubro |
| `explicacion(Cumplidos, Texto)` | (opcional) Explicación de la conclusión |

## Ejecución local

Requisitos: [SWI-Prolog](https://www.swi-prolog.org/download/stable) 9 o superior.

```bash
git clone https://github.com/PlowableClover/pces-experto.git
cd pces-experto
swipl servidor.pl
```

Abrir `http://localhost:8080`. Para usar otro puerto: `PORT=9000 swipl servidor.pl` (en Windows PowerShell: `$env:PORT=9000; swipl servidor.pl`).

Para hacer consultas directamente en Prolog, sin el servidor:

```bash
swipl base_conocimiento.pl
```

### Con Docker

```bash
docker build -t pces-experto .
docker run -p 8080:8080 pces-experto
```

## Despliegue en Render

1. Subir el repositorio a GitHub.
2. En [render.com](https://render.com) entrar con la cuenta de GitHub → **New → Web Service** → elegir este repositorio.
3. Render detecta el `Dockerfile` (runtime **Docker**). Plan **Free**. No hace falta comando de construcción ni de arranque: los toma del `Dockerfile`.
4. **Create Web Service**. Render asigna la variable `PORT` y el servidor la lee al iniciar.
5. Cada `git push` a `main` vuelve a desplegar la aplicación.

En el plan gratuito el servicio se suspende tras unos 15 minutos sin uso; la primera visita después tarda alrededor de un minuto en responder.

## Ejemplos de consultas

_(completar con las consultas y resultados reales de la base de conocimientos)_

```prolog
?- nivel([...], Nivel, Puntos).
?- faltante([...], Id).
```

Ejemplo de solicitud a la API:

```bash
curl -X POST https://URL/api/evaluar -H "Content-Type: application/json" -d '{"cumplidos": ["..."]}'
```

## Uso de IA generativa

- **Claude (Anthropic):** servidor HTTP (`servidor.pl`), interfaz web (`public/`), `Dockerfile`, configuración de Git y Render, y redacción de este README.
- La base de conocimientos (`base_conocimiento.pl`) fue elaborada sin IA, como lo exige la sección 4.2 de los requerimientos.

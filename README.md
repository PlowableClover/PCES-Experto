# Asistente de pre-evaluación PCES

Sistema experto en **SWI-Prolog**, con interfaz web, que pre-evalúa una edificación según el **Programa de Certificación de Edificaciones Sustentables (PCES)** de la Ciudad de México. A partir de las medidas que tiene la edificación, infiere qué acciones de sustentabilidad cubre, si cumple las cuatro acciones mínimas que exige el programa para acreditar, qué le falta, qué medidas podría agregar y qué indicadores y evidencias tendría que reportar según su etapa.

Práctica integradora del primer parcial · Paradigmas de Programación · ESCOM-IPN
Autor: Martínez Díaz Ian Arath (3BM2)

- **Aplicación publicada:** _(pegar aquí la URL de Render)_
- **Fuente normativa:** Aviso por el cual se da a conocer el Programa de Certificación de Edificaciones Sustentables de la Ciudad de México, *Gaceta Oficial de la Ciudad de México*, 6 de noviembre de 2023 (deja sin efectos al programa de 2020). Rubros (numeral 9.1), indicadores (tablas 1 a 5) y acciones mínimas (tabla 6, numeral 9.7).
- **Antecedente:** expediente PCES de una casa habitación en Jalapa 124, Col. Roma (proyecto escolar, CECyT 11), usado como caso de prueba.

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

- `base_conocimiento.pl`: hechos (rubros, acciones de sustentabilidad, medidas, indicadores y evidencias) y reglas de inferencia. Toda la lógica del sistema está aquí.
- `servidor.pl`: servicio web. Valida los datos recibidos, llama a los predicados de la base de conocimientos y devuelve JSON. No contiene reglas del dominio.
- `public/`: interfaz. Solo envía la selección del usuario y muestra lo que responde Prolog.
- `Dockerfile`: imagen basada en la oficial `swipl`, usada para el despliegue.

Todo corre en un solo servicio (alternativa C de los requerimientos), empaquetado con Docker y publicado en Render.

### API

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/catalogo` | Rubros, acciones y medidas para construir el formulario |
| POST | `/api/evaluar` | Recibe `{"etapa": "diseno" \| "operacion", "medidas": ["id1", "id2"]}` y devuelve las conclusiones del sistema experto |
| GET | `/api/salud` | Comprobación de que el servicio está activo |

El servidor solo acepta una etapa válida e identificadores que existan en `medida/2`; nunca ejecuta texto enviado por el usuario como código Prolog.

### Predicados que el servidor consulta

| Predicado | Uso |
|---|---|
| `rubro(Id, Nombre)` | Los cinco rubros del PCES |
| `accion(Id, Rubro, Tipo)` | Acciones de sustentabilidad; `Tipo` es `minima` u `opcional` |
| `nombre_accion(Id, Texto)` | (opcional) Nombre legible de la acción |
| `medida(Id, Accion)` | Medida concreta y acción que cubre (una medida puede cubrir varias) |
| `nombre_medida(Id, Texto)` | (opcional) Nombre legible de la medida |
| `dictamen(Medidas, Dictamen)` | `acredita` o `no_acredita` |
| `accion_cubierta(Medidas, Accion)` | Acciones cubiertas (varias soluciones) |
| `minima_faltante(Medidas, Accion)` | Acciones mínimas que faltan (varias soluciones) |
| `sugerencia(Medidas, Accion, Medida)` | Medidas que cubrirían una acción faltante |
| `rubro_sin_accion(Medidas, Rubro)` | Rubros sin ninguna acción cubierta |
| `indicador_reportar(Medidas, Accion, Indicador, Unidad)` | Indicadores que se deben reportar |
| `evidencia_requerida(Etapa, Medidas, Texto)` | Evidencias según la etapa |
| `explicacion(Etapa, Medidas, Texto)` | (opcional) Explicación de la conclusión |
| `avance(Medidas, Cubiertas, Total)` | (opcional) Acciones cubiertas del total |

## Ejecución local

Requisitos: [SWI-Prolog](https://www.swi-prolog.org/download/stable) 9 o superior.

```bash
git clone https://github.com/PlowableClover/PCES-Experto.git
cd PCES-Experto
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
?- dictamen([...], D).
?- minima_faltante([...], A).
```

Ejemplo de solicitud a la API:

```bash
curl -X POST https://URL/api/evaluar -H "Content-Type: application/json" -d '{"etapa": "diseno", "medidas": ["..."]}'
```

## Uso de IA generativa

- **Claude (Anthropic):** servidor HTTP (`servidor.pl`), interfaz web (`public/`), `Dockerfile`, configuración de Git y Render, y redacción de este README.
- La base de conocimientos (`base_conocimiento.pl`) fue elaborada sin IA, como lo exige la sección 4.2 de los requerimientos.

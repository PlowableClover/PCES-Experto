# Asistente de pre-evaluación PCES

Sistema experto en **SWI-Prolog**, con interfaz web, que pre-evalúa una edificación según el **Programa de Certificación de Edificaciones Sustentables (PCES)** de la Ciudad de México. A partir de las medidas que tiene la edificación, infiere qué acciones de sustentabilidad cubre, si cumple las cuatro acciones mínimas que exige el programa para acreditar, qué le falta, qué medidas podría agregar y qué indicadores y evidencias tendría que reportar según su etapa.

Práctica integradora del primer parcial · Paradigmas de Programación · ESCOM-IPN
Autor: Martínez Díaz Ian Arath (3BM2)

- **Aplicación publicada:** https://pces-experto.onrender.com
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
| `rubro/2`, `accion/3`, `nombre_accion/2`, `medida/2`, `nombre_medida/2` | Catálogo para construir el formulario |
| `dictamen/2` | `acredita` o `no_acredita` (numeral 9.7) |
| `accion_cubierta/2`, `accion_opcional_cubierta/2` | Acciones cubiertas por las medidas (varias soluciones) |
| `minima_faltante/2` | Acciones mínimas que faltan (varias soluciones) |
| `sugerencia/3` | Medidas que cubrirían una acción mínima faltante |
| `rubro_sin_accion/2` | Rubros sin ninguna acción cubierta |
| `avance/3` | Acciones cubiertas del total (conteo recursivo) |
| `indicador_reportar/3`, `evidencia_linea_base/3` | Indicadores de las tablas 1 a 5 y su evidencia según la etapa |
| `evidencia_accion/2` | Documentación de cada acción cubierta |
| `caso_prueba/2` | Caso de prueba Jalapa 124 (solo para el botón de la interfaz; no interviene en las reglas) |

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

Las 12 consultas de prueba de la sección D de `base_conocimiento.pl`, con los resultados obtenidos en SWI-Prolog (`;` pide la siguiente solución):

| # | Consulta | Resultado obtenido |
|---|---|---|
| 1 | `dictamen([], D).` | `D = no_acredita.` |
| 2 | `minima_faltante([], A).` | `reduccion_consumo_electrico ; reduccion_consumo_agua ; reduccion_valorizacion_residuos ; uso_materiales_reciclados` |
| 3 | `dictamen([luminarias_eficientes, inodoros_eficientes, reciclaje_residuos, uso_materiales_contenido_reciclado], D).` | `D = acredita.` |
| 4 | `minima_faltante([luminarias_eficientes, inodoros_eficientes, reciclaje_residuos], A).` | `A = uso_materiales_reciclados.` |
| 5 | `sugerencia([luminarias_eficientes, reciclaje_residuos, uso_materiales_contenido_reciclado], reduccion_consumo_agua, M).` | `inodoros_eficientes ; regaderas_bajo_flujo ; griferia_bajo_consumo ; riego_eficiente` |
| 6 | `accion_cubierta([paneles_fotovoltaicos], A).` | `A = energia_renovable.` |
| 7 | `rubro_sin_accion([luminarias_eficientes], R).` | `agua ; residuos ; calidad_vida ; impactos_ambientales` |
| 8 | `accion_opcional_cubierta([paneles_fotovoltaicos, captacion_agua_pluvial, naturacion_muros], A).` | `energia_renovable ; superficie_area_verde ; uso_agua_pluvial_tratada` |
| 9 | `avance([luminarias_eficientes, equipos_bombeo_eficientes], C, T).` | `C = 1, T = 10.` |
| 10 | `avance([...una medida por cada una de las 10 acciones...], C, T).` | `C = T, T = 10.` |
| 11 | `indicador_reportar(I, agua, M).` | 6 soluciones, todas con `M = m3` |
| 12 | `evidencia_linea_base(diseno, consumo_agua_potable_red, E).` / `evidencia_linea_base(operacion, consumo_agua_potable_red, E).` | `"Proyección de acuerdo a la memoria de cálculo"` / `"Recibo de SACMEX"` |

Caso completo de la casa Jalapa 124:

```prolog
?- caso_prueba(jalapa_124, M), dictamen(M, D), avance(M, C, T).
D = acredita, C = 8, T = 10.
```

Ejemplo de solicitud a la API:

```bash
curl -X POST https://pces-experto.onrender.com/api/evaluar -H "Content-Type: application/json" -d '{"etapa": "diseno", "medidas": ["..."]}'
```

## Uso de IA generativa

- **Claude (Anthropic):** servidor HTTP (`servidor.pl`), interfaz web (`public/`), `Dockerfile`, configuración de Git y Render, y redacción de este README.
- La base de conocimientos (`base_conocimiento.pl`) fue elaborada sin IA, como lo exige la sección 4.2 de los requerimientos.

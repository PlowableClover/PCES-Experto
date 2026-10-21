:- encoding(utf8).

/*
Objetivo: preevaluación académica de medidas de sustentabilidad conforme al PCES 2023.
Fuente principal: Gaceta Oficial de la CDMX, 6 de noviembre de 2023.
Jalapa 124 se utiliza únicamente como caso de prueba.
*/

% SECCION A: HECHOS NORMATIVOS

% Rubros

rubro(energia,
      "Ahorro y eficiencia energética").

rubro(agua,
      "Ahorro en el consumo de agua y su tratamiento").

rubro(residuos,
      "Manejo adecuado de los residuos generados").

rubro(calidad_vida,
      "Calidad de vida y responsabilidad social").

rubro(impactos_ambientales,
      "Mitigación de impactos ambientales").

% Acciones: accion(Id, Rubro, Tipo)

accion(reduccion_consumo_electrico, energia, minima).
accion(energia_renovable, energia, opcional).
accion(reduccion_consumo_combustibles, energia, opcional).

accion(reduccion_consumo_agua, agua, minima).
accion(uso_agua_pluvial_tratada, agua, opcional).

accion(reduccion_valorizacion_residuos, residuos, minima).

accion(campanas_educacion_ambiental_social, calidad_vida, opcional).

accion(superficie_area_verde, impactos_ambientales, opcional).
accion(uso_materiales_reciclados, impactos_ambientales, minima).
accion(reduccion_captura_gei, impactos_ambientales, opcional).

% Nombres de acciones

nombre_accion(reduccion_consumo_electrico,
              "Reducción en el consumo de energía eléctrica").

nombre_accion(energia_renovable,
              "Generación y consumo de energía de fuentes renovables").

nombre_accion(reduccion_consumo_combustibles,
              "Reducción en el consumo de combustibles").

nombre_accion(reduccion_consumo_agua,
              "Reducción en el consumo de agua").

nombre_accion(uso_agua_pluvial_tratada,
              "Consumo de agua pluvial y agua tratada dentro o fuera de la edificación").

nombre_accion(reduccion_valorizacion_residuos,
              "Reducción y valorización de residuos").

nombre_accion(campanas_educacion_ambiental_social,
              "Implementación de campañas de educación ambiental y social").

nombre_accion(superficie_area_verde,
              "Superficie de área verde").

nombre_accion(uso_materiales_reciclados,
              "Uso de materiales reciclados").

nombre_accion(reduccion_captura_gei,
              "Reducción y captura de gases de efecto invernadero dentro y fuera de la edificación").

% Etapas

etapa(diseno, "Diseño y construcción").
etapa(operacion, "Operación").

% Indicadores oficiales de las Tablas 1 a 5.
% Se reportan independientemente de las medidas seleccionadas.

% Energía
indicador(
    consumo_energia_red_electrica,
    energia,
    "Consumo de energía de la red eléctrica",
    kwh,
    "Proyección de acuerdo a la memoria de cálculo",
    "Recibo de pago de CFE"
).

indicador(
    consumo_energia_renovable_externa,
    energia,
    "Consumo de energía renovable generada fuera de la edificación",
    kwh,
    "Proyección de acuerdo a la memoria de cálculo",
    "Facturas de adquisición de energía eléctrica y/o reportes del proveedor"
).

indicador(
    consumo_energia_renovable_interna,
    energia,
    "Consumo de energía renovable generada dentro de la edificación",
    kwh,
    "Proyección de acuerdo a la memoria de cálculo",
    "Recibo de pago de CFE y/o reportes de generación y consumo"
).

indicador(
    consumo_combustibles,
    energia,
    "Consumo de combustibles, especificar por cada tipo de combustible",
    joules,
    "Proyección de acuerdo a la memoria de cálculo",
    "Recibos de pago a proveedores y/o facturas de compra y bitácoras de consumo"
).

% Agua
indicador(
    consumo_agua_potable_red,
    agua,
    "Consumo de agua potable de la red",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Recibo de SACMEX"
).

indicador(
    consumo_agua_potable_pipas,
    agua,
    "Consumo de agua potable proveniente de pipas",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Facturas de compra"
).

indicador(
    consumo_agua_tratada_interna,
    agua,
    "Consumo de agua tratada por la edificación",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Bitácoras de consumo"
).

indicador(
    uso_agua_tratada_externa,
    agua,
    "Consumo de agua tratada proveniente de la red o pipas o fuera de la edificación",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Facturas de compra"
).

indicador(
    generacion_agua_residual,
    agua,
    "Generación de agua residual",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Bitácoras de generación"
).

indicador(
    consumo_agua_pluvial,
    agua,
    "Consumo de agua pluvial",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Bitácoras de consumo"
).

% Residuos
indicador(
    generacion_residuos_por_tipo,
    residuos,
    "Generación de residuos por tipo de residuo según la clasificación secundaria",
    kg,
    "Proyección de acuerdo a la memoria de cálculo",
    "Bitácora de generación y manifiestos de entrega-recepción"
).

indicador(
    valorizacion_residuos_generados,
    residuos,
    "Valorización de residuos generados",
    kg,
    "Proyección de acuerdo a la memoria de cálculo",
    "Bitácora de generación y manifiestos de entrega-recepción"
).

% Calidad de vida
indicador(
    personas_alcanzadas_campanas,
    calidad_vida,
    "Impactos en campañas de información en temas de educación social y ambiental",
    personas,
    "Proyección de acuerdo a la memoria descriptiva",
    "Proyección de acuerdo a la memoria descriptiva y/o reportes de proveedores y/o reportes de aplicaciones"
).

% Impactos ambientales
indicador(
    superficie_area_verde_permeable,
    impactos_ambientales,
    "Superficie de área verde permeable",
    m2,
    "Plano del proyecto y memoria descriptiva",
    "Plano As-Build y memoria descriptiva"
).

indicador(
    superficie_naturacion_azoteas,
    impactos_ambientales,
    "Superficie de naturación en azoteas",
    m2,
    "Plano del proyecto y memoria descriptiva",
    "Plano As-Build y memoria descriptiva"
).

indicador(
    superficie_naturacion_muros,
    impactos_ambientales,
    "Superficie de naturación en muros",
    m2,
    "Plano del proyecto y memoria descriptiva",
    "Plano As-Build y memoria descriptiva"
).

indicador(
    uso_materiales_reciclados_costo_adquisicion,
    impactos_ambientales,
    "Materiales, insumos y productos con contenido reciclado",
    costo_adquisicion,
    "Proyección de compra",
    "Facturas de compra"
).

indicador(
    reduccion_captura_co2e,
    impactos_ambientales,
    "Reducción y captura de bióxido de carbono equivalente por la implementación de acciones dentro y fuera de la edificación",
    toneladas_co2e,
    "Proyección de acuerdo a la memoria de cálculo",
    "Memoria de cálculo"
).

indicador(
    uso_refrigerantes,
    impactos_ambientales,
    "Uso de refrigerantes en la edificación",
    m3,
    "Proyección de acuerdo a la memoria de cálculo",
    "Recibos de pago a proveedores y/o facturas de compra, bitácoras de consumo y manifiestos de entrega-recepción de residuos"
).

% Documentación por acción de sustentabilidad.

documentacion_accion(
    reduccion_consumo_electrico,
    [
        "Inventario de equipos conforme al numeral 6 del Anexo 1",
        "Registros de consumo conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Descripción de políticas conforme al numeral 11 del Anexo 1",
        "Descripción de procedimientos conforme al numeral 3 del Anexo 1",
        "Memorias descriptivas conforme al numeral 1 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Recibos de CFE"
    ]
).

documentacion_accion(
    energia_renovable,
    [
        "Memorias descriptivas conforme al numeral 1 del Anexo 1",
        "Registros de generación de energía renovable conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Registros de consumo conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Descripción de procedimientos conforme al numeral 3 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Recibos de CFE",
        "Contratos de interconexión",
        "Reportes de consumo de proveedores"
    ]
).

documentacion_accion(
    reduccion_consumo_combustibles,
    [
        "Inventario de equipos conforme al numeral 6 del Anexo 1",
        "Registros de consumo conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Descripción de políticas conforme al numeral 11 del Anexo 1",
        "Descripción de procedimientos conforme al numeral 3 del Anexo 1",
        "Memorias descriptivas conforme al numeral 1 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Recibos de adquisición de combustible"
    ]
).

documentacion_accion(
    reduccion_consumo_agua,
    [
        "Inventario de equipos conforme al numeral 6 del Anexo 1",
        "Registros de consumo conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Descripción de políticas conforme al numeral 11 del Anexo 1",
        "Descripción de procedimientos conforme al numeral 3 del Anexo 1",
        "Memorias descriptivas conforme al numeral 1 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Recibos de consumo de agua potable y/o tratada"
    ]
).

documentacion_accion(
    uso_agua_pluvial_tratada,
    [
        "Memorias descriptivas conforme al numeral 1 del Anexo 1",
        "Registros de generación de agua tratada y agua cosechada conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Registros de consumo de agua tratada y pluvial conforme a la Tabla 1 del numeral 2 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Recibos de SACMEX",
        "Recibos de compra de agua tratada"
    ]
).

documentacion_accion(
    reduccion_valorizacion_residuos,
    [
        "Plan de manejo de residuos de competencia local",
        "Bitácoras de generación y valorización de residuos conforme a la Tabla 2 del numeral 2 del Anexo 1",
        "Descripción de políticas conforme al numeral 11 del Anexo 1",
        "Descripción de procedimientos conforme al numeral 3 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Manifiestos de entrega-recepción"
    ]
).

documentacion_accion(
    campanas_educacion_ambiental_social,
    [
        "Descripción de la campaña de educación ambiental o social conforme al numeral 11 del Anexo 1",
        "Memorias fotográficas conforme al numeral 4 del Anexo 1",
        "Registros del alcance de las campañas conforme al numeral 8 del Anexo 1",
        "Material de difusión utilizado conforme al numeral 11 del Anexo 1"
    ]
).

documentacion_accion(
    superficie_area_verde,
    [
        "Memoria descriptiva conforme al numeral 1 del Anexo 1",
        "Memorias fotográficas conforme al numeral 4 del Anexo 1",
        "Planos",
        "Inventario de la paleta vegetal conforme al numeral 7 del Anexo 1",
        "Programa de mantenimiento conforme al numeral 12 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Convenios o autorizaciones"
    ]
).

documentacion_accion(
    uso_materiales_reciclados,
    [
        "Memoria descriptiva conforme al numeral 1 del Anexo 1",
        "Inventario de productos conforme al numeral 9 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos"
    ]
).

documentacion_accion(
    reduccion_captura_gei,
    [
        "Memoria descriptiva conforme al numeral 1 del Anexo 1",
        "Manual de procedimiento conforme al numeral 3 del Anexo 1",
        "Memoria fotográfica conforme al numeral 4 del Anexo 1",
        "Inventario de equipos conforme al numeral 6 del Anexo 1",
        "Inventario de productos conforme al numeral 9 del Anexo 1",
        "Memoria de cálculo conforme al numeral 10 del Anexo 1",
        "Descripción de políticas conforme al numeral 11 del Anexo 1",
        "Facturas",
        "Fichas técnicas",
        "Contratos",
        "Convenios o autorizaciones",
        "Reportes de proveedores"
    ]
).

% SECCION B: CONOCIMIENTO EXPERTO
% medida/2 relaciona una medida con la acción que puede apoyar preliminarmente.

% Energía eléctrica
medida(luminarias_eficientes, reduccion_consumo_electrico).
medida(equipos_bombeo_eficientes, reduccion_consumo_electrico).
medida(climatizacion_eficiente, reduccion_consumo_electrico).
medida(automatizacion_sistemas_electricos, reduccion_consumo_electrico).
medida(diseno_bioclimatico, reduccion_consumo_electrico).

% Energía renovable
medida(paneles_fotovoltaicos, energia_renovable).
medida(calentadores_solares, energia_renovable).
medida(generadores_eolicos, energia_renovable).
medida(energia_renovable_externa, energia_renovable).

% Combustibles
medida(equipos_combustion_eficientes, reduccion_consumo_combustibles).
medida(automatizacion_sistemas_combustion, reduccion_consumo_combustibles).
medida(aislamiento_tuberias, reduccion_consumo_combustibles).

% Consumo de agua
medida(inodoros_eficientes, reduccion_consumo_agua).
medida(regaderas_bajo_flujo, reduccion_consumo_agua).
medida(griferia_bajo_consumo, reduccion_consumo_agua).
medida(riego_eficiente, reduccion_consumo_agua).

% Agua pluvial y tratada
medida(tratamiento_reuso_agua_residual, uso_agua_pluvial_tratada).
medida(uso_agua_tratada_externa, uso_agua_pluvial_tratada).
medida(captacion_agua_pluvial, uso_agua_pluvial_tratada).

% Residuos
medida(consumo_responsable, reduccion_valorizacion_residuos).
medida(reutilizacion_residuos, reduccion_valorizacion_residuos).
medida(reciclaje_residuos, reduccion_valorizacion_residuos).
medida(valorizacion_residuos, reduccion_valorizacion_residuos).

% Educación ambiental y social
medida(campana_electronica, campanas_educacion_ambiental_social).
medida(campana_impresa, campanas_educacion_ambiental_social).
medida(campana_presencial, campanas_educacion_ambiental_social).

% Área verde
medida(conservacion_area_verde_permeable, superficie_area_verde).
medida(naturacion_azotea, superficie_area_verde).
medida(naturacion_muros, superficie_area_verde).
medida(vegetacion_nativa, superficie_area_verde).

% Materiales reciclados
medida(uso_materiales_contenido_reciclado, uso_materiales_reciclados).

% GEI
medida(refrigerantes_bajo_pca, reduccion_captura_gei).
medida(control_fugas_refrigerantes, reduccion_captura_gei).

% Nombres de medidas

nombre_medida(luminarias_eficientes,
              "Luminarias de alta eficiencia energética").
nombre_medida(equipos_bombeo_eficientes,
              "Bombas y equipos de bombeo de alta eficiencia").
nombre_medida(climatizacion_eficiente,
              "Equipos eficientes de climatización y ventilación").
nombre_medida(automatizacion_sistemas_electricos,
              "Automatización y control de sistemas eléctricos").
nombre_medida(diseno_bioclimatico,
              "Diseño bioclimático con aprovechamiento de iluminación y ventilación natural").

nombre_medida(paneles_fotovoltaicos,
              "Sistema solar fotovoltaico").
nombre_medida(calentadores_solares,
              "Calentadores solares").
nombre_medida(generadores_eolicos,
              "Generadores eólicos").
nombre_medida(energia_renovable_externa,
              "Consumo de energía renovable generada fuera de la edificación").

nombre_medida(equipos_combustion_eficientes,
              "Equipos de combustión de alta eficiencia").
nombre_medida(automatizacion_sistemas_combustion,
              "Automatización y control de sistemas que consumen combustibles").
nombre_medida(aislamiento_tuberias,
              "Aislamiento de tuberías para reducir pérdidas de energía").

nombre_medida(inodoros_eficientes,
              "Inodoros de bajo consumo o doble descarga").
nombre_medida(regaderas_bajo_flujo,
              "Regaderas de bajo flujo").
nombre_medida(griferia_bajo_consumo,
              "Grifería y mezcladoras de bajo consumo").
nombre_medida(riego_eficiente,
              "Sistema de riego eficiente").

nombre_medida(tratamiento_reuso_agua_residual,
              "Tratamiento y reúso de agua residual en sitio").
nombre_medida(uso_agua_tratada_externa,
              "Uso de agua tratada proveniente de fuera de la edificación").
nombre_medida(captacion_agua_pluvial,
              "Captación y aprovechamiento de agua pluvial").

nombre_medida(consumo_responsable,
              "Prácticas de consumo responsable para prevenir la generación de residuos").
nombre_medida(reutilizacion_residuos,
              "Reutilización de materiales y residuos").
nombre_medida(reciclaje_residuos,
              "Reciclaje de residuos sólidos").
nombre_medida(valorizacion_residuos,
              "Valorización y aprovechamiento de residuos").

nombre_medida(campana_electronica,
              "Campaña electrónica de educación ambiental o social").
nombre_medida(campana_impresa,
              "Campaña impresa de educación ambiental o social").
nombre_medida(campana_presencial,
              "Campaña presencial de educación ambiental o social").

nombre_medida(conservacion_area_verde_permeable,
              "Conservación de área verde permeable").
nombre_medida(naturacion_azotea,
              "Naturación de azoteas").
nombre_medida(naturacion_muros,
              "Naturación de muros o fachadas").
nombre_medida(vegetacion_nativa,
              "Incorporación de especies vegetales nativas").

nombre_medida(uso_materiales_contenido_reciclado,
              "Uso de materiales o insumos con contenido reciclado").

nombre_medida(refrigerantes_bajo_pca,
              "Uso de refrigerantes de menor potencial de calentamiento atmosférico").
nombre_medida(control_fugas_refrigerantes,
              "Prevención, detección y control de fugas de refrigerantes").

% SECCION C: REGLAS DE INFERENCIA

% 1. Lista única de acciones cubiertas.
acciones_cubiertas_lista(Medidas, AccionesUnicas) :-
    findall(
        Accion,
        (member(Medida, Medidas), medida(Medida, Accion)),
        Acciones
    ),
    sort(Acciones, AccionesUnicas).

% 2. Acciones cubiertas.
accion_cubierta(Medidas, Accion) :-
    acciones_cubiertas_lista(Medidas, Acciones),
    member(Accion, Acciones).

% 3. Acciones mínimas faltantes.
minima_faltante(Medidas, Accion) :-
    accion(Accion, _, minima),
    \+ accion_cubierta(Medidas, Accion).

% 4. Verifica las acciones mínimas.
cumple_minimas(Medidas) :-
    \+ minima_faltante(Medidas, _).

% 5. Dictamen preliminar.
dictamen(Medidas, acredita) :-
    cumple_minimas(Medidas),
    !.

dictamen(_, no_acredita).

% 6. Sugerencias para mínimos faltantes.
sugerencia(Medidas, Accion, Medida) :-
    minima_faltante(Medidas, Accion),
    medida(Medida, Accion),
    \+ member(Medida, Medidas).

% 7. Rubros sin acción cubierta.
rubro_sin_accion(Medidas, Rubro) :-
    rubro(Rubro, _),
    \+ (
        accion_cubierta(Medidas, Accion),
        accion(Accion, Rubro, _)
    ).

% 8. Acciones opcionales cubiertas.
accion_opcional_cubierta(Medidas, Accion) :-
    accion_cubierta(Medidas, Accion),
    accion(Accion, _, opcional).

% 9. Conteo recursivo.
contar_lista([], 0).

contar_lista([_|Resto], Total) :-
    contar_lista(Resto, Parcial),
    Total is Parcial + 1.

% 10. Total de acciones.
total_acciones(Total) :-
    findall(A, accion(A, _, _), Acciones),
    sort(Acciones, AccionesUnicas),
    contar_lista(AccionesUnicas, Total).

% 11. Avance interno.
avance(Medidas, Cubiertas, Total) :-
    acciones_cubiertas_lista(Medidas, Acciones),
    contar_lista(Acciones, Cubiertas),
    total_acciones(Total).

% 12. Indicadores a reportar.
indicador_reportar(Indicador, Rubro, Metrica) :-
    indicador(Indicador, Rubro, _, Metrica, _, _).

% 13. Evidencia de línea base.
evidencia_linea_base(diseno, Indicador, Evidencia) :-
    indicador(Indicador, _, _, _, Evidencia, _).

evidencia_linea_base(operacion, Indicador, Evidencia) :-
    indicador(Indicador, _, _, _, _, Evidencia).

% 14. Documentación por acción.
evidencia_accion(Accion, Evidencia) :-
    documentacion_accion(Accion, Evidencias),
    member(Evidencia, Evidencias).

/*
SECCION D: CONSULTAS DE PRUEBA

   1) Lista vacia:
      ?- dictamen([], D).
      Esperado: D = no_acredita.

   2) Backtracking de acciones minimas faltantes:
      ?- minima_faltante([], A).
      Esperado: cuatro soluciones al presionar ;.

   3) Las cuatro acciones minimas cubiertas:
      ?- dictamen([
             luminarias_eficientes,
             inodoros_eficientes,
             reciclaje_residuos,
             uso_materiales_contenido_reciclado
         ], D).
      Esperado: D = acredita.

   4) Falta exactamente materiales reciclados:
      ?- minima_faltante([
             luminarias_eficientes,
             inodoros_eficientes,
             reciclaje_residuos
         ], A).
      Esperado: A = uso_materiales_reciclados.

   5) Sugerencias por backtracking:
      ?- sugerencia([
             luminarias_eficientes,
             reciclaje_residuos,
             uso_materiales_contenido_reciclado
         ], reduccion_consumo_agua, M).
      Esperado: varias soluciones, por ejemplo:
      M = inodoros_eficientes ;
      M = regaderas_bajo_flujo ;
      M = griferia_bajo_consumo ;
      M = riego_eficiente.

   6) Accion cubierta por un sistema fotovoltaico:
      ?- accion_cubierta([paneles_fotovoltaicos], A).
      Esperado: A = energia_renovable.

   7) Rubros sin acciones:
      ?- rubro_sin_accion([luminarias_eficientes], R).
      Esperado: varias soluciones por backtracking.

   8) Acciones opcionales cubiertas:
      ?- accion_opcional_cubierta([
             paneles_fotovoltaicos,
             captacion_agua_pluvial,
             naturacion_muros
         ], A).
      Esperado: tres soluciones por backtracking.

   9) Dos medidas de la misma accion no duplican el avance:
      ?- avance([luminarias_eficientes, equipos_bombeo_eficientes], C, T).
      Esperado: C = 1, T = 10.

   10) Una medida representativa de cada accion:
       ?- avance([
              luminarias_eficientes,
              paneles_fotovoltaicos,
              equipos_combustion_eficientes,
              inodoros_eficientes,
              captacion_agua_pluvial,
              reciclaje_residuos,
              campana_presencial,
              naturacion_muros,
              uso_materiales_contenido_reciclado,
              refrigerantes_bajo_pca
          ], C, T).
       Esperado: C = 10, T = 10.

   11) Indicadores del rubro agua:
       ?- indicador_reportar(I, agua, M).
       Esperado: seis soluciones por backtracking.

   12) La evidencia de linea base cambia con la etapa:
       ?- evidencia_linea_base(diseno, consumo_agua_potable_red, E).
       Esperado: E = "Proyección de acuerdo a la memoria de cálculo".

       ?- evidencia_linea_base(operacion, consumo_agua_potable_red, E).
       Esperado: E = "Recibo de SACMEX".

       La documentacion especifica de una accion puede consultarse aparte:
       ?- evidencia_accion(energia_renovable, E).

*/

/*
   SECCION E. CASO DE PRUEBA: JALAPA 124

   Este caso NO forma parte de la normativa ni modifica los hechos del
   PCES. Solo traduce a medidas generales algunas estrategias documentadas
   en el expediente académico de Jalapa 124 para probar el motor.

   No se marca reduccion_consumo_combustibles ni reduccion_captura_gei,
   porque el expediente no demuestra una medida independiente y clara
   para esas acciones sin reutilizar estrategias ya clasificadas en otros
   rubros.
*/

caso_prueba(
    jalapa_124,
    [
        luminarias_eficientes,
        automatizacion_sistemas_electricos,
        diseno_bioclimatico,
        paneles_fotovoltaicos,
        inodoros_eficientes,
        griferia_bajo_consumo,
        captacion_agua_pluvial,
        reciclaje_residuos,
        campana_impresa,
        campana_electronica,
        conservacion_area_verde_permeable,
        naturacion_muros,
        vegetacion_nativa,
        uso_materiales_contenido_reciclado
    ]
).

/*
Consulta de ejemplo:
?- caso_prueba(jalapa_124, M), dictamen(M, D), avance(M, Cubiertas, Total).
Esperado: D = acredita, Cubiertas = 8, Total = 10.
*/

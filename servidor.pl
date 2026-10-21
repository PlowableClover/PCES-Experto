:- encoding(utf8).
/*  servidor.pl  -  Servicio web del Asistente PCES (versión 2023)

    Este archivo SOLO contiene la integración: servidor HTTP, validación de
    datos y conversión a JSON. No contiene hechos ni reglas del sistema
    experto; toda la lógica está en base_conocimiento.pl.

    Elaborado con apoyo de IA generativa (Claude, Anthropic) para la parte de
    integración frontend-backend, como lo permite la sección 4.2 de los
    requerimientos de la práctica.
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(time)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- ensure_loaded(base_conocimiento).

:- initialization(main, main).

:- dynamic dir_publico/1.
:- prolog_load_context(directory, D),
   directory_file_path(D, public, Pub),
   asserta(dir_publico(Pub)).

/* ----------------------------------------------------------------------
   Rutas
   ---------------------------------------------------------------------- */

:- http_handler(root(api/salud), salud, []).
:- http_handler(root(api/catalogo), catalogo, []).
:- http_handler(root(api/evaluar), evaluar, [method(post)]).
:- http_handler(root(api/caso), caso, []).
:- http_handler(root(.), archivos, [prefix]).

main :-
    (   getenv('PORT', P), atom_number(P, Port) -> true ; Port = 8080 ),
    http_server(http_dispatch, [port(Port)]),
    format(user_error, "Servidor PCES escuchando en el puerto ~w~n", [Port]),
    thread_get_message(_).                  % mantiene vivo el proceso

archivos(Request) :-
    dir_publico(Pub),
    http_reply_from_files(Pub, [indexes(['index.html'])], Request), !.
archivos(Request) :-
    http_404([], Request).

% GET /api/caso -> medidas del caso de prueba (si está definido)
caso(_) :-
    una(caso_prueba(jalapa_124, L), L, Res),
    (   is_list(Res) -> Medidas = Res ; Medidas = [] ),
    reply_json_dict(_{caso: "jalapa_124", medidas: Medidas}).

salud(_) :-
    reply_json_dict(_{estado: "ok"}).

/* ----------------------------------------------------------------------
   GET /api/catalogo  ->  rubros, acciones y medidas para la interfaz
   ---------------------------------------------------------------------- */

catalogo(_) :-
    todas(R, rubro_json(R), Rubros),
    todas(A, accion_json(A), Acciones),
    todas(M, medida_json(M), Medidas),
    reply_json_dict(_{rubros: Rubros, acciones: Acciones, medidas: Medidas}).

rubro_json(_{id: Id, nombre: N}) :-
    rubro(Id, N0), texto(N0, N).

accion_json(_{id: Id, nombre: N, rubro: R, tipo: T}) :-
    accion(Id, R, T), nombre_de(accion, Id, N).

medida_json(_{id: Id, nombre: N, acciones: As}) :-
    findall(M, medida(M, _), Ids0), list_to_set(Ids0, Ids), member(Id, Ids),
    findall(A, medida(Id, A), As0), list_to_set(As0, As),
    nombre_de(medida, Id, N).

nombre_de(accion, Id, N) :- current_predicate(nombre_accion/2), nombre_accion(Id, N0), !, texto(N0, N).
nombre_de(medida, Id, N) :- current_predicate(nombre_medida/2), nombre_medida(Id, N0), !, texto(N0, N).
nombre_de(_, Id, N) :- texto(Id, N).

/* ----------------------------------------------------------------------
   POST /api/evaluar   {"etapa": "diseno" | "operacion", "medidas": [...]}
   ---------------------------------------------------------------------- */

evaluar(Request) :-
    catch(http_read_json_dict(Request, Datos), _, fail), !,
    validar(Datos).
evaluar(_) :-
    error_json(400, "La solicitud no tiene un formato JSON válido.").

validar(Datos) :-
    get_dict(etapa, Datos, E0), a_atomo(E0, Etapa),
    memberchk(Etapa, [diseno, operacion]), !,
    (   get_dict(medidas, Datos, L), is_list(L)
    ->  validar_medidas(Etapa, L)
    ;   error_json(400, "Falta la lista de medidas.")
    ).
validar(_) :-
    error_json(400, "Indica la etapa: diseño y construcción u operación.").

validar_medidas(_, []) :- !,
    reply_json_dict(_{ok: false, tipo: "datos_incompletos",
                      mensaje: "Selecciona al menos una medida que tenga la edificación."}).
validar_medidas(_, L) :-
    length(L, N), N > 300, !,
    error_json(400, "Demasiados elementos en la solicitud.").
validar_medidas(Etapa, L) :-
    maplist(a_atomo, L, Ats),
    exclude(es_medida, Ats, Desc),
    (   Desc == []
    ->  sort(Ats, Medidas),
        responder(Etapa, Medidas)
    ;   atomic_list_concat(Desc, ', ', Txt),
        format(string(Msg), "Medidas no reconocidas: ~w", [Txt]),
        error_json(400, Msg)
    ).

a_atomo(X, A) :- string(X), !, atom_string(A, X).
a_atomo(X, X) :- atom(X), !.
a_atomo(X, A) :- term_to_atom(X, A).

es_medida(M) :- medida(M, _), !.

/* ----------------------------------------------------------------------
   Consultas al motor de inferencia (base_conocimiento.pl)
   ---------------------------------------------------------------------- */

responder(Etapa, M) :-
    una(dictamen(M, D), D, Dict),
    todas(A, accion_cubierta(M, A), Cub),
    todas(A1, accion_opcional_cubierta(M, A1), Opc),
    todas(A2, minima_faltante(M, A2), Falt),
    todas(A3-Me, sugerencia(M, A3, Me), Sug),
    todas(R, rubro_sin_accion(M, R), SinAcc),
    todas(I-Ru-Mt, indicador_reportar(I, Ru, Mt), Ind),
    todas(A4-Ev, (accion_cubierta(M, A4), evidencia_accion(A4, Ev)), Docs),
    todas(T2, explicacion(Etapa, M, T2), Expl),
    una(avance(M, C, Tot), C-Tot, Av),
    maplist(accion_item, Cub, CubJ),
    maplist(accion_item, Falt, FaltJ),
    maplist(sug_item, Sug, SugJ),
    maplist(rubro_item, SinAcc, SinJ),
    maplist(ind_item(Etapa), Ind, IndJ),
    maplist(doc_item, Docs, DocJ),
    maplist(texto, Expl, ExJ),
    (   Av = C1-T1 -> AvJ = _{cubiertas: C1, total: T1} ; AvJ = null ),
    length(M, NM),
    reply_json_dict(_{ok: true, etapa: Etapa, dictamen: Dict, seleccionadas: NM,
                      acciones_cubiertas: CubJ, opcionales_cubiertas: Opc,
                      minimas_faltantes: FaltJ, sugerencias: SugJ,
                      rubros_sin_accion: SinJ, indicadores: IndJ,
                      documentacion: DocJ, explicacion: ExJ, avance: AvJ}).

% una/3: primera solución de Meta (null si falla, no existe o hay error)
una(Meta, Plantilla, Res) :-
    catch(call_with_time_limit(3, (once(Meta) -> Res = Plantilla ; Res = null)), _, Res = null).

% todas/3: todas las soluciones distintas obtenidas por backtracking
todas(Plantilla, Meta, Lista) :-
    catch(call_with_time_limit(3, findall(Plantilla, Meta, L0)), _, L0 = []),
    list_to_set(L0, Lista).

accion_item(Id, _{id: Id, nombre: N, rubro: R, tipo: T}) :-
    accion(Id, R, T), !, nombre_de(accion, Id, N).
accion_item(Id, _{id: Id, nombre: N}) :- texto(Id, N).

sug_item(A-M, _{accion: A, accion_nombre: NA, medida: M, medida_nombre: NM}) :-
    nombre_de(accion, A, NA), nombre_de(medida, M, NM).

rubro_item(Id, _{id: Id, nombre: N}) :-
    ( rubro(Id, N0) -> texto(N0, N) ; texto(Id, N) ).

% indicador_reportar(Indicador, Rubro, Metrica) y su evidencia de línea base según la etapa
ind_item(Etapa, I-R-Mt, _{id: I, rubro: R, rubro_nombre: RN, indicador: IT, metrica: MT, evidencia: ET}) :-
    rubro_item(R, _{id: _, nombre: RN}),
    ( catch(indicador(I, _, Txt, _, _, _), _, fail) -> texto(Txt, IT) ; texto(I, IT) ),
    texto(Mt, MT),
    una(evidencia_linea_base(Etapa, I, E), E, E1),
    ( E1 == null -> ET = null ; texto(E1, ET) ).

doc_item(A-Ev, _{accion: A, accion_nombre: NA, documento: DT}) :-
    nombre_de(accion, A, NA), texto(Ev, DT).

texto(T, S) :- string(T), !, S = T.
texto(T, S) :- format(string(S), "~w", [T]).

error_json(Status, Mensaje) :-
    reply_json_dict(_{ok: false, tipo: "error", mensaje: Mensaje}, [status(Status)]).

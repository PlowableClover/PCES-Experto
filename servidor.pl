/*  servidor.pl  -  Servicio web del Asistente de pre-evaluacion PCES

    Este archivo SOLO contiene la integracion (servidor HTTP, validacion de
    datos y conversion a JSON). No contiene hechos ni reglas del sistema
    experto: toda la logica esta en base_conocimiento.pl.

    Elaborado con apoyo de IA generativa (Claude, Anthropic) para la parte de
    integracion frontend-backend, como lo permite la seccion 4.2 de los
    requerimientos.
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_client)).
:- use_module(library(time)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- ensure_loaded(base_conocimiento).

:- initialization(main, main).

/* ----------------------------------------------------------------------
   Rutas
   ---------------------------------------------------------------------- */

:- dynamic dir_publico/1.
:- prolog_load_context(directory, D),
   directory_file_path(D, public, Pub),
   asserta(dir_publico(Pub)).

:- http_handler(root(.), archivos, [prefix]).
:- http_handler(root(api/salud), salud, []).
:- http_handler(root(api/criterios), criterios, []).
:- http_handler(root(api/evaluar), evaluar, [method(post)]).

main :-
    (   getenv('PORT', P), atom_number(P, Port) -> true ; Port = 8080 ),
    http_server(http_dispatch, [port(Port)]),
    format(user_error, "Servidor PCES escuchando en el puerto ~w~n", [Port]),
    thread_get_message(_).          % mantiene vivo el proceso

archivos(Request) :-
    dir_publico(Pub),
    http_reply_from_files(Pub, [indexes(['index.html'])], Request).
archivos(Request) :-
    http_404([], Request).

salud(_Request) :-
    reply_json_dict(_{estado: "ok"}).

/* ----------------------------------------------------------------------
   GET /api/criterios  ->  catalogo para construir el formulario
   ---------------------------------------------------------------------- */

criterios(_Request) :-
    findall(C, criterio_json(C), Lista),
    reply_json_dict(_{criterios: Lista}).

criterio_json(_{id: Id, nombre: Nombre, rubro: Rubro, puntos: Puntos, tipo: Tipo}) :-
    criterio(Id, Rubro, Puntos, Tipo),
    nombre_de(Id, Nombre).

nombre_de(Id, Nombre) :-
    current_predicate(nombre_criterio/2),
    nombre_criterio(Id, Nombre), !.
nombre_de(Id, Id).

/* ----------------------------------------------------------------------
   POST /api/evaluar   {"cumplidos": ["id1", "id2", ...]}
   ---------------------------------------------------------------------- */

evaluar(Request) :-
    catch(http_read_json_dict(Request, Datos), _, fail), !,
    procesar(Datos).
evaluar(_) :-
    error_json(400, "La solicitud no tiene un formato JSON valido.").

procesar(Datos) :-
    (   get_dict(cumplidos, Datos, Lista), is_list(Lista)
    ->  validar(Lista)
    ;   error_json(400, "Falta la lista de criterios cumplidos.")
    ).

validar([]) :- !,
    reply_json_dict(_{ok: false, tipo: "datos_incompletos",
                      mensaje: "Selecciona al menos un criterio que cumpla la edificacion."}).
validar(Lista) :-
    length(Lista, N), N > 200, !,
    error_json(400, "Demasiados elementos en la solicitud.").
validar(Lista) :-
    maplist(a_atomo, Lista, Atomos),
    exclude(es_criterio, Atomos, Desconocidos),
    (   Desconocidos == []
    ->  sort(Atomos, Cumplidos),
        responder(Cumplidos)
    ;   atomic_list_concat(Desconocidos, ', ', Txt),
        format(string(M), "Criterios no reconocidos: ~w", [Txt]),
        error_json(400, M)
    ).

a_atomo(X, A) :- string(X), !, atom_string(A, X).
a_atomo(X, X) :- atom(X), !.
a_atomo(X, A) :- term_to_atom(X, A).

es_criterio(Id) :- criterio(Id, _, _, _), !.

/* ----------------------------------------------------------------------
   Consultas al motor de inferencia (base_conocimiento.pl)
   ---------------------------------------------------------------------- */

responder(Cumplidos) :-
    una(nivel(Cumplidos, Nivel, Puntos), [Nivel, Puntos], ResNivel),
    todas(Id, faltante(Cumplidos, Id), Faltantes),
    todas(Id2, recomendacion(Cumplidos, Id2), Recs),
    todas(R-P, puntos_rubro(Cumplidos, R, P), Rubros),
    todas(T, opcional_explicacion(Cumplidos, T), Expl),
    maplist(item_json, Faltantes, FJ),
    maplist(item_json, Recs, RJ),
    maplist(rubro_json, Rubros, RubJ),
    maplist(texto, Expl, EJ),
    (   ResNivel = [N0, P0]
    ->  Base = _{ok: true, nivel: N0, puntos: P0}
    ;   Base = _{ok: true, nivel: null, puntos: null,
                 mensaje: "El sistema no pudo inferir un nivel con los datos proporcionados."}
    ),
    length(Cumplidos, NC),
    reply_json_dict(Base.put(_{seleccionados: NC, faltantes: FJ, recomendaciones: RJ,
                               rubros: RubJ, explicacion: EJ})).

opcional_explicacion(C, T) :-
    current_predicate(explicacion/2),
    explicacion(C, T).

% una/3: primera solucion de Meta (o [] si falla o hay error)
una(Meta, Plantilla, Res) :-
    catch(call_with_time_limit(3, (once(Meta) -> Res = Plantilla ; Res = [])), _, Res = []).

% todas/3: todas las soluciones distintas por backtracking
todas(Plantilla, Meta, Lista) :-
    catch(call_with_time_limit(3, findall(Plantilla, Meta, L0)), _, L0 = []),
    list_to_set(L0, Lista).

item_json(Id, _{id: Id, nombre: Nombre, rubro: R, puntos: P, tipo: T}) :-
    criterio(Id, R, P, T), !, nombre_de(Id, Nombre).
item_json(Id, _{id: Id, nombre: Id}).

rubro_json(R-P, _{rubro: R, puntos: P}).

texto(T, S) :- ( string(T) -> S = T ; format(string(S), "~w", [T]) ).

error_json(Status, Mensaje) :-
    reply_json_dict(_{ok: false, tipo: "error", mensaje: Mensaje}, [status(Status)]).

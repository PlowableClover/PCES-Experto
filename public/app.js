// Interfaz del Asistente PCES.
// Solo envía datos al servidor y muestra lo que responde Prolog:
// aquí no se decide ninguna conclusión.

// Medidas de la casa de Jalapa 124 (expediente PCES del CECyT 11).
// Escribe aquí los identificadores tal como los definiste en base_conocimiento.pl.
const CASO_JALAPA = [];

const $ = (s) => document.querySelector(s);
let cat = { rubros: [], acciones: [], medidas: [] };

const bonito = (x) => {
  const s = String(x ?? '').replace(/_/g, ' ');
  return s.charAt(0).toUpperCase() + s.slice(1);
};
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function cargarCatalogo() {
  try {
    const r = await fetch('/api/catalogo');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    cat = await r.json();
    pintarLista();
  } catch (e) {
    $('#lista').innerHTML = `<p class="error">No se pudo obtener el catálogo del servidor (${esc(e.message)}). Si el servicio estaba dormido, espera unos segundos y recarga.</p>`;
  }
}

function pintarLista() {
  if (!cat.medidas.length) {
    $('#lista').innerHTML = '<p class="error">La base de conocimientos no tiene medidas cargadas.</p>';
    return;
  }
  const accion = Object.fromEntries(cat.acciones.map((a) => [a.id, a]));
  const grupos = new Map(cat.rubros.map((r) => [r.id, { nombre: r.nombre, medidas: [] }]));
  const otros = { nombre: 'Otras medidas', medidas: [] };
  cat.medidas.forEach((m) => {
    const rub = accion[m.acciones[0]]?.rubro;
    (grupos.get(rub) || otros).medidas.push(m);
  });
  const lista = [...grupos.values(), otros].filter((g) => g.medidas.length);
  $('#lista').innerHTML = lista.map((g) => `
    <fieldset class="rubro">
      <legend>${esc(bonito(g.nombre))}</legend>
      ${g.medidas.map((m) => `
        <label class="item">
          <input type="checkbox" value="${esc(m.id)}">
          <span class="nombre">${esc(bonito(m.nombre))}
            <small>${m.acciones.map((a) => esc(bonito(accion[a]?.nombre ?? a))).join(' · ')}</small></span>
        </label>`).join('')}
    </fieldset>`).join('');
  document.querySelectorAll('#lista input').forEach((i) => i.addEventListener('change', contar));
  $('#btn-caso').hidden = !CASO_JALAPA.some((id) => cat.medidas.some((m) => m.id === id));
  contar();
}

const seleccionadas = () => [...document.querySelectorAll('#lista input:checked')].map((i) => i.value);
const etapa = () => document.querySelector('input[name="etapa"]:checked')?.value;
const contar = () => { const n = seleccionadas().length; $('#contador').textContent = `${n} seleccionada${n === 1 ? '' : 's'}`; };
const marcar = (ids) => { document.querySelectorAll('#lista input').forEach((i) => (i.checked = ids.includes(i.value))); contar(); };

async function evaluar() {
  const btn = $('#btn-evaluar');
  btn.disabled = true; btn.textContent = 'Consultando a Prolog…';
  try {
    const r = await fetch('/api/evaluar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ etapa: etapa(), medidas: seleccionadas() }),
    });
    const d = await r.json().catch(() => ({ ok: false, mensaje: 'Respuesta no válida del servidor.' }));
    mostrar(d);
  } catch (e) {
    mostrar({ ok: false, mensaje: 'No hay conexión con el servidor. Intenta de nuevo en unos segundos.' });
  } finally {
    btn.disabled = false; btn.textContent = 'Evaluar edificación';
  }
}

const bloque = (titulo, n, cuerpo) => `<div class="bloque"><h3>${titulo}${n == null ? '' : ` <span class="num">${n}</span>`}</h3>${cuerpo}</div>`;
const ul = (items, clase, vacio) => items.length ? `<ul class="${clase}">${items.join('')}</ul>` : `<p class="nada">${vacio}</p>`;

function mostrar(d) {
  const s = $('#salida');
  if (!d.ok) {
    s.innerHTML = `<div class="alerta ${d.tipo === 'datos_incompletos' ? 'aviso2' : ''}">${esc(d.mensaje || 'Ocurrió un error.')}</div>`;
    return;
  }
  const dic = d.dictamen;
  const clase = dic == null ? 'sin' : `d-${esc(String(dic))}`;
  const etiqueta = dic == null ? 'Sin conclusión' : bonito(dic);
  const av = d.avance ? `<p>${esc(d.avance.cubiertas)} de ${esc(d.avance.total)} acciones de sustentabilidad cubiertas</p>` : '';
  const etapaTxt = d.etapa === 'operacion' ? 'operación' : 'diseño y construcción';

  // Sugerencias agrupadas por acción (solo presentación)
  const porAccion = {};
  d.sugerencias.forEach((x) => (porAccion[x.accion_nombre] ||= []).push(x.medida_nombre));

  s.innerHTML = `
    <div class="nivel ${clase}"><small>Dictamen · etapa de ${etapaTxt}</small><span>${esc(etiqueta)}</span>${av}</div>
    ${d.explicacion.length ? bloque('Por qué', null, ul(d.explicacion.map((t) => `<li>${esc(t)}</li>`), 'expl', '')) : ''}
    ${bloque('Acciones mínimas faltantes', d.minimas_faltantes.length,
      ul(d.minimas_faltantes.map((a) => `<li>${esc(bonito(a.nombre))}</li>`), 'falt', 'Cubre las cuatro acciones mínimas.'))}
    ${bloque('Medidas sugeridas', d.sugerencias.length,
      ul(Object.entries(porAccion).map(([a, ms]) => `<li><span>${esc(bonito(a))}</span><small>${ms.map((m) => esc(bonito(m))).join(' · ')}</small></li>`), 'rec', 'El sistema no tiene sugerencias para esta combinación.'))}
    ${bloque('Acciones cubiertas', d.acciones_cubiertas.length,
      ul(d.acciones_cubiertas.map((a) => `<li><span>${esc(bonito(a.nombre))}</span><small>${a.tipo ? esc(bonito(a.tipo)) : ''}</small></li>`), 'ok', 'Ninguna acción cubierta.'))}
    ${d.rubros_sin_accion.length ? bloque('Rubros sin ninguna acción', d.rubros_sin_accion.length,
      ul(d.rubros_sin_accion.map((r) => `<li>${esc(bonito(r.nombre))}</li>`), 'falt', '')) : ''}
    ${d.indicadores.length ? bloque('Indicadores que deberá reportar', d.indicadores.length,
      `<table class="tabla"><thead><tr><th>Acción</th><th>Indicador</th><th>Unidad</th></tr></thead><tbody>${d.indicadores.map((i) => `<tr><td>${esc(bonito(i.accion_nombre))}</td><td>${esc(i.indicador)}</td><td>${esc(i.unidad)}</td></tr>`).join('')}</tbody></table>`) : ''}
    ${d.evidencias.length ? bloque(`Evidencias requeridas (${etapaTxt})`, d.evidencias.length, ul(d.evidencias.map((t) => `<li>${esc(t)}</li>`), 'expl', '')) : ''}
    <details class="json"><summary>Ver respuesta de Prolog (JSON)</summary><pre>${esc(JSON.stringify(d, null, 2))}</pre></details>`;
}

$('#btn-evaluar').addEventListener('click', evaluar);
$('#btn-limpiar').addEventListener('click', () => { marcar([]); $('#salida').innerHTML = '<p class="vacio">Selección limpia. Marca medidas y vuelve a evaluar.</p>'; });
$('#btn-caso').addEventListener('click', () => marcar(CASO_JALAPA));
cargarCatalogo();

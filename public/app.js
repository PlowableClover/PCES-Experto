// Interfaz del Asistente PCES.
// Solo envía datos al servidor y muestra lo que responde Prolog:
// aquí no se decide ninguna conclusión.

// Medidas del caso de prueba Jalapa 124: se leen de caso_prueba/2 en Prolog.
let CASO_JALAPA = [];
const UNIDAD = { kwh: 'kWh', m3: 'm³', m2: 'm²', kg: 'kg', joules: 'J', personas: 'personas', toneladas_co2e: 't CO₂e', costo_adquisicion: 'Costo de adquisición' };

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
    try { const c = await (await fetch('/api/caso')).json(); CASO_JALAPA = c.medidas || []; } catch (_) { CASO_JALAPA = []; }
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

  // Agrupaciones solo de presentación
  const indPorRubro = {};
  d.indicadores.forEach((i) => (indPorRubro[i.rubro_nombre] ||= []).push(i));
  const docPorAccion = {};
  d.documentacion.forEach((x) => (docPorAccion[x.accion_nombre] ||= []).push(x.documento));

  s.innerHTML = `
    <div class="nivel ${clase}"><small>Dictamen · etapa de ${etapaTxt}</small><span>${esc(etiqueta)}</span>${av}</div>
    ${d.explicacion.length ? bloque('Por qué', null, ul(d.explicacion.map((t) => `<li>${esc(t)}</li>`), 'expl', '')) : ''}
    ${bloque('Acciones mínimas faltantes', d.minimas_faltantes.length,
      ul(d.minimas_faltantes.map((a) => `<li>${esc(bonito(a.nombre))}</li>`), 'falt', 'Cubre las cuatro acciones mínimas del numeral 9.7.'))}
    ${d.sugerencias.length ? bloque('Medidas sugeridas para las mínimas faltantes', d.sugerencias.length,
      ul(Object.entries(porAccion).map(([a, ms]) => `<li><span>${esc(bonito(a))}</span><small>${ms.map((m) => esc(bonito(m))).join(' · ')}</small></li>`), 'rec', '')) : ''}
    ${bloque('Acciones cubiertas', d.acciones_cubiertas.length,
      ul(d.acciones_cubiertas.map((a) => `<li><span>${esc(bonito(a.nombre))}</span><small>${a.tipo === 'minima' ? 'Mínima' : 'Opcional'}</small></li>`), 'ok', 'Ninguna acción cubierta.'))}
    ${d.rubros_sin_accion.length ? bloque('Rubros sin ninguna acción', d.rubros_sin_accion.length,
      ul(d.rubros_sin_accion.map((r) => `<li>${esc(bonito(r.nombre))}</li>`), 'falt', '')) : ''}
    ${d.indicadores.length ? bloque(`Indicadores a reportar y evidencia de línea base (${etapaTxt})`, d.indicadores.length,
      Object.entries(indPorRubro).map(([r, is]) => `<h4>${esc(r)}</h4><table class="tabla"><thead><tr><th>Indicador</th><th>Unidad</th><th>Evidencia</th></tr></thead><tbody>${is.map((i) => `<tr><td>${esc(i.indicador)}</td><td>${esc(UNIDAD[i.metrica] || i.metrica)}</td><td>${esc(i.evidencia ?? '—')}</td></tr>`).join('')}</tbody></table>`).join('')
      + '<p class="nota">Numeral 7.4: los indicadores se reportan para toda edificación, aplique o no acciones de sustentabilidad.</p>') : ''}
    ${d.documentacion.length ? bloque('Documentación de las acciones cubiertas', Object.keys(docPorAccion).length,
      Object.entries(docPorAccion).map(([a, ds]) => `<details class="doc"><summary>${esc(bonito(a))} <span class="num">${ds.length}</span></summary><ul>${ds.map((t) => `<li>${esc(t)}</li>`).join('')}</ul></details>`).join('')) : ''}
    <details class="json"><summary>Ver respuesta de Prolog (JSON)</summary><pre>${esc(JSON.stringify(d, null, 2))}</pre></details>`;
}

$('#btn-evaluar').addEventListener('click', evaluar);
$('#btn-limpiar').addEventListener('click', () => { marcar([]); $('#salida').innerHTML = '<p class="vacio">Selección limpia. Marca medidas y vuelve a evaluar.</p>'; });
$('#btn-caso').addEventListener('click', () => marcar(CASO_JALAPA));
cargarCatalogo();

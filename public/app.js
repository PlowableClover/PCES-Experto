// Interfaz del Asistente PCES.
// Solo envía datos al servidor y muestra lo que responde Prolog:
// aquí no se calcula ningún nivel ni ninguna regla.

// Criterios que cumple la casa de Jalapa 124 (expediente PCES del CECyT 11).
// Escribe aquí los identificadores tal como los definiste en base_conocimiento.pl.
const CASO_JALAPA = [];

const $ = (s) => document.querySelector(s);
let catalogo = [];

const bonito = (x) => {
  const s = String(x ?? '').replace(/_/g, ' ');
  return s.charAt(0).toUpperCase() + s.slice(1);
};
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function cargarCriterios() {
  try {
    const r = await fetch('/api/criterios');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    const d = await r.json();
    catalogo = d.criterios || [];
    pintarLista();
  } catch (e) {
    $('#lista').innerHTML = `<p class="error">No se pudo obtener el catálogo de criterios del servidor (${esc(e.message)}). Si el servicio estaba dormido, espera unos segundos y recarga.</p>`;
  }
}

function pintarLista() {
  if (!catalogo.length) {
    $('#lista').innerHTML = '<p class="error">La base de conocimientos no tiene criterios cargados.</p>';
    return;
  }
  const porRubro = {};
  catalogo.forEach((c) => (porRubro[c.rubro] ||= []).push(c));
  $('#lista').innerHTML = Object.keys(porRubro).map((rubro) => `
    <fieldset class="rubro">
      <legend>${esc(bonito(rubro))}</legend>
      ${porRubro[rubro].map((c) => `
        <label class="item">
          <input type="checkbox" value="${esc(c.id)}">
          <span class="nombre">${esc(bonito(c.nombre))}</span>
          <span class="meta">${c.tipo === 'obligatorio' ? '<span class="badge">Obligatorio</span>' : ''}<span class="pts">${esc(c.puntos)} pts</span></span>
        </label>`).join('')}
    </fieldset>`).join('');
  document.querySelectorAll('#lista input').forEach((i) => i.addEventListener('change', contar));
  const validos = CASO_JALAPA.filter((id) => catalogo.some((c) => c.id === id));
  $('#btn-caso').hidden = validos.length === 0;
  contar();
}

const seleccionados = () => [...document.querySelectorAll('#lista input:checked')].map((i) => i.value);
const contar = () => { const n = seleccionados().length; $('#contador').textContent = `${n} seleccionado${n === 1 ? '' : 's'}`; };

function marcar(ids) {
  document.querySelectorAll('#lista input').forEach((i) => (i.checked = ids.includes(i.value)));
  contar();
}

async function evaluar() {
  const btn = $('#btn-evaluar');
  btn.disabled = true; btn.textContent = 'Consultando a Prolog…';
  try {
    const r = await fetch('/api/evaluar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cumplidos: seleccionados() }),
    });
    const d = await r.json().catch(() => ({ ok: false, mensaje: 'Respuesta no válida del servidor.' }));
    mostrar(d);
  } catch (e) {
    mostrar({ ok: false, mensaje: 'No hay conexión con el servidor. Intenta de nuevo en unos segundos.' });
  } finally {
    btn.disabled = false; btn.textContent = 'Evaluar edificación';
  }
}

function lista(titulo, items, vacio, clase) {
  const cuerpo = items.length
    ? `<ul class="${clase}">${items.map((x) => `<li><span>${esc(bonito(x.nombre))}</span>${x.puntos != null ? `<small>${esc(bonito(x.rubro))} · ${esc(x.puntos)} pts</small>` : ''}</li>`).join('')}</ul>`
    : `<p class="nada">${vacio}</p>`;
  return `<div class="bloque"><h3>${titulo} <span class="num">${items.length}</span></h3>${cuerpo}</div>`;
}

function mostrar(d) {
  const s = $('#salida');
  if (!d.ok) {
    s.innerHTML = `<div class="alerta ${d.tipo === 'datos_incompletos' ? 'aviso2' : ''}">${esc(d.mensaje || 'Ocurrió un error.')}</div>`;
    return;
  }
  const max = Math.max(1, ...d.rubros.map((r) => Number(r.puntos) || 0));
  const nivel = d.nivel == null
    ? `<div class="nivel sin"><span>Sin conclusión</span><p>${esc(d.mensaje)}</p></div>`
    : `<div class="nivel n-${esc(String(d.nivel))}"><small>Nivel inferido</small><span>${esc(bonito(d.nivel))}</span><p>${esc(d.puntos)} puntos con ${esc(d.seleccionados)} criterios</p></div>`;
  s.innerHTML = `
    ${nivel}
    ${d.explicacion.length ? `<div class="bloque"><h3>Por qué</h3><ul class="expl">${d.explicacion.map((t) => `<li>${esc(t)}</li>`).join('')}</ul></div>` : ''}
    ${lista('Obligatorios que faltan', d.faltantes, 'No falta ningún criterio obligatorio.', 'falt')}
    ${lista('Recomendaciones para subir de nivel', d.recomendaciones, 'El sistema no encontró recomendaciones para esta combinación.', 'rec')}
    ${d.rubros.length ? `<div class="bloque"><h3>Puntos por rubro</h3>${d.rubros.map((r) => `
      <div class="barra"><span>${esc(bonito(r.rubro))}</span><i style="--p:${(Number(r.puntos) || 0) / max * 100}%"></i><b>${esc(r.puntos)}</b></div>`).join('')}</div>` : ''}
    <details class="json"><summary>Ver respuesta de Prolog (JSON)</summary><pre>${esc(JSON.stringify(d, null, 2))}</pre></details>`;
}

$('#btn-evaluar').addEventListener('click', evaluar);
$('#btn-limpiar').addEventListener('click', () => { marcar([]); $('#salida').innerHTML = '<p class="vacio">Selección limpia. Marca criterios y vuelve a evaluar.</p>'; });
$('#btn-caso').addEventListener('click', () => marcar(CASO_JALAPA));
cargarCriterios();

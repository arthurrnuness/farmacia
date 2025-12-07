// app/assets/javascripts/calendario.js

function toggleCalendario(calendarioId) {
  const calendario = document.getElementById(calendarioId);
  const compacto = calendario.querySelector('.calendario-compacto');
  const expandido = calendario.querySelector('.calendario-expandido');
  const iconeExpandir = calendario.querySelector('.icone-expandir');
  const iconeRecolher = calendario.querySelector('.icone-recolher');
  const periodoCompacto = calendario.querySelector('.periodo-compacto');
  const periodoExpandido = calendario.querySelector('.periodo-expandido');

  const estaExpandido = expandido.style.display !== 'none';

  if (estaExpandido) {
    // Recolher
    expandido.style.display = 'none';
    compacto.style.display = 'block';
    iconeExpandir.style.display = 'inline';
    iconeRecolher.style.display = 'none';
    periodoCompacto.style.display = 'inline';
    periodoExpandido.style.display = 'none';
  } else {
    // Expandir
    compacto.style.display = 'none';
    expandido.style.display = 'block';
    iconeExpandir.style.display = 'none';
    iconeRecolher.style.display = 'inline';
    periodoCompacto.style.display = 'none';
    periodoExpandido.style.display = 'inline';
  }
}

function togglePeriodo(calendarioId) {
  const calendario = document.getElementById(calendarioId);
  const vistaMensal = calendario.querySelector('.vista-mensal');
  const vistaSemanal = calendario.querySelector('.vista-semanal');
  const textoMes = calendario.querySelector('.texto-mes');
  const textoSemana = calendario.querySelector('.texto-semana');

  const estaMostrandoSemana = vistaSemanal.style.display !== 'none';

  if (estaMostrandoSemana) {
    // Mudar para vista mensal
    vistaSemanal.style.display = 'none';
    vistaMensal.style.display = 'flex';
    textoSemana.style.display = 'none';
    textoMes.style.display = 'inline';
  } else {
    // Mudar para vista semanal
    vistaMensal.style.display = 'none';
    vistaSemanal.style.display = 'flex';
    textoMes.style.display = 'none';
    textoSemana.style.display = 'inline';
  }
}
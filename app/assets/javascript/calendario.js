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
// Toggle entre visualização semanal e mensal no grid
function initGridToggle() {
  const btnToggle = document.getElementById('btn-toggle-periodo-grid');
  if (!btnToggle) return;

  // Remover listeners antigos
  const novoBotao = btnToggle.cloneNode(true);
  btnToggle.parentNode.replaceChild(novoBotao, btnToggle);

  novoBotao.addEventListener('click', function() {
    const vistaSemanal = document.querySelector('.vista-semanal-grid');
    const vistaMensal = document.querySelector('.vista-mensal-grid');
    const textoMes = novoBotao.querySelector('.texto-mes-grid');
    const textoSemana = novoBotao.querySelector('.texto-semana-grid');

    if (vistaSemanal.style.display !== 'none') {
      // Mudar para vista mensal
      vistaSemanal.style.display = 'none';
      vistaMensal.style.display = 'block';
      textoMes.style.display = 'none';
      textoSemana.style.display = 'inline';
    } else {
      // Mudar para vista semanal
      vistaMensal.style.display = 'none';
      vistaSemanal.style.display = 'block';
      textoSemana.style.display = 'none';
      textoMes.style.display = 'inline';
    }
  });
}

// Inicializar em carregamento normal e com Turbo
document.addEventListener('DOMContentLoaded', initGridToggle);
document.addEventListener('turbo:load', initGridToggle);
document.addEventListener('turbo:render', initGridToggle);

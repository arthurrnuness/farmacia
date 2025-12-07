// Funcionalidade "Ver Hoje" - mostra apenas o dia atual
function initVerHoje() {
  const btnVerHoje = document.getElementById('btn-ver-hoje');
  if (!btnVerHoje) return;

  // Remover listeners antigos (evitar duplicação)
  const novoBotao = btnVerHoje.cloneNode(true);
  btnVerHoje.parentNode.replaceChild(novoBotao, btnVerHoje);

  let modoHoje = false;

  novoBotao.addEventListener('click', function() {
    modoHoje = !modoHoje;

    if (modoHoje) {
      // Ativar modo "Ver Hoje"
      novoBotao.textContent = 'Ver Calendário Completo';
      novoBotao.classList.add('active');
      mostrarApenasHoje();
    } else {
      // Desativar modo "Ver Hoje"
      novoBotao.textContent = 'Ver Hoje';
      novoBotao.classList.remove('active');
      mostrarCalendarioCompleto();
    }
  });

  function mostrarApenasHoje() {
    // Esconder navegação de meses
    const mesNavegacao = document.querySelector('.mes-navegacao');
    if (mesNavegacao) {
      mesNavegacao.style.display = 'none';
    }

    // Encontrar o dia de hoje
    const hoje = new Date();
    const diaHoje = hoje.getDate();

    // Para cada hábito, esconder o calendário completo e mostrar apenas hoje
    document.querySelectorAll('.habito-card').forEach(card => {
      // Esconder calendário completo
      const calendario = card.querySelector('.calendario-habito');
      if (calendario) {
        calendario.style.display = 'none';
      }

      // Criar visualização do dia de hoje se não existir
      let diaHojeView = card.querySelector('.dia-hoje-view');
      if (!diaHojeView) {
        diaHojeView = document.createElement('div');
        diaHojeView.className = 'dia-hoje-view';

        // Encontrar o elemento do dia de hoje no calendário
        const diasCompactos = card.querySelectorAll('.dia-compacto, .dia-pequeno');
        let diaEncontrado = null;

        diasCompactos.forEach(dia => {
          const numero = dia.querySelector('.dia-numero-compacto, .dia-numero');
          if (numero && parseInt(numero.textContent) === diaHoje) {
            diaEncontrado = dia.cloneNode(true);
          }
        });

        if (diaEncontrado) {
          diaEncontrado.classList.add('dia-hoje-ampliado');
          diaHojeView.appendChild(diaEncontrado);
        } else {
          diaHojeView.innerHTML = '<p class="sem-agendamento">Não agendado para hoje</p>';
        }

        calendario.parentNode.insertBefore(diaHojeView, calendario.nextSibling);
      } else {
        diaHojeView.style.display = 'flex';
      }
    });
  }

  function mostrarCalendarioCompleto() {
    // Mostrar navegação de meses
    const mesNavegacao = document.querySelector('.mes-navegacao');
    if (mesNavegacao) {
      mesNavegacao.style.display = 'flex';
    }

    // Para cada hábito, mostrar calendário completo e esconder dia de hoje
    document.querySelectorAll('.habito-card').forEach(card => {
      // Mostrar calendário completo
      const calendario = card.querySelector('.calendario-habito');
      if (calendario) {
        calendario.style.display = 'block';
      }

      // Esconder visualização do dia de hoje
      const diaHojeView = card.querySelector('.dia-hoje-view');
      if (diaHojeView) {
        diaHojeView.style.display = 'none';
      }
    });
  }
}

// Inicializar em carregamento normal e com Turbo
document.addEventListener('DOMContentLoaded', initVerHoje);
document.addEventListener('turbo:load', initVerHoje);
document.addEventListener('turbo:render', initVerHoje);

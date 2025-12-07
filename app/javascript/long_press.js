// Long press para abrir página de edição de registro
let pressTimer = null;
let longPressTriggered = false;
let pressStartTime = null;

function initLongPress() {
  const diaCells = document.querySelectorAll('.dia-cell');

  diaCells.forEach(cell => {
    // Verificar se já tem o listener (evitar duplicados)
    if (cell.dataset.longPressEnabled) return;
    cell.dataset.longPressEnabled = 'true';

    // Só adicionar long press em células que não são futuras
    if (!cell.classList.contains('dia-futuro')) {

      // Mouse events
      cell.addEventListener('mousedown', function(e) {
        pressStartTime = Date.now();
        longPressTriggered = false;
        const habitoId = this.dataset.habitoId;
        const dia = this.dataset.dia;
        const currentCell = this;

        pressTimer = setTimeout(() => {
          longPressTriggered = true;
          // Visual feedback quando long press é ativado
          currentCell.style.transform = 'scale(1.05)';
          currentCell.style.boxShadow = '0 0 10px rgba(0,123,255,0.5)';

          // Pequeno delay para mostrar feedback antes de redirecionar
          setTimeout(() => {
            abrirEdicaoRegistro(habitoId, dia);
          }, 100);
        }, 800); // 800ms = 0.8 segundos
      });

      cell.addEventListener('mouseup', function(e) {
        clearTimeout(pressTimer);

        // Se foi um long press, prevenir o click normal
        const pressDuration = Date.now() - pressStartTime;
        if (pressDuration >= 800) {
          e.preventDefault();
          e.stopPropagation();
        }
      });

      cell.addEventListener('mouseleave', function(e) {
        clearTimeout(pressTimer);
      });

      // Touch events para mobile
      cell.addEventListener('touchstart', function(e) {
        pressStartTime = Date.now();
        longPressTriggered = false;
        const habitoId = this.dataset.habitoId;
        const dia = this.dataset.dia;
        const currentCell = this;

        pressTimer = setTimeout(() => {
          longPressTriggered = true;
          // Visual feedback
          currentCell.style.transform = 'scale(1.05)';
          currentCell.style.boxShadow = '0 0 10px rgba(0,123,255,0.5)';

          setTimeout(() => {
            abrirEdicaoRegistro(habitoId, dia);
          }, 100);
        }, 800);
      });

      cell.addEventListener('touchend', function(e) {
        clearTimeout(pressTimer);

        // Se foi um long press, prevenir o click normal
        const pressDuration = Date.now() - pressStartTime;
        if (pressDuration >= 800) {
          e.preventDefault();
          e.stopPropagation();
        }
      });

      cell.addEventListener('touchmove', function(e) {
        clearTimeout(pressTimer);
        longPressTriggered = false;
      });
    }
  });
}

function abrirEdicaoRegistro(habitoId, dia) {
  // Buscar ou criar registro
  fetch('/registros/editar_ou_criar', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      habito_id: habitoId,
      data: dia
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      // Redirecionar para página de edição
      window.location.href = `/registros/${data.registro_id}/edit`;
    }
  })
  .catch(error => {
    console.error('Erro ao abrir edição:', error);
    alert('Erro ao abrir edição. Tente novamente.');
  });
}

// Inicializar em carregamento normal e com Turbo
document.addEventListener('DOMContentLoaded', initLongPress);
document.addEventListener('turbo:load', initLongPress);
document.addEventListener('turbo:render', initLongPress);

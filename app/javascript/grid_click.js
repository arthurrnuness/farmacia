// Funcionalidade de clicar nos dias para marcar como feito/não feito
function initGridClick() {
  const diaCells = document.querySelectorAll('.dia-cell');

  diaCells.forEach(cell => {
    // Verificar se já tem o listener (evitar duplicados)
    if (cell.dataset.clickEnabled) return;
    cell.dataset.clickEnabled = 'true';

    // Permitir click em todos os dias, exceto futuros
    if (!cell.classList.contains('dia-futuro')) {

      cell.addEventListener('click', function(e) {
        e.preventDefault();

        const habitoId = this.dataset.habitoId;
        const dia = this.dataset.dia;
        const currentCell = this;

        // Desabilitar temporariamente para evitar cliques múltiplos
        currentCell.style.pointerEvents = 'none';
        currentCell.style.opacity = '0.6';

        // Fazer requisição para toggle do registro
        fetch('/registros/toggle', {
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
        .then(response => {
          if (!response.ok) {
            throw new Error('Erro na requisição');
          }
          return response.json();
        })
        .then(data => {
          if (data.success) {
            // Atualizar visual da célula em TODAS as tabelas (semanal e mensal)
            const allCells = document.querySelectorAll(
              `.dia-cell[data-habito-id="${habitoId}"][data-dia="${dia}"]`
            );

            allCells.forEach(cell => {
              const diaStatus = cell.querySelector('.dia-status');

              if (data.concluido) {
                // Marcar como feito
                cell.classList.remove('dia-nao-feito', 'dia-hoje', 'dia-nao-agendado');
                cell.classList.add('dia-feito');
                if (diaStatus) {
                  diaStatus.textContent = '✓';
                } else {
                  cell.innerHTML = '<div class="dia-status">✓</div>';
                }
              } else {
                // Marcar como não feito
                cell.classList.remove('dia-feito', 'dia-nao-agendado');

                // Se for hoje, voltar para dia-hoje, senão dia-nao-feito
                const diaDate = new Date(dia);
                const hoje = new Date();
                hoje.setHours(0, 0, 0, 0);
                diaDate.setHours(0, 0, 0, 0);

                if (diaDate.getTime() === hoje.getTime()) {
                  cell.classList.add('dia-hoje');
                } else {
                  cell.classList.add('dia-nao-feito');
                }

                if (diaStatus) {
                  diaStatus.textContent = '○';
                } else {
                  cell.innerHTML = '<div class="dia-status">○</div>';
                }
              }

              // Reabilitar célula
              cell.style.pointerEvents = '';
              cell.style.opacity = '';
            });

            // Atualizar progresso após um pequeno delay
            setTimeout(() => {
              atualizarProgresso(habitoId);
            }, 100);
          }
        })
        .catch(error => {
          console.error('Erro ao atualizar registro:', error);
          alert('Erro ao atualizar registro. Tente novamente.');

          // Reabilitar célula em caso de erro
          currentCell.style.pointerEvents = '';
          currentCell.style.opacity = '';
        });
      });

      // Adicionar cursor pointer para dias clicáveis
      cell.style.cursor = 'pointer';
    } else if (cell.classList.contains('dia-futuro')) {
      // Dias futuros não são clicáveis
      cell.style.cursor = 'not-allowed';
    }
  });
}

function atualizarProgresso(habitoId) {
  // Buscar progresso atualizado via AJAX
  fetch(`/habitos/${habitoId}/progresso`, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      // Atualizar todas as células de progresso para este hábito
      const progressoCells = document.querySelectorAll(
        `.progresso-cell[data-habito-id="${habitoId}"]`
      );

      progressoCells.forEach(cell => {
        const percentual = data.percentual;
        const feitos = data.feitos;
        const meta = data.meta;

        // Atualizar o conteúdo
        cell.innerHTML = `
          <div class="progresso-mini">
            <span class="percentual">${percentual}%</span>
            <span class="detalhes">${feitos}/${meta}</span>
          </div>
        `;
      });
    }
  })
  .catch(error => {
    console.error('Erro ao atualizar progresso:', error);
    // Em caso de erro, não fazer nada (célula já foi atualizada visualmente)
  });
}

// Inicializar em carregamento normal e com Turbo
document.addEventListener('DOMContentLoaded', initGridClick);
document.addEventListener('turbo:load', initGridClick);
document.addEventListener('turbo:render', initGridClick);

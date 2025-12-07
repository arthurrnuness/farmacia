// Filtro de tags sem refresh
function initTagFilter() {
  const tagFilters = document.querySelectorAll('.tag-filter');
  const habitoCards = document.querySelectorAll('.habito-card');

  tagFilters.forEach(filter => {
    filter.addEventListener('click', function() {
      const tagId = this.dataset.tagId;

      // Atualizar botões ativos
      tagFilters.forEach(f => f.classList.remove('active'));
      this.classList.add('active');

      // Filtrar hábitos
      habitoCards.forEach(card => {
        const cardTagIds = card.dataset.tagIds.split(',').filter(id => id !== '');

        if (tagId === 'all' || cardTagIds.includes(String(tagId))) {
          card.style.display = 'block';
        } else {
          card.style.display = 'none';
        }
      });
    });
  });
}

// Inicializar em carregamento normal e com Turbo
document.addEventListener('DOMContentLoaded', initTagFilter);
document.addEventListener('turbo:load', initTagFilter);
document.addEventListener('turbo:render', initTagFilter);

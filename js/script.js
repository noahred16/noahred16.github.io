const EXPAND_ICON = `<svg viewBox="0 0 14 14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 5V1h4M9 1h4v4M13 9v4H9M5 13H1V9"/></svg>`;
const COLLAPSE_ICON = `<svg viewBox="0 0 14 14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M5 1v4H1M13 5H9V1M9 13v-4h4M1 9h4v4"/></svg>`;

function toggle(id) {
  const card = document.querySelector(`.card[data-id="${id}"]`);
  const btn  = card.querySelector('.expand-btn');
  const isExpanded = card.classList.toggle('expanded');
  btn.innerHTML = isExpanded ? COLLAPSE_ICON : EXPAND_ICON;
  btn.setAttribute('aria-label', isExpanded ? 'Collapse' : 'Expand');
}

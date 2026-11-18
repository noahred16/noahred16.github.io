/* Renders date-driven event cards from EVENTS (see events-data.js). */

const MS_PER_DAY = 86400000;

const EVENT_TYPES = {
  birthday:    { label: 'Birthday',    icon: '🎂' },
  anniversary: { label: 'Anniversary', icon: '💍' },
  holiday:     { label: 'Holiday',     icon: '🎉' },
  event:       { label: 'Coming Up',   icon: '📅' },
};

/** @param {string} iso 'YYYY-MM-DD' @returns {Date} local midnight */
function parseDate(iso) {
  const [y, m, d] = iso.split('-').map(Number);
  return new Date(y, m - 1, d);
}

/** @param {string} monthDay 'MM-DD' @param {number} year @returns {Date} */
function atYear(monthDay, year) {
  const [m, d] = monthDay.split('-').map(Number);
  return new Date(year, m - 1, d);
}

/** @param {Date} from @param {Date} to @returns {number} whole days (signed) */
function daysBetween(from, to) {
  return Math.round((to - from) / MS_PER_DAY);
}

/** @param {Date} today @returns {Date} today at local midnight */
function startOfDay(today) {
  return new Date(today.getFullYear(), today.getMonth(), today.getDate());
}

/**
 * Finds the occurrence of an event whose display window contains `today`.
 * @param {object} event
 * @param {Date} today local midnight
 * @returns {Date | null} the occurrence date, or null if not showing
 */
function findActiveOccurrence(event, today) {
  if (event.recurring === false) {
    const inWindow = today >= parseDate(event.start_date) && today <= parseDate(event.end_date);
    return inWindow ? parseDate(event.date) : null;
  }

  const origin = parseDate(event.date);
  const originMonthDay = event.date.slice(5);

  for (const year of [today.getFullYear() - 1, today.getFullYear(), today.getFullYear() + 1]) {
    const occurrence = new Date(year, origin.getMonth(), origin.getDate());
    // Window bounds sit on whichever side of the occurrence they belong to (handles New Year wrap).
    const startYear = event.start_date > originMonthDay ? year - 1 : year;
    const endYear = event.end_date < originMonthDay ? year + 1 : year;
    const start = atYear(event.start_date, startYear);
    const end = atYear(event.end_date, endYear);
    if (today >= start && today <= end) return occurrence;
  }
  return null;
}

/** @param {number} n @returns {string} e.g. 1 → '1st', 22 → '22nd', 27 → '27th', 111 → '111th' */
function toOrdinal(n) {
  const lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 13) return `${n}th`;
  return n + ({ 1: 'st', 2: 'nd', 3: 'rd' }[n % 10] || 'th');
}

/** @param {number} daysUntil @returns {string} */
function describeWhen(daysUntil) {
  if (daysUntil === 0) return 'today';
  const n = Math.abs(daysUntil);
  const unit = n === 1 ? 'day' : 'days';
  return daysUntil > 0 ? `in ${n} ${unit}` : `${n} ${unit} ago`;
}

/**
 * @param {object} event
 * @param {Date} occurrence
 * @param {Date} today
 * @returns {object} props passed to event.message()
 */
function buildProps(event, occurrence, today) {
  const daysUntil = daysBetween(today, occurrence);
  const age = occurrence.getFullYear() - parseDate(event.date).getFullYear();
  return {
    name: event.name,
    age,
    ageOrdinal: toOrdinal(age),
    days: Math.abs(daysUntil),
    daysUntil,
    isToday: daysUntil === 0,
    isPast: daysUntil < 0,
    isFuture: daysUntil > 0,
    date: occurrence.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
    when: describeWhen(daysUntil),
  };
}

/**
 * @param {object[]} events
 * @param {Date} today
 * @returns {{ event: object, props: object }[]} active events, soonest first
 */
function getActiveEvents(events, today) {
  const day = startOfDay(today);
  return events
    .map(event => {
      const occurrence = findActiveOccurrence(event, day);
      return occurrence && { event, props: buildProps(event, occurrence, day) };
    })
    .filter(Boolean)
    .sort((a, b) => Math.abs(a.props.daysUntil) - Math.abs(b.props.daysUntil));
}

/** @param {{ event: object, props: object }} active @returns {HTMLElement} */
function renderEventCard({ event, props }) {
  const type = EVENT_TYPES[event.type] || EVENT_TYPES.event;
  const card = document.createElement('div');
  card.className = `card card-event card-event--${event.type}${props.isToday ? ' is-today' : ''}`;

  const tag = document.createElement('div');
  tag.className = 'card-tag';
  tag.textContent = `${type.icon} ${type.label} · ${props.date}`;

  const title = document.createElement('h2');
  title.textContent = event.name;

  const divider = document.createElement('div');
  divider.className = 'divider';

  const body = document.createElement('div');
  body.className = 'card-body';
  [].concat(event.message(props)).forEach(text => {
    const p = document.createElement('p');
    p.textContent = text;
    body.appendChild(p);
  });

  card.append(tag, title, divider, body);
  if (event.sketch) card.appendChild(renderSketch(event.sketch));
  return card;
}

/** @param {string} source .pde path @returns {HTMLElement} */
function renderSketch(source) {
  const wrap = document.createElement('div');
  wrap.className = 'card-event-sketch';
  const canvas = document.createElement('canvas');
  canvas.setAttribute('data-processing-sources', source);
  wrap.appendChild(canvas);
  return wrap;
}

/**
 * Removes every Processing card from the grid so only the spotlighted event's sketch runs.
 * Must run before DOMContentLoaded, when processing.js starts every sketch canvas it finds.
 * @param {HTMLElement} grid
 */
function removeSketchCards(grid) {
  grid.querySelectorAll('.card').forEach(card => {
    if (card.querySelector('canvas[data-processing-sources]')) card.remove();
  });
}

/** @returns {Date} ?date=YYYY-MM-DD override, else now */
function resolveToday() {
  const override = new URLSearchParams(window.location.search).get('date');
  return override && /^\d{4}-\d{2}-\d{2}$/.test(override) ? parseDate(override) : new Date();
}

function mountEventCards() {
  const grid = document.getElementById('grid');
  if (!grid || typeof EVENTS === 'undefined') return;
  const active = getActiveEvents(EVENTS, resolveToday());
  if (active.some(({ event }) => event.spotlight)) removeSketchCards(grid);
  grid.prepend(...active.map(renderEventCard));
}

if (typeof module !== 'undefined') {
  module.exports = { getActiveEvents };
} else {
  mountEventCards();
}

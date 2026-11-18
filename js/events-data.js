/**
 * Date-driven event cards (birthdays, anniversaries, countdowns, ...).
 *
 * Each event:
 *   name        Display name / card title.
 *   type        'birthday' | 'anniversary' | 'holiday' | 'event'  (controls tag + styling)
 *   date        'YYYY-MM-DD'. For recurring events this is the original date
 *               (birth date, wedding date) and is used to compute age/years.
 *   recurring   true (default) → repeats every year. false → one-off event.
 *   start_date  When the card starts showing.
 *   end_date    When the card stops showing (inclusive).
 *               Recurring: 'MM-DD' (year-relative, may wrap around New Year).
 *               One-off:   'YYYY-MM-DD'.
 *   message     (props) => string | string[]   Each string becomes a paragraph.
 *   sketch      (optional) Processing sketch path to show inside the card.
 *   spotlight   (optional) true → while this card shows, the other Processing
 *               cards are removed from the page so only this card's sketch runs.
 *
 * Props passed to message():
 *   name, age (years since `date` as of this occurrence), ageOrdinal ('27th'), days (absolute days
 *   to/from the date), daysUntil (signed), isToday, isPast, isFuture,
 *   date ('Nov 22'), when ('in 5 days' | 'today' | '3 days ago').
 *
 * Preview any date with ?date=YYYY-MM-DD in the URL.
 */
const EVENTS = [
  {
    name: 'Noah Smith',
    type: 'birthday',
    date: '1997-10-26',
    start_date: '10-01',
    end_date: '10-31',
    message: ({ age, when, isToday, isPast }) => [
      'Happy Birthday to me!',
      isToday ? `I turned ${age} today!`
        : isPast ? `I turned ${age} ${when}.`
        : `I'll be turning ${age} ${when}.`,
    ],
  },
  {
    name: 'Kenia Rangel',
    type: 'birthday',
    date: '1999-11-22',
    start_date: '11-01',
    end_date: '11-30',
    message: ({ ageOrdinal }) => [
      `Happy ${ageOrdinal} Birthday <3`,
      'I love you forever sweet pea.',
    ],
    sketch: 'processing/flowers.pde',
    spotlight: true,
  },
];

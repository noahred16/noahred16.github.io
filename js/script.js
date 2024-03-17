document.addEventListener('DOMContentLoaded', function() {
    const themeToggleButton = document.getElementById('theme-toggle');
    const body = document.body;

    // Check for saved user preference, if any, on page load
    const currentTheme = localStorage.getItem('theme');
    if (currentTheme) {
        body.classList.add(currentTheme);
    }

    themeToggleButton.addEventListener('click', function() {
        if (body.classList.contains('dark-mode')) {
            body.classList.remove('dark-mode');
            localStorage.setItem('theme', '');
        } else {
            body.classList.add('dark-mode');
            localStorage.setItem('theme', 'dark-mode');
        }
    });
});

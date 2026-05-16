import './darkmode.js';
import './terminal.js';
import './copy.js';
import { loadStacksCards } from './search.js';

document.addEventListener('DOMContentLoaded', () => {
    loadStacksCards();
    const searchInput = document.getElementById('globalSearch');
    if(searchInput) {
        searchInput.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase();
            document.querySelectorAll('.stack-card').forEach(card => {
                const text = card.innerText.toLowerCase();
                card.style.display = text.includes(term) ? 'block' : 'none';
            });
        });
    }
});

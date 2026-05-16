document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const text = btn.getAttribute('data-cmd') || btn.previousElementSibling?.innerText;
        if(text) navigator.clipboard.writeText(text);
        btn.innerText = '✓ Copiado!';
        setTimeout(() => btn.innerText = 'Copiar', 1500);
    });
});

// DevForge - Dark Mode Script (VERSÃO CORRIGIDA)
// Alterna entre modo claro e escuro corretamente

function initDarkMode() {
    // Verificar preferência salva ou do sistema
    const isDark = localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches);
    
    // Aplicar tema
    if (isDark) {
        document.documentElement.classList.add('dark');
    } else {
        document.documentElement.classList.remove('dark');
    }
    
    // Atualizar ícones e texto dos botões
    function updateButtonIcons() {
        const isDarkMode = document.documentElement.classList.contains('dark');
        const buttons = document.querySelectorAll('#darkModeToggleDesktop, #darkModeToggleMobile');
        
        buttons.forEach(btn => {
            if (btn) {
                if (isDarkMode) {
                    btn.innerHTML = '<i class="fas fa-sun w-5"></i><span>Modo claro</span>';
                } else {
                    btn.innerHTML = '<i class="fas fa-moon w-5"></i><span>Modo escuro</span>';
                }
            }
        });
    }
    
    // Alternar tema
    function toggleDarkMode() {
        document.documentElement.classList.toggle('dark');
        const isDarkNow = document.documentElement.classList.contains('dark');
        localStorage.theme = isDarkNow ? 'dark' : 'light';
        updateButtonIcons();
    }
    
    // Registrar eventos para todos os botões
    const toggleButtons = document.querySelectorAll('#darkModeToggleDesktop, #darkModeToggleMobile');
    toggleButtons.forEach(btn => {
        if (btn) {
            btn.removeEventListener('click', toggleDarkMode);
            btn.addEventListener('click', toggleDarkMode);
        }
    });
    
    // Inicializar ícones
    updateButtonIcons();
}

// Executar quando o DOM estiver pronto
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initDarkMode);
} else {
    initDarkMode();
}
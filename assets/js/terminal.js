const terminalDiv = document.getElementById('fakeTerminal');
const demoBtn = document.getElementById('runDemoCmd');
let commandIndex = 0;
const demoCommands = [
    '> curl -fsSL https://get.devforge.sh/php | bash',
    '> ✔ PHP 8.3 installed',
    '> composer global require laravel/installer',
    '> ✔ Laravel installer ready'
];
if(demoBtn) {
    demoBtn.addEventListener('click', () => {
        terminalDiv.innerHTML += `<div class="text-blue-400">$> ${demoCommands[commandIndex % demoCommands.length]}</div>`;
        commandIndex++;
        terminalDiv.scrollTop = terminalDiv.scrollHeight;
    });
}

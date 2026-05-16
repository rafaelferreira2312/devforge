export function loadStacksCards() {
    const container = document.getElementById('cardsGrid');
    if(!container) return;
    const stacks = [
        { name: 'PHP', icon: '🐘', link: 'stacks/php.html', desc: 'Setup LAMP, Laravel, Composer' },
        { name: 'Node.js', icon: '🟢', link: 'stacks/nodejs.html', desc: 'NPM, Express, TS, Fastify' },
        { name: 'Python', icon: '🐍', link: 'stacks/python.html', desc: 'Django, Flask, Data Science' },
        { name: 'Docker', icon: '🐳', link: 'stacks/docker.html', desc: 'Containers, Compose, Swarm' },
        { name: 'DevOps', icon: '🔧', link: 'stacks/devops.html', desc: 'K8s, Terraform, CI/CD' },
        { name: 'Linux', icon: '🐧', link: 'stacks/linux.html', desc: 'Servers, bash, hardening' }
    ];
    container.innerHTML = stacks.map(s => `
        <a href="${s.link}" class="stack-card block bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-800 p-5 card-hover">
            <div class="text-3xl mb-2">${s.icon}</div>
            <h3 class="font-bold text-lg">${s.name}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">${s.desc}</p>
        </a>
    `).join('');
}

#!/usr/bin/env bash
set -e

echo "🚀 Création de ng-baguette-conf..."

mkdir -p ../git-workshop-starter && cd ../git-workshop-starter
rm -rf ng-baguette-conf
git init -b main ng-baguette-conf
cd ng-baguette-conf

git config user.email "workshop@ngbaguette.dev"
git config user.name "NG Baguette Dev"

# ─── Helpers ──────────────────────────────────────────────────────────────────

commit() { git add -A && git commit -m "$1" --quiet; }

# ─── Commits 1-3 : Init ───────────────────────────────────────────────────────

cat > package.json << 'EOF'
{
  "name": "ng-baguette-conf",
  "type": "module",
  "version": "0.0.1",
  "scripts": {
    "dev": "astro dev",
    "start": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "astro": "astro"
  },
  "dependencies": {
    "@astrojs/check": "^0.9.5",
    "@astrojs/tailwind": "^6.0.2",
    "astro": "^5.15.5",
    "tailwindcss": "^3.4.17",
    "typescript": "^5.7.2"
  },
  "devDependencies": {
    "daisyui": "^4.12.22"
  }
}
EOF
cat > astro.config.mjs << 'EOF'
import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

export default defineConfig({
  i18n: {
    locales: ["en", "fr"],
    defaultLocale: "fr",
    prefixDefaultLocale: true,
    routing: {
      prefixDefaultLocale: true,
    },
  },
  integrations: [tailwind()],
});
EOF
cat > tsconfig.json << 'EOF'
{
  "extends": "astro/tsconfigs/strict",
  "include": [".astro/types.d.ts", "**/*"],
  "exclude": ["dist"]
}
EOF
cat > .gitignore << 'EOF'
dist/
node_modules/
.env
.astro/
EOF
mkdir -p src
cat > src/env.d.ts << 'EOF'
/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />
EOF

# Ajouter bisect-test.sh dès le début pour qu'il soit disponible lors du bisect
cat > bisect-test.sh << 'BISECT_EOF'
#!/bin/bash
# Script pour git bisect run
# Exit 0 = commit bon, Exit 1 = commit mauvais, Exit 125 = skip

# Vérifier que le fichier schedule.ts existe (commits 1-11 ne l'ont pas encore)
if [ ! -f "src/utils/schedule.ts" ]; then
  exit 125
fi

# Tester le sens du tri dans getSortedSessions
node --input-type=module << 'EOF'
import { readFileSync } from "fs";
const code = readFileSync("src/utils/schedule.ts", "utf8");
const isCorrect = code.includes("new Date(a.start).getTime() - new Date(b.start).getTime()");
process.exit(isCorrect ? 0 : 1);
EOF
BISECT_EOF
chmod +x bisect-test.sh

commit "feat: init Astro project"

cat > tailwind.config.mjs << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: { extend: {} },
  daisyui: {
    themes: [
      {
        mytheme: {
          primary: "#CA55A3",
          secondary: "#f6d860",
          accent: "#37cdbe",
          neutral: "#3d4451",
          "base-100": "#1D242A",
        },
      },
    ],
  },
  plugins: [require("daisyui")],
};
EOF
commit "feat: add Tailwind CSS and DaisyUI"

mkdir -p src/layouts
cat > src/layouts/BaseLayout.astro << 'EOF'
---
export interface Props {
  title: string;
  description?: string;
}
const { title, description = "NG Baguette Conf — French cooked Angular conference" } = Astro.props;
---
<!doctype html>
<html lang="fr" data-theme="mytheme">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  </head>
  <body class="min-h-screen bg-base-100 text-base-content font-sans antialiased">
    <slot />
  </body>
</html>
EOF
cat > src/layouts/Layout.astro << 'EOF'
---
import BaseLayout from "./BaseLayout.astro";
import Header from "../components/Header.astro";
import Footer from "../components/Footer.astro";
export interface Props { title: string; description?: string; }
const { title, description } = Astro.props;
---
<BaseLayout title={title} description={description}>
  <Header />
  <main>
    <slot />
  </main>
  <Footer />
</BaseLayout>
EOF
commit "feat: add base layout and main layout"

# ─── Commits 4-7 : Composants de navigation ───────────────────────────────────

mkdir -p src/components
cat > src/components/Header.astro << 'EOF'
---
const lang = Astro.url.pathname.startsWith("/en") ? "en" : "fr";
const base = `/${lang}`;
---
<header class="navbar bg-base-100 shadow-sm">
  <div class="navbar-start">
    <a href={base} class="text-xl font-bold">NG Baguette Conf</a>
  </div>
  <nav class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><a href={`${base}/schedule`}>Agenda</a></li>
      <li><a href={`${base}/sponsors`}>Sponsors</a></li>
      <li><a href={`${base}/about`}>À propos</a></li>
    </ul>
  </nav>
</header>
EOF
commit "feat: add Header component"

cat > src/components/Footer.astro << 'EOF'
---
---
<footer class="mt-20 border-t border-base-300 bg-base-200/30">
  <div class="container mx-auto px-6 py-12">
    <div class="flex flex-col md:flex-row items-center justify-between gap-6">
      <div class="text-center md:text-left">
        <p class="font-black text-xl">🥖 NG Baguette Conf</p>
        <p class="text-base-content/40 text-sm mt-1">French cooked Angular conference</p>
      </div>
      <p class="text-base-content/30 text-sm hidden md:block">
        La Sorbonne · 29 mai 2026 · Paris
      </p>
      <p class="text-base-content/25 text-xs">© 2026 Angular Devs France</p>
    </div>
  </div>
</footer>
EOF
commit "feat: add Footer component"

cat > src/components/Drawer.astro << 'EOF'
---
const lang = Astro.url.pathname.startsWith("/en") ? "en" : "fr";
const base = `/${lang}`;
---
<div class="drawer">
  <input id="nav-drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content">
    <label for="nav-drawer" class="btn btn-ghost lg:hidden">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </label>
  </div>
  <div class="drawer-side">
    <label for="nav-drawer" class="drawer-overlay"></label>
    <ul class="menu p-4 w-64 min-h-full bg-base-200">
      <li><a href={`${base}/schedule`}>Agenda</a></li>
      <li><a href={`${base}/sponsors`}>Sponsors</a></li>
      <li><a href={`${base}/about`}>À propos</a></li>
    </ul>
  </div>
</div>
EOF
commit "feat: add Drawer component for mobile navigation"

cat > src/consts.ts << 'EOF'
export const SITE_TITLE = "NG BAGUETTE CONF 2026";
export const SITE_ACRONYM = "NG Baguette Conf";
export const SITE_DESCRIPTION = "French cooked Angular conference";
export const EVENT_DATE = "2026-05-29";
export const EVENT_START_TIME = "9h00";
export const EVENT_END_TIME = "18h00";
export const CFP_END_DATE = "2026-01-31";
EOF
commit "feat: add i18n config and site constants"

# ─── Commits 8-10 : Pages ─────────────────────────────────────────────────────

mkdir -p src/pages/fr src/pages/en
cat > src/pages/index.astro << 'EOF'
---
return Astro.redirect("/fr");
---
EOF
cat > src/pages/fr/index.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import { SITE_TITLE } from "../../consts";
---
<Layout title={SITE_TITLE}>
  <!-- Hero -->
  <div class="relative min-h-[88vh] flex items-center justify-center overflow-hidden">
    <div class="absolute inset-0 pointer-events-none" style="background: radial-gradient(ellipse 80% 60% at 50% 20%, rgba(202,85,163,0.18) 0%, transparent 70%), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(55,205,190,0.08) 0%, transparent 60%)"></div>
    <div class="relative z-10 text-center px-6 max-w-5xl mx-auto py-20">
      <p class="inline-flex items-center gap-2 border border-primary/30 text-primary/80 rounded-full px-5 py-2 text-sm font-semibold mb-10 bg-primary/5 backdrop-blur-sm">
        🥖 French cooked Angular conference
      </p>
      <h1 class="font-black leading-none tracking-tight mb-8">
        <span class="block text-6xl md:text-8xl lg:text-9xl">NG BAGUETTE</span>
        <span class="block text-7xl md:text-9xl lg:text-[11rem] text-primary" style="text-shadow: 0 0 80px rgba(202,85,163,0.4)">CONF</span>
        <span class="block text-4xl md:text-6xl lg:text-7xl text-base-content/20 font-black">2026</span>
      </h1>
      <div class="flex flex-wrap items-center justify-center gap-x-8 gap-y-3 text-base-content/50 text-lg mb-12">
        <span class="flex items-center gap-2">
          <svg class="w-5 h-5 text-primary/60" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
          29 mai 2026 &middot; 9h–18h
        </span>
        <span class="text-primary/30">—</span>
        <span class="flex items-center gap-2">
          <svg class="w-5 h-5 text-primary/60" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
          La Sorbonne · Faculté des Sciences · Paris
        </span>
      </div>
      <div class="flex flex-wrap gap-4 justify-center">
        <a href="/fr/schedule" class="btn btn-primary btn-lg" style="box-shadow: 0 8px 30px rgba(202,85,163,0.35)">
          Voir l'agenda →
        </a>
        <a href="/fr/speakers" class="btn btn-outline btn-lg hover:btn-primary">
          Les speakers
        </a>
      </div>
    </div>
  </div>

  <!-- Stats strip -->
  <div class="border-y border-base-300 bg-base-200/50">
    <div class="container mx-auto px-6 py-10">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">5+</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Speakers</p>
        </div>
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">2</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Tracks</p>
        </div>
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">1j</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">De conférences</p>
        </div>
        <div class="px-4">
          <p class="text-5xl font-black mb-1">🇫🇷</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Paris</p>
        </div>
      </div>
    </div>
  </div>

  <!-- About -->
  <div class="container mx-auto px-6 py-24">
    <div class="max-w-3xl mx-auto text-center">
      <h2 class="text-3xl md:text-4xl font-black mb-6">
        La conférence Angular<br/>
        <span class="text-primary">made in France</span>
      </h2>
      <p class="text-base-content/60 text-lg leading-relaxed mb-10">
        NG Baguette Conf rassemble la communauté Angular francophone pour une journée de conférences,
        de retours d'expérience et d'échanges. Des talks techniques de haut niveau dispensés par
        les meilleurs experts Angular.
      </p>
      <div class="flex flex-wrap gap-3 justify-center">
        <span class="badge badge-lg badge-outline">Angular 19+</span>
        <span class="badge badge-lg badge-outline">Signals</span>
        <span class="badge badge-lg badge-outline">NgRx</span>
        <span class="badge badge-lg badge-outline">Testing</span>
        <span class="badge badge-lg badge-outline">Performance</span>
        <span class="badge badge-lg badge-outline">Architecture</span>
      </div>
    </div>
  </div>

  <!-- Final CTA -->
  <div style="background: linear-gradient(135deg, rgba(202,85,163,0.06) 0%, transparent 50%, rgba(55,205,190,0.04) 100%)" class="border-t border-base-300">
    <div class="container mx-auto px-6 py-20 text-center">
      <h2 class="text-3xl font-black mb-4">Prêt pour le 29 mai ?</h2>
      <p class="text-base-content/50 mb-8 text-lg max-w-md mx-auto">
        Rejoignez la communauté Angular à Paris pour une journée inoubliable.
      </p>
      <a href="/fr/schedule" class="btn btn-primary btn-lg">Découvrir le programme</a>
    </div>
  </div>
</Layout>
EOF
cat > src/pages/en/index.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import { SITE_TITLE } from "../../consts";
---
<Layout title={SITE_TITLE}>
  <!-- Hero -->
  <div class="relative min-h-[88vh] flex items-center justify-center overflow-hidden">
    <div class="absolute inset-0 pointer-events-none" style="background: radial-gradient(ellipse 80% 60% at 50% 20%, rgba(202,85,163,0.18) 0%, transparent 70%), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(55,205,190,0.08) 0%, transparent 60%)"></div>
    <div class="relative z-10 text-center px-6 max-w-5xl mx-auto py-20">
      <p class="inline-flex items-center gap-2 border border-primary/30 text-primary/80 rounded-full px-5 py-2 text-sm font-semibold mb-10 bg-primary/5 backdrop-blur-sm">
        🥖 French cooked Angular conference
      </p>
      <h1 class="font-black leading-none tracking-tight mb-8">
        <span class="block text-6xl md:text-8xl lg:text-9xl">NG BAGUETTE</span>
        <span class="block text-7xl md:text-9xl lg:text-[11rem] text-primary" style="text-shadow: 0 0 80px rgba(202,85,163,0.4)">CONF</span>
        <span class="block text-4xl md:text-6xl lg:text-7xl text-base-content/20 font-black">2026</span>
      </h1>
      <div class="flex flex-wrap items-center justify-center gap-x-8 gap-y-3 text-base-content/50 text-lg mb-12">
        <span class="flex items-center gap-2">
          <svg class="w-5 h-5 text-primary/60" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
          May 29, 2026 &middot; 9am–6pm
        </span>
        <span class="text-primary/30">—</span>
        <span class="flex items-center gap-2">
          <svg class="w-5 h-5 text-primary/60" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
          La Sorbonne · Faculty of Science · Paris
        </span>
      </div>
      <div class="flex flex-wrap gap-4 justify-center">
        <a href="/en/schedule" class="btn btn-primary btn-lg" style="box-shadow: 0 8px 30px rgba(202,85,163,0.35)">
          View schedule →
        </a>
        <a href="/en/speakers" class="btn btn-outline btn-lg hover:btn-primary">
          Meet the speakers
        </a>
      </div>
    </div>
  </div>

  <!-- Stats strip -->
  <div class="border-y border-base-300 bg-base-200/50">
    <div class="container mx-auto px-6 py-10">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">5+</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Speakers</p>
        </div>
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">2</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Tracks</p>
        </div>
        <div class="px-4 border-r border-base-300">
          <p class="text-5xl font-black text-primary mb-1">1d</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Of talks</p>
        </div>
        <div class="px-4">
          <p class="text-5xl font-black mb-1">🇫🇷</p>
          <p class="text-base-content/40 text-xs uppercase tracking-widest">Paris</p>
        </div>
      </div>
    </div>
  </div>

  <!-- About -->
  <div class="container mx-auto px-6 py-24">
    <div class="max-w-3xl mx-auto text-center">
      <h2 class="text-3xl md:text-4xl font-black mb-6">
        The Angular conference<br/>
        <span class="text-primary">made in France</span>
      </h2>
      <p class="text-base-content/60 text-lg leading-relaxed mb-10">
        NG Baguette Conf brings together the French-speaking Angular community for a full day
        of talks, experience sharing and networking. High-level technical sessions delivered
        by the best Angular experts.
      </p>
      <div class="flex flex-wrap gap-3 justify-center">
        <span class="badge badge-lg badge-outline">Angular 19+</span>
        <span class="badge badge-lg badge-outline">Signals</span>
        <span class="badge badge-lg badge-outline">NgRx</span>
        <span class="badge badge-lg badge-outline">Testing</span>
        <span class="badge badge-lg badge-outline">Performance</span>
        <span class="badge badge-lg badge-outline">Architecture</span>
      </div>
    </div>
  </div>

  <!-- Final CTA -->
  <div style="background: linear-gradient(135deg, rgba(202,85,163,0.06) 0%, transparent 50%, rgba(55,205,190,0.04) 100%)" class="border-t border-base-300">
    <div class="container mx-auto px-6 py-20 text-center">
      <h2 class="text-3xl font-black mb-4">Ready for May 29?</h2>
      <p class="text-base-content/50 mb-8 text-lg max-w-md mx-auto">
        Join the Angular community in Paris for an unforgettable day.
      </p>
      <a href="/en/schedule" class="btn btn-primary btn-lg">Discover the program</a>
    </div>
  </div>
</Layout>
EOF
commit "feat: add home page (fr + en)"

cat > src/pages/fr/about.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="À propos — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">À propos</h1>
  <p>NG Baguette Conf est une conférence dédiée à Angular, organisée par Angular Devs France.</p>
  <p class="mt-4">Une journée de talks, d'ateliers et de networking autour de l'écosystème Angular.</p>
</Layout>
EOF
cat > src/pages/en/about.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="About — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">About</h1>
  <p>NG Baguette Conf is a conference dedicated to Angular, organized by Angular Devs France.</p>
  <p class="mt-4">A day of talks, workshops and networking around the Angular ecosystem.</p>
</Layout>
EOF
commit "feat: add about page (fr + en)"

cat > src/consts.ts << 'EOF'
export const SITE_TITLE = "NG BAGUETTE CONF 2026";
export const SITE_ACRONYM = "NG Baguette Conf";
export const SITE_DESCRIPTION = "French cooked Angular conference";
export const EVENT_DATE = "2026-05-29";
export const EVENT_START_TIME = "9h00";
export const EVENT_END_TIME = "18h00";
export const CFP_END_DATE = "2026-01-31";
export const EVENT_YEAR = 2026;
export const ADDRESS = {
  streetAddress: "4, place Jussieu",
  addressLocality: "Paris",
  postalCode: "75005",
  addressCountry: "France",
};
export const SOCIAL_LINKS = {
  twitter: "https://x.com/AngularDevsFr",
  linkedin: "https://www.linkedin.com/company/angular-devs-france",
};
EOF
commit "feat: add conference constants (address, social links)"

# ─── Commits 11-12 : Programme ────────────────────────────────────────────────

mkdir -p src/content
cat > src/content/schedule.json << 'EOF'
{
  "sessions": [
    {
      "id": "s1",
      "start": "2026-05-29T09:00:00Z",
      "end": "2026-05-29T09:30:00Z",
      "track": "main",
      "title": "Ouverture / Opening",
      "language": "fr",
      "proposal": null
    },
    {
      "id": "s2",
      "start": "2026-05-29T09:30:00Z",
      "end": "2026-05-29T10:15:00Z",
      "track": "main",
      "title": "Keynote : L'avenir d'Angular",
      "language": "fr",
      "proposal": {
        "id": "p1",
        "proposalNumber": 1,
        "abstract": "Tour d'horizon des nouveautés Angular 19 et de la roadmap 2026.",
        "level": "BEGINNER",
        "formats": ["keynote"],
        "categories": ["Angular"],
        "speakers": [
          {
            "id": "sp1",
            "name": "Sophie Martin",
            "bio": "Google Developer Expert Angular, organisatrice de meetups.",
            "company": "Google",
            "picture": "/speakers/sophie-martin.jpg",
            "socialLinks": ["https://github.com/sophiemartin"]
          }
        ]
      }
    },
    {
      "id": "s3",
      "start": "2026-05-29T10:30:00Z",
      "end": "2026-05-29T11:15:00Z",
      "track": "track-a",
      "title": "Signals avancés : patterns et anti-patterns",
      "language": "fr",
      "proposal": {
        "id": "p2",
        "proposalNumber": 2,
        "abstract": "Retour d'expérience sur l'adoption des Signals en production.",
        "level": "ADVANCED",
        "formats": ["conference"],
        "categories": ["Angular", "Signals"],
        "speakers": [
          {
            "id": "sp2",
            "name": "Lucas Dupont",
            "bio": "Architecte frontend, contributeur Angular.",
            "company": "SNCF",
            "picture": "/speakers/lucas-dupont.jpg",
            "socialLinks": ["https://github.com/lucasdupont", "https://linkedin.com/in/lucasdupont"]
          }
        ]
      }
    },
    {
      "id": "s4",
      "start": "2026-05-29T11:30:00Z",
      "end": "2026-05-29T12:15:00Z",
      "track": "track-b",
      "title": "Testing Angular avec Playwright",
      "language": "fr",
      "proposal": {
        "id": "p3",
        "proposalNumber": 3,
        "abstract": "Comment tester efficacement ses composants Angular avec Playwright.",
        "level": "INTERMEDIATE",
        "formats": ["conference"],
        "categories": ["Testing"],
        "speakers": [
          {
            "id": "sp3",
            "name": "Marie Leblanc",
            "bio": "Experte qualité logicielle, passionnée de testing.",
            "company": "Capgemini",
            "picture": "/speakers/marie-leblanc.jpg",
            "socialLinks": ["https://x.com/marieleblanc"]
          }
        ]
      }
    },
    {
      "id": "s5",
      "start": "2026-05-29T14:00:00Z",
      "end": "2026-05-29T14:45:00Z",
      "track": "track-a",
      "title": "NgRx Store vs Signal Store",
      "language": "fr",
      "proposal": {
        "id": "p4",
        "proposalNumber": 4,
        "abstract": "Comparatif des deux approches de gestion d'état en Angular.",
        "level": "INTERMEDIATE",
        "formats": ["conference"],
        "categories": ["State Management", "NgRx"],
        "speakers": [
          {
            "id": "sp4",
            "name": "Thomas Bernard",
            "bio": "Développeur Angular senior, mainteneur de bibliothèques OSS.",
            "company": "Theodo",
            "picture": "/speakers/thomas-bernard.jpg",
            "socialLinks": ["https://github.com/thomasbernard"]
          }
        ]
      }
    }
  ]
}
EOF
commit "feat: add schedule JSON data"

mkdir -p src/utils
cat > src/utils/schedule.ts << 'EOF'
import scheduleData from "../content/schedule.json";

export type Speaker = {
  id: string;
  name: string;
  bio: string;
  company: string | null;
  picture: string;
  socialLinks: string[];
};

export type Session = {
  id: string;
  start: string;
  end: string;
  track: string;
  title: string;
  language: string | null;
  proposal: {
    id: string;
    proposalNumber: number;
    abstract: string;
    level: string;
    formats: string[];
    categories: string[];
    speakers: Speaker[];
  } | null;
};

export function getAllSpeakers(): (Speaker & { sessions: Session[] })[] {
  const sessions: Session[] = scheduleData.sessions;
  const speakerMap = new Map<string, Speaker & { sessions: Session[] }>();
  for (const session of sessions) {
    if (session.proposal?.speakers) {
      for (const speaker of session.proposal.speakers) {
        if (!speakerMap.has(speaker.id)) {
          speakerMap.set(speaker.id, { ...speaker, sessions: [] });
        }
        speakerMap.get(speaker.id)!.sessions.push(session);
      }
    }
  }
  return Array.from(speakerMap.values());
}

export function getSpeakerSlug(speaker: Speaker): string {
  return speaker.name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function getSortedSessions(): Session[] {
  const sessions: Session[] = scheduleData.sessions;
  return [...sessions].sort(
    (a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()
  );
}
EOF
commit "feat: add schedule utilities (getSortedSessions, getAllSpeakers)"

# ─── Commits 13-15 : Composants programme ─────────────────────────────────────

cat > src/components/Agenda.astro << 'EOF'
---
import { getSortedSessions, getSpeakerSlug } from "../utils/schedule";
const sessions = getSortedSessions();
const locale = Astro.url.pathname.startsWith("/en") ? "en" : "fr";
const langBase = `/${locale}`;

const tracks = [...new Set(sessions.map(s => s.track))];
const trackLabels: Record<string, Record<string, string>> = {
  fr: { main: "Scène principale", "track-a": "Track A", "track-b": "Track B" },
  en: { main: "Main Stage", "track-a": "Track A", "track-b": "Track B" },
};
const levelColors: Record<string, string> = {
  BEGINNER: "badge-success",
  INTERMEDIATE: "badge-warning",
  ADVANCED: "badge-error",
};
const levelLabels: Record<string, Record<string, string>> = {
  fr: { BEGINNER: "Débutant", INTERMEDIATE: "Intermédiaire", ADVANCED: "Avancé" },
  en: { BEGINNER: "Beginner", INTERMEDIATE: "Intermediate", ADVANCED: "Advanced" },
};
---
<div class="space-y-14">
  {tracks.map(track => {
    const trackSessions = sessions.filter(s => s.track === track);
    const label = (trackLabels[locale] ?? trackLabels["fr"])[track] ?? track;
    return (
      <div>
        <div class="flex items-center gap-4 mb-6">
          <div class="w-1 h-7 bg-primary rounded-full shrink-0"></div>
          <h2 class="text-xl font-bold">{label}</h2>
          <div class="flex-1 h-px bg-base-300"></div>
          <span class="text-sm text-base-content/30">{trackSessions.length} session{trackSessions.length > 1 ? "s" : ""}</span>
        </div>
        <div class="space-y-3">
          {trackSessions.map(session => (
            <div class="group flex rounded-xl border border-base-300 bg-base-100 hover:border-primary/40 hover:bg-base-200/30 transition-all overflow-hidden">
              <div class="w-24 shrink-0 flex flex-col items-center justify-center bg-base-200/60 border-r border-base-300 py-5 px-2">
                <span class="text-sm font-mono font-bold text-primary">{session.start.slice(11, 16)}</span>
                <span class="text-xs font-mono text-base-content/30 mt-0.5">{session.end.slice(11, 16)}</span>
              </div>
              <div class="flex-1 p-4 md:p-5">
                <h3 class="font-semibold text-base md:text-lg leading-snug mb-2 group-hover:text-primary transition-colors">
                  {session.title}
                </h3>
                {session.proposal && (
                  <div class="flex flex-wrap items-center gap-x-3 gap-y-1.5">
                    {session.proposal.speakers.map(s => (
                      <a href={`${langBase}/speaker/${getSpeakerSlug(s)}`} class="flex items-center gap-1.5 text-sm text-base-content/50 hover:text-primary transition-colors">
                        <span class="w-5 h-5 rounded-full bg-primary/20 text-primary text-[10px] font-bold inline-flex items-center justify-center shrink-0">
                          {s.name.charAt(0)}
                        </span>
                        {s.name}
                        {s.company && <span class="text-base-content/30 hidden md:inline">· {s.company}</span>}
                      </a>
                    ))}
                    <div class="flex gap-1.5 ml-auto flex-wrap justify-end">
                      <span class={`badge badge-sm ${levelColors[session.proposal.level] ?? "badge-ghost"}`}>
                        {(levelLabels[locale] ?? levelLabels["fr"])[session.proposal.level] ?? session.proposal.level}
                      </span>
                      {session.language && (
                        <span class="badge badge-sm badge-outline">{session.language.toUpperCase()}</span>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  })}
</div>
EOF
commit "feat: add Agenda component"

cat > src/components/Speaker.astro << 'EOF'
---
export interface Props {
  speaker: {
    id: string;
    name: string;
    bio: string;
    company: string | null;
    picture: string;
    socialLinks: string[];
  };
}
const { speaker } = Astro.props;
---
<div class="card bg-base-100 shadow-sm border border-base-300">
  <div class="card-body">
    <div class="flex items-center gap-4">
      <div class="avatar placeholder">
        <div class="bg-primary text-primary-content rounded-full w-12">
          <span class="text-xl">{speaker.name.charAt(0)}</span>
        </div>
      </div>
      <div>
        <h3 class="font-bold">{speaker.name}</h3>
        {speaker.company && <p class="text-sm text-base-content/70">{speaker.company}</p>}
      </div>
    </div>
    <p class="text-sm mt-2">{speaker.bio}</p>
  </div>
</div>
EOF
commit "feat: add Speaker component"

cat > src/pages/fr/schedule.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import Agenda from "../../components/Agenda.astro";
import { getSortedSessions } from "../../utils/schedule";
const sessions = getSortedSessions();
---
<Layout title="Agenda — NG Baguette Conf">
  <div class="relative overflow-hidden border-b border-base-300">
    <div class="absolute inset-0 pointer-events-none" style="background: linear-gradient(90deg, rgba(202,85,163,0.06) 0%, transparent 60%)"></div>
    <div class="container mx-auto px-6 py-16">
      <p class="text-primary font-semibold uppercase tracking-widest text-sm mb-2">Programme</p>
      <h1 class="text-4xl md:text-5xl font-black mb-3">Agenda</h1>
      <p class="text-base-content/50 text-lg">29 mai 2026 · Paris · {sessions.length} sessions</p>
    </div>
  </div>
  <div class="container mx-auto px-6 py-12">
    <Agenda />
  </div>
</Layout>
EOF
cat > src/pages/en/schedule.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import Agenda from "../../components/Agenda.astro";
import { getSortedSessions } from "../../utils/schedule";
const sessions = getSortedSessions();
---
<Layout title="Schedule — NG Baguette Conf">
  <div class="relative overflow-hidden border-b border-base-300">
    <div class="absolute inset-0 pointer-events-none" style="background: linear-gradient(90deg, rgba(202,85,163,0.06) 0%, transparent 60%)"></div>
    <div class="container mx-auto px-6 py-16">
      <p class="text-primary font-semibold uppercase tracking-widest text-sm mb-2">Schedule</p>
      <h1 class="text-4xl md:text-5xl font-black mb-3">Agenda</h1>
      <p class="text-base-content/50 text-lg">May 29, 2026 · Paris · {sessions.length} sessions</p>
    </div>
  </div>
  <div class="container mx-auto px-6 py-12">
    <Agenda />
  </div>
</Layout>
EOF
commit "feat: add schedule page (fr + en)"

# ─── Commits 16-18 : Détail speakers, CFP, sponsors ──────────────────────────

mkdir -p src/pages/fr/speaker src/pages/en/speaker
cat > src/pages/fr/speaker/\[slug\].astro << 'EOF'
---
import Layout from "../../../layouts/Layout.astro";
import { getAllSpeakers, getSpeakerSlug } from "../../../utils/schedule";

export async function getStaticPaths() {
  return getAllSpeakers().map((speaker) => ({
    params: { slug: getSpeakerSlug(speaker) },
    props: { speaker },
  }));
}

const { speaker } = Astro.props;
---
<Layout title={`${speaker.name} — NG Baguette Conf`}>
  <a href="/fr/schedule" class="btn btn-ghost mb-4">← Retour à l'agenda</a>
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold">{speaker.name}</h1>
    {speaker.company && <p class="text-lg text-base-content/70 mt-1">{speaker.company}</p>}
    <p class="mt-4">{speaker.bio}</p>
  </div>
</Layout>
EOF
cat > src/pages/en/speaker/\[slug\].astro << 'EOF'
---
import Layout from "../../../layouts/Layout.astro";
import { getAllSpeakers, getSpeakerSlug } from "../../../utils/schedule";

export async function getStaticPaths() {
  return getAllSpeakers().map((speaker) => ({
    params: { slug: getSpeakerSlug(speaker) },
    props: { speaker },
  }));
}

const { speaker } = Astro.props;
---
<Layout title={`${speaker.name} — NG Baguette Conf`}>
  <a href="/en/schedule" class="btn btn-ghost mb-4">← Back to schedule</a>
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold">{speaker.name}</h1>
    {speaker.company && <p class="text-lg text-base-content/70 mt-1">{speaker.company}</p>}
    <p class="mt-4">{speaker.bio}</p>
  </div>
</Layout>
EOF
commit "feat: add speaker detail pages (fr + en)"

cat > src/pages/fr/speakers.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import { getAllSpeakers, getSpeakerSlug } from "../../utils/schedule";
const speakers = getAllSpeakers();
const levelColors: Record<string, string> = {
  BEGINNER: "badge-success",
  INTERMEDIATE: "badge-warning",
  ADVANCED: "badge-error",
};
const levelLabels: Record<string, string> = {
  BEGINNER: "Débutant",
  INTERMEDIATE: "Intermédiaire",
  ADVANCED: "Avancé",
};
---
<Layout title="Speakers — NG Baguette Conf">
  <div class="relative overflow-hidden border-b border-base-300">
    <div class="absolute inset-0 pointer-events-none" style="background: linear-gradient(90deg, rgba(202,85,163,0.06) 0%, transparent 60%)"></div>
    <div class="container mx-auto px-6 py-16">
      <p class="text-primary font-semibold uppercase tracking-widest text-sm mb-2">Intervenants</p>
      <h1 class="text-4xl md:text-5xl font-black mb-3">Les Speakers</h1>
      <p class="text-base-content/50 text-lg">{speakers.length} intervenants confirmés · édition 2026</p>
    </div>
  </div>
  <div class="container mx-auto px-6 py-12">
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {speakers.map(speaker => {
        const level = speaker.sessions?.[0]?.proposal?.level;
        const session = speaker.sessions?.[0];
        return (
          <a href={`/fr/speaker/${getSpeakerSlug(speaker)}`}
             class="group block rounded-2xl border border-base-300 bg-base-100 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/5 transition-all overflow-hidden">
            <div class="h-1.5 bg-gradient-to-r from-primary to-secondary"></div>
            <div class="p-6">
              <div class="flex items-start gap-4 mb-4">
                <div class="avatar placeholder shrink-0">
                  <div class="rounded-full w-14 text-primary font-black text-2xl flex items-center justify-center" style="background: linear-gradient(135deg, rgba(202,85,163,0.25), rgba(55,205,190,0.15))">
                    {speaker.name.charAt(0)}
                  </div>
                </div>
                <div class="min-w-0">
                  <h3 class="font-bold text-lg group-hover:text-primary transition-colors leading-tight">{speaker.name}</h3>
                  {speaker.company && <p class="text-sm text-base-content/50 mt-0.5">{speaker.company}</p>}
                  {level && (
                    <span class={`badge badge-sm mt-2 ${levelColors[level] ?? "badge-ghost"}`}>
                      {levelLabels[level] ?? level}
                    </span>
                  )}
                </div>
              </div>
              <p class="text-sm text-base-content/60 line-clamp-2 mb-3">{speaker.bio}</p>
              {session && (
                <p class="text-xs text-base-content/30 border-t border-base-300 pt-3 truncate">
                  🎤 {session.title}
                </p>
              )}
            </div>
          </a>
        );
      })}
    </div>
  </div>
</Layout>
EOF
cat > src/pages/en/speakers.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import { getAllSpeakers, getSpeakerSlug } from "../../utils/schedule";
const speakers = getAllSpeakers();
const levelColors: Record<string, string> = {
  BEGINNER: "badge-success",
  INTERMEDIATE: "badge-warning",
  ADVANCED: "badge-error",
};
const levelLabels: Record<string, string> = {
  BEGINNER: "Beginner",
  INTERMEDIATE: "Intermediate",
  ADVANCED: "Advanced",
};
---
<Layout title="Speakers — NG Baguette Conf">
  <div class="relative overflow-hidden border-b border-base-300">
    <div class="absolute inset-0 pointer-events-none" style="background: linear-gradient(90deg, rgba(202,85,163,0.06) 0%, transparent 60%)"></div>
    <div class="container mx-auto px-6 py-16">
      <p class="text-primary font-semibold uppercase tracking-widest text-sm mb-2">Speakers</p>
      <h1 class="text-4xl md:text-5xl font-black mb-3">Our Speakers</h1>
      <p class="text-base-content/50 text-lg">{speakers.length} confirmed speakers · 2026 edition</p>
    </div>
  </div>
  <div class="container mx-auto px-6 py-12">
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {speakers.map(speaker => {
        const level = speaker.sessions?.[0]?.proposal?.level;
        const session = speaker.sessions?.[0];
        return (
          <a href={`/en/speaker/${getSpeakerSlug(speaker)}`}
             class="group block rounded-2xl border border-base-300 bg-base-100 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/5 transition-all overflow-hidden">
            <div class="h-1.5 bg-gradient-to-r from-primary to-secondary"></div>
            <div class="p-6">
              <div class="flex items-start gap-4 mb-4">
                <div class="avatar placeholder shrink-0">
                  <div class="rounded-full w-14 text-primary font-black text-2xl flex items-center justify-center" style="background: linear-gradient(135deg, rgba(202,85,163,0.25), rgba(55,205,190,0.15))">
                    {speaker.name.charAt(0)}
                  </div>
                </div>
                <div class="min-w-0">
                  <h3 class="font-bold text-lg group-hover:text-primary transition-colors leading-tight">{speaker.name}</h3>
                  {speaker.company && <p class="text-sm text-base-content/50 mt-0.5">{speaker.company}</p>}
                  {level && (
                    <span class={`badge badge-sm mt-2 ${levelColors[level] ?? "badge-ghost"}`}>
                      {levelLabels[level] ?? level}
                    </span>
                  )}
                </div>
              </div>
              <p class="text-sm text-base-content/60 line-clamp-2 mb-3">{speaker.bio}</p>
              {session && (
                <p class="text-xs text-base-content/30 border-t border-base-300 pt-3 truncate">
                  🎤 {session.title}
                </p>
              )}
            </div>
          </a>
        );
      })}
    </div>
  </div>
</Layout>
EOF
commit "feat: add speakers list page (fr + en)"

cat > src/pages/fr/cfp.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="CFP — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Call for Papers</h1>
  <p class="mb-4">Le CFP pour NG Baguette Conf 2026 est maintenant fermé. Merci à tous les candidats !</p>
  <p>Les talks sélectionnés sont visibles dans <a href="/fr/schedule" class="link link-primary">l'agenda</a>.</p>
</Layout>
EOF
cat > src/pages/en/cfp.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="CFP — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Call for Papers</h1>
  <p class="mb-4">The CFP for NG Baguette Conf 2026 is now closed. Thank you to all applicants!</p>
  <p>Selected talks are visible in the <a href="/en/schedule" class="link link-primary">schedule</a>.</p>
</Layout>
EOF
commit "feat: add CFP page (fr + en)"

cat > src/pages/fr/sponsors.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Sponsors — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Sponsors</h1>
  <p class="mb-8">Merci à nos sponsors qui rendent l'événement possible.</p>
  <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
    <div class="card bg-base-100 shadow-sm border border-base-300 p-8 text-center">
      <p class="text-base-content/40">Sponsor Gold</p>
    </div>
  </div>
</Layout>
EOF
cat > src/pages/en/sponsors.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Sponsors — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Sponsors</h1>
  <p class="mb-8">Thank you to our sponsors who make the event possible.</p>
  <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
    <div class="card bg-base-100 shadow-sm border border-base-300 p-8 text-center">
      <p class="text-base-content/40">Gold Sponsor</p>
    </div>
  </div>
</Layout>
EOF
commit "feat: add sponsors page (fr + en)"

# ─── Commits 19-20 : Venue, Crew ──────────────────────────────────────────────

cat > src/pages/fr/venue.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Lieu — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Lieu</h1>
  <div class="card bg-base-100 shadow-sm border border-base-300 max-w-lg">
    <div class="card-body">
      <h2 class="card-title">La Sorbonne — Faculté des Sciences et Ingénierie</h2>
      <p>4, place Jussieu — 75005 Paris</p>
      <p class="mt-2 text-base-content/70">Accessible depuis les stations Jussieu (lignes 7 et 10).</p>
    </div>
  </div>
</Layout>
EOF
cat > src/pages/en/venue.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Venue — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Venue</h1>
  <div class="card bg-base-100 shadow-sm border border-base-300 max-w-lg">
    <div class="card-body">
      <h2 class="card-title">La Sorbonne — Faculty of Science and Engineering</h2>
      <p>4, place Jussieu — 75005 Paris</p>
      <p class="mt-2 text-base-content/70">Accessible from Jussieu metro station (lines 7 and 10).</p>
    </div>
  </div>
</Layout>
EOF
commit "feat: add venue page (fr + en)"

cat > src/components/Crew.astro << 'EOF'
---
const crew = [
  { name: "Yann Thomas-Lemoigne", role: "Organisateur" },
  { name: "Alice Dupuis", role: "Organisatrice" },
  { name: "Marc Fontaine", role: "MC / Animateur" },
];
---
<section class="my-8">
  <h2 class="text-2xl font-bold mb-6">L'équipe</h2>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    {crew.map((member) => (
      <div class="card bg-base-100 shadow-sm border border-base-300">
        <div class="card-body py-4 text-center">
          <div class="avatar placeholder mx-auto mb-2">
            <div class="bg-secondary text-secondary-content rounded-full w-12">
              <span>{member.name.charAt(0)}</span>
            </div>
          </div>
          <p class="font-bold">{member.name}</p>
          <p class="text-sm text-base-content/70">{member.role}</p>
        </div>
      </div>
    ))}
  </div>
</section>
EOF
commit "feat: add crew section component"

# ─── Commit 21 — LE BUG ───────────────────────────────────────────────────────

cat > src/utils/schedule.ts << 'EOF'
import scheduleData from "../content/schedule.json";

export type Speaker = {
  id: string;
  name: string;
  bio: string;
  company: string | null;
  picture: string;
  socialLinks: string[];
};

export type Session = {
  id: string;
  start: string;
  end: string;
  track: string;
  title: string;
  language: string | null;
  proposal: {
    id: string;
    proposalNumber: number;
    abstract: string;
    level: string;
    formats: string[];
    categories: string[];
    speakers: Speaker[];
  } | null;
};

export function getAllSpeakers(): (Speaker & { sessions: Session[] })[] {
  const sessions: Session[] = scheduleData.sessions;
  const speakerMap = new Map<string, Speaker & { sessions: Session[] }>();
  for (const session of sessions) {
    if (session.proposal?.speakers) {
      for (const speaker of session.proposal.speakers) {
        if (!speakerMap.has(speaker.id)) {
          speakerMap.set(speaker.id, { ...speaker, sessions: [] });
        }
        speakerMap.get(speaker.id)!.sessions.push(session);
      }
    }
  }
  return Array.from(speakerMap.values());
}

export function getSpeakerSlug(speaker: Speaker): string {
  return speaker.name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function getSortedSessions(): Session[] {
  const sessions: Session[] = scheduleData.sessions;
  return [...sessions].sort(
    (a, b) => new Date(b.start).getTime() - new Date(a.start).getTime()
  );
}
EOF
commit "refactor(schedule): optimize session sort for performance"

# ─── Commits 22-28 : Features post-bug ────────────────────────────────────────

cat > src/components/Speaker.astro << 'EOF'
---
export interface Props {
  speaker: {
    id: string;
    name: string;
    bio: string;
    company: string | null;
    picture: string;
    socialLinks: string[];
    sessions?: { proposal: { level: string } | null }[];
  };
}
const { speaker } = Astro.props;
const levelColors: Record<string, string> = {
  BEGINNER: "badge-success",
  INTERMEDIATE: "badge-warning",
  ADVANCED: "badge-error",
};
const levelLabels: Record<string, string> = {
  BEGINNER: "Débutant",
  INTERMEDIATE: "Intermédiaire",
  ADVANCED: "Avancé",
};
const level = speaker.sessions?.[0]?.proposal?.level;
---
<div class="card bg-base-100 shadow-sm border border-base-300">
  <div class="card-body">
    <div class="flex items-center gap-4">
      <div class="avatar placeholder">
        <div class="bg-primary text-primary-content rounded-full w-12">
          <span class="text-xl">{speaker.name.charAt(0)}</span>
        </div>
      </div>
      <div>
        <h3 class="font-bold">{speaker.name}</h3>
        {speaker.company && <p class="text-sm text-base-content/70">{speaker.company}</p>}
        {level && <span class={`badge badge-sm mt-1 ${levelColors[level] ?? "badge-ghost"}`}>{levelLabels[level] ?? level}</span>}
      </div>
    </div>
    <p class="text-sm mt-2">{speaker.bio}</p>
  </div>
</div>
EOF
commit "feat: add talk level badges to Speaker component"

cat > src/components/Header.astro << 'EOF'
---
const lang = Astro.url.pathname.startsWith("/en") ? "en" : "fr";
const base = `/${lang}`;
const navItems = lang === "fr"
  ? [{ href: "/schedule", label: "Agenda" }, { href: "/speakers", label: "Speakers" }, { href: "/sponsors", label: "Sponsors" }, { href: "/about", label: "À propos" }]
  : [{ href: "/schedule", label: "Schedule" }, { href: "/speakers", label: "Speakers" }, { href: "/sponsors", label: "Sponsors" }, { href: "/about", label: "About" }];
const currentPath = Astro.url.pathname;
---
<header class="navbar bg-base-100/80 backdrop-blur-md border-b border-base-300 sticky top-0 z-50">
  <div class="navbar-start">
    <div class="dropdown lg:hidden">
      <div tabindex="0" role="button" class="btn btn-ghost btn-sm">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </div>
      <ul tabindex="0" class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow-xl bg-base-100 border border-base-300 rounded-box w-52">
        {navItems.map(item => <li><a href={`${base}${item.href}`} class="hover:text-primary">{item.label}</a></li>)}
      </ul>
    </div>
    <a href={base} class="ml-2 flex items-center gap-1 font-black text-lg">
      <span>🥖</span>
      <span><span class="text-primary">NG</span> Baguette <span class="text-base-content/40 font-normal text-sm">Conf</span></span>
    </a>
  </div>
  <nav class="navbar-center hidden lg:flex">
    <ul class="flex items-center gap-1">
      {navItems.map(item => (
        <li>
          <a href={`${base}${item.href}`}
             class={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors hover:text-primary hover:bg-primary/8 ${currentPath.includes(item.href) ? "text-primary bg-primary/10" : "text-base-content/70"}`}>
            {item.label}
          </a>
        </li>
      ))}
    </ul>
  </nav>
  <div class="navbar-end">
    <a href={lang === "fr" ? "/en" : "/fr"} class="btn btn-ghost btn-sm font-semibold text-base-content/50 hover:text-primary">
      {lang === "fr" ? "EN" : "FR"}
    </a>
  </div>
</header>
EOF
commit "fix: improve mobile navigation with dropdown"

cat > src/layouts/BaseLayout.astro << 'EOF'
---
export interface Props {
  title: string;
  description?: string;
  ogImage?: string;
}
const {
  title,
  description = "NG Baguette Conf — French cooked Angular conference",
  ogImage = "/og-image.png",
} = Astro.props;
const canonical = new URL(Astro.url.pathname, "https://ngbaguette.angulardevs.fr");
---
<!doctype html>
<html lang="fr" data-theme="mytheme">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet" />
    <link rel="canonical" href={canonical} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:image" content={ogImage} />
    <meta property="og:type" content="website" />
    <meta name="twitter:card" content="summary_large_image" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  </head>
  <body class="min-h-screen bg-base-100 text-base-content font-sans antialiased">
    <slot />
  </body>
</html>
EOF
commit "feat: add SEO meta tags and OpenGraph support"

cat > src/components/ProgramItem.astro << 'EOF'
---
import type { Session } from "../utils/schedule";
export interface Props { session: Session; locale?: "fr" | "en"; }
const { session, locale = "fr" } = Astro.props;
const levelColors: Record<string, string> = {
  BEGINNER: "badge-success",
  INTERMEDIATE: "badge-warning",
  ADVANCED: "badge-error",
};
const startTime = session.start.slice(11, 16);
const endTime = session.end.slice(11, 16);
---
<div class="flex gap-4 py-3 border-b border-base-200 last:border-0">
  <div class="text-sm font-mono text-base-content/50 w-20 shrink-0 pt-1">
    {startTime}–{endTime}
  </div>
  <div class="flex-1">
    <h3 class="font-semibold">{session.title}</h3>
    {session.proposal && (
      <div class="flex items-center gap-2 mt-1 flex-wrap">
        {session.proposal.speakers.map(s => (
          <span class="text-sm text-base-content/70">{s.name}</span>
        ))}
        <span class={`badge badge-sm ${levelColors[session.proposal.level] ?? "badge-ghost"}`}>
          {session.proposal.level}
        </span>
        {session.language && (
          <span class="badge badge-sm badge-outline">{session.language.toUpperCase()}</span>
        )}
      </div>
    )}
  </div>
</div>
EOF
commit "feat: add ProgramItem component with level badges and timing"

cat > src/components/Track.astro << 'EOF'
---
import type { Session } from "../utils/schedule";
import ProgramItem from "./ProgramItem.astro";
export interface Props {
  name: string;
  sessions: Session[];
  locale?: "fr" | "en";
}
const { name, sessions, locale = "fr" } = Astro.props;
---
<div class="card bg-base-100 shadow-sm border border-base-300">
  <div class="card-body p-4">
    <h3 class="card-title text-lg capitalize">{name}</h3>
    <div>
      {sessions.map(session => <ProgramItem session={session} locale={locale} />)}
    </div>
  </div>
</div>
EOF
commit "feat: add Track component for schedule layout"

cat > src/components/Sponsors.astro << 'EOF'
---
export interface Props {
  sponsors: Array<{ name: string; url: string; logo?: string; tier: string }>;
  locale?: "fr" | "en";
}
const { sponsors, locale = "fr" } = Astro.props;
const tiers = [...new Set(sponsors.map(s => s.tier))];
const tierLabels: Record<string, Record<string, string>> = {
  fr: { platinum: "Platine", gold: "Or", silver: "Argent", bronze: "Bronze" },
  en: { platinum: "Platinum", gold: "Gold", silver: "Silver", bronze: "Bronze" },
};
---
<div class="space-y-8">
  {tiers.map(tier => (
    <div>
      <h3 class="text-xl font-bold mb-4 capitalize">{tierLabels[locale][tier] ?? tier}</h3>
      <div class="flex flex-wrap gap-4">
        {sponsors.filter(s => s.tier === tier).map(s => (
          <a href={s.url} target="_blank" rel="noopener noreferrer"
             class="card bg-base-100 shadow-sm border border-base-300 p-6 hover:shadow-md transition-shadow">
            <span class="font-bold">{s.name}</span>
          </a>
        ))}
      </div>
    </div>
  ))}
</div>
EOF
commit "feat: add Sponsors component with tier grouping"

cat > src/pages/fr/coc.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Code de conduite — NG Baguette Conf">
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold mb-6">Code de conduite</h1>
    <p class="mb-4">NG Baguette Conf s'engage à offrir un environnement accueillant et sûr pour tous les participants.</p>
    <h2 class="text-xl font-bold mb-2">Notre engagement</h2>
    <p class="mb-4">Nous ne tolérons aucune forme de harcèlement des participants à la conférence.</p>
    <h2 class="text-xl font-bold mb-2">Signalement</h2>
    <p>Pour signaler un incident : <a href="mailto:coc@ngbaguette.dev" class="link link-primary">coc@ngbaguette.dev</a></p>
  </div>
</Layout>
EOF
cat > src/pages/en/coc.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="Code of Conduct — NG Baguette Conf">
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold mb-6">Code of Conduct</h1>
    <p class="mb-4">NG Baguette Conf is committed to providing a welcoming and safe environment for all participants.</p>
    <h2 class="text-xl font-bold mb-2">Our pledge</h2>
    <p class="mb-4">We do not tolerate any form of harassment of conference participants.</p>
    <h2 class="text-xl font-bold mb-2">Reporting</h2>
    <p>To report an incident: <a href="mailto:coc@ngbaguette.dev" class="link link-primary">coc@ngbaguette.dev</a></p>
  </div>
</Layout>
EOF
commit "feat: add code of conduct page (fr + en)"

# ─── Commits 29-30 : Social links, release ────────────────────────────────────

cat > src/consts.ts << 'EOF'
export const SITE_TITLE = "NG BAGUETTE CONF 2026";
export const SITE_ACRONYM = "NG Baguette Conf";
export const SITE_DESCRIPTION = "French cooked Angular conference";
export const EVENT_DATE = "2026-05-29";
export const EVENT_START_TIME = "9h00";
export const EVENT_END_TIME = "18h00";
export const CFP_END_DATE = "2026-01-31";
export const EVENT_YEAR = 2026;
export const ADDRESS = {
  streetAddress: "4, place Jussieu",
  addressLocality: "Paris",
  postalCode: "75005",
  addressCountry: "France",
};
export const SOCIAL_LINKS = {
  twitter: "https://x.com/AngularDevsFr",
  bluesky: "https://bsky.app/profile/angulardevs.fr",
  linkedin: "https://www.linkedin.com/company/angular-devs-france",
};
export const CFP_LINK = "https://conference-hall.io/ng-baguette-conf-2026";
EOF
commit "feat: add social links (Bluesky, Twitter, LinkedIn)"

cat > src/components/Footer.astro << 'EOF'
---
import { SOCIAL_LINKS } from "../consts";
---
<footer class="mt-20 border-t border-base-300 bg-base-200/30">
  <div class="container mx-auto px-6 py-12">
    <div class="flex flex-col md:flex-row items-center justify-between gap-8">
      <div class="text-center md:text-left">
        <p class="font-black text-xl">🥖 NG Baguette Conf</p>
        <p class="text-base-content/40 text-sm mt-1">French cooked Angular conference</p>
        <p class="text-base-content/25 text-xs mt-1">La Sorbonne · 29 mai 2026 · Paris</p>
      </div>
      <div class="flex items-center gap-1">
        <a href={SOCIAL_LINKS.twitter} target="_blank" rel="noopener noreferrer"
           class="btn btn-ghost btn-sm btn-square" title="Twitter / X">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.74l7.73-8.835L1.254 2.25H8.08l4.253 5.622zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
        </a>
        <a href={SOCIAL_LINKS.linkedin} target="_blank" rel="noopener noreferrer"
           class="btn btn-ghost btn-sm btn-square" title="LinkedIn">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 01-2.063-2.065 2.064 2.064 0 112.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
        </a>
        {SOCIAL_LINKS.bluesky && (
          <a href={SOCIAL_LINKS.bluesky} target="_blank" rel="noopener noreferrer"
             class="btn btn-ghost btn-sm btn-square" title="Bluesky">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 10.8c-1.087-2.114-4.046-6.053-6.798-7.995C2.566.944 1.561 1.266.902 1.565.139 1.908 0 3.08 0 3.768c0 .69.378 5.65.624 6.479.815 2.736 3.713 3.66 6.383 3.364.136-.02.275-.039.415-.056-.138.022-.276.04-.415.056-3.912.58-7.387 2.005-2.83 7.078 5.013 5.19 6.87-1.113 7.823-4.308.953 3.195 2.05 9.271 7.733 4.308 4.267-4.308 1.172-6.498-2.74-7.078a8.741 8.741 0 01-.415-.056c.14.017.279.036.415.056 2.67.297 5.568-.628 6.383-3.364.246-.828.624-5.79.624-6.478 0-.69-.139-1.861-.902-2.206-.659-.298-1.664-.62-4.3 1.24C16.046 4.748 13.087 8.687 12 10.8z"/></svg>
          </a>
        )}
      </div>
      <p class="text-base-content/25 text-xs">© 2026 Angular Devs France</p>
    </div>
  </div>
</footer>
EOF
commit "feat: update footer with social links"

echo "1.0.0" > VERSION
commit "chore: release v1.0.0"

# ─── Branches pour les exercices ──────────────────────────────────────────────

MAIN_HASH=$(git rev-parse HEAD)

# Branch feature/responsive-nav — WIP (rebase exercice)
git checkout -b feature/responsive-nav --quiet
cat > src/components/Header.astro << 'EOF'
---
const lang = Astro.url.pathname.startsWith("/en") ? "en" : "fr";
const base = `/${lang}`;
const navItems = lang === "fr"
  ? [{ href: "/schedule", label: "Agenda" }, { href: "/sponsors", label: "Sponsors" }, { href: "/about", label: "À propos" }, { href: "/venue", label: "Lieu" }]
  : [{ href: "/schedule", label: "Schedule" }, { href: "/sponsors", label: "Sponsors" }, { href: "/about", label: "About" }, { href: "/venue", label: "Venue" }];
---
<header class="navbar bg-base-100 shadow-sm sticky top-0 z-50">
  <div class="navbar-start">
    <div class="drawer lg:hidden">
      <input id="mobile-nav" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content">
        <label for="mobile-nav" class="btn btn-ghost drawer-button" aria-label="Menu">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </label>
      </div>
      <div class="drawer-side z-[100]">
        <label for="mobile-nav" aria-label="close sidebar" class="drawer-overlay"></label>
        <ul class="menu p-4 w-64 min-h-full bg-base-100 shadow-xl">
          <li class="mb-4">
            <a href={base} class="text-xl font-bold">🥖 NG Baguette Conf</a>
          </li>
          {navItems.map(item => <li><a href={`${base}${item.href}`}>{item.label}</a></li>)}
        </ul>
      </div>
    </div>
    <a href={base} class="text-xl font-bold ml-2 hidden lg:flex">🥖 NG Baguette Conf</a>
  </div>
  <nav class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      {navItems.map(item => <li><a href={`${base}${item.href}`}>{item.label}</a></li>)}
    </ul>
  </nav>
  <div class="navbar-end">
    <a href={lang === "fr" ? "/en" : "/fr"} class="btn btn-ghost btn-sm">{lang === "fr" ? "EN" : "FR"}</a>
  </div>
</header>
EOF
git add -A && git commit -m "feat(nav): replace dropdown with drawer for mobile navigation" --quiet

# Modification non-committée intentionnelle (travail en cours)
cat >> src/components/Drawer.astro << 'EOF'

<!-- TODO: add close on ESC key -->
<script>
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const checkbox = document.getElementById('mobile-nav') as HTMLInputElement | null;
      if (checkbox) checkbox.checked = false;
    }
  });
</script>
EOF
git checkout main --quiet

# Branch feature/speaker-search — Complète (2 commits, worktrees exercice)
git checkout -b feature/speaker-search --quiet
cat >> src/utils/schedule.ts << 'EOF'

export function searchSpeakers(query: string): (Speaker & { sessions: Session[] })[] {
  if (!query.trim()) return getAllSpeakers();
  const q = query.toLowerCase();
  return getAllSpeakers().filter(
    (s) =>
      s.name.toLowerCase().includes(q) ||
      (s.company ?? "").toLowerCase().includes(q) ||
      s.bio.toLowerCase().includes(q)
  );
}
EOF
git add -A && git commit -m "feat(search): add searchSpeakers utility function" --quiet

cat > src/components/SpeakerSearch.astro << 'EOF'
---
import { getAllSpeakers } from "../utils/schedule";
import Speaker from "./Speaker.astro";
const allSpeakers = getAllSpeakers();
---
<div>
  <input
    id="speaker-search"
    type="search"
    placeholder="Rechercher un speaker..."
    class="input input-bordered w-full mb-6"
  />
  <div id="speaker-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    {allSpeakers.map((speaker) => (
      <div class="speaker-card" data-name={speaker.name.toLowerCase()} data-company={(speaker.company ?? "").toLowerCase()}>
        <Speaker speaker={speaker} />
      </div>
    ))}
  </div>
</div>
<script>
  const searchInput = document.getElementById('speaker-search') as HTMLInputElement;
  const cards = document.querySelectorAll<HTMLElement>('.speaker-card');
  searchInput?.addEventListener('input', (e) => {
    const q = (e.target as HTMLInputElement).value.toLowerCase();
    cards.forEach(card => {
      const matches = card.dataset.name?.includes(q) || card.dataset.company?.includes(q);
      card.style.display = matches ? '' : 'none';
    });
  });
</script>
EOF
git add -A && git commit -m "feat: add SpeakerSearch component with live filtering" --quiet
git checkout main --quiet

# Branch feature/cfp-form — sera "supprimée" pour l'exercice reflog
git checkout -b feature/cfp-form --quiet
cat > src/pages/fr/cfp.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="CFP — NG Baguette Conf">
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold mb-6">Call for Papers</h1>
    <p class="mb-6">Vous souhaitez parler à NG Baguette Conf 2026 ? Soumettez votre proposition ci-dessous.</p>
    <form class="space-y-4" action="/api/cfp" method="POST">
      <div class="form-control">
        <label class="label"><span class="label-text">Titre du talk *</span></label>
        <input name="title" type="text" class="input input-bordered" required maxlength="100" />
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Abstract *</span></label>
        <textarea name="abstract" class="textarea textarea-bordered h-32" required maxlength="1000"></textarea>
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Niveau</span></label>
        <select name="level" class="select select-bordered">
          <option value="BEGINNER">Débutant</option>
          <option value="INTERMEDIATE" selected>Intermédiaire</option>
          <option value="ADVANCED">Avancé</option>
        </select>
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Votre email *</span></label>
        <input name="email" type="email" class="input input-bordered" required />
      </div>
      <button type="submit" class="btn btn-primary w-full">Soumettre ma proposition</button>
    </form>
  </div>
</Layout>
EOF
git add -A && git commit -m "feat(cfp): add CFP submission form" --quiet

CFP_FORM_HASH=$(git rev-parse HEAD)
git checkout main --quiet

# Simuler la suppression de la branche (exercice reflog)
git branch -D feature/cfp-form

git checkout main --quiet

echo ""
echo "✅ ng-baguette-conf prêt !"
echo ""
git log --oneline | wc -l | xargs echo "   Commits :"
git branch | xargs echo "   Branches :"
echo ""
echo "   Bug planté au commit : $(git log --oneline | grep 'optimize session sort' | awk '{print $1}')"
echo "   Script bisect        : ./bisect-test.sh"
echo ""
echo "👉 Vérification rapide :"
node --input-type=module << 'EOF'
import { readFileSync } from "fs";
const code = readFileSync("src/utils/schedule.ts", "utf8");
const hasBug = code.includes("new Date(b.start).getTime() - new Date(a.start).getTime()");
console.log(hasBug ? "   ⚠️  Bug confirmé dans schedule.ts (ordre inversé)" : "   ✅ Pas de bug détecté");
EOF

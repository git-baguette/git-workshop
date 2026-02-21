import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Vous croyez connaître Git ?',
  tagline: 'Challenge Accepted — Worktrees, Reflog, Bisect, Workflows',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://your-docusaurus-site.example.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'git-workshop', // Usually your GitHub org/user name.
  projectName: 'git-workshop', // Usually your repo name.

  onBrokenLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Git Workshop',
      logo: {
        alt: 'Git logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Modules',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Modules',
          items: [
            { label: 'Introduction',          to: '/docs/intro' },
            { label: 'Setup',                 to: '/docs/setup' },
            { label: '1 — Worktrees',         to: '/docs/worktrees/overview' },
            { label: '2 — Reflog',            to: '/docs/reflog/overview' },
            { label: '3 — Bisect',            to: '/docs/bisect/overview' },
            { label: '4 — Rebase',            to: '/docs/rebase/overview' },
            { label: '5 — Workflows',         to: '/docs/workflows/overview' },
          ],
        },
        {
          title: 'Ressources',
          items: [
            { label: 'Documentation Git',  href: 'https://git-scm.com/doc' },
            { label: 'Pro Git (gratuit)',   href: 'https://git-scm.com/book/fr/v2' },
          ],
        },
      ],
      copyright: `Workshop Git "Vous croyez connaître Git ?" — ${new Date().getFullYear()}`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

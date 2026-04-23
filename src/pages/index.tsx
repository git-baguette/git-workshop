import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import Heading from "@theme/Heading";

import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to={siteConfig.baseUrl + "docs/intro"}
          >
            Relever le défi →
          </Link>
          <a
            className="button button--secondary button--lg"
            href="https://bit.ly/gitbaguette"
            target="_blank"
            rel="noreferrer"
            style={{
              position: "absolute",
              top: "1rem",
              right: "1rem",
              zIndex: 1,
            }}
          >
            https://bit.ly/gitbaguette
          </a>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Workshop Git avancé — Worktrees, Reflog, Bisect, Workflows. Hands-on, en français."
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}

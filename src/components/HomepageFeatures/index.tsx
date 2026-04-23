import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";

type FeatureItem = {
  title: string;
  emoji: string;
  description: ReactNode;
  link: string;
  badge: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Worktrees",
    emoji: "🌳",
    badge: "Module 1",
    description: (
      <>
        Travaillez sur 3 features en même temps sans stash, sans clone, sans
        perdre la tête. Un seul objet store, toutes vos branches accessibles
        instantanément dans des dossiers séparés.
      </>
    ),
    link: "docs/worktrees/overview",
  },
  {
    title: "Reflog",
    emoji: "🔍",
    badge: "Module 2",
    description: (
      <>
        Retrouvez CE commit que vous juriez avoir perdu à jamais.{" "}
        <code>git reset --hard</code>, branche supprimée, rebase catastrophique
        — le reflog est votre filet de sécurité ultime.
      </>
    ),
    link: "docs/reflog/overview",
  },
  {
    title: "Bisect",
    emoji: "🔬",
    badge: "Module 3",
    description: (
      <>
        Débusquez le bug introduit il y a 47 commits en 6 questions. La
        recherche binaire appliquée à votre historique Git — manuellement ou
        entièrement automatisée avec un script de test.
      </>
    ),
    link: "docs/bisect/overview",
  },
  {
    title: "Rebase",
    emoji: "✂️",
    badge: "Module 4",
    description: (
      <>
        Enfin comprendre ce que fait <code>git rebase</code>. Squash, fixup,
        reword, drop, réordonnancement — maîtrisez le rebase interactif pour un
        historique qui raconte une histoire.
      </>
    ),
    link: "docs/rebase/overview",
  },
  {
    title: "Workflows",
    emoji: "🗺️",
    badge: "Module 5",
    description: (
      <>
        Gitflow, GitHub Flow, Trunk-Based Development. Comprenez les trade-offs
        et choisissez le bon workflow pour votre équipe — arrêtez de subir celui
        qu'on vous a imposé.
      </>
    ),
    link: "docs/workflows/overview",
  },
  {
    title: "Bonus",
    emoji: "🎁",
    badge: "Module 6",
    description: (
      <>
        Hooks, alias, astuces de config, commandes moins connues — un condensé
        de tips pour booster votre productivité et épater vos collègues.
      </>
    ),
    link: "docs/bonus/overview",
  },
];

function Feature({ title, emoji, badge, description, link }: FeatureItem) {
  return (
    <div className={clsx("col col--4")} style={{ marginBottom: "2rem" }}>
      <div
        className="text--center"
        style={{ fontSize: "3rem", padding: "1.5rem 1rem 0.5rem" }}
      >
        {emoji}
      </div>
      <div
        className="text--center padding-horiz--md"
        style={{ paddingBottom: "1.5rem" }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            gap: "0.5rem",
            marginBottom: "0.5rem",
          }}
        >
          <small
            style={{
              color: "var(--ifm-color-primary)",
              fontWeight: 600,
              textTransform: "uppercase",
              letterSpacing: "0.05em",
            }}
          >
            {badge}
          </small>
        </div>
        <Heading as="h3" style={{ marginTop: 0 }}>
          {title}
        </Heading>
        <p>{description}</p>
        <a
          className="button button--outline button--primary button--sm"
          href={link}
        >
          Commencer →
        </a>
      </div>
    </div>
  );
}

function DiscountCTA() {
  return (
    <div
      style={{
        marginTop: "3rem",
        padding: "2.5rem 2rem",
        borderRadius: "1rem",
        background:
          "linear-gradient(135deg, rgba(236, 72, 153, 0.08), rgba(168, 85, 247, 0.08))",
        border: "1px solid var(--ifm-color-primary-lightest)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        textAlign: "center",
        gap: "1rem",
      }}
    >
      <img
        src="img/ng-baguette-logo.svg"
        alt="NG Baguette Conf"
        style={{ maxWidth: "260px", width: "100%", height: "auto" }}
      />
      <Heading as="h2" style={{ margin: 0 }}>
        Offre spéciale participants
      </Heading>
      <p style={{ maxWidth: "640px", margin: 0 }}>
        Profitez d'une réduction exclusive sur votre billet pour
        <strong>NG Baguette Conf</strong> — la seule conférence Angular
        française.
      </p>
      <p>
        Code de réduction : <strong>NGBDEVOXX</strong> (20% de réduction sur les
        billets individuels)
      </p>
      <a
        className="button button--primary button--lg"
        href="https://www.helloasso.com/associations/angular-nexus/evenements/ng-baguette-conf-2026"
        target="_blank"
        rel="noopener noreferrer"
      >
        Obtenir ma réduction →
      </a>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row" style={{ justifyContent: "center" }}>
          {FeatureList.map((props, idx) => (
            <Feature
              key={idx}
              {...props}
              link={siteConfig.baseUrl + props.link}
            />
          ))}
        </div>
        <DiscountCTA />
      </div>
    </section>
  );
}

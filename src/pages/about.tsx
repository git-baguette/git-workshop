import type { ReactNode } from "react";
import Layout from "@theme/Layout";
import Heading from "@theme/Heading";

import styles from "./about.module.css";

type Speaker = {
  name: string;
  role: string;
  photo: string;
  github: string;
  bio: string;
};

const speakers: Speaker[] = [
  {
    name: "Yann-Thomas Le Moigne",
    role: "TechLead @ CGI — Tours, France",
    photo: "https://github.com/yatho.png",
    github: "https://github.com/yatho",
    bio:
      "Passionné par l'informatique depuis sa plus tendre enfance, Yann-Thomas aime partager ses connaissances. " +
      "Curieux et fan des outils qui simplifient le quotidien des développeurs, il partage son expertise autour " +
      "de JavaScript, Angular, Svelte, Java, Spring et Quarkus. En dehors du code, il est sapeur-pompier volontaire depuis plus de 10 ans.",
  },
  {
    name: "Anthony Pena",
    role: "Staff Engineer — Nantes, France",
    photo: "https://github.com/kuroidoruido.png",
    github: "https://github.com/kuroidoruido",
    bio:
      "Développeur web et Staff Engineer, Anthony est un utilisateur ArchLinux passionné par la philosophie du logiciel libre. " +
      "Il maîtrise les frameworks frontend (Angular, React, Vue, Lit, Web Components) autant que le backend JVM (Java, Quarkus, Spring), " +
      "et partage régulièrement articles techniques et retours d'expérience à la communauté.",
  },
];

function SpeakerCard({ speaker }: { speaker: Speaker }): ReactNode {
  return (
    <article className={styles.card}>
      <img
        src={speaker.photo}
        alt={`Photo de ${speaker.name}`}
        className={styles.photo}
        loading="lazy"
      />
      <Heading as="h2" className={styles.name}>
        {speaker.name}
      </Heading>
      <p className={styles.role}>{speaker.role}</p>
      <p className={styles.bio}>{speaker.bio}</p>
      <div className={styles.links}>
        <a
          className="button button--primary button--sm"
          href={speaker.github}
          target="_blank"
          rel="noopener noreferrer"
        >
          GitHub ↗
        </a>
      </div>
    </article>
  );
}

export default function About(): ReactNode {
  return (
    <Layout
      title="À propos"
      description="Les intervenants du workshop Git : Yann-Thomas Le Moigne et Anthony Pena."
    >
      <main className={styles.container}>
        <div className={styles.intro}>
          <Heading as="h1">À propos</Heading>
          <p>Ce workshop Git est animé par deux développeurs passionnés.</p>
        </div>
        <div className={styles.speakers}>
          {speakers.map((speaker) => (
            <SpeakerCard key={speaker.name} speaker={speaker} />
          ))}
        </div>
      </main>
    </Layout>
  );
}

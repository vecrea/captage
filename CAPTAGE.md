# CAPTAGE.md · Le pourquoi

Ce fichier, c'est le monde dans lequel tu vas coder. Pas la procédure (elle est
dans les 9 étapes), pas les règles de l'agent (elles sont dans `CLAUDE.md`). Juste
ce qu'il faut comprendre une fois pour que le reste ait du sens. Lis-le une fois,
garde-le sous le coude.

---

## Ce que tu construis, en une image

Tu passes ta journée à croiser des trucs qui valent le coup : un article, une vidéo,
un thread, un PDF, un podcast. Et 95 % se perd, parce que « je le rangerai plus tard »
n'arrive jamais.

Captage règle ça avec un seul geste : tu **captes du bruit**, une **IA locale pré-trie**,
**tu tranches**, et ce que tu gardes va **se graver dans ta Vérité**. Le reste meurt sans
te déranger.

Tout le système tient dans une distinction :

- **Le Réservoir** · jetable, bruyant, local. On y jette tout sans réfléchir.
- **La Vérité** · choisie, durable, partagée (une base Notion). On n'y met que ce qu'on
  a décidé de garder.

Trier, c'est faire passer un item du Réservoir à la Vérité. Tout Captage est là.

---

## Les deux gestes : s'abonner / capter

Il y a deux façons de remplir le Réservoir, et c'est volontairement deux verbes
distincts :

- **S'abonner** · un flux qui te suit dans le temps (RSS). Tu le poses une fois, il
  alimente le Réservoir tout seul, en continu.
- **Capter** · un truc précis, maintenant (une page web, une image, un son). Geste
  ponctuel, à la demande.

Même destination, deux intentions. Ne les confonds pas : s'abonner, c'est tendre un
filet ; capter, c'est attraper à la main.

---

## Les 4 concepts qui tiennent tout

**1. Réservoir vs Vérité.** Déjà dit, mais c'est le cœur, donc on le répète : le
Réservoir a le droit d'être sale. La Vérité non. Le jour où tu hésites sur une
décision technique, demande-toi de quel côté tu es. Côté Réservoir, on est permissif
(on capte large, on dédoublonne en silence). Côté Vérité, on est exigeant (on ne grave
que ce qu'un humain a validé).

**2. Structure commune.** D'où qu'il vienne, tout item a la même forme :
`{ source, titre, contenu, media_url, url, capte_le }`. Un article RSS, une image, un
épisode de podcast · même moule. C'est ce qui rend les sources **interchangeables** :
ajouter une source, c'est écrire un petit traducteur qui rend cette forme, et rien
d'autre. Tu ne touches **jamais** à la partie qui écrit en base. Une source récolte
(et c'est pur, ça ne parle à personne), seul le Réservoir écrit.

**3. Local-first.** Postgres et l'IA (Gemma via Ollama) tournent **sur ta machine**.
Rien ne part dans le cloud tant que tu n'as pas tranché. Trois raisons : tu es
souverain sur tes données, ça coûte zéro, et c'est rapide. Le seul truc distant, c'est
la Vérité Notion · la sortie, pas l'usine.

**4. « L'IA pré-trie, l'humain tranche. »** L'IA locale lit chaque item et propose un
verdict · `produire`, `ignorer`, `peut-être`. Elle **propose**, elle ne décide jamais.
La décision finale (Garder / Jeter) reste la tienne. C'est la ligne rouge du projet :
l'IA te fait gagner du temps en classant le bruit, elle ne te remplace pas sur le
jugement. Le jour où tu la laisses trancher seule, ce n'est plus Captage.

---

## La place dans CAPITAINE

Captage ne vit pas seul. C'est la première brique d'une chaîne :

> **Captage → Traitement → Cascade**

- **Captage** remplit le Réservoir et le trie. Il ne **crée** rien · il capte et choisit.
- **Traitement** enrichit ce qui a été gardé.
- **Cascade** produit (du contenu éditorial, à partir de cette matière première triée).

Autrement dit : Captage est la **porte d'entrée**. Sans lui, Cascade tourne à vide.
Une bonne captation aujourd'hui, c'est une bonne production demain.

---

## La double nature

Ce repo est deux choses à la fois, et c'est voulu :

1. **Un outil de production réel.** Tu ne construis pas une maquette qu'on jette à la
   fin. À la dernière étape, tu auras un système qui capte vraiment, que tu vas vraiment
   utiliser.
2. **Un parcours pédagogique reproductible.** Chaque étape produit une **preuve**
   vérifiable (un conteneur qui tourne, une page qui répond, une row en base, un verdict
   qui se remplit). Ces preuves sont testées · un script de conformance les constate, et
   un agent peut même rejouer tout le parcours dans un Linux jetable pour vérifier que
   « suivre le guide produit un système qui marche ».

Tu apprends Postgres, Docker, Python, une IA locale et une UI · non pas sur un projet
bidon, mais en te fabriquant ton propre outil. C'est le meilleur moteur qui soit.

---

## La méthode (vibecoding)

On construit avec un agent (Claude Code), et ça suit une discipline simple :

- **Intention d'abord.** On sait ce qu'on veut avant de taper.
- **Plan depuis l'existant.** On inventorie avant d'agir (`lsof`, `docker ps`,
  `ollama list`). On ne réinstalle pas ce qui tourne déjà.
- **Un seul changement à la fois.** Si un test échoue, on ne bouge qu'une variable.
- **Protocole d'erreur.** Tout raté part dans `JOURNAL.md`. Et avant de diagnostiquer
  un bug, on grep `JOURNAL.md` · si on l'a déjà croisé, on applique la solution connue.

Les règles dures (ports, conventions, formats) vivent dans `CLAUDE.md`. Ici on dit
juste l'esprit · là-bas, la lettre.

---

## Comment lire ce parcours

Dans l'ordre :

1. **CAPTAGE.md** (ici) · le pourquoi. Le monde.
2. **README.md** · le quickstart. Prérequis, comment démarrer.
3. **01 → 09** · le faire. Une étape, un brief exécutable, une preuve.
4. **CLAUDE.md** · les règles de l'agent. À garder ouvert pendant qu'on code.

Un dernier repère, le **walking skeleton** · ne cherche pas à tout finir avant de voir
quelque chose. Le front naît dès l'étape 3 (en lecture seule, sur `:3333`) et **grandit
à chaque étape** : un champ d'URL à l'étape 4, le verdict de l'IA à l'étape 5, les
boutons Garder/Jeter à l'étape 8, la promotion vers la Vérité à l'étape 9. Tu vois ton
système vivre très tôt, et tu l'étoffes. C'est plus motivant, et c'est plus sûr.

Allez. `01-recup-repo.md`.

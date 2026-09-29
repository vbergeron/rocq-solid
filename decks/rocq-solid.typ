#import "/template/lib.typ": *

// Skeleton of the talk, extracted from its abstract:
// https://rebootwithai.digitregroup.io/programme/talk-3-t2
// Each `#todo[..]` marks content still to write.

#show: solid-theme.with(
  title: [Solide comme un Rocq],
  subtitle: [Une introduction au vericoding],
  institution: [Reboot with AI],
  // date: datetime(year: 2026, month: 10, day: 1),
  // slug: "rocq-solid",  // adds a "Follow along" QR slide, see template/lib.typ
  links: (
    (url: "https://github.com/vbergeron/rocq-solid", label: "Sources"),
    (url: "https://rocq-prover.org", label: "Rocq"),
  ),
)

= Douter de nos garanties

== La question

#hero[Les tests et les types sont censés nous protéger des bugs.

*Mais qui vérifie que ces garanties tiennent vraiment ?*]

== Ce que les tests garantissent

- Des exemples, pas des propriétés
- #todo[un bug qui passe une suite de tests verte]

== Ce que les types garantissent

- La forme des données, rarement leur sens
- #todo[un invariant que le système de types ne voit pas]

== L'urgence

#hero[Les agents IA écrivent du code *plus vite qu'on ne peut le relire*.]

#todo[chiffres ou anecdote : volume de code généré vs capacité de revue]

= Le vericoding

== Définition

- Faire de la vérification formelle un *outil du quotidien*
- Sortir les assistants de preuve des labos de recherche
- Les mettre entre les mains des équipes qui livrent en prod

== Rocq en une slide

- #todo[assistant de preuve, noyau de confiance, extraction]
- #todo[historique rapide : Coq devient Rocq, CompCert, etc.]

== L'asymétrie

#hero[Écrire une preuve, c'est dur.

Écrire *ce qu'on veut prouver*, beaucoup moins.]

== La répartition des rôles

- *Vous* : dites ce qui doit être vrai (la spécification)
- *L'IA* : se débrouille pour démontrer pourquoi (la preuve)
- *Rocq* : vérifie la preuve, sans avoir à faire confiance à l'IA

== Exemple : la spécification

// Placeholder example, to replace with the talk's running example.
#rocq-file("/theories/Intro.v", lines: (20, 20))

#todo[l'énoncé écrit par l'humain, lisible sans lire la preuve]

== Exemple : la preuve

#rocq-file("/theories/Intro.v", lines: (20, 25))

#todo[la preuve produite par l'agent, vérifiée par Rocq]

== Des garanties d'un nouveau genre

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    *Interface aujourd'hui*
    - Une promesse
    - Documentée, testée, espérée
  ],
  [
    *Interface prouvée*
    - Un contrat
    - Vérifié par la machine
  ],
)

= Quoi prouver ?

== Le code qui mérite d'être prouvé

- *Invariants*
- *Machines à états*
- *Règles métier* où un bug n'est pas un incident mais peut coûter très cher

== Invariants

#todo[exemple d'invariant et sa spécification Rocq]

== Machines à états

#todo[exemple de machine à états : transitions interdites, états inatteignables]

== Règles métier

#todo[exemple de règle métier coûteuse : facturation, droits, quotas…]

== Où la preuve rapporte, où elle ne vaut pas l'effort

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    *Rapporte gros*
    - #todo[critères : coût d'un bug, stabilité de la spec…]
  ],
  [
    *Ne vaut pas l'effort*
    - #todo[critères : UI changeante, code jetable…]
  ],
)

= Livrer du code prouvé

== De la preuve à la prod

#todo[extraction : de Rocq vers un langage de production]

== Backend

#todo[exemple : un service dont le cœur métier est extrait de Rocq]

== Frontend

#todo[exemple : logique d'état côté client prouvée]

== Systèmes événementiels

#todo[exemple : handlers d'événements et invariants de projection]

== Firmware embarqué

#todo[exemple : code prouvé sur cible contrainte]

== Ce que ça change dans votre archi

- #todo[un noyau prouvé, une coquille non prouvée]
- #todo[où placer la frontière, comment la faire respecter]

== Ce que ça change dans votre codebase

- #todo[moins de tests défensifs, revues centrées sur les spécifications]
- #todo[CI : les preuves sont vérifiées à chaque build]

= Conclusion

== À retenir

- #todo[trois idées à emporter]

== Solide comme un Rocq

#hero[On a commencé par douter de nos garanties.

On repartira avec des fondations *solides comme un Rocq*.]

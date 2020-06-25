# Ausarbeitung Uebung 10

## 1. P(S+RO)L  --> PSL on PROL16 :)

Die Assertions der Core Control wurden so gewählt, dass vor allem Abweichungen gegenüber den Standardwerten getestet wurden.

## 2. Vacuity

- Erklären Sie Vacuity! Warum ist dieses Konzept wichtig? Ist es auch für andere (temporale) Logiken wichtig ist, oder ist es nur in PSL notwendig?

Das Wort vacuous bedeutet "leer" oder "nichts sagend".
Eine Bedingung ist vacuous, wenn beispielsweise in einer Implikation die linke Seite nie gilt. Somit ist die gesamte Bedingung wahr. Eie Aussage über die Erfüllung der eigentlichen Bedingung ist jedoch nicht gegeben.
Beispiel: `assert always (r |=> s0);` Die Bedingung erwartet, dass bei einem Reset r, der nächste Zustand der Anfangszustand sein muss. Falls während der Simulation jedoch niemals ein Reset r auftritt, ist die Bedingung erfüllt, obwohl die Sequenz (r |=> s0) niemals wirklich geprüft wurde In dem Fall ist es also komplett egal was auf der rechten Seite der Bedingung steht.

Das Konzept ist wichtig, um genau solche Beispiele von Bedingungen zu erkennen. PSL definiert Aussagen aufgrund von unendlichen Pfaden. Die Simulation beendet jedoch nach einer bestimmten Dauer und ist somit endlich. Für diesen Fall ist Vacuity nützlich, da es so etwas sagt wie "Vorsicht. Die Bedingung ist zwar erfüllt, aber der zu prüfende Fall ist nie eingetreten!".

Vacuity ist auch für andere temporale Logiken (LTL, CTL) wichtig, da oben genannte Beispiele dort genauso auftreten können.

- Geben Sie für die folgenden Assertions je mindestens einen Signalverlauf an, für den die Assertion *vacuously* hält!

1. assert always (x -> y);
  "x impliziert y"
  "Stelle sicher, dass y immer wahr ist, wenn x wahr ist"

    t 01234567
    x 00000000
    y -------- (don't care)

    Erklärung des Beispiels:
      Die linke Seite gilt nie, bzw. tritt niemals auf.
      Es gilt nie ein x.

2. assert always (x -> next y);
  "x impliziert y im nächsten State"
  "Stelle sicher, dass y immer wahr ist, wenn x im vorigen Zyklus wahr war"

    t 01234567
    x 00000000
    y -------- (don't care)

    Erklärung des Beispiels:
      Die linke Seite gilt nie, bzw. tritt niemals auf.
      Es gilt nie ein x.

3. assert always ({x; y} |-> {z});
  "Stelle sicher, dass z immer wahr ist, wenn {zuerst x und dann y} in diesem Zyklus wahr sind"
  "Wenn zuerst x und dann y, dann muss gleichzeitig mit y bereits z gelten."

    t 01234567
    x 01111000
    y 10000011
    z -------- (don't care)

    Erklärung des Beispiels:
      Die linke Seite gilt nie, bzw. tritt niemals auf.
      Es gilt nie ein "zuerst x dann y".

4. assert always ({x[*]; y} |-> {z});
  "Stelle sicher, dass z immer wahr ist, wenn {zuerst beliebig lang x und dann y} in diesem Zyklus wahr sind"
  "Wenn zuerst beliebig lange x und dann y, dann muss gleichzeitig mit y bereits z gelten."

    t 01234567
    x 01111100
    y 00000000
    z -------- (don't care)

    Erklärung des Beispiels:
      Die linke Seite gilt nie, bzw. tritt niemals auf.
      Es gilt nie ein "zuerst beliebig lange x dann y".

- Erklären Sie, warum der Operator `eventually!` (für eine Simulation) ein starker Operator sein muss, bzw. warum eine schwache Version davon in einer Simulation wenig Sinn ergeben würde!

Ein '!' nach dem PSL Operator kennzeichnet einen starken Operator.

Starker Operator (strong): "Im Zweifel falsch"
Schwacher Operator (weak): "Im Zweifel richtig"

`eventually! p` ist gleichbedeutend mit `F p` ("finally") aus LTL.
`F p` ist eine Liveness Eigenschaft. Um diese zu widerlegen, bräuchte es ein unendliches Gegenbeispiel - und "unendliche Zeit" ist in Simulation nicht möglich. Wäre `eventually!` also ein schwacher Operator, und `p` würde innerhalb der Simulationsdauer nicht auftreten, würde die Bedingung erfüllt sein ("im Zweifel richtig").

- Beschreiben Sie den Algorithmus für Model Checking für Invarianten mit eigenen Worten!

1. Beginne mit einem Initialzustand.
    (Dieser kann der Reset-Zustand sein, muss aber nicht. Er kann auch durch einen zuvor ausgeführten gerichteten Test entstanden sein.)
2. Wähle mit BFS (breadth-first search / Breitensuche) einen noch nicht besuchten Zustand aus.
    Prüfe, ob hier eine Assertion verletzt wird. Wenn ja, gib den Pfad zum aktuellen Zustand aus. Dieser ist ein Gegenbeispiel zur Assertion.
    (Die Pfade entsprechen den Inputs, um in den nächsten Zustand zu kommen.)
    Mache diesen Schritt solange, bis alle Zustände besucht wurden.
3. Erzeuge weitere von hier erreichbare Zustände.
    (Alle möglichen Inputs, um in einen nächsten Zustand zu kommen.)
4. Konnten neue Zustände erzeugt werden, gehe zu Schritt 2.
   Falls keine neuen Zustände erzeugt wurden, gib einen Beweis aus, dass die Assertion in keinem Zustand verletzt wird.

## 3. Model Checking: Anwendung

### 3.1 Mutex

- Beweisen Sie die durch den Algorithmus zum Prüfen von Invarianten, dass die folgende Eigenschaft gilt: `never (s1=c1 and s2=c2);`

Abarbeitung des Algorithmus:

1. Initialzustand n1n2
2. Auswahl n1n2, Assertion nicht verletzt
--- alle Zustände besucht
3. Neue Zustände erzeugt: {t1n2, t1t2, n1t2}
--- Iteration 1 vorbei (gehe zu Punkt 2 oben)
4. Auswahl t1n2, Assertion nicht verletzt
5. Auswahl t1t2, Assertion nicht verletzt
6. Auswahl n1t2, Assertion nicht verletzt
--- alle Zustände besucht
7. Neue Zustände erzeugt: {c1n2, c1t2, t1c2, n1c2}
--- Iteration 2 vorbei (gehe zu Punkt 2 oben)
8. Auswahl c1n2, Assertion nicht verletzt
9. Auswahl c1t2, Assertion nicht verletzt
10. Auswahl t1c2, Assertion nicht verletzt
11. Auswahl n1c2, Assertion nicht verletzt
--- alle Zustände besucht
12. Neue Zustände erzeugt: {}
13. Keine neuen Zustände erzeugt. Beweis ausgeben:
    "Kein gefundener Zustand verletzt die Assertion.
     Gefundene Zustände sind: {n1n2, t1n2, t1t2, n1t2, c1n2, c1t2, t1c2, n1c2}"
--- Done.

- Prüfen Sie zusätzlich durch Betrachten des Zustandsraums, ob die beiden folgenden Eigenschaften gelten:

`always (s1=t1 -> eventually! s1=c1);`
"Wann immer Automat 1 den Mutex haben wollte, hat er es schlussendlich auch bekommen"
Gilt. ZB: n1n2 --> **t1**t2 --> **c1**t2

`always (s2=t2 -> eventually! s2=c2);`
"Wann immer Automat 2 den Mutex haben wollte, hat er es schlussendlich auch bekommen"
Gilt. ZB: n1n2 --> n1**t2** --> n1**c2**

### 3.2 Mutex, Implementierung 2

Die obigen Eigenschaften sind jetzt nicht mehr alle gültig!

`never (s1=c1 and s2=c2);`
Es gibt den Zustand c1c2. Dieser wird erreicht durch n1n2 --> t1t2 --> c1c2.

`always (s1=t1 -> eventually! s1=c1);`
Ist noch erfüllt. Automat 1 hat den Mutex bekommen, nachdem er ihn haben wollte.

`always (s2=t2 -> eventually! s2=c2);`
Ist noch erfüllt. Automat 2 hat den Mutex bekommen, nachdem er ihn haben wollte.

![Bsp 3.2](bsp3.png)

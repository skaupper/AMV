# Ausarbeitung Uebung 10

## 1. P(S+RO)L  --> PSL on PROL16 :)

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


## 3. Model Checking: Anwendung


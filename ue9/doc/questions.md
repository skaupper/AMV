# Ausarbeitung Uebung 9

## 1. Safety und Liveness

- Was ist der Unterschied zwischen einer Safety- und einer Liveness-Eigenschaft?

Safety: Diese Eigenschaft gibt an, dass ein Ereignis nie eintreten wird.
Liveness: Diese Eigenschaft gibt an, dass ein Ereignis schlussendlich immer eintreten wird.

- Gegeben sei die folgende Aussage: "Eine Gegenbeispiel zu einer Liveness-Eigenschaft muss in einer endlichen Kripkestruktur eine Schleife im Zustandsraum beinhalten."
Ist diese Aussage richtig oder falsch? Begründen Sie Ihre Antwort ausführlich!

Richtig. Ein Gegenbeispiel für eine Liveness-Eigenschaft muss ein unendlicher Pfad sein. Ein unendlicher Pfad in einer endlichen Kripkestruktur muss schlussendlich in einer Schleife landen.

- Beschreiben die folgenden Formeln Safety- oder Liveness-Eigenschaften (oder keines von beiden)? Begründen Sie!

-- Xa

Safety. Sobald ein Pfad im nächsten Zustand nicht `a` ist, ist die Eigenschaft verletzt.

-- Fa

Liveness. Damit die Eigenschaft überprüft werden kann, müssen alle unendlichen Pfade berücksichtigt werden -> Ein Gegenbeispiel kann sich nur durch einen unendlichen Pfad ergeben.

-- G(a -> Fb)

Liveness. Siehe `Fa`.

-- Ga

Safety. Sobald es einen Zustand gibt, der nicht `a` ist, ist die Eigenschaft verletzt.

-- [b U a]

Safety, sobald einmal weder `b` noch `a` gilt ist die Eigenschaft verletzt.

## 2. Fairness

Faire Pfade:
- 0 3 4 2 1 2 1 2 1 2 1 ...
- 0 1 2 1 2 1 3 4 2 1 2 1 2 1 2 ...
- 0 3 4 2 1 3 4 2 1 3 4 2 1 ...

Nicht faire Pfade:
- 0 3 4 4 4 4 4 ...
- 0 3 4 2 1 2 1 3 4 4 4 4 4 4 4 4 ...

## 3. LTL vs. CTL vs. PSL

- LTL und CTL haben unterschiedliche Mächtigkeiten, es können also mit jeder der beiden Logiken Ausdrücke formuliert werden die in der jeweils anderen nicht möglich sind. Geben Sie ein Beispiel für eine CTL-Formel an, die in LTL nicht darstellbar ist, und erklären Sie dieses Beispiel*!

*Der umgekehrte Weg ist schwieriger zu beweisen, ein Beispiel sei hier aber gegeben: Die Formel "FGp" hat kein Pendant in CTL.

EXb

In CTL kann unterschieden werden, ob alle möglichen Pfade eine Eigenschaft erfüllen müssen, oder ob nur so ein Pfad exisitieren muss, damit die Gesamteigenschaft erfüllt ist.
EXb sagt aus, dass vom aktuellen Zustand aus es einen Pfad geben muss, in dem der nächste Zustand `b` ist (0 1 ...). In LTL ist dieser Ausdruck nicht möglich, da LTL immer alle Pfade betrachtet.

- Gegeben seien nun die beiden Formeln (A) und (B). Geben Sie an, welche der beiden Formeln für die Zähler-Kripke-Struktur aus der Vorlesung gilt! Sind beide Formeln sinnvoll?

Die LTL Formel ist sinnvoll, da `Gr` alle Pfade die `r` nicht mehr erfüllen von vornherein ausschließt.
Die CTL Formel ist nicht sinnvoll, da `AGr` nur dann erfüllt ist, wenn alle  möglichen Nachfolge-Zustände ebenfalls `r` erfüllen. Einen solchen Zustand gibt es aber nicht -> sinnlos!

- Welche Änderung gegenüber LTL und CTL verhilft PSL zu einer nochmals anderen Mächtigkeit? Geben Sie ein Beispiel für einen Ausdruck an, der in PSL, nicht aber in LTL und/oder CTL darstellbar ist!

PSL besitzt u.a. auch die Mächtigkeit Omega-regulärer Sprachen -> man kann auch zählen!

Bsp: `assert always ({a} |=> {b[*3]; c});`

Eine solche Schleife (`b` muss für 3 Wiederholungen gelten), kann in LTL und CTL nicht ausgedrückt werden.

# Coverage - Allgemein

## Erklären Sie die Begriffe

### Statement Coverage

Bei der Statement Coverage werden die Anzahl der tatsächlich ausgeführten (einzigartigen) Statments, der Gesamtanzahl der Statements gegenübergestellt.

### Path Coverage

Path Coverage geht etwas weiter als Branch Coverage, indem nicht nur gefragt wird, ob einzelne Zweige ausgeführt wurden, sondern hierbei werden ganze Pfade (durch Funktionen) betrachtet. Das inkludiert neben Verzweigungen auch Funktionsaufrufe, als auch Schleifenwiederholgen.

### Expression Coverage

Jeder Pfad kann aufgrund mehrerer Expressions genommen werden. Bei der Expression Coverage geht es nicht nur darum, welche Pfade genommen wurden, sondern auch weshalb diese ausgeführt wurden.
Bei einer If-Verzweigung mit mehreren Subausdrücken als Bedingung (z.B. `a || b`) müssen alle Möglichkeiten dieser Bedingungen aufgetreten sein.

### FSM Coverage

Hierbei geht es sowohl darum, wie oft eine FSM in einem bestimmten Zustand war (State Coverage), als auch darum, wie die FSM in diesen Zustand gekommen ist (Transition Coverage).

## Lässt sich in jedem HW-Entwurf eine Code Coverage von 100% erreichen?

Es gibt zumindest zwei Möglichkeiten, warum 100% Code Coverage nicht erreicht werde kann:

1. In Designs die `others`-Zweige (o.Ä.) zur Fehlererkennung in der Simulation einsetzen, werden (idealerweise) keine 100% erreicht werden.
2. Systeme, die aus mehreren verschachtelten Komponenten bestehen, können unter Umständen gar nicht alle Zustände jeder Subkomponente erreicht werden, da die anderen Komponenten diese Zustände von vornherein ausschließen.

## Bedeutet 100% Code Coverage, dass der getestete Entwurf fehlerfrei ist?

Code Coverage sagt nichts über die Richtigkeit der Ergebnisse aus. Dementsprechend kann ein Design mit 100% Code Coverage schlicht falsche Ausgaben generieren.

# PROL16-Regression-Test

## Wo sehen Sie Lücken in der Coverage?

1. Bei Befehlen die nicht verwendet werden (Load, Store, Sleep)
2. Fehlerbehandlung (Illegal Instructions, Register Decode Error)
3. Address Mux cases (weil Load nicht verwendet wird)

## Wieso treten diese auf?

Weil die Befehle Load/Store/Sleep nicht verwendet werden in den Tests.

## Gibt es Code-Teile, die zwar in der CHD5-Übung gefordert waren, aber nicht verwendet werden?

Es gibt keinen Befehl, der die ALU Funktion "alu_pass_a_c" verwendet.

## Welche dieser Lücken können geschlossen werden, welche nicht?

Beispielsweise kann die Lücke bei "alu_pass_a_c" nicht geschlossen werden, da es keinen Befehl gibt, in dem die ALU diese Funktion ausführt.

Prinzipiell lassen sich die Lücken in der Fehlerbehandlung, mit etwas Mehraufwand schließen (z.B. mit signal_force()).

Die nicht benutzten Befehle Load, Store und Sleep können ohne weiteres nicht getestet werden. Für Load und Store würde z.B. eine externe RAM Implementierung nötig sein.

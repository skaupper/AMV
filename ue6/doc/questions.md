# Constrained Random Stimulus

## Sind die randomisierten Werte vorhersehbar? Begründen Sie Ihre Antwort! Welchen Vorteil haben/hätten vorhersehbare Werte?

Nachdem man in Software prinzipiell nur mit Pseudorandomzahlen arbeiten kann, sind ist die Testsequenz theoretisch vorhersehbar.

Beim Generieren von Tests ist das aber kein Problem, weil der Programmierer insofern keinen Einfluss auf die tatsächliche Sequenz hat, dass es Edgecases verbergen würde (der Programmierer sagt nicht, zuerst wird Test A, dann B, dann C ausgeführt).
Zusätzlich hat diese Pseudorandomness den Vorteil, dass durch den gleichen Seed immer die gleiche Sequenz generiert wird, was die Testfälle reproduzierbar macht!

## Welcher mathematischen Funktion folgt die erreichte Functional Coverage in Abhängigkeit der Anzahl der durchgeführten Tests? Begründen Sie diesen Verlauf!

## Wie würden Sie ihre Constraints der Klasse Prol16Opode wählen, wenn:

### 50% der generierten Registeradressen 0 sein sollen?



### Die beiden Registeradressen für NOP immer 0 sein müssen?

Wie in der tatsächlichen Implementierung:

    constraint no_reg_used {
        cmd inside {
            NOP, SLEEP
        } -> (ra == 0 && rb == 0);
    }

Damit das Constraint erfüllt ist, müssen `ra` und `rb` 0 sein, sobald `cmd` `NOP` oder `SLEEP` ist.

## Was ist der Unterschied zwischen rand und randc?

Bei `rand` werden zufällige Werte aus dem gültigen Wertebereich generiert, ohne dass vorhergegangene Werte einen Einfluss auf die nächsten Werte haben.

`randc` generiert zyklisch (und zufällig) jeden möglichen Wert genau 1x bevor sich ein Wert wiederholen darf.

## Wieviele Befehle werden mindestens benötigt, um das folgende Covarage-Ziel zu erreichen (siehe Angabe)?

Anzahl der Befehle, die:
- kein Status Flag beeinflussen:               `cmd_00 = 5`
- Carry auf 0 setzen und Zero beeinflussen:    `cmd_01 = 4`
- beide Status Flags setzen:                   `cmd_11 = 11`

Kein Befehl aus `cmd_00` setzt je ein Flag, demnach sind hierführ 5 Testfälle ausreichend.

Die Befehle aus `cmd_01` können jeweils 2 verschiedene Ausgaben (= Flagkombinationen) generieren, also werden hierfür mindestens 8 Testfälle benötigt.

Die Befehle aus `cmd_11` können jeweils 4 verschiedene Ausgaben (= Flagkombinationen) generieren, also werden hierfür mindestens 44 Testfälle benötigt.



# 2 Modellierung

## 2.1 Geben Sie die formale Darstellung des LTS als 4-Tupel, inklusive seiner Komponenten, an!

    L = (S, I, E, ->)

    S   = {1, 2, 3, 4}
    I   = {1, 2}
    E   = {x, y}
    ->  = {(1,y,2), (1,x,4),
          (2,y,2), (2,x,3),
          (3,y,4), (4,x,4)}

## 2.2 Konstruieren Sie eine Kripke-Struktur zu dem oben gegebenen LTS!

    K = (S, I, ->, L)

    S   = {(1,x), (1,y), (2,x), (2,y), (3,x), (3,y), (4,x), (4,y)}
    I   = {(1,x), (1,y), (2,x), (2,y)}
    ->  = {((1,x), (4,x)), ((1,x), (4,y)), ((1,y), (2,x)), ((1,y), (2,y)),
           ((2,x), (3,x)), ((2,x), (3,y)), ((2,y), (2,x)), ((2,y), (2,y)),
           ((3,y), (4,x)), ((3,y), (4,y)), ((4,x), (4,x)), ((4,x), (4,y))}
    L   = (s,w) -> w

Siehe 2-2.png!

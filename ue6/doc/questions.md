# Constrained Random Stimulus

## Sind die randomisierten Werte vorhersehbar? Begründen Sie Ihre Antwort! WelchenVorteil haben/hätten vorhersehbare Werte?

## Welcher mathematischen Funktion folgt die erreichte Functional Coverage in Abhängigkeit der Anzahl der durchgeführten Tests? Begründen Sie diesen Verlauf!

## Wie würden Sie ihre Constraints der Klasse Prol16Opode wählen, wenn:

### 50% der generierten Registeradressen 0 sein sollen?

### Die beiden Registeradressen für NOP immer 0 sein müssen?

## Was ist der Unterschied zwischen rand und randc?

## Wieviele Befehle werden mindestens benötigt, um das folgende Covarage-Ziel zu erreichen (siehe Angabe)?



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

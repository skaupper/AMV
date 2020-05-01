# Constrained Random Stimulus


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

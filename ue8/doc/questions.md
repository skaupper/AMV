# CTL

## `AXa`

Gilt nicht, da im Zustand 1 `a` nicht gilt.

0 1 ...

## `EXa`

Gilt, da in Zustand 3 `a` gilt.

0 3 ...

## `EFb`

Gilt, da Pfade existieren die `b` erreichen können.

0 1 ...
0 3 4 4 2 ...

## `EXAG(a)`

Gilt nicht, da es Zustände gibt, die kein `a` enthalten.

0 1 ...
0 3 4 2 1 ...

## `EXEG(a)`

Gilt, da im Zustand 4 geloopt werden kann, und somit immer `a` gilt.

0 3 4 4 4 4 4 4 4 ...

## `AXAXa`

Gilt, da für alle möglichen übernächsten Zustände (`{2, 3, 4}`) `a` gilt.

0 1 3 ...
0 3 4 ...
0 1 2 ...

## `EG(b -> a)`

Gilt, da der Pfad 0 3 4 4 4 ... nie ein `b` enthält und die Formel damit auf diesen zutrifft.

## `AG(b -> AFa)`

Gilt, da von allen Zuständen die `b` enthalten, alle Pfade zwangsläufig in Zustände mit einem `a` führen.

0 1 2 1 3 ...

## `EXEGE(b U a)`

Gilt, da es (außer für Zustand 0) keinen Zustand gibt, der weder `a` noch `b` enthält.

## `AXA(a U b)`

Gilt nicht, da es einen Pfad gibt, in dem schlussendlich nie ein `b` auftritt.

0 1 2 1 3 4 4 4 4 4 4 4 4 ...

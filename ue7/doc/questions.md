# LTL

## `Xa`

Gilt nicht.

0 1 2 ...

## `XXa`

Gilt.

0 1 2 ... ( --> {a,b} enthält a, somit erfüllt)
0 1 3 ...
0 3 4 ...

## `Fa`

Gilt.

Weil es keine Möglichkeit gibt, nie einen Zustand mit `a` zu erreichen.
In allen möglichen Pfaden ist ein `a` enthalten.

## `G(a v b)`

Gilt nicht, weil in 0 gibt es kein a,b.

0 1 ...

## `XG(a v b)`

Gilt, weil der Initialzustand 0 "weggeschnitten" wird.

0 1 2 1 ...

## `G(b -> a)`

Gilt nicht, da nicht in allen Zuständen die `b` sind, auch `a` gilt.
Bedingung: (!b || a)

0 1 ...

## `G(b -> Fa)`

Gilt, da von allen Zuständen mit `b` für alle Pfade *finally* `a` gilt (es gibt keine Pfade, die keine `a`s enthalten).

## `G(b U a)`

Gilt nicht, weil in 0 gibt es kein a,b.

0 1 ...

## `XG(b U a)`

Gilt, da nach Zustand `0` immer entweder `a` oder `b` gilt.

## `GFa`

Gilt, da es keinen Zustand gibt, von dem aus es einen Pfad gibt, der kein `a` enthält.
In allen möglichen Pfaden (von allen möglichen Zuständen aus) ist ein `a` enthalten.

- Welchen Effekt hat die VHDL-Anweisung `wait until clk_i = '1';`?
  Was passiert, wenn `clk_i` zum Zeitpunkt des Aufrufs bereits `'1'` ist?

Die Funktion `wait until` wartet auf ein Event. Wenn clk_i also bereits '1' ist, wird trotzdem auf die nächste rising edge gewartet. Das passiert im nächsten Zyklus.

- Welchen Effekt hat die VHDL-Anweisung `wait on clk_i until ack_i = '1';`?

Diese `wait`-Anweisung wartet darauf, dass `ack_i` während eines Events von `clk_i` `'1'` ist.
Dabei spielt es keine Rolle, ob `clk_i` eine steigende oder eine fallende Flanke aufweist.

- Warum müssen für die Funktionen des BFM Signal-Parameter verwendet werden
  (im Gegensatz zu Constants oder Variables)?

Damit man diese direkt in das DUT weiterleiten kann. Dort werden Signale
erwartet, die nicht als `variable`s an Prozeduren übergeben werden können.

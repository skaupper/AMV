- Erklären Sie den Unterschied zwischen den SystemVerilog-Datentypen `bit` und `logic`! Wo liegen die jeweiligen Vorteile?

Mit `bit` kann man zweiwertige Logik modellieren ('0' und '1'), während man mit `logic` vierwertige darstellen kann ('0', '1', 'X' und 'Z').
Der Vorteil von `logic` liegt darin, dass in der Simulation zwischen mehr Werten (z.B. ungültige Werte mit 'X') unterschieden werden kann, was bei der Fehlersuche hilfreich ist.
Ein `bit` währenddessen benötigt nur den halben Speicher eines `logic`s und ist somit speichereffizienter.


- Erklären Sie den Unterschied zwischen `packed` und `unpacked` Arrays! Geben Sie für beide Varianten sinnvolle Einsatzbeispiele an!

Bei `packed` Arrays liegen die Elemente direkt hintereinander im Speicher (ähnlich eines VHDL-Vektors), wohingegen die Elemente eines `unpacked` Arrays nicht zwingenderweise nacheinander im Speicher liegen.

`packed`-Arrays werden bei breiten Signalen (32 Bit breite Register, Bussignale, etc.) verwendet, während `unpacked`-Arrays bei lose gekoppelten Elementen (z.B. die Testfälle einer Simulation) verwendet werden.

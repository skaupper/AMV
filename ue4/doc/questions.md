# Parameter der `$signal_force`-Funktion

## Syntax

`$signal_force( dest_object, value, rel_time, force_type, cancel_period, verbose)`

## Parameters

### `dest_object`

Gibt den Pfad des Signals an, das mit einem Wert überschrieben werden soll.

### `value`

Bestimmt den Wert, mit dem das Signal überschrieben werden soll.

### `rel_time`

Kann verwendet werden, um das Signal nicht sofort, sondern nach einer gewissen Zeitdauer, mit `value` zu überschreiben.

### `force_type`

Gibt an, wie das Signal überschrieben werden soll. Dabei werden folgende Typen unterschieden:

- `freeze`:   Forciert das Signal solange auf den gegebenen Wert, bis das Force wieder aufgehoben wurde.
- `drive`:    Forciert einen Treiber an das Signal, solange bis dieser wieder aufgehoben wird (unforce).
- `deposit`:  Setzt das Signal solange auf den Wert, bis das Force aufgehoben wird oder das Signal per Treiber überschrieben wird.

### `cancel_period`

Gibt die Zeitdauer an, nach der das Force automatisch aufgehoben wird.

### `verbose`

Gibt an, ob eine Ausgabe im Transkript erfolgen soll.

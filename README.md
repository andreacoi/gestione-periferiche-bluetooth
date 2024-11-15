# Script bash per la gestione delle periferiche collegate tramite Bluetooth

Perché nasce questa serie di script? Personalmente ho incontrato un po' di problemi nell'escludere (su KDE Plasma 5.27.5 almeno) la tastiera del portatile durante l'utilizzo della mia tastiera Bluetooth MX Mechanical Keyboard Mini di Logitech.

## Tentativi effettuati

Ovviamente prima di passare allo script in bash (di cui riporto i sorgenti) ho seguito la strada canonica (tramite script udev) e ho fatto un buco nell'acqua. Sostanzialmente non sono riuscito a disabilitare la tastiera integrata nel laptop tramite udev.

## Tool utilizzati

Per realizzare questo script in bash ho utilizzato i seguenti tool:

- `bash` (ovviamente :) );
- `awk` (gestione output);
- `grep` (ricerca stringhe in output);
- `xinput` (gestione periferiche collegate - abilitazione, disabilitazione e check status);
- `bluetoothctl` (check status singole periferiche Bluetooth);

## Evoluzione degli Script

Ho iniziato prima con il progettare lo script per la disabilitazione della tastiera integrata nel portatile quando la tastiera Bluetooth risulta collegata. Poi, cercando all'interno delle impostazioni di KDE, mi sono reso conto che non è possibile disabilitare nemmeno il trackpad se un mouse Bluetooth risulta collegato (manca proprio l'opzione all'interno del pannello di controllo di KDE PLASMA).
Quindi ho scritto uno script simile per fare la stessa cosa anche per quanto riguarda il mouse Bluetooth.

### Differenze tra "script tastiera" e "script mouse"

Mentre lo script tastiera usa `grep -q "Name: $TASTIERA_BLUETOOTH_LOGITECH"` per l'individuazione su bluetoothctl della tastiera, per il mouse ho deciso di utilizzare l'indirizzo MAC.

## Invocazione e gestione degli eventi

Trattandosi di script in bash, non ho potuto fare in modo che l'abilitazione/disabilitazione avvenga QUANDO il mouse (o la tastiera) vengono collegati/scollegati (all'evento stesso). È proprio per questo che esiste udev (che come detto sopra non sono riuscito a configurare per farlo funzionare).

### Workaround

Per sopperire all'impossibilità del richiamo dell'evento (collego/scollego) mi sono inventato un "falso polling" --> `fake-polling.sh`.
Nello script fake-polling ho inserito un ciclo while (`while true`) infinito. Ad ogni giro del ciclo while invoco prima lo script per il check del collegamento della tastiera, poi quello per il mouse, poi sleep per 1 secondo.

### Come si avvia fake-polling.sh?

Ho impostato `fake-polling.sh` come script di avvio di sessione su KDE.

## Ciclo di vita e funzionamento

Ad ogni avvio `fake-polling.sh` ad ogni secondo invoca gli script di controllo del collegamento della tastiera Bluetooth e del mouse Bluetooth. Se tastiera e mouse bluetooth sono abilitati e tastiera e mouse integrati sono abilitati disabilita quelli integrati (SE NON SONO GIÀ STATI DISABILITATI), altrimenti se una delle due periferiche bluetooth viene spenta riabilita la sua omologa integrata.

## Posizionamento degli script

Per il posizionamento degli script occorre modificare il percorso in `fake-polling.sh`.
Personalmente ho una directory `sys/autostart` nella root della directory utente `/home/utente/`.

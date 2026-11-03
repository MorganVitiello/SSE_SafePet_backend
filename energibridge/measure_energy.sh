#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: measure_energy.sh
# POSIZIONE: energibridge/measure_energy.sh
# SCOPO:  Orchestra l'acquisizione energetica con EnergiBridge incapsulando
#         direttamente il comando target (sleep 120 o run_jmeter.sh).
# ==============================================================================

if [ -z "$1" ]; then
    echo "Errore: Specifica la modalità di test (idle_os, idle_app, load)"
    echo "Uso: sudo ./measure_energy.sh [idle_os | idle_app | load]"
    exit 1
fi

MODE="$1"

# 1. Ricava l'utente reale (morgan) e la sua vera HOME (/home/morgan) anche sotto sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# 2. Percorsi assoluti (sale di un livello '..' perché lo script è in energibridge/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 3. Individua l'eseguibile di EnergiBridge
if [ -x "$REAL_HOME/EnergiBridge/energibridge" ]; then
    ENERGIBRIDGE_BIN="$REAL_HOME/EnergiBridge/energibridge"
elif [ -x "$REAL_HOME/EnergiBridge/target/release/energibridge" ]; then
    ENERGIBRIDGE_BIN="$REAL_HOME/EnergiBridge/target/release/energibridge"
else
    ENERGIBRIDGE_BIN="$REAL_HOME/EnergiBridge"
fi

# Cartella di output energetico richiesta
ENERGY_OUT="$PROJECT_ROOT/sse-reports/baseline/energibridge"
sudo -u "$REAL_USER" mkdir -p "$ENERGY_OUT"

# Controllo preliminare di EnergiBridge
if [ ! -x "$ENERGIBRIDGE_BIN" ] || [ -d "$ENERGIBRIDGE_BIN" ]; then
    echo "Errore: Impossibile trovare l'eseguibile EnergiBridge in $ENERGIBRIDGE_BIN"
    exit 1
fi

case "$MODE" in
    idle_os)
        CSV_FILE="$ENERGY_OUT/idle_os_energy.csv"
        echo "====================================================="
        echo " MISURAZIONE ENERGY: IDLE OS (Senza app avviate)"
        echo "====================================================="
        echo " Assicurati di essere in Modalità Aereo e non toccare il PC."
        echo " Il test durerà 120 secondi (2 minuti), poi si fermerà da solo."
        echo "-----------------------------------------------------"

        # EnergiBridge esegue e monitora direttamente il comando 'sleep 120'
        "$ENERGIBRIDGE_BIN" -o "$CSV_FILE" sleep 120

        chown "$REAL_USER:$REAL_USER" "$CSV_FILE" 2>/dev/null
        echo "Test IDLE OS completato. Salvato in: $CSV_FILE"
        ;;

    idle_app)
        CSV_FILE="$ENERGY_OUT/idle_app_energy.csv"
        echo "====================================================="
        echo " MISURAZIONE ENERGY: IDLE APP (Spring Boot acceso, 0 richieste)"
        echo "====================================================="
        echo " Assicurati che il backend sia avviato e in ascolto su porta 8080."
        echo " Il test durerà 120 secondi (2 minuti)."
        echo "-----------------------------------------------------"

        # EnergiBridge esegue e monitora direttamente il comando 'sleep 120'
        "$ENERGIBRIDGE_BIN" -o "$CSV_FILE" sleep 120

        chown "$REAL_USER:$REAL_USER" "$CSV_FILE" 2>/dev/null
        echo "Test IDLE APP completato. Salvato in: $CSV_FILE"
        ;;

    load)
        CSV_FILE="$ENERGY_OUT/load_energy.csv"
        JMETER_OUT="sse-reports/baseline/jmeter/load_energy_run"
        JMX_FILE="$PROJECT_ROOT/jmeter/load_test.jmx"

        echo "====================================================="
        echo " MISURAZIONE ENERGY + LOAD TEST UFFICIALE"
        echo "====================================================="

        cd "$PROJECT_ROOT"
        echo "Avvio EnergiBridge + JMeter (Load Test)..."

        # EnergiBridge avvia e monitora direttamente lo script JMeter fino al suo termine
        "$ENERGIBRIDGE_BIN" -o "$CSV_FILE" sudo -u "$REAL_USER" HOME="$REAL_HOME" ./jmeter/run_jmeter.sh "$JMX_FILE" "$JMETER_OUT"

        chown "$REAL_USER:$REAL_USER" "$CSV_FILE" 2>/dev/null

        echo "====================================================="
        echo "Misurazione Load Energetico completata!"
        echo "Report JMeter: $PROJECT_ROOT/$JMETER_OUT/report/index.html"
        echo "File Energia:  $CSV_FILE"
        echo "====================================================="
        ;;
    *)
        echo "Modalità sconosciuta: $MODE"
        echo "Usa: sudo ./measure_energy.sh [idle_os | idle_app | load]"
        exit 1
        ;;
esac
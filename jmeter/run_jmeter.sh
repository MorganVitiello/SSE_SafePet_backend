#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: run_jmeter.sh
# SCOPO:  1. Rigenera i token JWT freschi chiamando generate_test_data.sh
#         2. Esegue JMeter in modalità NON-GUI (CLI)
#         3. Genera la dashboard HTML con i grafici (granularità automatica)
#         4. Salva i metadati hardware e del test in metadata.txt
# USO:    ./jmeter/run_jmeter.sh jmeter/load_test.jmx sse-reports/baseline/jmeter/load
# ==============================================================================

# 1. Percorso dell'eseguibile di JMeter 5.6.3
JMETER_BIN="$HOME/apache-jmeter-5.6.3/bin/jmeter"

# 2. Controllo dei parametri passati allo script ($1 = file .jmx, $2 = cartella output)
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Errore: devi specificare il file .jmx e la cartella di output."
    echo "Esempio: ./jmeter/run_jmeter.sh jmeter/load_test.jmx sse-reports/baseline/jmeter/load"
    exit 1
fi

JMX_FILE="$1"
OUTPUT_DIR="$2"

# 3. Trova la cartella 'jmeter/' e lancia generate_test_data.sh per avere token JWT freschi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/generate_test_data.sh"

# 4. Definizione dei percorsi assoluti e della root del progetto
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JMX_ABS="$(realpath "$JMX_FILE")"
OUT_ABS="$PROJECT_ROOT/$OUTPUT_DIR"
RESULTS_JTL="$OUT_ABS/results.jtl"

# 5. Pulizia dei risultati precedenti
rm -rf "$RESULTS_JTL" "$OUT_ABS/report"
mkdir -p "$OUT_ABS"

# 6. Raccolta informazioni sull'Hardware del PC Linux per il file metadata.txt
CPU_MODEL=$(lscpu | grep -E "Model name|Nome modello" | sed 's/.*:\s*//')
CPU_CORES=$(nproc)
TOTAL_MEM=$(free -h | awk '/Mem:/ {print $2}')
OS_INFO=$(uname -a)

# 7. Estrazione automatica dei parametri del test (Thread, Ramp-up, Durata, Endpoint) dal file .jmx
THREADS_LIST=($(grep -oP '(?<=<intProp name="ThreadGroup.num_threads">)\d+' "$JMX_ABS"))
RAMPUP_LIST=($(grep -oP '(?<=<intProp name="ThreadGroup.ramp_time">)\d+' "$JMX_ABS"))
DURATION_LIST=($(grep -oP '(?<=<longProp name="ThreadGroup.duration">)\d+' "$JMX_ABS"))
DELAY_LIST=($(grep -oP '(?<=<longProp name="ThreadGroup.delay">)\d+' "$JMX_ABS"))
ENDPOINTS=$(grep -oP '(?<=<stringProp name="HTTPSampler.path">).*(?=</stringProp>)' "$JMX_ABS" | sort -u)

# 8. Riconoscimento automatico della granularità in base al nome del file .jmx
TEST_NAME=$(basename "$JMX_FILE" .jmx)
case "$TEST_NAME" in
    *spike*)
        GRANULARITY=1000   # 1 secondo (ottimale per test rapidi da 45s)
        echo "[Auto-Config] Rilevato SPIKE test -> Granularità: 1s (1000ms)"
        ;;
    *stress*)
        GRANULARITY=2000   # 2 secondi (ottimale per test da 60s)
        echo "[Auto-Config] Rilevato STRESS test -> Granularità: 2s (2000ms)"
        ;;
    *load*)
        GRANULARITY=5000   # 5 secondi (ottimale per test da 120s)
        echo "[Auto-Config] Rilevato LOAD test -> Granularità: 5s (5000ms)"
        ;;
    *soak*)
        GRANULARITY=15000  # 15 secondi (ottimale per test lunghi da 600s)
        echo "[Auto-Config] Rilevato SOAK test -> Granularità: 15s (15000ms)"
        ;;
    *)
        GRANULARITY=5000   # Default di sicurezza
        echo "[Auto-Config] Test generico -> Granularità di default: 5s (5000ms)"
        ;;
esac

# 9. Esecuzione del test JMeter da riga di comando (CLI)
echo "Avvio del test JMeter in modalità CLI..."
cd "$SCRIPT_DIR"
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

"$JMETER_BIN" -n \
  -t "$JMX_ABS" \
  -l "$RESULTS_JTL" \
  -Jjmeter.reportgenerator.overall_granularity="$GRANULARITY" \
  -e -o "$OUT_ABS/report"

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
cd "$PROJECT_ROOT"

# 10. Scrittura del file metadata.txt nella cartella di output
META_FILE="$OUT_ABS/metadata.txt"
{
    echo "System Metadata"
    echo "-------------------------"
    echo "CPU Model:      $CPU_MODEL"
    echo "CPU Cores:      $CPU_CORES"
    echo "Total Memory:   $TOTAL_MEM"
    echo "OS:             $OS_INFO"
    echo ""
    echo "JMeter Test Metadata"
    echo "-------------------------"
    echo "Start time:  $START_TIME"
    echo "End time:    $END_TIME"
    echo "JMX file:    $JMX_FILE"
    echo "Granularity: ${GRANULARITY}ms"
    echo ""
    echo "Thread Groups:"
    echo "-------------------------"
    for i in "${!THREADS_LIST[@]}"; do
        echo "TG$((i+1)) -> threads: ${THREADS_LIST[$i]}, ramp-up: ${RAMPUP_LIST[$i]}, duration: ${DURATION_LIST[$i]}, delay: ${DELAY_LIST[$i]:-0}"
    done
    echo ""
    echo "Endpoints used:"
    echo "-------------------------"
    echo "$ENDPOINTS"
} > "$META_FILE"

echo "====================================================="
echo "Test completato con successo!"
echo "Report HTML: $OUT_ABS/report/index.html"
echo "Metadati:    $META_FILE"
echo "====================================================="
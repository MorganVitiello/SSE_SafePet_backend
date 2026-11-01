#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: generate_test_data.sh
# SCOPO:  Effettua il login dei 5 proprietari presenti nel Seeder, recupera i
#         loro Token JWT e genera il file test_data.csv (20 righe) per JMeter.
# ==============================================================================

# 1. URL di base del backend Spring Boot
BACKEND_URL="http://localhost:8080"

# 2. Ricava automaticamente la cartella in cui si trova questo script (jmeter/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/test_data.csv"

echo "Verifica connettività Backend su $BACKEND_URL..."

# 3. Controlla che il backend sia acceso facendo una chiamata HTTP a elencoVeterinari.
#    -s = silenzioso, -f = fallisce se HTTP >= 400, --max-time 3 = timeout di 3 secondi
if ! curl -sf --max-time 3 "$BACKEND_URL/reportCliniche/elencoVeterinari" > /dev/null; then
    echo "[ERRORE CRITICO] Il Backend NON risponde su $BACKEND_URL!"
    echo "Avvia prima il file .jar del backend in un altro terminale."
    exit 1
fi

echo "Backend attivo! Generazione dei token JWT e del file $CSV_FILE..."

# 4. Scriviamo la prima riga (intestazione) del file CSV.
#    L'operatore '>' crea il file da zero (sovrascrivendo eventuali vecchi CSV).
echo "jwtToken,petId,vetId,lat,lon" > "$CSV_FILE"

# 5. Array dei 5 Proprietari del Seeder (Email:Password)
EMAILS=(
    "gianniangel99@example.com"
    "maria.rossi@example.com"
    "luca.bianchi@example.com"
    "sara.verdi@example.com"
    "paolo.neri@example.com"
)
PASSWORDS=(
    "Password123"
    "MariaR123"
    "LucaB1992"
    "SaraV123"
    "NeriP1995_ERR_FIX" # Nota: sotto usiamo NeriP1975 come nel Seeder
)
PASSWORDS[4]="NeriP1975"

# 6. Coordinate reali delle 20 Cliniche (dal VeterinariClinicheSeeder.java)
LATS=(
    "40.667808217305264" "40.748323195781786" "40.681698254988945" "40.761614557438925"
    "40.76979646864549"  "40.6571210652716"   "40.77308191757273"  "40.78452413349735"
    "40.78056844131724"  "40.7815058276157"   "40.76001147388277"  "40.66530559670722"
    "40.76467637883549"  "40.78875799035043"  "40.726320917020516" "40.70265961129606"
    "40.72474991309838"  "40.70710312235834"  "40.73896667640164"  "40.74180229816638"
)
LONS=(
    "14.798157969061371" "14.775263009418884" "14.766198224076366" "14.779088084565712"
    "14.802020993286323" "14.808987753943399" "14.79742443502071"  "14.754706668156071"
    "14.747091008136438" "14.70060865509447"  "14.782332730226333" "14.813341076580066"
    "14.777245728274728" "14.701155835432957" "14.75700441801544"  "14.702021684359128"
    "14.757770041602617" "14.70377728419267"  "14.656100242031949" "14.672751189300856"
)

# 7. Effettuiamo il login per i 5 proprietari e salviamo i rispettivi token JWT
TOKENS=()
for i in {0..4}; do
    EMAIL="${EMAILS[$i]}"
    PASS="${PASSWORDS[$i]}"

    # Chiamata POST /auth/login con curl
    RESP=$(curl -s -X POST "$BACKEND_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}")

    # Estrae il valore del campo "token":"..." dal JSON di risposta
    TOKEN=$(echo "$RESP" | grep -oP '(?<="token":")[^"]+')

    if [ -z "$TOKEN" ]; then
        echo "[ERRORE LOGIN] Impossibile ottenere il token per $EMAIL"
        exit 1
    fi
    TOKENS+=("$TOKEN")
done

# 8. Come nello script di Chiara, generiamo 20 righe (una per ogni veterinario/clinica da 1 a 20)
#    associando a rotazione i 10 Pet (Pet 1 e 2 sono di Gianni, 3 e 4 di Maria, ecc.)
for vIdx in {1..20}; do
    # Indice da 0 a 9 per ciclare sui 10 Pet
    PET_INDEX=$(( (vIdx - 1) % 10 ))
    PET_ID=$(( PET_INDEX + 1 ))

    # Ogni proprietario possiede 2 Pet consecutivi: dividendo per 2 otteniamo l'indice del proprietario (0..4)
    USER_INDEX=$(( PET_INDEX / 2 ))
    JWT_TOKEN="${TOKENS[$USER_INDEX]}"

    # Coordinate della clinica corrente (indice da 0 a 19)
    COORD_INDEX=$(( vIdx - 1 ))
    LAT="${LATS[$COORD_INDEX]}"
    LON="${LONS[$COORD_INDEX]}"

    # Aggiunge ('>>') la riga al file CSV
    echo "$JWT_TOKEN,$PET_ID,$vIdx,$LAT,$LON" >> "$CSV_FILE"
done

echo "Dataset creato con successo (20 righe) in: $CSV_FILE"
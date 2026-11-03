package it.safepet.backend.seeders;

import it.safepet.backend.reportCliniche.model.Clinica;
import it.safepet.backend.reportCliniche.model.OrarioDiApertura;
import it.safepet.backend.reportCliniche.repository.ClinicaRepository;
import it.safepet.backend.gestioneUtente.model.Veterinario;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;

@Component
@Order(1)
public class VeterinariClinicheSeeder implements CommandLineRunner {
    private final ClinicaRepository clinicaRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.db.seeder.enabled:false}")
    private boolean seedEnabled;

    @Value("${app.db.seeder.reset:false}")
    private boolean resetDatabase;

    public VeterinariClinicheSeeder(ClinicaRepository clinicaRepository, PasswordEncoder passwordEncoder) {
        this.clinicaRepository = clinicaRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (!seedEnabled) {
            System.out.println("Seeder Cliniche disabilitato.");
            return;
        }

        if (resetDatabase) {
            clinicaRepository.deleteAll();
            System.out.println("Eliminazione Cliniche");
        }

        if (clinicaRepository.count() == 0) {
            System.out.println("### Inizio popolamento tabelle veterinari, cliniche, orari_di_apertura");
            ArrayList<Clinica> cliniche = new ArrayList<Clinica>() {{
                add(new Clinica("Zampa Felice", "Via Ugo Foscolo, 18 - Salerno", "0899911111", 40.667808217305264, 14.798157969061371));
                add(new Clinica("Oasi Vet", "Via Aldo Moro, 1 - Baronissi", "0899955555", 40.748323195781786, 14.775263009418884));
                add(new Clinica("Animalia", "Via Michele Vernieri, 16 - Salerno", "0899922222", 40.681698254988945, 14.766198224076366));
                add(new Clinica("Arca Vet", "Via Tenente Nastri, 120 - Baronissi", "0899966666", 40.761614557438925, 14.779088084565712));
                add(new Clinica("Vet Nova", "Via Isolella, 6 - Fisciano", "0899977777", 40.76979646864549, 14.802020993286323));
                add(new Clinica("Pet Harmony", "Via Zarra Nicola, 2 - Salerno", "0899933333", 40.6571210652716, 14.808987753943399));
                add(new Clinica("Pet Fusion", "Via Roma, 84 - Fisciano", "0899988888", 40.77308191757273, 14.79742443502071));
                add(new Clinica("AnimAxis", "Via Roma, 14 - Mercato San Severino", "0899999999", 40.78452413349735, 14.754706668156071));
                add(new Clinica("Vet Mind", "Via Vincenzo Alfano, 414 - Mercato San Severino", "0899922222", 40.78056844131724, 14.747091008136438));
                add(new Clinica("Pinto Pet", "Via Nicola Capuano, 4 - Castel San Giorgio", "0899912121", 40.7815058276157, 14.70060865509447));
                add(new Clinica("TorinoPet", "Via Quattro Novembre, 35 - Penta", "0899913131", 40.76001147388277, 14.782332730226333));
                add(new Clinica("Vet Guardian", "Via Alfonso Grassi, 3 - Salerno", "0899944444", 40.66530559670722, 14.813341076580066));
                add(new Clinica("Pet Well", "Via del Centenario, 533 - Penta", "0899914141", 40.76467637883549, 14.777245728274728));
                add(new Clinica("Vet Sphere", "Via S. Francesco, 7 - Castel San Giorgio", "0899911112", 40.78875799035043, 14.701155835432957));
                add(new Clinica("Neo Vet", "Via Giovanni Falcone, 6 - Pellezzano", "0899915151", 40.726320917020516, 14.75700441801544));
                add(new Clinica("Vet Atlas", "Via Gaetano Filangieri, 33 - Cava de' Tirreni", "0899917171", 40.70265961129606, 14.702021684359128));
                add(new Clinica("Vet Quantum", "Via Casal Murino, 22 - Pellezzano", "0899916161", 40.72474991309838, 14.757770041602617));
                add(new Clinica("Pet Horizon", "Via Clemente Tafuri, 53 - Cava de' Tirreni", "0899918181",  40.70710312235834, 14.70377728419267));
                add(new Clinica("Pet Logic", "Via Santacroce, 9 - Nocera Superiore", "0899921212", 40.73896667640164, 14.656100242031949));
                add(new Clinica("Vet Zen", "Via S. Clemente, 150 - Nocera Superiore", "0899919191", 40.74180229816638, 14.672751189300856));
            }};

            ArrayList<Veterinario> veterinari =  new ArrayList<Veterinario>() {{
                add(new Veterinario("Simone", "Cimmino", LocalDate.of(1985, 4, 12),
                        "M", "scimmino@gmail.com", passwordEncoder.encode("SCimmino.85"), "3311111111", "Cani, gatti"));
                add(new Veterinario("Luca", "Salvatore", LocalDate.of(1980, 6, 8),
                        "M", "lsalvatore@gmail.com", passwordEncoder.encode("LSalvatore.80"), "3322222222", "Uccelli, rettili"));
                add(new Veterinario("Morgan", "Vitiello", LocalDate.of(1992, 2, 20),
                        "M", "mvitiello@gmail.com", passwordEncoder.encode("MVitiello.92"), "3333333333", "Animali esotici"));
                add(new Veterinario("Vincenzo", "Nappi", LocalDate.of(1978, 9, 14),
                        "M", "vnappi@gmail.com", passwordEncoder.encode("VNappi.78"), "3344444444", "Cani, cavalli"));
                add(new Veterinario("Chiara", "Memoli", LocalDate.of(1987, 5, 30),
                        "F", "cmemoli@gmail.com", passwordEncoder.encode("CMemoli.87"), "3355555555", "Gatti, conigli"));
                add(new Veterinario("AnnaChiara", "Memoli", LocalDate.of(1991, 12, 2),
                        "F", "acmemoli@gmail.com", passwordEncoder.encode("ACMemoli.91"), "3366666666", "Animali domestici"));
                add(new Veterinario("Rosario", "Saggese", LocalDate.of(1983, 10, 18),
                        "M", "rsaggese@gmail.com", passwordEncoder.encode("RSaggese.83"), "3377777777", "Cani, gatti, roditori"));
                add(new Veterinario("Giuseppe", "Rossano", LocalDate.of(1979, 1, 7),
                        "M", "grossano@gmail.com", passwordEncoder.encode("GRossano.79"), "3388888888", "Animali da fattoria"));
                add(new Veterinario("Aldo", "Adinolfi", LocalDate.of(1984, 8, 25),
                        "M", "aadinolfi@gmail.com", passwordEncoder.encode("AAdinolfi.84"), "3399999999", "Cani, gatti, cavalli"));
                add(new Veterinario("Gianmarco", "Amatruda", LocalDate.of(1993, 3, 3),
                        "M", "gamatruda2@gmail.com", passwordEncoder.encode("GAmatruda.93"), "3322222222", "Cani, cavalli, animali esotici"));
                add(new Veterinario("Francesco", "Pinto", LocalDate.of(1990, 3, 15),
                        "M", "fpinto@gmail.com", passwordEncoder.encode("fPinto.90"), "3321212121", "Gatti, conigli"));
                add(new Veterinario("Matteo", "Emolo", LocalDate.of(1988, 6, 11),
                        "M", "memolo@gmail.com", passwordEncoder.encode("MEmolo.88"), "3311111122", "Cani, gatti, uccelli"));
                add(new Veterinario("Francesco", "Torino", LocalDate.of(1982, 7, 19),
                        "M", "ftorino@gmail.com", passwordEncoder.encode("FTorino.82"), "3331313131", "Cani, cavalli"));
                add(new Veterinario("Federica", "D'Amato", LocalDate.of(1989, 8, 9),
                        "F", "fdamato@gmail.com", passwordEncoder.encode("FDamato.89"), "3341414141", "Animali esotici"));
                add(new Veterinario("Davide", "Marino", LocalDate.of(1985, 12, 21),
                        "M", "dmarino@gmail.com", passwordEncoder.encode("DMarino.85"), "3351515151", "Cani, gatti, roditori"));
                add(new Veterinario("Alessia", "Ferrara", LocalDate.of(1994, 4, 27),
                        "F", "aferrara@gmail.com", passwordEncoder.encode("AFerrara.94"), "3361616161", "Cani, gatti, conigli"));
                add(new Veterinario("Stefano", "Greco", LocalDate.of(1981, 1, 4),
                        "M", "sgreco@gmail.com", passwordEncoder.encode("SGreco.81"), "3371717171", "Animali da fattoria"));
                add(new Veterinario("Martina", "Vitale", LocalDate.of(1992, 5, 6),
                        "F", "mvitale@gmail.com", passwordEncoder.encode("MVitale.92"), "3381818181", "Cani, gatti, cavalli"));
                add(new Veterinario("Paolo", "Ruggiero", LocalDate.of(1986, 6, 17),
                        "M", "pruggiero@gmail.com", passwordEncoder.encode("PRuggiero.86"), "3391919191", "Uccelli, rettili"));
                add(new Veterinario("Lorenzo", "Parisi", LocalDate.of(1987, 2, 14),
                        "M", "lparisi@gmail.com", passwordEncoder.encode("LParisi.87"), "3312121212", "Cani, gatti, roditori"));
            }};

            for (int i = 0; i < cliniche.size(); i++) {
                Clinica c = cliniche.get(i);
                Veterinario v = veterinari.get(i);
                v.setClinica(c);
                c.setVeterinario(v);
                aggiungiOrariStandard(c);
            }

            clinicaRepository.saveAll(cliniche);
            System.out.println("### Tabelle veterinari, cliniche, orari_di_apertura popolate con successo");
        }
    }

    private void aggiungiOrariStandard(Clinica clinica) {
        for (OrarioDiApertura.Giorno giorno : Arrays.asList(
                OrarioDiApertura.Giorno.LUNEDI,
                OrarioDiApertura.Giorno.MARTEDI,
                OrarioDiApertura.Giorno.MERCOLEDI,
                OrarioDiApertura.Giorno.GIOVEDI,
                OrarioDiApertura.Giorno.VENERDI)) {
            clinica.getOrariApertura().add(new OrarioDiApertura(giorno,
                    LocalTime.of(9, 0), LocalTime.of(19, 0), false, clinica));
        }
        clinica.getOrariApertura().add(new OrarioDiApertura(OrarioDiApertura.Giorno.SABATO,
                LocalTime.of(9, 0), LocalTime.of(13, 0), false, clinica));
        clinica.getOrariApertura().add(new OrarioDiApertura(OrarioDiApertura.Giorno.DOMENICA,
                LocalTime.of(0, 0), LocalTime.of(23, 59), true, clinica));
    }
}

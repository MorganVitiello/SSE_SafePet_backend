package it.safepet.backend.seeders;

import it.safepet.backend.gestionePet.model.Pet;
import it.safepet.backend.gestioneUtente.model.Proprietario;
import it.safepet.backend.gestioneUtente.repository.ProprietarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.FileCopyUtils;

import java.io.InputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;

@Component
@Order(2)
public class ProprietariPetsSeeder implements CommandLineRunner {
    private final ProprietarioRepository proprietarioRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.db.seeder.enabled:false}")
    private boolean seedEnabled;

    @Value("${app.db.seeder.reset:false}")
    private boolean resetDatabase;

    public ProprietariPetsSeeder(ProprietarioRepository proprietarioRepository, PasswordEncoder passwordEncoder) {
        this.proprietarioRepository = proprietarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (!seedEnabled) {
            System.out.println("Seeder Proprietari disabilitato.");
            return;
        }

        if (resetDatabase) {
            proprietarioRepository.deleteAll();
            System.out.println("Eliminazione Proprietari");
        }

        if (proprietarioRepository.count() == 0) {
            ArrayList<Proprietario> proprietari =  new ArrayList<>() {{
                add(new Proprietario("Gianni", "Angel", LocalDate.of(1970, 12, 25), "M",
                        "gianniangel99@example.com", passwordEncoder.encode("Password123"), "3333333333", "Via Roma 16"));
                add(new Proprietario("Maria", "Rossi", LocalDate.of(1985, 3, 14), "F",
                        "maria.rossi@example.com", passwordEncoder.encode("MariaR123"), "3331112222", "Via Firenze 22"));
                add(new Proprietario("Luca", "Bianchi", LocalDate.of(1992, 7, 9), "M",
                        "luca.bianchi@example.com", passwordEncoder.encode("LucaB1992"), "3409876543", "Viale Milano 8"));
                add(new Proprietario("Sara", "Verdi", LocalDate.of(1998, 11, 3), "F",
                        "sara.verdi@example.com", passwordEncoder.encode("SaraV123"), "3472223344", "Corso Torino 45"));
                add(new Proprietario("Paolo", "Neri", LocalDate.of(1975, 6, 21), "M",
                        "paolo.neri@example.com", passwordEncoder.encode("NeriP1975"), "3485566778", "Via Napoli 10"));
            }};

            ArrayList<Pet> pets = new ArrayList<>() {{
                add(new Pet("Rocky", "M", "Cane", "Golden Retrivier", LocalDate.of(2020, 4, 5), 28.5,
                        "Marrone Chiaro", "985112003457890", true, loadImage("images/dog1.jpg")));
                add(new Pet("Luna", "F", "Cane", "Beagle", LocalDate.of(2019, 9, 22), 9.4,
                        "Tricolore", "985112003457893", true, loadImage("images/beagle1.png")));
                add(new Pet("Bella", "F", "Gatto", "Europeo", LocalDate.of(2021, 2, 17), 4.2,
                        "Tigrato", "985112003457891", true, loadImage("images/cat1.jpg")));
                add(new Pet("Kira", "F", "Gatto", "Siamese", LocalDate.of(2020, 1, 30), 3.6,
                        "Crema / Marrone", "985112003457894", true, loadImage("images/cat2.jpg")));
                add(new Pet("Milo", "M", "Coniglio", "Nano", LocalDate.of(2022, 6, 10), 1.1,
                        "Bianco", "985112003457892", true, loadImage("images/rabbit1.png")));
                add(new Pet("Pippo", "M", "Porcellino d’India", "Abyssinian", LocalDate.of(2023, 3, 11), 0.7,
                        "Arancio / Bianco", "985112003457895", true, loadImage("images/guinea1.jpg")));
                add(new Pet("Rio", "M", "Pappagallo", "Ara Blu e Oro", LocalDate.of(2018, 8, 14), 1.0,
                        "Blu e Giallo", "985112003457896", true, loadImage("images/parrot1.png")));
                add(new Pet("Nala", "F", "Cane", "Labrador", LocalDate.of(2017, 12, 2), 30.0,
                        "Nero", "985112003457897", true, loadImage("images/dog3.jpg")));
                add(new Pet("Oscar", "M", "Gatto", "Maine Coon", LocalDate.of(2019, 4, 18), 7.8,
                        "Grigio", "985112003457898", true, loadImage("images/cat3.png")));
                add(new Pet("Coco", "F", "Coniglio", "Ariete", LocalDate.of(2022, 5, 25), 1.5,
                        "Marrone", "985112003457899", true, loadImage("images/rabbit2.jpg")));
            }};

            for (int i = 0; i < proprietari.size(); i++) {
                Proprietario p = proprietari.get(i);
                Pet pet1 = pets.get(i * 2);
                Pet pet2 = pets.get(i * 2 + 1);
                pet1.setProprietario(p);
                pet2.setProprietario(p);
                p.getPets().add(pet1);
                p.getPets().add(pet2);
            }

            proprietarioRepository.saveAll(proprietari);
        }
    }

    private byte[] loadImage(String path) {
        ClassPathResource imgFile = new ClassPathResource(path);

        try (InputStream inputStream = imgFile.getInputStream()) {
            return FileCopyUtils.copyToByteArray(inputStream);
        } catch (IOException e) {
            System.err.println("⚠️  Impossibile caricare immagine: " + path + " → " + e.getMessage());
            return null;
        }
    }
}

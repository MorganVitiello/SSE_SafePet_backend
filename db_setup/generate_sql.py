from faker import Faker
import random

fake = Faker('it_IT')
BCRYPT_HASH = "$2a$10$Ew.V/a.Uo.L/h0Ue.yRkxeiL/p0mI./k/W.b/G91k1oT2W.j9E/G."

with open('mock_data.sql', 'w') as f:
    f.write("SET FOREIGN_KEY_CHECKS=0;\n\n")

    f.write("-- Pulizia dati finti precedenti\n")
    f.write("DELETE FROM veterinari WHERE id >= 100;\n")
    f.write("DELETE FROM cliniche WHERE id >= 100;\n")
    f.write("DELETE FROM pets WHERE id >= 100;\n")
    f.write("DELETE FROM proprietari WHERE id >= 100;\n\n")

    # 1. Genera 500 Proprietari (ID da 100 a 599)
    print("Generazione 500 Proprietari...")
    for i in range(100, 600):
        genere = random.choice(['M', 'F'])
        nome = fake.first_name().replace("'", "")[:50]
        cognome = fake.last_name().replace("'", "")[:50]
        indirizzo = fake.street_address().replace("'", "")[:255]

        f.write(
            f"INSERT INTO proprietari (id, cognome, data_nascita, email, genere, indirizzo_domicilio, nome, numero_telefono, password) "
            f"VALUES ({i}, '{cognome}', '{fake.date_of_birth(minimum_age=18, maximum_age=80)}', "
            f"'{fake.unique.email()}', '{genere}', '{indirizzo}', "
            f"'{nome}', '33{random.randint(10000000, 99999999)}', '{BCRYPT_HASH}');\n")

    # 2. Genera 1000 Pet (ID da 100 a 1099)
    print("Generazione 1000 Pet...")
    specie_razze = {'Cane': ['Labrador', 'Beagle', 'Carlino', 'Pastore Tedesco'],
                    'Gatto': ['Europeo', 'Siamese', 'Persiano', 'Maine Coon']}
    for i in range(100, 1100):
        proprietario_id = random.randint(100, 599)
        specie = random.choice(list(specie_razze.keys()))
        razza = random.choice(specie_razze[specie])
        sesso = random.choice(['M', 'F'])
        sterilizzato = random.choice([0, 1])
        nome_pet = fake.first_name().replace("'", "")[:255]

        f.write(
            f"INSERT INTO pets (id, colore_mantello, data_nascita, sterilizzato, microchip, nome, peso, proprietario_id, razza, sesso, specie) "
            f"VALUES ({i}, '{fake.color_name()}', '{fake.date_between(start_date='-10y', end_date='today')}', {sterilizzato}, "
            f"'{fake.unique.numerify(text='###############')}', '{nome_pet}', {round(random.uniform(2.0, 35.0), 1)}, "
            f"{proprietario_id}, '{razza}', '{sesso}', '{specie}');\n")

    # 3. Genera 100 Cliniche (ID da 100 a 199)
    print("Generazione 100 Cliniche...")
    for i in range(100, 200):
        lat = random.uniform(37.0, 46.0)
        lon = random.uniform(8.0, 16.0)
        nome_clinica = f"Clinica {fake.company()}".replace("'", "")[:50]
        indirizzo_clinica = fake.address().replace('\n', ' ').replace("'", "")[:255]

        f.write(f"INSERT INTO cliniche (id, indirizzo, latitudine, longitudine, nome, numero_telefono) "
                f"VALUES ({i}, '{indirizzo_clinica}', {lat}, {lon}, '{nome_clinica}', '08{random.randint(10000000, 99999999)}');\n")

    # 4. Genera 100 Veterinari (ID da 100 a 199) - 1:1 con le cliniche
    print("Generazione 100 Veterinari (1:1 con le cliniche)...")
    for i in range(100, 200):
        clinica_id = i
        genere = random.choice(['M', 'F'])
        nome_vet = fake.first_name().replace("'", "")[:50]
        cognome_vet = fake.last_name().replace("'", "")[:50]

        f.write(
            f"INSERT INTO veterinari (id, clinica_id, cognome, data_nascita, email, genere, nome, numero_telefono, password, specializzazioni_animali) "
            f"VALUES ({i}, {clinica_id}, '{cognome_vet}', '{fake.date_of_birth(minimum_age=25, maximum_age=65)}', "
            f"'{fake.unique.email()}', '{genere}', '{nome_vet}', '33{random.randint(10000000, 99999999)}', "
            f"'{BCRYPT_HASH}', 'Cani, Gatti');\n")

    f.write("\nSET FOREIGN_KEY_CHECKS=1;\n")
print("File mock_data.sql generato (con limiti varchar rispettati)!")
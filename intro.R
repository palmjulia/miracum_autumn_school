##### Code Beispiele #####

#erste Installation (1x pro Maschine)
install.packages("fhircrackr")

#Paket laden (1x pro R Session)
library(fhircrackr)

##### FHIR Herunterladen #####

#FHIR Search Request zusammenbauen
request <- fhir_url(url = "https://mii-agiop-3p.life.uni-leipzig.de/blaze",
                    resource = "Patient",
                    parameters = c(gender = "female",
                                   birthdate = "gt1990"))

#Objekt inspizieren
request

#Download
bundles <- fhir_search(request = request,
                       max_bundles = 2)

#Ergebnis
bundles

#einzelnes Bundle
cat(toString(bundles[[1]]))

#Doku
?fhir_search

### Ressourcen herunterladen per POST
request <- fhir_url(url = "https://mii-agiop-3p.life.uni-leipzig.de/blaze",
                    resource = "Patient")

#body definieren
body <- fhir_body(content = list(gender = "female",
                                 birthdate = "ge1990"))
body

#download
bundles <- fhir_search(request = request,
                       body = body,
                       max_bundles = 2)
bundles

### Umgang mit HTTP-Fehlern

#Fehlende Authentifizierung
fhir_search("https://mii-agiop-polar.life.uni-leipzig.de/blaze/Patient", 
            stop_on_error = 1)

#Fehler aufrufen
cat(fhir_recent_http_error())


###### FHIR Verflachen ######

### Extraktion aller Elemente

#Table Description
pat_desc <- fhir_table_description(resource = "Patient")
pat_desc

#cracken
patients <- fhir_crack(bundles = bundles, design = pat_desc)
View(patients)

### Extraktion definierter Spalten

pat_desc <- fhir_table_description(resource = "Patient",
                                   cols = c(Id = "id",
                                            Stadt = "address/city",
                                            Geschlecht = "gender"))
pat_desc

#cracken
patients <- fhir_crack(bundles = bundles, design = pat_desc)
View(patients)

### Multiple Elemente

#Beispielbundle verfügbar machen
bundles <- fhir_unserialize(example_bundles5)
cat(toString(bundles[[1]]))

#Kompakte Repräsentation
obs_desc <- fhir_table_description(resource = "Observation",
                                   sep = " <> ")
                                   
observations_compact <- fhir_crack(bundles = bundles, design = obs_desc)
                       
View(observations_compact)


#Filtern über XPath Expressions
obs_desc <- fhir_table_description(resource = "Observation",
                                   cols = c(
                                     id = "id",
                                     code = "code/coding[system[@value='http://loinc.org']]/code",
                                     system = "code/coding[system[@value='http://loinc.org']]/system"
                                     )
                                   )
                                   
observations <- fhir_crack(bundles = bundles, design = obs_desc)
                       
View(observations)

#Wide Format
obs_desc <- fhir_table_description(resource = "Observation",
                                   cols = c(
                                     id = "id",
                                     code = "code/coding/code",
                                     system = "code/coding/system"
                                     ),
                                   format = "wide",
                                   brackets = c("[", "]")
                                   )
                                   
observations <- fhir_crack(bundles = bundles, design = obs_desc)
                       
View(observations)



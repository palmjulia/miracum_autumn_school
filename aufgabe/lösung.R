library(fhircrackr)

### Teil 1 ###

#Search Request bauen
request <- fhir_url(
  url = "https://mii-agiop-3p.life.uni-leipzig.de/blaze",
  resource = "Observation",
  parameters = c(code = "http://loinc.org|718-7")
)


## Bundles Herunterladen
bundles <- fhir_search(request)


## Table Description bauen
obs_desc <- fhir_table_description(
  resource = "Observation",
  cols = c(
    id      = "id",
    patient = "subject/reference",
    loinc   = "code/coding/code",
    wert    = "valueQuantity/value",
    einheit = "valueQuantity/unit",
    datum   = "effectiveDateTime"
  )
)

## Verflachen
obs <- fhir_crack(bundles, obs_desc)

#Anschauen
View(obs)

#Anzahl Zeilen
nrow(obs)

### Teil 2 ###

#unique Patient Ids
pat_ids <- unique(obs$patient)

#Länge des Vektors (Anzahl der IDs)
length(pat_ids)

### Teil 3 ###
#search request
request <- fhir_url(url = "https://mii-agiop-3p.life.uni-leipzig.de/blaze",
                    resource = "Patient")

#"Patient/" vor jeder Pat-ID muss gelöscht werden
obs$patient <- sub("Patient/", "", obs$patient)

#ids zu einem String zusammenkleben
id_string <- paste(obs$patient, collapse = ",")

#body definieren
body <- fhir_body(content = list(`_id` = id_string))

#Download
bundles <- fhir_search(request = request,
                       body = body)

#verflachen
pat_desc <- fhir_table_description(resource = "Patient")

pat <- fhir_crack(bundles, pat_desc)


#mergen
data <- merge(x = obs, 
              y = pat, 
              by.x = "patient",
              by.y = "id")

data

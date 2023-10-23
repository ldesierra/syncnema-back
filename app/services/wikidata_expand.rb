class WikidataExpand < ApplicationService
  def initialize(cast_list)
    @cast_list = cast_list
  end

  def call
    sparql = SPARQL::Client.new("https://query.wikidata.org/sparql")
    query = "
    SELECT ?actorName ?actorImage (GROUP_CONCAT(DISTINCT ?award;separator='|') AS ?actorAwards) (GROUP_CONCAT(DISTINCT ?occupation;separator='|') AS ?occupations)
    WHERE {

      ?actor wdt:P31 wd:Q5 .
      ?actor wdt:P345 ?imdbId .

      ?actor rdfs:label ?actorName .
      FILTER(LANG(?actorName) = 'es')

      OPTIONAL { ?actor wdt:P18 ?actorImage . }

      OPTIONAL {
        ?actor wdt:P166/rdfs:label ?award .
        FILTER(LANG(?award) = 'es')
      }

      OPTIONAL {
        ?actor wdt:P106/rdfs:label ?occupation .
        FILTER(LANG(?occupation) = 'es')
      }

        FILTER (?imdbId IN ('#{@cast_list.join("', '")}'))
      } GROUP BY ?actorName ?actorImage
    "

    result = sparql.query(query)
  end
end

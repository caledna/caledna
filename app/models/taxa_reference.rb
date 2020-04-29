# frozen_string_literal: true

# https://github.com/datasets/language-codes

class TaxaReference
  PHYLUM_SUPERKINGDOM = {
    'Candidatus Acetothermia' => 'Bacteria',
    'Candidatus Latescibacteria' => 'Bacteria',
    'Candidatus Microgenomates' => 'Bacteria',
    'Picozoa' => 'Eukaryota',
    'Candidatus Aerophobetes' => 'Bacteria',
    'Candidatus Saccharibacteria' => 'Bacteria',
    'Candidatus Yanofskybacteria' => 'Bacteria',
    'Candidatus Diapherotrites' => 'Archaea',
    'Acidobacteria' => 'Bacteria',
    'Candidatus Hydrogenedentes' => 'Bacteria',
    'Candidatus Roizmanbacteria' => 'Bacteria',
    'Candidatus Campbellbacteria' => 'Bacteria',
    'Candidatus Moranbacteria' => 'Bacteria',
    'Orthonectida' => 'Eukaryota',
    'Candidatus Chisholmbacteria' => 'Bacteria',
    'Chrysiogenetes' => 'Bacteria',
    'Thermodesulfobacteria' => 'Bacteria',
    'Candidatus Lloydbacteria' => 'Bacteria',
    'Candidatus Niyogibacteria' => 'Bacteria',
    'Candidatus Staskawiczbacteria' => 'Bacteria',
    'Candidatus Terrybacteria' => 'Bacteria',
    'Candidatus Wildermuthbacteria' => 'Bacteria',
    'Candidatus Yonathbacteria' => 'Bacteria',
    'Candidatus Cloacimonetes' => 'Bacteria',
    'Candidatus Margulisbacteria' => 'Bacteria',
    'Candidatus Eisenbacteria' => 'Bacteria',
    'Candidatus Harrisonbacteria' => 'Bacteria',
    'Candidatus Delongbacteria' => 'Bacteria',
    'Streptophyta' => 'Eukaryota',
    'Spirochaetes' => 'Bacteria',
    'Synergistetes' => 'Bacteria',
    'Entorrhizomycota' => 'Eukaryota',
    'Candidatus Lokiarchaeota' => 'Archaea',
    'Kinorhyncha' => 'Eukaryota',
    'Cnidaria' => 'Eukaryota',
    'Mollusca' => 'Eukaryota',
    'Cryptomycota' => 'Eukaryota',
    'Euryarchaeota' => 'Archaea',
    'Lentisphaerae' => 'Bacteria',
    'Chordata' => 'Eukaryota',
    'Nemertea' => 'Eukaryota',
    'Calditrichaeota' => 'Bacteria',
    'Zoopagomycota' => 'Eukaryota',
    'Thaumarchaeota' => 'Archaea',
    'Chlorophyta' => 'Eukaryota',
    'Mucoromycota' => 'Eukaryota',
    'Kiritimatiellaeota' => 'Bacteria',
    'Aquificae' => 'Bacteria',
    'Deferribacteres' => 'Bacteria',
    'Loricifera' => 'Eukaryota',
    'Fusobacteria' => 'Bacteria',
    'Tenericutes' => 'Bacteria',
    'Aurearenophyceae' => 'Eukaryota',
    'Gnathostomulida' => 'Eukaryota',
    'Tardigrada' => 'Eukaryota',
    'Xenacoelomorpha' => 'Eukaryota',
    'Armatimonadetes' => 'Bacteria',
    'Candidatus Parcubacteria' => 'Bacteria',
    'Candidatus Calescamantes' => 'Bacteria',
    'Nitrospinae' => 'Bacteria',
    'Candidatus Daviesbacteria' => 'Bacteria',
    'Candidatus Pacebacteria' => 'Bacteria',
    'Candidatus Aminicenantes' => 'Bacteria',
    'Placozoa' => 'Eukaryota',
    'candidate division NC10' => 'Bacteria',
    'Candidatus Woykebacteria' => 'Bacteria',
    'Myzostomida' => 'Eukaryota',
    'Gemmatimonadetes' => 'Bacteria',
    'Candidatus Falkowbacteria' => 'Bacteria',
    'Candidatus Nomurabacteria' => 'Bacteria',
    'Candidatus Jorgensenbacteria' => 'Bacteria',
    'Candidatus Levybacteria' => 'Bacteria',
    'Candidatus Gottesmanbacteria' => 'Bacteria',
    'Candidatus Woesebacteria' => 'Bacteria',
    'Candidatus Shapirobacteria' => 'Bacteria',
    'Candidatus Giovannonibacteria' => 'Bacteria',
    'Candidatus Collierbacteria' => 'Bacteria',
    'Candidatus Beckwithbacteria' => 'Bacteria',
    'Candidatus Kaiserbacteria' => 'Bacteria',
    'Candidatus Amesbacteria' => 'Bacteria',
    'Candidatus Uhrbacteria' => 'Bacteria',
    'Candidatus Magasanikbacteria' => 'Bacteria',
    'Candidatus Adlerbacteria' => 'Bacteria',
    'Candidatus Wolfebacteria' => 'Bacteria',
    'Candidatus Kuenenbacteria' => 'Bacteria',
    'Candidatus Azambacteria' => 'Bacteria',
    'Candidatus Blackburnbacteria' => 'Bacteria',
    'Candidatus Brennerbacteria' => 'Bacteria',
    'Candidatus Buchananbacteria' => 'Bacteria',
    'Candidatus Colwellbacteria' => 'Bacteria',
    'Chlamydiae' => 'Bacteria',
    'Candidatus Komeilibacteria' => 'Bacteria',
    'Candidatus Ryanbacteria' => 'Bacteria',
    'Candidatus Tagabacteria' => 'Bacteria',
    'Candidatus Poribacteria' => 'Bacteria',
    'Candidatus Curtissbacteria' => 'Bacteria',
    'Candidatus Rokubacteria' => 'Bacteria',
    'Candidatus Coatesbacteria' => 'Bacteria',
    'Candidatus Kryptonia' => 'Bacteria',
    'candidate division WWE3' => 'Bacteria',
    'Blastocladiomycota' => 'Eukaryota',
    'Ignavibacteriae' => 'Bacteria',
    'candidate division WPS-1' => 'Bacteria',
    'Candidatus Portnoybacteria' => 'Bacteria',
    'Candidatus Jacksonbacteria' => 'Bacteria',
    'Candidatus Kerfeldbacteria' => 'Bacteria',
    'Candidatus Spechtbacteria' => 'Bacteria',
    'candidate division Zixibacteria' => 'Bacteria',
    'candidate division GAL15' => 'Bacteria',
    'Candidatus Parvarchaeota' => 'Archaea',
    'Candidatus Handelsmanbacteria' => 'Bacteria',
    'Candidatus Edwardsbacteria' => 'Bacteria',
    'Candidatus Riflebacteria' => 'Bacteria',
    'Candidatus Wallbacteria' => 'Bacteria',
    'Candidatus Firestonebacteria' => 'Bacteria',
    'Candidatus Fischerbacteria' => 'Bacteria',
    'Candidatus Fraserbacteria' => 'Bacteria',
    'Candidatus Glassbacteria' => 'Bacteria',
    'Candidatus Lindowbacteria' => 'Bacteria',
    'Candidatus Raymondbacteria' => 'Bacteria',
    'Candidatus Schekmanbacteria' => 'Bacteria',
    'Candidatus Andersenbacteria' => 'Bacteria',
    'Candidatus Veblenbacteria' => 'Bacteria',
    'candidate division CPR2' => 'Bacteria',
    'candidate division CPR3' => 'Bacteria',
    'Candidatus Sungbacteria' => 'Bacteria',
    'Candidatus Taylorbacteria' => 'Bacteria',
    'Candidatus Vogelbacteria' => 'Bacteria',
    'Candidatus Zambryskibacteria' => 'Bacteria',
    'Candidatus Wirthbacteria' => 'Bacteria',
    'candidate division WOR-3' => 'Bacteria',
    'candidate division KD3-62' => 'Bacteria',
    'Candidatus Fermentibacteria' => 'Bacteria',
    'Candidatus Micrarchaeota' => 'Archaea',
    'Candidatus Tectomicrobia' => 'Bacteria',
    'Candidatus Doudnabacteria' => 'Bacteria',
    'Candidatus Liptonbacteria' => 'Bacteria',
    'Candidatus Heimdallarchaeota' => 'Archaea',
    'Candidatus Goldbacteria' => 'Bacteria',
    'Candidatus Bathyarchaeota' => 'Archaea',
    'Candidatus Geoarchaeota' => 'Archaea',
    'candidate phylum NAG2' => 'Archaea',
    'Candidatus Aenigmarchaeota' => 'Archaea',
    'Candidatus Thorarchaeota' => 'Archaea',
    'Nanoarchaeota' => 'Archaea',
    'Candidatus Nanohaloarchaeota' => 'Archaea',
    'Candidatus Odinarchaeota' => 'Archaea',
    'Cycliophora' => 'Eukaryota',
    'Candidatus Fervidibacteria' => 'Bacteria',
    'Fibrobacteres' => 'Bacteria',
    'Candidatus Berkelbacteria' => 'Bacteria',
    'Candidatus Marinimicrobia' => 'Bacteria',
    'Candidatus Verstraetearchaeota' => 'Archaea',
    'Candidatus Atribacteria' => 'Bacteria',
    'candidate division WPS-2' => 'Bacteria',
    'Caldiserica' => 'Bacteria',
    'Candidatus Dadabacteria' => 'Bacteria',
    'Entoprocta' => 'Eukaryota',
    'Candidatus Peregrinibacteria' => 'Bacteria',
    'candidate division JL-ETNP-Z39' => 'Bacteria',
    'Candidatus Abawacabacteria' => 'Bacteria',
    'Candidatus Desantisbacteria' => 'Bacteria',
    'candidate division ZB3' => 'Bacteria',
    'Candidatus Woesearchaeota' => 'Archaea',
    'Rhombozoa' => 'Eukaryota',
    'Candidatus Korarchaeota' => 'Archaea',
    'Onychophora' => 'Eukaryota',
    'Candidatus Gracilibacteria' => 'Bacteria',
    'candidate division CPR1' => 'Bacteria',
    'Candidatus Nealsonbacteria' => 'Bacteria',
    'Candidatus Omnitrophica' => 'Bacteria',
    'Bacteroidetes' => 'Bacteria',
    'Firmicutes' => 'Bacteria',
    'Actinobacteria' => 'Bacteria',
    'Echinodermata' => 'Eukaryota',
    'Elusimicrobia' => 'Bacteria',
    'Annelida' => 'Eukaryota',
    'Porifera' => 'Eukaryota',
    'Chytridiomycota' => 'Eukaryota',
    'Verrucomicrobia' => 'Bacteria',
    'Rotifera' => 'Eukaryota',
    'Chlorobi' => 'Bacteria',
    'Cyanobacteria' => 'Bacteria',
    'Deinococcus-Thermus' => 'Bacteria',
    'Candidatus Melainabacteria' => 'Bacteria',
    'Rhodothermaeota' => 'Bacteria',
    'Gastrotricha' => 'Eukaryota',
    'Dictyoglomi' => 'Bacteria',
    'Colponemidia' => 'Eukaryota',
    'Haplosporidia' => 'Eukaryota',
    'Chromerida' => 'Eukaryota',
    'Bolidophyceae' => 'Eukaryota',
    'Xanthophyceae' => 'Eukaryota',
    'Eustigmatophyceae' => 'Eukaryota',
    'Euglenida' => 'Eukaryota',
    'Ascomycota' => 'Eukaryota',
    'Nematoda' => 'Eukaryota',
    'Apicomplexa' => 'Eukaryota',
    'Brachiopoda' => 'Eukaryota',
    'Bryozoa' => 'Eukaryota',
    'Proteobacteria' => 'Bacteria',
    'Phaeophyceae' => 'Eukaryota',
    'Bacillariophyta' => 'Eukaryota',
    'Platyhelminthes' => 'Eukaryota',
    'Basidiomycota' => 'Eukaryota',
    'Microsporidia' => 'Eukaryota',
    'Arthropoda' => 'Eukaryota',
    'Chaetognatha' => 'Eukaryota',
    'Acanthocephala' => 'Eukaryota',
    'Crenarchaeota' => 'Archaea',
    'Chloroflexi' => 'Bacteria',
    'Ctenophora' => 'Eukaryota',
    'Hemichordata' => 'Eukaryota',
    'Pinguiophyceae' => 'Eukaryota',
    'Thermotogae' => 'Bacteria',
    'Planctomycetes' => 'Bacteria',
    'Priapulida' => 'Eukaryota',
    'Nitrospirae' => 'Bacteria',
    'Heterokontophyta' => 'Eukaryota',
    'Balneolaeota' => 'Bacteria',
    'Nematomorpha' => 'Eukaryota'
  }.freeze
end
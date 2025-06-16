docker-compose build
docker-compose up -d
docker-compose ps
docker-compose exec mass-spec-analyzer bash

MetaboliteSpectralMatcher -write_ini params.ini

MetaboliteSpectralMatcher \
  -in        /workspace/data/MSV000097085/082322_NM_14-1.mzML \
  -database  /workspace/libs/GNPS-LIBRARY.mzML \
  -out       /workspace/results/082322_NM_14-1.msmatch.mzTab \
  -ini       /workspace/params.ini \
  -threads   4


FeatureFinderMetabo \
  -in /workspace/data/MSV000097085/082322_NM_14-1.mzML \
  -out /workspace/results/features.featureXML

SiriusAdapter \
  -in                        /workspace/data/MSV000097085/082322_NM_14-1.mzML \
  -executable                /usr/local/bin/sirius \
  -out_sirius                /workspace/results/sample_sirius.mzTab \
  -sirius:ppm_max            15 \
  -sirius:auto_charge        \
  -threads                   4 \
  -preprocessing:feature_only

docker-compose build

docker-compose up -d

docker-compose exec mass-spec-analyzer python3 /workspace/scripts/test_environment.py

docker-compose exec mass-spec-analyzer jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root

http://localhost:8888 


fetch_gnps_library

convert_gnps_to_mzml

MetaboliteSpectralMatcher \
  -in /workspace/data/sample.mzML \
  -out /workspace/results/sample.msmatch.idXML \
  -database /workspace/libs/GNPS-LIBRARY.mgf \
  -precursor_mass_tolerance 10


  SiriusAdapter \
  -in /workspace/data/sample.mzML \
  -out /workspace/results/sample_sirius.idXML \
  -executable /usr/local/bin/sirius \
  -ppm_max 15 \
  -ionization [M+H]+


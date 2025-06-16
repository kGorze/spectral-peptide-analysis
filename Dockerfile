# Dockerfile dla analizy spektrometrii mas
FROM ubuntu:22.04

# Ustawienie nieinteraktywnego trybu dla apt
ENV DEBIAN_FRONTEND=noninteractive

# Aktualizacja systemu i instalacja podstawowych narzędzi
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    wget \
    curl \
    unzip \
    build-essential \
    cmake \
    git \
    default-jre \
    # Java 17 (wymagane przez SIRIUS 5.x)
    openjdk-17-jre-headless \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Tworzenie symbolicznego linku dla python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Instalacja bibliotek Python potrzebnych do analizy
RUN pip3 install --no-cache-dir \
    pymzml \
    matplotlib \
    seaborn \
    pandas \
    numpy \
    scipy \
    plotly \
    jupyter \
    notebook \
    pyopenms \
    lxml \
    scikit-learn

# Instalacja OpenMS (apt) - wszystkie narzędzia trafiają do /usr/bin
RUN apt-get update && apt-get install -y \
    libc6-dev \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5svg5-dev \
    libqt5opengl5-dev \
    libgl1-mesa-dev \
    openms \
    && rm -rf /var/lib/apt/lists/*

# Instalacja MSGF+
WORKDIR /opt
RUN wget https://github.com/MSGFPlus/msgfplus/releases/download/v2024.03.26/MSGFPlus_v20240326.zip \
    && unzip MSGFPlus_v20240326.zip \
    && mkdir -p /opt/msgfplus \
    && mv MSGFPlus.jar /opt/msgfplus/ \
    && rm MSGFPlus_v20240326.zip

# Tworzenie skryptu uruchomieniowego dla MSGF+
RUN echo '#!/bin/bash\njava -Xmx3500M -jar /opt/msgfplus/MSGFPlus.jar "$@"' > /usr/local/bin/msgfplus \
    && chmod +x /usr/local/bin/msgfplus

# Instalacja SIRIUS 6.x + CSI:FingerID (in-silico metabolomics)
ENV SIRIUS_VER=6.2.2
RUN wget -q https://github.com/sirius-ms/sirius/releases/download/v${SIRIUS_VER}/sirius-${SIRIUS_VER}-linux-x64.zip \
    -O /tmp/sirius.zip \
    && cd /opt \
    && unzip -q /tmp/sirius.zip \
    && ln -s /opt/sirius/bin/sirius /usr/local/bin/sirius \
    && rm /tmp/sirius.zip
ENV SIRIUS_HOME=/opt/sirius



# Tworzenie katalogu roboczego
WORKDIR /workspace

# Tworzenie katalogu na dane
RUN mkdir -p /workspace/data /workspace/results /workspace/libs

# Ustawienie uprawnień
RUN chmod -R 755 /workspace

# Skrypt pomocniczy do pobierania biblioteki GNPS
# — uruchamiasz go *po* zbudowaniu obrazu, gdy jej potrzebujesz
RUN echo '#!/bin/bash\n'\
'echo ">> Pobieram bibliotekę GNPS-LIBRARY.mgf... (to ~2–3 GB, pierwszy raz trwa)"\n'\
'mkdir -p /workspace/libs\n'\
'wget -c -O /workspace/libs/GNPS-LIBRARY.mgf \\\n'\
'  "https://external.gnps2.org/gnpslibrary/GNPS-LIBRARY.mgf"\n'\
'echo ">> Gotowe: /workspace/libs/GNPS-LIBRARY.mgf"\n' > /usr/local/bin/fetch_gnps_library \
    && chmod +x /usr/local/bin/fetch_gnps_library

# Skrypt do konwersji MGF → mzML
RUN echo '#!/bin/bash\n'\
'echo ">> Konwertowanie GNPS-LIBRARY.mgf do mzML..."\n'\
'cd /workspace/libs\n'\
'if [ ! -f "GNPS-LIBRARY.mgf" ]; then\n'\
'  echo "Błąd: Nie znaleziono pliku GNPS-LIBRARY.mgf"\n'\
'  echo "Najpierw uruchom: fetch_gnps_library"\n'\
'  exit 1\n'\
'fi\n'\
'echo ">> Używam FileConverter do konwersji MGF → mzML..."\n'\
'FileConverter \\\n'\
'  -in  GNPS-LIBRARY.mgf \\\n'\
'  -out GNPS-LIBRARY.mzML\n'\
'echo ">> Gotowe: /workspace/libs/GNPS-LIBRARY.mzML"\n' > /usr/local/bin/convert_gnps_to_mzml \
    && chmod +x /usr/local/bin/convert_gnps_to_mzml

# Domyślna komenda
CMD ["/bin/bash"] 
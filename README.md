
## Analiza widma białek przy pomocy OpenMS
[![Docker Pulls](https://img.shields.io/docker/pulls/kgorzel306/spectral-peptide-analysis.svg)](https://hub.docker.com/r/kgorzel306/spectral-peptide-analysis)  
[![Docker Image Size](https://img.shields.io/docker/image-size/kgorzel306/spectral-peptide-analysis/latest.svg)](https://hub.docker.com/r/kgorzel306/spectral-peptide-analysis/tags)
## Pochodzenie danych
Jako że dane było bardzo trudno poszukać samodzielnie ze względu na to, że trzeba było dobrać odpowiedni plik .mzML oraz fasta, skorzystałem ze strony która udostępnia materiały do nauki używania narzędzi OpenMS do identyfikacji Peptide i Protein ID - [Galaxy Training](https://training.galaxyproject.org/training-material/topics/proteomics/tutorials/protein-id-oms/tutorial.html#input-data). 
Z tej strony znalazłem dane, które pochodzą z "**Test dataset for ProteinID**" autorstwa *Vaudel, Marc*; *Martens, Lennart* ;*Sigloch, Florian Christoph* stamtąd zabrałem pliki
- **human_database_including_decoys_(cRAP_and_Mycoplasma_added).fasta** jako baze danych stworzoną tak, żeby zawierały decoye które normalnie są robione również przez OpenMS narzędziem np.
```bash
DecoyDatabase \
  -in   swissprot_human.fasta \
  -out  swissprot_human_target_decoy.fasta \
  -decoy_string "DECOY_" \
  -type protein \
  -method shuffle
```
-  **qExactive01819_profile.mzml** oraz sam plik do analizy.

Opis próbki znajduje się na tych stronach:
- [MassIve](https://massive.ucsd.edu/ProteoSAFe/dataset.jsp?task=c985415fc46a4593bb350d98f264b55b)
- [Pride](https://www.ebi.ac.uk/pride/archive/projects/PXD000674)

W skrócie spektrum pochodzi z jednego wstrzyknięcia lizatu HeLa analizowanego na Q Exactive z fragmentacją HCD. Przygotowanie próbki odpowiada standardowej procedurze bottom-up: trawienie trypsyną i alkilacja cystein. Metadane (licencja CC0, kompletny FASTA, pliki RAW/MGF/mzML) sprawiają, że zbiór idealnie nadaje się do testowania narzędzi identyfikacji peptydów/białek (stąd wybór jako “example dataset” PeptideShaker).

## Wczytywanie i wizualizacja widma surowego
Całość kodu jaka została napisane odnośnie tego programu jest w **qExactive01819_analysis.ipynb**.

![](https://i.imgur.com/pri2nwe.png)
**Fig. 1**
*WIdmo masowe surowe wczytane za pomocą pomzml w notebooku dla pliku qExactive01819_profile.mzml*


Redukując szum, trzeba było trochę poeksperymentować i sprawdziś jakie ustawienia będą najlepsze. Czy tak jak zostało podane w zadaniu "*Usunięcie pików o intensywności poniżej ustalonego progu (np. 100)*" - jako przykładową wartość **100**.
Do tego sprawdziłem rozkład intensywności pików i wyglądał on tak
```python
Statystyki intensywności: 
Minimum: 0.00e+00 
Maksimum: 8.39e+03 
Średnia: 1.92e+03 
Mediana: 0.00e+00 
Percentyl 90%: 6.32e+03 
Percentyl 95%: 6.87e+03
```
![](https://i.imgur.com/JHg4TtR.png)
**Fig. 2**
*Rozkład intensywności pików pliku qExactive01819_profile.mzml*

Zredukowałem szumy do 25.0%

```python
Próg filtracji: 4.52e+03 
Liczba pików przed filtracją: 296 
Liczba pików po filtracji: 74 
Procent zachowanych pików: 25.0%
```

Zrobiłem normalizacje metodą do najintensywniejszego pliku

```python
Maksymalna intensywność przed normalizacją: 8.39e+03 
Zakres po normalizacji: 54.2% - 100.0% 
Top 10 najintensywniejszych pików: 
1. m/z: 1334.06, intensywność: 100.0% 
2. m/z: 725.55, intensywność: 96.3% 
3. m/z: 1062.70, intensywność: 95.9% 
4. m/z: 725.56, intensywność: 95.2% 
5. m/z: 1029.35, intensywność: 91.0% 
6. m/z: 774.07, intensywność: 91.0% 
7. m/z: 1334.07, intensywność: 90.6% 
8. m/z: 837.42, intensywność: 90.0% 
9. m/z: 1062.69, intensywność: 87.2% 
10. m/z: 799.12, intensywność: 86.0%
```
Po tych zabiegach tak prezentuje się wykres przed i po operacjach:
![](https://i.imgur.com/gskoy2n.png)
**Fig. 3**
*Wykres przed i po zastosowaniu operacji normalizacji oraz usuwaniu szumów.* Widać tutaj jakieś dziwne zachowania pików nałożonych na sobie przy prawym końcu.

Jak wydać sygnał ten wychwytuje konkretne piki ale wygląda **źle**. Może się wydawać, że jest to niewłaściwa intepretacja danych, gdzie dane z Q Exactive w trybie profile są ciągłym sygnałem a nie są dyskretnymi pikami jak w centroid mode. Dane cały czas zawierają szum instrumnetalny wymagający odszumienia, dodatkowo każdy punkt powyżej progrmu jest traktowany jako pik co trzeba zmienić.

Mamy następny kod który pokazuje nam, że 
```python
Poziom szumu: 1.64e-01 
Próg sygnału (3×szum): 4.91e-01 
Znaleziono 22 rzeczywistych pików
```

na tej podstawie prowadzimy nową analize
```python
Top 10 najintensywniejszych pików (poprawiona analiza): 
1. m/z: 1334.06, intensywność: 100.0% 
2. m/z: 725.55, intensywność: 97.6% 
3. m/z: 1062.70, intensywność: 97.5% 
4. m/z: 774.07, intensywność: 91.9% 
5. m/z: 1029.35, intensywność: 90.9% 
6. m/z: 837.42, intensywność: 89.5% 
7. m/z: 799.12, intensywność: 88.3% 
8. m/z: 1097.94, intensywność: 86.3% 
9. m/z: 687.70, intensywność: 85.5% 
10. m/z: 515.38, intensywność: 83.1%
```
Nasępnie mamy to! Zmiana metody z metody percentylowej która miała 74 punkty, nakładające się czasami na sobie, została zmieniona na metode **SNR**(*signal-to-noise ratio*). To są wyniki: 
![](https://i.imgur.com/FdIkQH3.png)
**Fig. 4**
*Poprawione dane po ulepszeniach odszumiania i filtracji*
## Identyfikacja związków/białek

Jednak do identyfikacji peptydów/białek lepiej użyć oryginalnych surowych danych, a nie przetworzonych. Nasza próbka najlepiej będzie reprezentowana poprzez oryginalne dane i zawansowane algorytmy w narzędziach openMS.

Cały workflow przy proteomice wygląda w ten sposób:

![](https://i.imgur.com/Ko0b89m.png)
**Fig. 5**
*Pipeline przedstawiony za pomocą narzędzia graficznego TOPAS od OpenMS*

Całość rzeczy które się tutaj dzieje występuje w tych komendach:
1. **PeakPickerHiRes** - Centroidowanie profilu $MS^{1/2}$ – ustawiamy czułość S/N, poziom skanów i liczbę rdzeni:
```bash
PeakPickerHiRes \
  -in qExactive01819_profile.mzML \
  -out Exa_centroided.mzML \
  -algorithm:signal_to_noise 2.0 \
  -algorithm:ms_levels 1 \
  -threads 4
```
2. **MSFGPlusAdapter**  - Wyszukiwanie bazy z MS-GF+ z parametrami dobranymi do Q Exactive i standardowej próbki trypsynowej:
```bash
MSGFPlusAdapter \
  -in Exa_centroided.mzML \
  -out Exa.idXML \
  -executable /ścieżka/do/MSGFPlus.jar \
  -database human_database_including_decoys_(cRAP_and_Mycoplasma_added).fasta \
  -instrument Q_Exactive \
  -threads 4
```
3. **ProteinQuantifier** - Zliczanie identyfikacji (spectral counting) i eksport do CSV:
```bash
ProteinQuantifier \
  -in Exa.idXML \
  -out Ilosc.csv \
  -peptide_out Ilosc_peptydy.csv \
  -method top \
  -threads 4
```
Wynikiem tej całej analizy jest plik który zawiera białka/peptydy które zostały rozpoznane jako możliwie zawierające się w tym widmie. Cały plik **qExactive01819_profile.unknown** wyglądał w ten sposób: 

![](https://i.imgur.com/322IAeW.png)
**Fig. 6**
*Plik zawierający dane po analizie za pomocą narzędzi OpenMS*

Po zrobieniu analizy danych dochodzimy do takich wyników:

```python
============================================================
ANALIZA WYNIKÓW IDENTYFIKACJI PEPTYDÓW/BIAŁEK
============================================================
Pomyślnie wczytano 4082 wierszy danych
Kolumny: ['peptide', 'protein', 'n_proteins', 'charge', 'abundance', 'fraction']

=== PODSTAWOWE STATYSTYKI ===
Liczba zidentyfikowanych peptydów: 4082
Liczba unikalnych białek: 2235
Średnia abundancja: 1.39
Zakres abundancji: 1.0 - 45.0

=== TOP 10 PEPTYDÓW (według abundancji) ===
 1. VFLENVIR        | P62805          |  45.0
 2. LISWYDNEFGYSNR  | P04406          |  38.0
 3. LLLPGELAK       | O60814          |  28.0
 4. IWHHTFYNELR     | A5A3E0          |  22.0
 5. ATRRFSWK        | C4XFA6          |  20.0
 6. YISPDQLADLYK    | P06733          |  20.0
 7. HQGVM(Oxidation)VGM(Oxidation)GQK | P60709          |  16.0
 8. YPIEHGIITNWDDM(Oxidation)EK | P62736          |  16.0
 9. VVDLM(Oxidation)AHM(Oxidation)ASKE | P04406          |  15.0
10. ISGLIYEETR      | P62805          |  13.0
```

Widzimy tutaj, że najbardziej prawdopodobnymi peptydami jakie znalazły się w naszym widmie są
- **P62805**
- **P04406**
- **060814**
Jednak nas bardziej interesują białka:
```python
=== ANALIZA BIAŁEK ===
Prawdziwe identyfikacje (bez decoy/kontaminantów): 4025
Unikalnych białek: 2074
Kontaminanty: 55
Decoy hits: 2
Mycoplasma: 88

=== TOP 10 BIAŁEK (według całkowitej abundancji) ===
 1. P04406          | Peptydów: 17 | Abundancja:   94.0
 2. P62805          | Peptydów: 12 | Abundancja:   80.0
 3. P11021          | Peptydów: 33 | Abundancja:   74.0
 4. P06733          | Peptydów: 18 | Abundancja:   60.0
 5. P11142          | Peptydów: 21 | Abundancja:   59.0
 6. P60709          | Peptydów: 19 | Abundancja:   58.0
 7. P08670          | Peptydów: 25 | Abundancja:   48.0
 8. P05787          | Peptydów: 22 | Abundancja:   43.0
 9. P08238          | Peptydów: 18 | Abundancja:   43.0
10. P0DMV9          | Peptydów: 22 | Abundancja:   43.0
```

Widać, że znowu na pierwszym miejscu pojawia się tajmeniczny **P04406**! Analizując co to jest za białko trafiamy na wejście w [UniProt](https://www.uniprot.org/uniprotkb/P04406/entry) - **Glyceraldehyde-3-phosphate dehydrogenase**. Następnie gdy sprawdzimy sobie na wikipedi czy innych źródłach danych biologicznych jest opis

>Glyceraldehyde-3-phosphate dehydrogenaza (GAPDH) to kluczowy enzym szóstego etapu glikolizy. Katalizuje ona utlenienie aldehydu 3-fosfoglicerynowego do 1,3-bisfosfoglicerynianu, jednocześnie redukując NAD⁺ do NADH i przyłączając nieorganiczny fosforan. Dzięki temu: 1. **W glikolizie** – pozwala komórce pozyskać elektrony (w postaci NADH) i przygotowuje substrat do późniejszej produkcji ATP. 2. **W biologii molekularnej** – jej gen jest często używany jako „housekeeping” kontrola w qPCR czy western blotach, bo GAPDH bywa stabilnie eksprymowana w wielu tkankach. 3. **Dodatkowe funkcje** – poza cytoplazmą może uczestniczyć w procesach jądrowych, naprawie DNA, transporcie mRNA, a także w regulacji stresu oksydacyjnego i apoptozy. W skrócie: GAPDH to nie tylko „trybik” glikolizy, ale też wielozadaniowe białko ważne w badaniach laboratoryjnych oraz regulacji komórkowej.

Mając to na uwadze można wysnuć wniosek, że **GAPDH** "świeci" w komórkach **HeLa**. HeLa to agresywna linia nowotworowa, która musi stale dublować DNA, białka i błony. Z tego powodu potrzebuje stałego, wysokiego dopływu energii i prekursorów. Komórki rakowe preferują glikolizę nawet przy dostępnym tlenu. Tempo glikolizy rośnie, by zaspokoić potrzeby biosyntezy, dlatego ekspresja całego „pakietu” enzymów glikolitycznych, w tym GAPDH, jest podkręcona. Jednak GAPDH i tak należy do białek konstytutywnych i jest potrzebna w każdej żywej komórce. Daje to połączenie funkcji konstytutywnej i Warburga czyli wyjątkowo wysoką obfitość białka.

## Dodatkowe analizy

Gdy już mamy gotowe dane możemy pokusić sie o dodatkowe analizy, które mogą dać inne spojrzenie na komplet informacji:

![](https://i.imgur.com/7rXwUQw.png)
**Fig. 7**
*Heatmapa korelacji metryki białek - Pokazuje korelacje między 5 metrykami: liczba peptydów, abundancja, abundancja na peptyd, log abundancji, log liczby peptydów. Najsilniejsze korelacje ($\approx$ 0.9-1.0) między abundance a log_abundance (oczywiste)*

![](https://i.imgur.com/m1lA446.png)
**Fig. 8**
*PCA Biplot w którym widać porównanie PC1 i PC2. Niebieskie punkty oznaczają białka w przestrzeni głównych składowych. Czerwone strzałki pokazują z jakim kierunkiem i zwrotem kojarzone są konkretne zmienne. Adnotacje pokazują outlinerów z naszego datasetu. Dodatkowo po prawej widzimy projekcje 3D na płaszczyzne 2D, gdzie PC2 jest opisany jako kolor.*

![](https://i.imgur.com/q2YxYoW.png)
**Fig. 9**
*Wykres osypiska który pokazuje % wariancji wyaśnianej przez każdą składową główną. Widać, że $PC_{1} \approx 62$, $PC_{2} \approx 32$ i $PC_{3} \approx 5$ łącznie pierwsze 3 składowe wyjaśniają $\approx 99$ procent wariancji.*

![](https://i.imgur.com/PvIqBky.png)
**Fig. 10**
*Klastrowanie dendogramowe w którym jest 30 najczęstszych białek. Widać hierarchiczne ugrupowanie do "rodzin" gdzie wysokość oznacza odległość między grupami a kolor oznacza różne klastry hierarchiczne. Pozwala to zidentyfikować podobne białka pod względem profili ilościowych.* 

![](https://i.imgur.com/hIQ1Olb.png)
**Fig. 11**
*Klastrowanie K-means w którym możemy zauważyć w jakich miejsach centra klastrów się znajdują. Białka są podzielone na 4 klastry. Widać tutaj analize przestrzeni PCA gdzie jest PC1 a PC2.*

Po tych przykładowych analizach możemy dojść do wniosku biologicznego, że mamy doczynienia z 4 grupami białek o różnych charakterstykach:
- Grupa 1: Białka o niskiej abundancji (**prawdopodobnie regulatorowe**)
- Grupa 2: Białka o średniej abundancji (**metaboliczne**)
- Grupa 3: Białka o bardzo wysokiej abundancji (**podstawowe do działania białka**)
- Grupa 4: Białka o specjalnych profilach (być może strukturalne)

Na koniec tutaj jest cała infografika z każdą analizą:
![](https://i.imgur.com/Ie10qcv.png)
**Fig. 12**
*Całkowita analiza danych białkowych*

## Kontener i repozytorium
Całośc kodu wraz z notebookami do analizy oraz kontenerem na docker-hubie znajdują się w [repozytorium](https://github.com/kGorze/spectral-peptide-analysis)

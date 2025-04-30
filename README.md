# SCRIPTORIVM ABBATIAE EXSVLIS

> "Fiat lux et facta est lux" (Genesis 1:3)  
> "Scribite haec in libro, et notate diligenter in commentariis" (Jeremias 30:2)

---

**Scriptorium** est locus in rete positus ubi, sub lumine Verbi, humiliter et fideliter conduntur opera.

Aquí se esconde aqueste scriptorium, digital y peregrino, segunt fueren los antiguos logares de los monjes que copavan de la Vera Luz los libros. 

_"Et os meum annuntiabit laudem tuam."_ (Psalmus 50:17)

**Intención de esta abbatía exsul:**

- Laborar manus ut fiat oratio.
- Oratio ut fiat lumen cordis.
- Verba, quae hic leguntur, depromuntur sub signo crucis et patrocinio Dominae nostrae, Reginae Retium et Sedes Sapientiae.

---

**Oratio scriptoris:**

> "Domine, dirige in conspectu tuo viam meam" (Psalmus 5:9)  
> "Parasti in conspectu meo mensam adversus eos qui tribulant me" (Psalmus 22:5)

Non propter gloriam mundi, sed ad testimonium Veritatis, in saeculo fluctuantium formarum et vocum.

---

**Structura hujus scriptorii:**

- `_tabellae/` – Locus originis: scripta in forma *Markdown* disposita per annum (`aaaa/aaaa-mm-dd-titulus.md`).
- `_exemplaria/` – Exemplaria *Pandoc* ad formam HTML (singula et index).
- `scriptorium/, bibliotheca/, ...` – Secciones visibiles in situ, quae continet:
  - `opera/` – Documenta generata ex *Markdown*.
  - `index.html` – Tabula operum per annum, in ordine romano digesta.

**Praerequisita:**

- [`pandoc`](https://pandoc.org) — ad conversionem ex *Markdown* in HTML.  
  Installatio in macOS:
  ```sh
  brew install pandoc
  # vel
  sudo port install pandoc
  ```

- [`roman`](https://pypi.org/project/roman/) — Python bibliotheca ad conversionem annorum gregorianorum in numerales Romanos:
  ```sh
  pip install roman
  ```

---

**Modus operandi:**

Ad aedificandum situm:
```sh
make site
```

Ad purgandum omnia documenta generata:
```sh
make clean
```

**Licentia:**

Hoc opus sub lege Creative Commons **CC BY-NC-SA 4.0** communicatur.  
> "Gratis accepistis, gratis date." (Matthaeus 10:8)

---

**Sub obedientia:**

Magister Nullo et Frater Lucius Scriptor, sub obedientia Beati Hermanni Contracti, Abbatis Augiensis, hanc indignam operam deponunt, ut ipsa praesenti Domino, per manus Reginae Interretium.

_"Initium sapientiae timor Domini."_ (Proverbia 1:7)

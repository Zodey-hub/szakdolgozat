#set document(
  title: "Teljesítmény- és méretoptimalizált webes keretrendszer tervezése és megvalósítása Rustban",
  author: "Bálint Máté",
  description: "Szakdolgozat",
  date: auto,
)

#set page(
  paper: "a4",
  margin: (inside: 35mm, outside: 25mm, top: 25mm, bottom: 25mm),
  footer: context {
    if here().page() >= 2 {
      align(right, counter(page).display("1"))
    }
  },
)

#set heading(numbering: (..n) => {
  let nums = n.pos().slice(1)
  if nums.len() == 1 { numbering("1.", ..nums) } else { numbering("1.1", ..nums) }
})

#set text(font: "Times New Roman", size: 12pt, lang: "hu", hyphenate: false)
#set par(justify: true, first-line-indent: (amount: 1.5em, all: true))
#set list(indent: 1.5em)

#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 1): it => counter(heading).step() + it
#show heading.where(level: 1): set block(below: 1em)
#show heading.where(level: 1): set align(center)

#let todo(body) = text(fill: red)[\[TODO: #body\]]

// ---------- Címlap ----------

#[
  #set par(justify: false, first-line-indent: 0em)

  #grid(
    columns: 1fr,
    rows: (auto, auto, auto, auto),
    row-gutter: 1fr,
    align: center,
    [
      #text(size: 16pt, weight: "bold")[Szegedi Tudományegyetem] \
      #text(size: 14pt)[Informatikai Intézet]
    ],
    [
      #text(size: 22pt, weight: "bold")[#context document.title]
      #v(1em)
      #text(size: 14pt)[#context upper(document.description)]
    ],
    grid(
      columns: (1fr, 1fr),
      align: center + top,
      box(align(left)[
        _Készítette:_
        #pad(left: 1.5em, top: -0.5em)[
          *#context document.author.first()* \
          programtervező informatikus \
          BSc szakos hallgató
        ]
      ]),
      box(align(left)[
        _Témavezető:_
        #pad(left: 1.5em, top: -0.5em)[
          *Dr. Siket István* \
          Szoftverfejlesztés Tanszék \
          adjunktus
        ]
      ]),
    ),
    [Szeged, 2026],
  )
]

#pagebreak()
#counter(page).update(1)

// ---------- Tartalmi összefoglaló ----------

= Tartalmi összefoglaló

== A téma megnevezése

#context document.title.

== A megadott feladat megfogalmazása

A feladat egy Rust nyelven írt, újrahasznosítható könyvtárakból álló webes keretrendszer megtervezése és elkészítése, amelynek elsődleges szempontja a nagy futási teljesítmény és a lefordított program minimális mérete. A könyvtárak gyakorlati használhatóságát egy publikus EPUB-kereső és -letöltő webalkalmazás mutatja be.

== A megoldási mód

A HTTP-szerver a nulláról készült, a smol aszinkron futtatókörnyezetre építve. A kérések elemzését az httparse, a protokoll típusait a http könyvtár biztosítja. Az adattárolásért egy saját adatbázisréteg felel, amely a redb beágyazott kulcs–érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül. Ennek köszönhetően a tárolt rekordok beolvasáskor elemzés, deszerializálás és újabb memóriafoglalás nélkül, közvetlenül Rust-struktúraként használhatók. A felhasználói felület szerveroldalon renderelődik: az oldalakat builder-mintán alapuló HTML-generátor állítja elő, a formázást a Pico.css végzi, így kliensoldali JavaScriptre alig van szükség.

== Alkalmazott eszközök, módszerek

- Programozási nyelv: Rust
- Aszinkron futtatókörnyezet: smol
- HTTP-szerver: http, httparse
- Adatbázis: redb, rkyv
- Felhasználói felület: build_html, Pico.css
- Verziókezelés: Git

== Elért eredmények

#todo[a mérési eredmények rövid összefoglalása: a futtatható állomány mérete és a függőségek száma, a bemutató alkalmazás válaszideje, áteresztőképessége és memóriahasználata, valamint a főbb tervezési döntések (pl. zero-copy olvasás) mért hatása]

== Kulcsszavak

Rust, webes keretrendszer, HTTP-szerver, zero-copy szerializáció, beágyazott adatbázis, teljesítményoptimalizálás

#pagebreak()

// ---------- Tartalomjegyzék ----------

#outline(title: "Tartalomjegyzék", depth: 3)

#pagebreak()

// ---------- Bevezetés ----------

= Bevezetés

== Motiváció

A webalkalmazások fejlesztése ma jellemzően nagy, általános célú keretrendszerekre épül. Ezek gyorsan használható, kényelmes megoldást adnak a leggyakoribb feladatokra, ennek azonban ára van: az alkalmazás a ténylegesen használt funkciók mellett a keretrendszer teljes függőségi fáját is magával hordozza. A sok függőség hosszabb fordítási időt, nagyobb futtatható állományt és nehezebben átlátható működést eredményez, az általánosság érdekében bevezetett absztrakciós rétegek pedig futásidőben is költséget jelentenek. Egy kisebb, jól körülhatárolt feladatot ellátó webalkalmazásnál a keretrendszer képességeinek nagy része kihasználatlan marad, a velük járó többletterhet viszont az alkalmazás ugyanúgy viseli.

A Rust nyelv jó alapot ad ahhoz, hogy ez a kompromisszum újragondolható legyen. Futásidejű környezet és szemétgyűjtő nélkül, a C és a C++ nyelvhez hasonló teljesítményű gépi kódra fordul, a memóriabiztonságot pedig fordítási időben garantálja. Az ökoszisztémában megtalálhatók azok a kicsi, egyetlen feladatra összpontosító könyvtárak, amelyekből egy webes rendszer alsó rétegei felépíthetők anélkül, hogy egy teljes keretrendszert kellene átvenni. Dolgozatom kiinduló kérdése ezért az, hogy milyen teljesítmény és méret érhető el, ha a webalkalmazás alapjait -- a HTTP-szervert, az adattárolást és a felület előállítását -- nem kész keretrendszer adja, hanem kifejezetten erre a célra tervezett, a lehető legkevesebb függőséget használó saját könyvtárak.

A témaválasztásnak személyes oka is van. Szívesen dolgozom Rust nyelven, és a saját projektjeimhez régóta szerettem volna egy olyan háttérrendszert, amelynek minden rétegét ismerem, és amely csak azt tartalmazza, amire ténylegesen szükségem van. A dolgozat ezért nem a meglévő keretrendszerek leváltására tesz kísérletet, hanem azt mutatja be, hogyan építhető fel egy ilyen rendszer, és milyen tervezési döntések vezetnek kicsi és gyors eredményhez.

== Célkitűzés

Dolgozatom célja egy olyan, Rust nyelven írt webes keretrendszer megtervezése és megvalósítása, amelynek minden tervezési döntését két szempont vezérli: a nagy futási teljesítmény és a lefordított program minimális mérete.

#par(first-line-indent: 0em)[A munkám három fő területet ölel fel:]

- *HTTP-szerver:* A hálózati réteget a nulláról írom meg, a smol aszinkron futtatókörnyezetre építve. Külső könyvtárat csak a kérések elemzéséhez (httparse) és a protokoll alapvető típusainak leírásához (http) használok, így elkerülöm a nagy webes keretrendszerek többletterhét.
- *Adatbázisréteg:* Az adatok tárolására saját adatbázisréteget készítek, amely a redb beágyazott kulcs--érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül. A tárolt rekordokat beolvasáskor nem kell elemezni, deszerializálni, és új memóriaterületet sem kell foglalni számukra: a nyers bájtok közvetlenül Rust-struktúraként használhatók. Mivel mindkét könyvtár tisztán Rust nyelven íródott, az adatbázis statikusan a programmal együtt fordul, külön adatbázismotorra és más nyelvű függőségre nincs szükség.
- *Szerveroldali megjelenítés:* Az oldalakat a szerveren állítom elő: a HTML-t a Rust nyelvben híres builder-mintára épülő generátorral hozom létre, a stílusokról pedig a Pico.css gondoskodik. A böngészőnek így kész oldalakat kell megjelenítenie, kliensoldali JavaScriptre alig van szükség.

A könyvtárak gyakorlati használhatóságát egy bemutató alkalmazással igazolom: egy publikus weboldal, amelyen EPUB formátumú elektronikus könyvek között lehet keresni illetve letölteni. Az alkalmazást szándékosan egyszerűre tervezem, mert a dolgozat hangsúlya nem rajta, hanem az alatta lévő rétegek megvalósításán van. Feladata az, hogy a keretrendszer valamennyi elemét valós körülmények között használja, és alapot adjon a mérésekhez.

A kitűzött célok teljesülését mérésekkel ellenőrzöm. Nem célom más keretrendszerekkel versenyezni, ezért a mérések magára az elkészült rendszerre irányulnak, és három kérdésre keresnek választ:

- *Méret:* Mekkora a lefordított futtatható állomány, hány függőségre épül, és az egyes tervezési és fordítási döntések mennyivel járulnak hozzá a méret csökkenéséhez.
- *Teljesítmény:* Milyen válaszidővel, áteresztőképességgel és memóriahasználattal szolgálja ki a kéréseket a bemutató alkalmazás.
- *A tervezési döntések hatása:* Mennyit számítanak a gyakorlatban a keretrendszer kulcsfontosságú megoldásai, például a zero-copy olvasás a hagyományos deszerializáláshoz képest.

== A dolgozat felépítése

#todo[a fejezetek végleges sorrendjéhez igazítani]

A dolgozatban először a felhasznált eszközöket és módszereket tekintem át: a Rust nyelv témához kapcsolódó tulajdonságait, az aszinkron programozási modellt, valamint a felhasznált könyvtárakat. Ezt követően a saját munkámat mutatom be: sorra veszem a keretrendszer rétegeit -- a HTTP-szervert, az adatbázisréteget és a HTML-generálást --, majd a rájuk épülő bemutató alkalmazást. A dolgozatot a mérések leírása és kiértékelése, végül az eredmények összefoglalása zárja.

#pagebreak()

// ---------- Nyilatkozat ----------

= Nyilatkozat

Alulírott #context document.author.first() programtervező informatikus BSc szakos hallgató, kijelentem, hogy a dolgozatomat a Szegedi Tudományegyetem, Informatikai Intézet Szoftverfejlesztés Tanszékén készítettem, programtervező informatikus BSc diploma megszerzése érdekében.

Kijelentem, hogy a dolgozatot más szakon korábban nem védtem meg, saját munkám eredménye, és csak a hivatkozott forrásokat (szakirodalom, eszközök stb.) használtam fel.

Tudomásul veszem, hogy szakdolgozatomat a Szegedi Tudományegyetem a Diplomamunka Repozitóriumában tárolja.

#v(1em)

#par(first-line-indent: 0em)[Szeged, 2026. november 6.]

#v(1em)

#align(right)[
  #box(width: 40%)[
    #align(center)[
      #line(length: 100%, stroke: (thickness: 0.5pt, dash: "dotted"))
      #v(-0.5em)
      *hallgató aláírása*
    ]
  ]
]

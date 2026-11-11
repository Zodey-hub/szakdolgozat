#set document(
  title: "Teljesítmény- és méretoptimalizált webes keretrendszer tervezése és megvalósítása Rustban",
  author: "Bálint Máté",
  description: "Szakdolgozat",
  date: auto,
)

#set page(
  paper: "a4",
  margin: 25mm,
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
#set par(justify: true, first-line-indent: 1.5em, spacing: 0.6em)
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
        #pad(left: 1.5em)[
          *#context document.author.first()* \
          programtervező informatikus \
          BSc szakos hallgató
        ]
      ]),
      box(align(left)[
        _Témavezető:_
        #pad(left: 1.5em)[
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

A feladat egy Rust nyelven írt, újrahasznosítható könyvtárakból álló webes keretrendszer megtervezése és elkészítése, amelynek elsődleges szempontja a nagy futási teljesítmény és a lefordított program minimális mérete.
A könyvtárak gyakorlati használhatóságát egy publikus EPUB-kereső és -letöltő webalkalmazás mutatja be.

== A megoldási mód

A HTTP-szerver a nulláról készült, a smol aszinkron futtatókörnyezetre építve.
A kérések elemzését az httparse, a protokoll típusait a http könyvtár biztosítja.
Az adattárolásért egy saját adatbázisréteg felel, amely a redb beágyazott kulcs–érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül, amelynek köszönhetően a tárolt rekordok beolvasáskor elemzés, deszerializálás és újabb memóriafoglalás nélkül, közvetlenül Rust-struktúraként használhatók.
A felhasználói felület szerveroldalon renderelődik: az oldalakat builder-mintán alapuló HTML-generátor állítja elő, a formázást a Pico.css végzi, így kliensoldali JavaScriptre alig van szükség.

== Alkalmazott eszközök, módszerek

- Programozási nyelv: Rust
- Aszinkron futtatókörnyezet: smol
- HTTP-szerver: http, httparse
- Adatbázis: redb, rkyv
- Felhasználói felület: build_html, Pico.css
- Verziókezelés: Git

== Elért eredmények

#todo[a mérési eredmények rövid összefoglalása: a futtatható állomány mérete, a bemutató alkalmazás válaszideje, áteresztőképessége és memóriahasználata, valamint a főbb tervezési döntések (pl. zero-copy olvasás) mért hatása]

== Kulcsszavak

Rust, webes keretrendszer, HTTP-szerver, zero-copy szerializáció, beágyazott adatbázis, teljesítményoptimalizálás

#pagebreak()

// ---------- Tartalomjegyzék ----------

#outline(title: "Tartalomjegyzék", depth: 3)

#pagebreak()

// ---------- Bevezetés ----------

= Bevezetés

== Motiváció

A webalkalmazások fejlesztése ma jellemzően nagy, általános célú keretrendszerekre épül.
Ezek gyorsan használható, kényelmes megoldást adnak a leggyakoribb feladatokra, ennek azonban ára van: a keretrendszer egyetlen egységként érkezik, így az alkalmazás azokat a képességeket is magával hordozza, amelyeket nem használ.
Az általánosság érdekében bevezetett absztrakciós rétegek futásidőben költséget jelentenek, a futtatható állományba olyan kód is bekerül, amelyre az alkalmazásnak nincs szüksége, a sok rejtett mechanizmus pedig megnehezíti annak átlátását, hogy egy kérés kiszolgálása közben pontosan mi történik.
Egy kisebb, jól körülhatárolt feladatot ellátó webalkalmazásnál a keretrendszer képességeinek nagy része kihasználatlan marad, a velük járó többletterhet viszont az alkalmazás ugyanúgy viseli.

A Rust nyelv jó alapot ad ahhoz, hogy ez a kompromisszum újragondolható legyen.
Futásidejű környezet és szemétgyűjtő nélkül, a C és a C++ nyelvhez hasonló teljesítményű gépi kódra fordul, a memóriabiztonságot pedig fordítási időben garantálja.
Az ökoszisztéma ráadásul erősen moduláris: egy webes rendszer alsó rétegei kicsi, egyetlen feladatra összpontosító könyvtárakból is felépíthetők anélkül, hogy egy teljes keretrendszert kellene átvenni.
A függőségek száma önmagában nem hátrány: a jól megválogatott, kis könyvtárak párhuzamosan fordíthatók, külön-külön cserélhetők, és az alkalmazásba csak az kerül be, amire valóban szükség van.
Dolgozatom kiinduló kérdése ezért az, hogy milyen teljesítmény és méret érhető el, ha a webalkalmazás alapjait -- a HTTP-szervert, az adattárolást és a felület előállítását -- nem kész keretrendszer adja, hanem kifejezetten erre a célra tervezett, gondosan megválogatott, kis könyvtárakra épülő saját megoldás.

A témaválasztásnak személyes oka is van.
Szívesen dolgozom Rust nyelven, és a saját projektjeimhez régóta szerettem volna egy olyan háttérrendszert, amelynek minden rétegét ismerem, és amely csak azt tartalmazza, amire ténylegesen szükségem van.
A dolgozat ezért nem a meglévő keretrendszerek leváltására tesz kísérletet, hanem azt mutatja be, hogyan építhető fel egy ilyen rendszer, és milyen tervezési döntések vezetnek kicsi és gyors eredményhez.

== Célkitűzés

Dolgozatom célja egy olyan, Rust nyelven írt webes keretrendszer megtervezése és megvalósítása, amelynek minden tervezési döntését két szempont vezérli: a nagy futási teljesítmény és a lefordított program minimális mérete.

#par(first-line-indent: 0em)[A munkám két fő területet ölel fel:]

- *HTTP-szerver:* A hálózati réteget a nulláról írom meg, a smol aszinkron futtatókörnyezetre építve.
  Külső könyvtárat csak a kérések elemzéséhez (httparse) és a protokoll alapvető típusainak leírásához (http) használok, így elkerülöm a nagy webes keretrendszerek többletterhét.
- *Adatbázisréteg:* Az adatok tárolására saját adatbázisréteget készítek, amely a redb beágyazott kulcs--érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül.
  A tárolt rekordokat beolvasáskor nem kell elemezni, deszerializálni, és új memóriaterületet sem kell foglalni számukra: a nyers bájtok közvetlenül Rust-struktúraként használhatók.
  Mivel mindkét könyvtár tisztán Rust nyelven íródott, az adatbázis statikusan a programmal együtt fordul, külön adatbázismotorra és más nyelvű függőségre nincs szükség.

#h(1.5em)

Mindkét könyvtár önálló, bármilyen projektben használható.
A gyakorlati használhatóságukat egy bemutató alkalmazással igazolom: egy publikus weboldal, amelyen EPUB formátumú elektronikus könyvek között lehet keresni illetve letölteni.
Az oldalakat az alkalmazás a szerveren állítja elő: a HTML-t a Rust nyelvben elterjedt builder-mintára épülő generátor hozza létre, a stílusokról pedig a Pico.css gondoskodik, így a böngészőnek kész oldalakat kell megjelenítenie, kliensoldali JavaScriptre alig van szükség.
Az alkalmazást szándékosan egyszerűre tervezem, mert a dolgozat hangsúlya nem rajta, hanem az alatta lévő rétegek megvalósításán van.
Feladata az, hogy a keretrendszer valamennyi elemét valós körülmények között használja, és alapot adjon a mérésekhez.

A kitűzött célok teljesülését mérésekkel ellenőrzöm.
Nem célom más keretrendszerekkel versenyezni, ezért a mérések magára az elkészült rendszerre irányulnak, és három kérdésre keresnek választ:

- *Méret:* Mekkora a lefordított futtatható állomány, és az egyes tervezési és fordítási döntések mennyivel járulnak hozzá a méret csökkenéséhez.
- *Teljesítmény:* Milyen válaszidővel, áteresztőképességgel és memóriahasználattal szolgálja ki a kéréseket a bemutató alkalmazás.
- *A tervezési döntések hatása:* Mennyit számítanak a gyakorlatban a keretrendszer kulcsfontosságú megoldásai, például a zero-copy olvasás a hagyományos deszerializáláshoz képest.

== A dolgozat felépítése

A dolgozatban először a felhasznált eszközöket és módszereket tekintem át: a Rust nyelv tulajdonságait, az aszinkron programozási modellt, a HTTP protokollt és a felhasznált könyvtárakat.
Ezt követően a saját munkámat mutatom be rétegenként: sorra veszem a HTTP-szervert és az adatbázisréteget, majd a rájuk épülő bemutató alkalmazást, benne a szerveroldali megjelenítéssel.
A dolgozatot a mérések leírása és kiértékelése, végül az eredmények összefoglalása zárja.

#pagebreak()

// ---------- Felhasznált technológiák ----------

= Felhasznált technológiák

== A Rust nyelv tulajdonságai

=== Memóriakezelés és biztonság

#todo[tulajdonjog és kölcsönzés (borrow checker), memóriabiztonság fordítási időben, nincs szemétgyűjtő és futásidejű környezet]

=== Absztrakciók és kódméret

#todo[zero-cost abstraction és monomorfizáció (ennek ára: a kódméret)]

=== Hibakezelés

#todo[a `Result` alapú hibakezelés és a `panic`]

=== Cargo és a crate-ek ökoszisztémája

#todo[a Cargo, a crate-ek, a release profil lehetőségei (LTO, `panic=abort`, `codegen-units`)]

== Aszinkron programozás Rustban

=== Blokkoló és aszinkron modell

#todo[a blokkoló, szálanként kapcsolatot kezelő modell és az aszinkron modell összehasonlítása]

=== Future és async/await

#todo[`Future`, `async`/`await`, az állapotgép, amivé a fordító alakítja]

=== Futtatókörnyezet és reaktor

#todo[az executor és a reaktor feladata; az operációs rendszer eseményfigyelője (epoll)]

=== A smol

#todo[a smol felépítése és miért kicsi (async-executor, async-io, async-net); egyszálú és többszálú végrehajtás]

== A HTTP/1.1 protokoll

#todo[a kérés és a válasz felépítése; a TCP bájtfolyam és a keretezés (fejléc vége, `Content-Length`, `Transfer-Encoding`); a tartós kapcsolat (keep-alive) és a pipelining; a request smuggling lényege; a http és a httparse könyvtár szerepe]

== Beágyazott adattárolás

=== Beágyazott adatbázisok és a redb

#todo[a beágyazott és a kliens--szerver adatbázis különbsége; a redb (copy-on-write B-fa, ACID tranzakciók, egyetlen író)]

=== Zero-copy szerializáció és az rkyv

#todo[a zero-copy szerializáció fogalma és az rkyv (archivált típusok, validálás)]

=== Miért nem SQLite

#todo[FFI, C függőség, a fordítás és a méret]

== További felhasznált eszközök

#todo[a bytes könyvtár (`Bytes`, `BytesMut`, referenciaszámlált szeletek); a build_html (builder minta); a Pico.css; a mérésekhez használt eszközök (wrk, kuva)]

#pagebreak()

// ---------- A HTTP-szerver ----------

= A HTTP-szerver

== Követelmények és tervezési szempontok

#todo[a szerver önálló, alkalmazásfüggetlen könyvtár, bármilyen projektben használható; mit tud és mit nem (nincs TLS, routing, middleware, streamelés); a kezelőfüggvény felülete (`Handler`, `http::Request<Body>` és `Response<Body>`); a kapcsolat élete: egy task kapcsolatonként]

== A kérés beolvasása

=== A TCP bájtfolyam és a három olvasási lépés

#todo[a bájtfolyam, nincs "kérés vége" jel; olvasás a fejléc végéig, a törzs hosszának meghatározása, a törzs beolvasása]

=== Pufferelés

#todo[kapcsolatonkénti puffer, pipelining, a `scratch` terület és a `Box<[u8]>`/`Vec<u8>` választás]

=== A fejléc elemzése és a zero-copy

#todo[a `split_to` és a `freeze`, ablakok a `Bytes`-ra; a kétszeri elemzés indoklása, a `Parts` kerülőút]

== A törzs hossza, korlátok és védelmek

=== A törzs hosszának meghatározása

#todo[`content_length` szabályai (táblázat)]

=== Védelmek

#todo[smuggling elleni védelem, nincs előzetes memóriafoglalás (slowloris)]

=== Korlátok

#todo[korlátok (fejléc, fejlécek száma, törzs) és indoklásuk]

== Időkorlátok és kapcsolatkezelés

=== Két időkorlát

#todo[tétlenségi (5 s) és kérésolvasási (30 s) időkorlát, a `wait_for_request`, keep-alive]

=== Kapcsolatok száma

#todo[kapcsolatszám-korlát hiánya és következménye]

== A válasz kiírása

#todo[válaszpuffer, `Vec<u8>`; a törzs másolása és a vectored write kérdése (a mérés eredményével)]

== Hibakezelési elvek

#todo[`unwrap` és `?` az invariánsokra, panic hatása a kapcsolatra, nincs `debug_assert`]

#pagebreak()

// ---------- Az adatbázisréteg ----------

= Az adatbázisréteg

== Követelmények

#todo[az adatbázisréteg önálló, alkalmazásfüggetlen könyvtár, bármilyen projektben használható; milyen általános igényeket szolgál ki; tervezési szempontok (méret, sebesség, zero-copy)]

== A redb és az rkyv együtt

=== Írás

#todo[hogyan kerül az rkyv által archivált típus a redb-be]

=== Olvasás deszerializálás nélkül

#todo[az olvasás útvonala beolvasás-deszerializálás nélkül, igazítás (alignment)]

=== Validálás és `unsafe`

#todo[a validálás költsége és szerepe, az `unsafe` kérdése]

== A tárolt adatok modellje

=== Táblák, kulcsok és rekordok

#todo[táblák és kulcsok, tetszőleges rkyv-vel archiválható rekordtípus tárolása]

=== Indexek és keresés

#todo[másodlagos indexek és keresés támogatása]

== A programozói felület

=== Az API felépítése

#todo[tranzakciók, olvasás, írás]

=== Hibakezelés és használat

#todo[hibakezelés, használati példa]

#pagebreak()

// ---------- A bemutató alkalmazás ----------

= A bemutató alkalmazás

== Az alkalmazás célja és funkciói

#todo[publikus EPUB-kereső és -letöltő oldal; milyen oldalak és útvonalak vannak; ez az egyetlen rész, amely az EPUB formátumhoz kötődik, a szerver és az adatbázisréteg ettől függetlenül működik]

== Az EPUB formátum

#todo[felépítése (ZIP, OPF, metaadatok, borító), mit nyerünk ki belőle]

== Bélyegképek

#todo[az EPUB-ban megadható bélyegkép (borítókép) kinyerése és megjelenítése; nincs futásidejű képfeldolgozás, így az image könyvtár sem szükséges; mi történik, ha nincs megadva bélyegkép]

== Felépítés és megvalósítás

=== A rétegek összekapcsolása

#todo[útvonalválasztás, a kezelőfüggvények, az adatbázis és a renderelés kapcsolata]

=== Könyvek betöltése és indexelése

#todo[könyvek betöltése, metaadatok kinyerése, indexelés]

=== Keresés és letöltés

#todo[a keresés működése; a letöltés kiszolgálása]

== A felhasználói felület

=== Szerveroldali renderelés

#todo[miért szerveroldalon; kliensoldali JavaScript minimalizálása]

=== A HTML-generátor

#todo[builder minta, a build_html használata, a biztonság (kimenet escape-elése, XSS)]

=== Stílus

#todo[Pico.css (méret, osztály nélküli stílus)]

== Telepítés és üzemeltetés

#todo[fordítás (release profil), futtatás, konfiguráció]

#pagebreak()

// ---------- Mérések ----------

= Mérések és kiértékelés

== A mérések módja

#todo[mérőkörnyezet, eszközök (wrk), a mérések korlátai]

== A futtatható állomány mérete

=== A fordítási beállítások hatása a méretre

#todo[az egyes beállítások halmozott hatása a méretre]

=== A méret és a sebesség viszonya

#todo[a méretre optimalizált változatok sebessége]

== Teljesítmény

=== Áteresztőképesség és késleltetés

#todo[a kapcsolatok számának hatása]

=== Nagy törzsek

#todo[nagy válaszok és kérések kiszolgálása]

== Memóriahasználat

=== Alapterhelés és terhelés alatt

#todo[indításkor, terhelés alatt]

=== Kapcsolatonkénti költség

#todo[tétlen kapcsolatok, nagy válaszok pufferei]

#pagebreak()

// ---------- Összefoglalás ----------

= Összefoglalás

== Elért eredmények

#todo[a kitűzött célok teljesülése a mérések alapján]

== Korlátok

#todo[egyszálú szerver, nincs TLS, nincs streamelés, nincs kapcsolatszám-korlát]

== Továbbfejlesztési lehetőségek

#todo[többszálúság, streamelés, HTTP/2, ...]

#pagebreak()

// ---------- Irodalomjegyzék ----------

= Irodalomjegyzék

#todo[a hivatkozott források (Rust könyv, a használt könyvtárak dokumentációja, RFC 9110/9112, wrk, ...)]

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
      *hallgató aláírása*
    ]
  ]
]

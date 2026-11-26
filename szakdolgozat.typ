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
#set figure(numbering: n => numbering("1.1", counter(heading).get().first() - 3, n)) // -3 a Tartalmi összefoglaló, a Tartalomjegyzék és a Bevezetés miatt
#set ref(supplement: none)

#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 1): it => counter(heading).step() + it
#show heading.where(level: 1): set block(below: 1em)
#show heading.where(level: 1): set align(center)
#show heading.where(level: 1): it => (raw, table, image).map(k => counter(figure.where(kind: k)).update(0)).join() + it

#show figure: set block(above: 1.5em, below: 1.5em)
#show figure.where(kind: raw): set figure(supplement: [Kódrészlet]) // a Typst magyar fordításából hiányzik a kódrészlet szava, ezért angolul „Listing” lenne

#show outline.entry: set text(size: 11pt)
#show bibliography: set text(size: 10pt)
#show raw: set text(font: "JetBrains Mono")
#show raw.where(block: true): set text(size: 9pt)
#show raw.where(block: true): set align(left)
#show raw.where(block: true): block.with(width: 100%, inset: 1em, stroke: 0.5pt + gray)
#show raw.where(block: false): box

#set table(stroke: (_, y) => if y == 0 { (bottom: 0.5pt) }, align: left)
#show table: box.with(stroke: (y: 1pt))
#show table.cell.where(y: 0): set text(weight: "bold")
#show table.cell: set par(justify: false)

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

A HTTP-szerver a nulláról készült, a smol aszinkron futtatókörnyezet építőelemeire (async-executor, async-io, async-net) építve.
A kérések elemzését a httparse, a protokoll típusait a http könyvtár biztosítja.
Az adattárolásért egy saját adatbázisréteg felel, amely a redb beágyazott kulcs--érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül.
Az rkyv-nek köszönhetően a tárolt rekordok beolvasáskor elemzés, deszerializálás és újabb memóriafoglalás nélkül, közvetlenül Rust-struktúraként használhatók.
A felhasználói felület szerveroldalon renderelődik: az oldalakat builder-mintán alapuló HTML-generátor állítja elő, a formázást egy saját stíluslap végzi, így kliensoldali JavaScriptre nincs szükség.

== Alkalmazott eszközök, módszerek

- Programozási nyelv: Rust
- Aszinkron futtatókörnyezet: a smol építőelemei (async-executor, async-io, async-net)
- HTTP-szerver: http, httparse
- Adatbázis: redb, rkyv
- Felhasználói felület: build_html, saját stíluslap
- EPUB-feldolgozás: epub
- JSON-kimenet: serde
- Verziókezelés: Git

== Elért eredmények

#todo[a mérési eredmények rövid összefoglalása: a HTTP-szerver futtatható állományának mérete, áteresztőképessége, késleltetése és memóriahasználata, az adatbázisréteg írási és olvasási sebessége, valamint a főbb tervezési döntések (pl. zero-copy olvasás) mért hatása]

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

- *HTTP-szerver:* A hálózati réteget a nulláról írom meg, a smol aszinkron futtatókörnyezet építőelemeire (async-executor, async-io, async-net) építve.
  Külső könyvtárat csak a kérések elemzéséhez (httparse) és a protokoll alapvető típusainak leírásához (http) használok, így elkerülöm a nagy webes keretrendszerek többletterhét.
- *Adatbázisréteg:* Az adatok tárolására saját adatbázisréteget készítek, amely a redb beágyazott kulcs--érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül.
  A tárolt rekordokat beolvasáskor nem kell elemezni, deszerializálni, és új memóriaterületet sem kell foglalni számukra: a nyers bájtok közvetlenül Rust-struktúraként használhatók.
  Mivel mindkét könyvtár tisztán Rust nyelven íródott, az adatbázis statikusan a programmal együtt fordul, külön adatbázismotorra és más nyelvű függőségre nincs szükség.

#h(1.5em)

Mindkét könyvtár önálló, bármilyen projektben használható.
A gyakorlati használhatóságukat egy bemutató alkalmazással igazolom: egy publikus weboldal, amelyen EPUB formátumú elektronikus könyvek között lehet keresni illetve letölteni.
Az oldalakat az alkalmazás a szerveren állítja elő: a HTML-t a Rust nyelvben elterjedt builder-mintára épülő generátor hozza létre, a stílusokról pedig egy saját, a programba fordított stíluslap gondoskodik, így a böngészőnek kész oldalakat kell megjelenítenie, kliensoldali JavaScriptre pedig nincs is szükség.
Az alkalmazást szándékosan egyszerűre tervezem, mert a dolgozat hangsúlya nem rajta, hanem az alatta lévő rétegek megvalósításán van.
Feladata az, hogy a keretrendszer valamennyi elemét valós körülmények között használja.

A kitűzött célok teljesülését mérésekkel ellenőrzöm.
Nem célom más keretrendszerekkel versenyezni, ezért a mérések magára a két elkészült könyvtárra irányulnak, és három kérdésre keresnek választ:

- *Méret:* Mekkora a lefordított futtatható állomány, és az egyes tervezési és fordítási döntések mennyivel járulnak hozzá a méret csökkenéséhez.
- *Teljesítmény:* Milyen áteresztőképességgel, késleltetéssel és memóriahasználattal szolgálja ki a kéréseket a HTTP-szerver, és milyen gyorsan ír és olvas az adatbázisréteg.
- *A tervezési döntések hatása:* Mennyit számítanak a gyakorlatban a keretrendszer kulcsfontosságú megoldásai, például a zero-copy olvasás a hagyományos deszerializáláshoz képest.

== A dolgozat felépítése

#par(first-line-indent: 0em)[A dolgozat a következő fejezetekből áll:]

- *Felhasznált technológiák:* Áttekintem a munka elméleti és eszközbeli alapjait: a Rust nyelv tulajdonságait, az aszinkron programozási modellt, a HTTP/1.1 protokollt, a beágyazott adattárolást és zero-copy szerializációt, valamint a felhasznált könyvtárakat.
- *A HTTP-szerver:* Bemutatom a nulláról írt szervert: a kérések beolvasását és feldolgozását, a védelmi korlátokat és időkorlátokat, a válasz kiírását, valamint a hibakezelési elveket.
- *Az adatbázisréteg:* Ismertetem a redb és az rkyv együttes használatát, a tárolt adatok modelljét és a programozói felületet.
- *A bemutató alkalmazás:* Leírom az EPUB-kereső és -letöltő oldalt: a funkciókat, a felépítést, a szerveroldali megjelenítést, valamint az alkalmazás üzemeltetését.
- *Mérések és kiértékelés:* Bemutatom a méréseket és eredményeiket a futtatható állomány méretéről, a teljesítményről és a memóriahasználatról, valamint a kulcsfontosságú tervezési döntések hatásáról.
- *Összefoglalás:* Értékelem az elért eredményeket és a rendszer korlátait, és felvázolom a továbbfejlesztési lehetőségeket.

#pagebreak()

// ---------- Felhasznált technológiák ----------
// terjedelem: kb. 7 oldal

= Felhasznált technológiák

== A Rust nyelv tulajdonságai

=== Memóriakezelés és biztonság

#todo[tulajdonjog és kölcsönzés (borrow checker), memóriabiztonság fordítási időben, nincs szemétgyűjtő és futásidejű környezet]

=== Absztrakciók és hibakezelés

#todo[zero-cost abstraction és monomorfizáció (ennek ára: a kódméret); traitek és generikus API-k, amelyekre a könyvtárak épülnek (`Handler`, `Record`); a `Result`, a `?` operátor és a `panic`; könyvtárban saját hibatípus (thiserror), alkalmazásban anyhow]

=== Cargo és a fordítási profilok

#todo[a Cargo, a crate-ek és a crates.io (mindkét könyvtár ott publikált); a feature-ök egyesítése (később: az rkyv `unaligned`); a release profil lehetőségei (`opt-level`, LTO, `codegen-units`, `panic=abort`, `strip`)]

== Aszinkron programozás Rustban

=== Blokkoló és aszinkron modell

#todo[a blokkoló, szálanként kapcsolatot kezelő modell és az aszinkron modell összehasonlítása]

=== Future, executor és reaktor

#todo[`Future`, `async`/`await`, az állapotgép, amivé a fordító alakítja; az executor és a reaktor feladata; az operációs rendszer eseményfigyelője (epoll)]

=== A smol és építőelemei

#todo[a smol kis, önálló crate-ekből áll (async-executor, async-io, async-net, futures-lite, async-channel), és ezek közvetlenül is használhatók, így csak az kerül a programba, ami kell; egy executor több szálon (a szálak ugyanabból a sorból veszik a taskokat)]

== A HTTP/1.1 protokoll

=== Az üzenetek és a keretezés

#todo[a kérés (kérősor, fejlécek, törzs) és a válasz felépítése, a `HEAD` metódus; a TCP-ben nincs „üzenet vége” jel: a fejléc végét az üres sor, a törzs hosszát a `Content-Length` vagy a `Transfer-Encoding: chunked` adja meg]

=== Tartós kapcsolatok és request smuggling

#todo[keep-alive és a `Connection` fejléc (HTTP/1.0 és 1.1 eltérő alapértelmezése), pipelining; ha két fél másképp határozza meg a kérés végét (két `Content-Length`, `Content-Length` és `Transfer-Encoding` együtt), a törzsből „új kérés” lesz]

== Beágyazott adattárolás

=== Beágyazott adatbázisok és a redb

#todo[a beágyazott és a kliens--szerver adatbázis különbsége; a redb (copy-on-write B-fa, ACID tranzakciók, egyetlen író és párhuzamos olvasók pillanatképpel; név szerinti táblák és multimap táblák; a `&[u8]` kulcsok bájtonkénti, lexikografikus összehasonlítása és a rendezett tartománybejárás, erre épül a kulcskódolás); miért nem SQLite (FFI, C függőség, fordítás és méret, SQL helyett típusos Rust API)]

=== Zero-copy szerializáció és az rkyv

#todo[a zero-copy szerializáció fogalma; az rkyv archivált típusai (relatív eltolások abszolút mutatók helyett, `ArchivedString`, `ArchivedVec`, fix bájtsorrendű egészek); validálás (bytecheck); igazítás és az `unaligned` feature]

== További felhasznált könyvtárak

#todo[a http (közös típusok I/O nélkül) és a httparse (allokáció nélküli fejlécelemző, `Complete`/`Partial`); a bytes (`Bytes`, `BytesMut`, referenciaszámlált szeletek); a build_html (builder minta, saját fork az űrlapelemek miatt); az epub; a serde és a serde_json; a unicode-normalization]

#pagebreak()

// ---------- A HTTP-szerver ----------
// terjedelem: kb. 7 oldal

= A HTTP-szerver

== Hatókör és programozói felület

=== Hatókör

A HTTP-szervert önálló, alkalmazásfüggetlen könyvtárként írtam meg, és `tiny-http-server` néven a crates.io-n is közzétettem (@tiny-http-server).
A könyvtár csak a protokollkezelésért felel: a TCP-kapcsolaton érkező bájtokból HTTP-kéréseket állít elő, átadja őket a kezelőnek, a kapott választ pedig visszaírja a hálózati kapcsolatra.
Támogatja a HTTP/1.0 és HTTP/1.1 szabványokat, egy kapcsolaton több kérést is képes egymás után kiszolgálni (keep-alive), és azokat a kéréseket is helyesen dolgozza fel, amelyeket a kliens az előző válasz megvárása nélkül küld el (pipelining).

Ami nem tartozik szorosan a protokollhoz, azt szándékosan a környező rétegekre bíztam: az útvonalválasztás (routing), a köztes rétegek (middleware) és a naplózás a hívó alkalmazás felelőssége, a titkosításról (TLS) pedig a szerver elé állított fordított proxy (reverse proxy) gondoskodhat.
A darabolt (chunked) átvitelt és a törzsek folyamatos továbbítását (streaming) sem támogatja a szerver: a kérések és a válaszok törzsét teljes egészében a memóriában tartja.

=== A `Handler` trait

A szerver és az alkalmazás közötti hidat a `Handler` trait jelenti (@lst:handler. kódrészlet).
Ennek egyetlen metódusa egy `Request`-ből aszinkron módon állít elő egy `Response`-t.
Mindkét típus a szabványos `http` könyvtárból (@http) származik, így a szerver nem saját adatstruktúrákat kényszerít a fejlesztőre, hanem a Rust-ökoszisztémában megszokott típusokra épít.
A traiten szereplő `Send + Sync + 'static` megkötésre azért van szükség, mert a kezelő egyetlen példányát a szerver összes munkaszála párhuzamosan használja.
Mivel a traithez tartozik egy általános implementáció minden olyan függvényre és closure-re (névtelen függvényre), amely kérést fogad és egy válaszra váró `Future`-t ad vissza, egy egyszerűbb alkalmazáshoz elég egy `async fn` megadása.
Ha viszont a kezelőnek belső állapotra -- például egy adatbázis-kapcsolatra -- is szüksége van, akkor a traitet egy saját struktúrán kell megvalósítani, ahogyan azt a bemutató alkalmazás `Router` típusa is teszi.

#figure(
  ```rust
  pub trait Handler: Send + Sync + 'static {
      fn handle(&self, request: Request<Body>)
          -> impl Future<Output = Response<Body>> + Send;
  }
  ```,
  caption: [A `Handler` trait],
) <lst:handler>

A kérés és a válasz törzsét a `Body` típus reprezentálja, amely a `bytes` könyvtár (@bytes) `Bytes` típusának álneve (type alias).
Mivel ez egy referenciaszámlált bájtszelet, a kérés törzse másolás nélkül (zero-copy) vágható ki a szerver olvasási pufferéből, a válasz törzseként pedig akár a binárisba fordított statikus adatok -- például egy stíluslap -- is másolás nélkül átadhatók a szervernek.
A kezelő metódusa `Result` helyett egyszerű `Response`-t ad vissza: a szerver nem kényszerít ki saját hibatípust, így az alkalmazásra bízza, hogyan kezeli a hibákat, és milyen HTTP-választ küld róluk.

=== Indítás és beállítások

A szerver kétféleképpen indítható el: a `Server::bind` az alapértelmezett beállításokkal köti a szervert a megadott címhez, míg a `ServerBuilder` segítségével ezek indítás előtt testreszabhatók, így a hívónak csak az eltéréseket kell megadnia.
A két méretkorlátot (`max_head_bytes`, `max_body_bytes`) a @tbl:korlatok. táblázat mutatja be, a harmadik beállítás, a `threads` a kapcsolatokat kiszolgáló munkaszálak száma.
Ez alapértelmezés szerint a folyamat számára elérhető logikai processzorok száma, vagy egy, ha ez nem állapítható meg.
A szálak számát `NonZeroUsize` típusú érték adja meg, így a nulla szálszám a típus szintjén ki van zárva: az értéket a hívó állítja elő, a szervernek pedig már nem kell ellenőriznie.
A `run` metódus visszatérési típusa `io::Result<Infallible>`, vagyis a metódus csak hibával térhet vissza.

A @lst:pelda. kódrészlet egy teljes példán mutatja be a használatot: itt a kezelő egy `async fn`, amely maga végzi az útvonalválasztást, a szerver pedig négy munkaszálon, 64 MiB-os törzskorláttal indul el.

#figure(
  ```rust
  async fn route(request: Request<Body>) -> Response<Body> {
      match request.uri().path() {
          "/" => Response::new(Body::from("hello")),
          _ => Response::builder()
              .status(StatusCode::NOT_FOUND)
              .body(Body::new())
              .unwrap(),
      }
  }

  ServerBuilder::new()
      .max_body_bytes(64 * 1024 * 1024)
      .threads(NonZeroUsize::new(4).unwrap())
      .bind("127.0.0.1:8080", route).unwrap()
      .run().unwrap();
  ```,
  caption: [Egy kis szerver a `tiny-http-server` könyvtárral],
) <lst:pelda>

== Szálak és kapcsolatok

=== Munkaszálak

A `run` metódusban a feladatokat két szerepkörre bontottam (@fig:szalak. ábra).
A hívó szál csak az új kapcsolatokat fogadja egy végtelen ciklusban, és mindegyikhez elindít egy aszinkron feladatot (task).
A kiszolgálást a `threads` darab munkaszál végzi, amelyek egy közös `Executor`-on osztoznak (@async-executor), így bármelyik szál bármelyik kapcsolat kérését feldolgozhatja.
Ennek előnye, hogy ha egy kezelő blokkoló műveletet végez, csak azt a munkaszálat tartja fel, amelyen éppen fut: a többi szál zavartalanul tovább dolgozik, és az új kapcsolatok fogadása sem akad meg.

#figure(
  block(width: 100%, inset: 1em, stroke: 0.5pt + gray, {
    set text(size: 8pt)
    let idle = rgb("#cfe0f1")
    let busy = rgb("#f6dcc0")
    let node(fill, body) = rect(width: 100%, radius: 3pt, fill: fill, stroke: 0.5pt + gray, inset: 5pt, body)
    let note(body) = text(size: 6pt, body)
    grid(
      columns: (1fr, 6em, 1.5fr, 5em, 1fr),
      align: center + horizon,
      node(luma(225))[hívó szál \ #note[`accept` ciklus]],
      [#note[kapcsolatonként \ egy task] \ #sym.arrow.r.long],
      node(busy, stack(
        spacing: 4pt,
        [közös `Executor`],
        ..("1.", "2.", "…").map(n => rect(
          width: 100%,
          fill: white,
          stroke: 0.5pt + gray,
        )[#note[#n kapcsolat taskja \ `RequestReader`, `ResponseWriter`]]),
      )),
      [#note[futtatják \ a taskokat] \ #sym.arrow.l.long],
      stack(
        spacing: 4pt,
        ..("1.", "2.", "…", "N.").map(n => node(idle)[#n munkaszál]),
      ),
    )
    note[Ha az `accept` hibát ad, a hívó szál lezárja a vezérlőcsatornát, a munkaszálak kilépnek, és a `thread::scope` végén a `run` visszaadja a hibát.]
  }),
  kind: image,
  caption: [A hívó szál, a munkaszálak és a kapcsolatok taskjai],
) <fig:szalak>

A munkaszálakat a szabványos könyvtár `thread::scope` függvényével hozom létre.
Mivel a fordító garantálja, hogy a hatókör végéig minden elindított szál befejeződik, ezek közvetlenül kölcsönözhetik a szervert és az executort, így egyiket sem szükséges `Arc`-ba csomagolni.
Ha a kapcsolatok fogadása valamilyen hiba miatt leáll, a hívó szál lezár egy vezérlőcsatornát, amelyre a munkaszálak várakoznak.
Ennek hatására a szálak kilépnek, a még nyitott kapcsolatok az executorral együtt megszűnnek, a `run` metódus pedig csak ezután adja vissza a hibát.

=== Kapcsolatonként egy task

Minden kapcsolathoz egy task tartozik, amely a kapcsolat élettartama alatt egymás után olvassa be és szolgálja ki a kéréseket.
Hogy a kapcsolat egy válasz után nyitva marad-e, azt a kérés verziója és `Connection` fejléce dönti el: HTTP/1.1 esetén nyitva marad, hacsak a kliens nem küld `close` jelzést, HTTP/1.0 esetén pedig csak akkor, ha a kliens `keep-alive` jelzéssel kéri.
Az olvasó és író adatfolyamok a task saját, lokális változói, így a szerver oldalán a párhuzamos kapcsolatok között nincs semmilyen megosztott, zárolást igénylő állapot.

Az újonnan elfogadott kapcsolatokon bekapcsolom a `TCP_NODELAY` opciót, amivel letiltom a Nagle-algoritmust (@rfc9293).
Ez az algoritmus a kisebb csomagokat visszatartja, amíg a korábban elküldött adatokra meg nem érkezik a nyugta, hogy több apró írást egy szegmensbe vonjon össze.
A szerver azonban minden választ egy írással küld el, így nincs mit összevonni, a várakozás csak késleltetést okozna.
Ha az opció beállítása mégsem sikerül, a kapcsolat ettől még működik, ezért ezt a hibát figyelmen kívül hagyom.

== A kérés beolvasása

=== A kérés határai és a pufferelés

A TCP-kapcsolat egy folyamatos bájtfolyam, ezért egy hálózati olvasás pontosan annyi bájtot ad vissza, amennyi addig megérkezett: egy kérés több olvasásra is széteshet, és egy olvasás a következő kérés elejét is magával hozhatja (@fig:olvasasok. ábra).
A kérés határait ezért csak a tartalma alapján lehet megállapítani: a fejléc végét az üres sor, a törzs hosszát a `Content-Length` fejléc jelzi (@rfc9112).
A szerver ezért olvasás közben elemez, és három szakaszban halad: először addig olvas, amíg a teljes fejléc össze nem áll, ezután meghatározza belőle a törzs méretét, végül addig folytatja az olvasást, amíg a törzs összes bájtja meg nem érkezik.
A fejléc teljességét a `httparse` könyvtár (@httparse) ellenőrzi, amely a puffer aktuális tartalmára vagy a teljes fejléc hosszát adja vissza, vagy jelzi, hogy még hiányoznak adatok.

#figure(
  ```
  1. olvasás:  POST /a HTTP/1.1\r\nHost: x\r\nCont
  2. olvasás:  ent-Length: 5\r\n\r\nhel
  3. olvasás:  loGET /b HTTP/1.1\r\n...
  ```,
  kind: image,
  caption: [Egy kérés három olvasásra szétesve, a harmadikban már a következő kérés eleje],
) <fig:olvasasok>

A beérkezett, de még fel nem dolgozott bájtokat a kapcsolat olvasója, a `RequestReader` egy `BytesMut` pufferben tárolja, amely nem csak egy kérésig, hanem a kapcsolat végéig él.
Amikor egy kérés beolvasása befejeződik, a szerver leválasztja a fejlécet és a törzset a puffer elejéről, a fennmaradó rész -- a következő kérés már megérkezett darabja -- pedig érintetlenül benne marad (@fig:puffer. ábra).
Így a pipelining külön logika nélkül működik: a következő kérés beolvasása pontosan ott folytatódik, ahol az előző véget ért.

Ennek viszont feltétele, hogy a szerver mindig először a pufferben már meglévő adatokat vizsgálja meg, és csak akkor olvasson a hálózatról, ha azok nem elegendőek.
Ha ugyanis az előző kérés egy teljes újabb kérést hagyott maga után a pufferben, egy felesleges hálózati olvasás olyan adatra várna, amelyet a kliens már rég elküldött -- így a kapcsolat a tétlenségi időkorlát lejártával tévesen bezárulna.
Ugyanez az ellenőrzési sorrend teszi lehetővé a kapcsolat tiszta lezárásának felismerését is: ha a kliens bontja a kapcsolatot (EOF), és a puffer üres, akkor két kérés között, szabályosan lépett ki; ha viszont maradt még feldolgozatlan adat a pufferben, akkor egy kérés közepén szakadt meg a kapcsolat, ami hibának számít.

Az új adatok közvetlenül a puffer végére kerülnek.
Mivel az `AsyncRead` csak inicializált memóriába enged írni, a puffert előbb 8 KiB-tal megnövelem -- az új területet nullákkal feltöltve --, ebbe olvasok a kapcsolatból, végül visszavágom a ténylegesen megérkezett bájtok végéig.
A 8 KiB csak egy olvasás felső határa, maga a kérés ennél jóval nagyobb is lehet.
Ennek költsége az új terület nullázása minden olvasásnál, cserébe nincs szükség külön átmeneti pufferre és adatmozgatásra, és az `unsafe` kód is teljesen elkerülhető.
A puffer így mindig csak érvényes, megérkezett bájtokat tartalmaz, amelyekből a fejléc és a törzs később másolás nélkül vágható ki.

#figure(
  block(width: 100%, inset: 1em, stroke: 0.5pt + gray, {
    set text(size: 9pt)
    let head = rgb("#f6dcc0")
    let body = rgb("#cfe0f1")
    let bytes(fill, content) = rect(
      width: 100%,
      fill: fill,
      stroke: 0.5pt + gray,
      text(size: 7pt, raw(content)),
    )
    let brace-top = pad(x: 2pt, box(width: 100%, height: 5pt, stroke: (top: 0.5pt, left: 0.5pt, right: 0.5pt)))
    let brace-bottom = pad(x: 2pt, box(width: 100%, height: 5pt, stroke: (bottom: 0.5pt, left: 0.5pt, right: 0.5pt)))
    let note(content) = text(size: 7pt, content)
    grid(
      columns: (5.5fr, 2fr, 2.5fr),
      row-gutter: 3pt,
      align: center + top,
      grid.cell(colspan: 3)[a három olvasás után: egyetlen `BytesMut` puffer],
      grid.cell(colspan: 3, brace-top),
      bytes(head, "POST /a HTTP/1.1\\r\\nHost: x\\r\\nContent-Length: 5\\r\\n\\r\\n"),
      bytes(body, "hello"),
      bytes(luma(225), "GET /b HTTP/1.1…"),
      brace-bottom, brace-bottom, brace-bottom,
      [`head: Bytes`], [`body: Bytes`], [`buffer: BytesMut`],
      note[az URI (`/a`) és a fejlécértékek \ (`x`, `5`) ebbe mutató nézetek],
      note[a kérés törzse],
      note[innen folytatódik \ a következő kérés],
    )
  }),
  kind: image,
  caption: [A bemeneti puffer a @fig:olvasasok. ábra olvasásai után, és ugyanaz a memória a két `split_to` hívás után, három részre osztva],
) <fig:puffer>

=== Zero-copy fejlécelemzés

A másolás nélküli feldolgozás a fejlécnél hoz a legtöbbet, amikor annak mezői a `http` könyvtár típusaiba kerülnek.
A fejlécet a `httparse` elemzi, amely maga sem másol: az eredményében kapott metódus, útvonal és fejlécértékek a fejléc bájtjaiba mutató szeletek.
A `Bytes` típus `slice_ref` metódusa egy ilyen, a `Bytes` belsejébe mutató szeletből egy újabb, csak arra a tartományra korlátozódó `Bytes` nézetet hoz létre, amely ugyanarra a memóriaterületre mutat, és csak a referenciaszámlálót növeli.
Az URI-t és az összes fejlécértéket ilyen részszeletekből építem fel (`from_maybe_shared`, @lst:fejlec. kódrészlet), tehát a fejlécek tartalma nem másolódik.
Memóriafoglalás így jellemzően csak a fejléceket tároló `HeaderMap`-nél és az egyedi fejlécneveknél történik, a szabványos metódusokhoz és fejlécnevekhez a `http` könyvtár előre definiált konstansokat használ.
Ugyanakkor amíg a kérés bármelyik része -- például egy elmentett fejlécérték -- életben marad, addig a mögötte álló teljes fejléc sem szabadul fel.

#figure(
  ```rust
  // read_request: a fejléc leválasztása és elemzése
  let head = self.buffer.split_to(head_len).freeze();
  let parts = parse_head(&head)?;

  // build_parts: az URI és a fejlécértékek nézetek a head-re
  *request.uri_mut() = Uri::from_maybe_shared(head.slice_ref(path.as_bytes()))?;
  let value = HeaderValue::from_maybe_shared(head.slice_ref(header.value))?;
  ```,
  caption: [A fejléc leválasztása és a zero-copy részszeletek],
) <lst:fejlec>

A fejlécet a `httparse` ezért kétszer elemzi, két különböző célból.
Az első elemzés csak a fejléc végét keresi meg: a beolvasás közben, a `BytesMut` pufferen fut, és a fejléc hosszát adja vissza.
Ez az elemzés többször is lefuthat, minden hálózati olvasás után elölről indul, amíg a fejléc teljes nem lesz.
Az eredményében kapott szeletek ilyenkor a pufferbe mutatnak, ezért nem tarthatók meg.
Amíg léteznek, kölcsönzik a puffert, így a borrow checker nem engedné meg a fejléc leválasztását végző `split_to` hívást.
Ráadásul a `slice_ref` is csak olyan szeletből készíthet nézetet, amely magába a leválasztott `Bytes` példányba mutat.
A második elemzés ezért már a leválasztott és befagyasztott `head` példányon fut (@lst:fejlec. kódrészlet), és az itt kapott szeletekből készülnek a `Bytes` nézetek.

== Korlátok és védelmek

A beolvasás eddig leírt lépéseit minden ponton korlátok határolják.
A szerver semmit nem feltételez a kliens megbízhatóságáról: a kérés minden adata ellenőrizetlen állítás, amelyet hitelesíteni kell, mielőtt a program erőforrást szánna rá.
Ezért minden kapcsolatra méret- és időkorlátok vonatkoznak (@tbl:korlatok. táblázat).
A két méretkorlát a `ServerBuilder`-en állítható, a többi érték a könyvtár publikus konstansa.

#figure(
  table(
    columns: (1fr, auto, auto),
    table.header[Korlát][Érték][Túllépéskor],
    [`max_head_bytes`: a kéréssor és a fejlécek mérete], [16 KiB], [`431 Request Header Fields Too Large`],
    [`MAX_HEADERS`: a fejlécek száma], [64], [`400 Bad Request`],
    [`max_body_bytes`: a törzs mérete], [1 MiB], [`413 Payload Too Large`],
    [`IDLE_TIMEOUT`: várakozás a következő kérésre], [5 s], [a kapcsolat bontása],
    [`CONNECTION_TIMEOUT`: egy kérés beolvasása vagy egy válasz kiírása], [30 s], [a kapcsolat bontása],
  ),
  caption: [A szerver korlátai],
) <tbl:korlatok>

=== A törzs hossza

A legkényesebb ilyen állítás a törzs hossza, hiszen ettől függ, hol ér véget az aktuális kérés, és hol kezdődik a következő.
Ezt az értéket a `content_length` függvény határozza meg a @tbl:hossz. táblázatban látható szabályok alapján, szigorúan a felsorolás sorrendjében haladva.

#figure(
  table(
    columns: 2,
    table.header[Feltétel][Eredmény],
    [van `Transfer-Encoding` fejléc], [`501 Not Implemented`],
    [nincs `Content-Length` fejléc], [nincs törzs (a hossz 0)],
    [több `Content-Length` fejléc van], [`400 Bad Request`],
    [az érték nem szám], [`400 Bad Request`],
    [az érték nagyobb a `max_body_bytes` korlátnál], [`413 Payload Too Large`],
    [egyébként], [a törzs hossza az érték],
  ),
  caption: [A törzs hosszának meghatározása],
) <tbl:hossz>

A szabályok a request smuggling támadások ellen védenek: ha két fél -- például egy fordított proxy és a mögötte álló szerver -- máshol látja egy kérés végét, a törzs maradékából az egyikük szemében új, ellenőrizetlen kérés lesz.
A szerver ezért kétértelmű helyzetben nem választ a lehetséges értelmezések közül, hanem elutasítja a kérést.
A `Transfer-Encoding` fejlécet ugyanezért nem hagyhatja figyelmen kívül, bár nem kezeli: ha nem venné észre, rossz helyen látná a kérés végét.
A méretkorlát ellenőrzése még a törzs beolvasása előtt megtörténik, így a túl nagy méretet bejelentő kérésre a szerver azonnal választ küld, és egyetlen bájtot sem vár meg a törzsből.

=== Időkorlátok

Egy kliens úgy is lekötheti a szerver erőforrásait, hogy egyáltalán nem küld adatot, vagy csak nagyon lassan csepegteti azt.
Erre épülnek a Slowloris típusú támadások.
A kapcsolatot kiszolgáló ciklus ezért minden hálózati várakozást időkorláttal futtat: a művelet és egy időzítő versenyez egymással, és ha az utóbbi jár le előbb, a szerver válasz nélkül lezárja a kapcsolatot.
A rövid tétlenségi időkorlát (`IDLE_TIMEOUT`) a következő kérés első bájtjára való várakozásra, a hosszabb kapcsolati időkorlát (`CONNECTION_TIMEOUT`) a már megkezdett kérés beolvasására és a válasz kiírására vonatkozik.

A két állapotot a `wait_for_request` metódus választja el egymástól.
Ez megvárja a következő kérés első bájtjának megérkezését -- vagy pipelining esetén azonnal visszatér, ha a pufferben már van feldolgozatlan adat --, és csak ezután indul el a kérés beolvasása.
Tétlen várakozás két helyzetben fordul elő: közvetlenül a kapcsolat felépülése után, valamint keep-alive működésnél két egymást követő kérés között.
Az előbbi gyakori, mert a böngészők előre nyitnak tartalék kapcsolatokat, amelyeket később nem feltétlenül használnak fel.
Egy néma kapcsolat csak feleslegesen foglalja az erőforrásokat, ezért erre elég egy rövid türelmi idő.

Ha viszont a kliens már megkezdte a küldést, egy lassabb hálózaton egy nagyobb törzs feltöltéséhez több időre is szüksége lehet.
Mivel a 30 másodperces korlát a kérés egészére vonatkozik, nem pedig az egyes olvasási műveletekre, egy bájtonként csepegtető kliens sem tarthatja ennél tovább nyitva a kapcsolatot egy kérés ürügyén.
Az időzítő minden új kérés kezdetekor újraindul, így egy aktív kapcsolat tetszőleges ideig életben maradhat, amíg két kérés között nem telik el 5 másodpercnél hosszabb szünet (@fig:idovonal. ábra).

#figure(
  block(width: 100%, inset: 1em, stroke: 0.5pt + gray, {
    set text(size: 9pt)
    let idle = rgb("#cfe0f1")
    let busy = rgb("#f6dcc0")
    let state(fill, name, limit) = rect(
      width: 100%,
      radius: 3pt,
      fill: fill,
      stroke: 0.5pt + gray,
    )[#name \ #text(size: 8pt, style: "italic", limit)]
    let step(label) = [#text(size: 7pt, label) \ #sym.arrow.r.long]
    let gap = 4em
    layout(size => {
      let state-width = (size.width - 3 * gap) / 4
      grid(
        columns: (state-width, gap) * 3 + (state-width,),
        align: center + horizon,
        state(idle)[várakozás][legfeljebb 5 s],
        step[első bájt],
        state(busy)[a kérés beolvasása][legfeljebb 30 s],
        step[kérés kész],
        state(luma(225))[a kezelő fut][nincs időkorlát],
        step[válasz kész],
        state(busy)[a válasz kiírása][legfeljebb 30 s],
        grid.cell(colspan: 7, pad(x: state-width / 2)[
          #box(width: 100%, height: 10pt, stroke: (left: 0.5pt, right: 0.5pt, bottom: 0.5pt))[
            #place(dx: -3.5pt, dy: -3.5pt, text(size: 7pt)[▲])
          ]
          #text(size: 8pt)[keep-alive esetén a ciklus a következő kéréssel újraindul]
        ]),
      )
    })
  }),
  kind: image,
  caption: [Egy kapcsolat kiszolgálásának ciklusa és az időkorlátok],
) <fig:idovonal>

=== A memóriahasználat

A fejléc méretét a szerver nemcsak a kész fejlécen, hanem olvasás közben is ellenőrzi: ha a puffer már nagyobb a korlátnál, de a fejléc még mindig nem teljes, a kérést elutasítja.
Így egy véget nem érő fejléc a puffert legfeljebb egy olvasásnyival növelheti a korlát fölé.
A fejlécek számának korlátja a `httparse` működéséből adódik: az elemző egy előre megadott méretű, a veremben lévő tömbbe gyűjti a fejléceket, így maga az elemzés nem foglal memóriát.

A bejelentett törzshosszt a memóriafoglalásnál sem fogadom el feltétel nélkül.
Bár kézenfekvő volna a beolvasás előtt egyszerre lefoglalni a teljes `Content-Length` méretű területet, ezt szándékosan elkerülöm.
Egy támadó ugyanis bejelenthetne egy éppen a korlát alatti törzset, majd küldés nélkül várakozna, és így néhány bájtnyi fejléccel kapcsolatonként a teljes törzskorlátnak megfelelő memóriát köthetne le a kapcsolati időkorlát lejártáig.
Sok párhuzamos kapcsolaton keresztül ez már kis hálózati forgalommal is kimerítheti a szerver memóriáját, ami a Slowloris-támadás egy változata.
Előzetes foglalás nélkül a puffer csak a ténylegesen megérkezett bájtokkal együtt növekszik, így a szerver legfeljebb annyi memóriát használ fel, amennyi adatot a kliens valóban elküldött.
Hátránya, hogy egy nagyobb törzs beolvasása közben a puffert többször is újra kell foglalni.

Az összes korlát kapcsolatonként érvényes: az egyidejűleg nyitott kapcsolatok számát a szerver nem korlátozza, hanem minden elfogadott kapcsolathoz feltétel nélkül elindít egy új taskot.
Legrosszabb esetben a memóriaigény így a párhuzamos kapcsolatok számának és a kapcsolatonkénti fejléc- és törzskorlát összegének szorzata, amelynek nincs felső határa.
Belső hálózaton vagy egy fordított proxy mögött -- amely a kapcsolatok számát is korlátozhatja -- ez kevésbé kritikus.
Közvetlenül a nyilvános internetre kitett szerveren azonban egy globális kapcsolatszám-korlát többet érne bármelyik meglévő paraméter finomhangolásánál.

== A válasz kiírása

A válaszok hálózatra írásáról a `RequestReader` párja, a kapcsolatonként egy példányban létező `ResponseWriter` gondoskodik.
A kimenet egy `Vec<u8>` pufferben áll össze, amely a bejövő pufferhez hasonlóan a kapcsolat végéig él.
Minden új válasz összeállítása előtt kiürítem, ami lenullázza a tárolt adatok hosszát, de megőrzi a már lefoglalt kapacitást -- így egy keep-alive kapcsolaton az első válasz után jellemzően már nincs szükség újabb memóriafoglalásra.
Az összeállítás elején a puffert egyszerre bővítem a várható méretre (a törzs hosszára, valamint a státuszsor és a fejlécek becsült keretére), elkerülve ezzel a többszöri újrafoglalást írás közben.

A kimeneti bájtfolyamba sorban bekerül a státuszsor, a kezelő által visszaadott fejlécek, a szerver által generált `Content-Length` és `Connection` mezők, az elválasztó üres sor, végül pedig maga a törzs.
Az üzenet keretezését meghatározó fejléceket (`Content-Length`, `Transfer-Encoding`) és a `Connection` fejlécet a kezelő nem bírálhatja felül: ha ezek szerepelnek a visszaadott válaszban, a szerver kihagyja őket.
A `Content-Length` értékét mindig a törzs tényleges hosszából, a `Connection` fejlécet pedig a kapcsolat megtartásáról hozott saját döntéséből állítja elő.
Így kizárható, hogy a kezelő más méretet jelentsen be, mint amennyit a szerver valójában elküld, és a kliens emiatt rossz helyen vágja el a választ.

A teljes üzenet egyetlen írási művelettel jut ki a hálózatra, ezért a törzs is bemásolódik a pufferbe, akkor is, ha a kezelő másolás nélkül, például statikus adatként adta át.
Ez válaszonként egy másolással jár, és a puffer kapacitása a kapcsolat végéig akkora marad, amekkorát a legnagyobb addigi válasz megkövetelt.

A `HEAD` kérésekre a szervernek pontosan ugyanazt a fejlécet kell küldenie, mint a megfelelő `GET` kérésre.
Ennek biztosításához a kezelő meghívása előtt a kérés metódusát `GET`-re cserélem, a válasz kiírásakor pedig egyszerűen elhagyom a törzset, miközben a `Content-Length` fejlécben meghagyom annak valódi hosszát.
Így az alkalmazásnak nem kell külön foglalkoznia a `HEAD` metódussal, és garantált, hogy a két válasz fejléce sosem tér el egymástól.
Hátránya, hogy a kezelő a `HEAD` kéréseknél is előállítja a teljes törzset, amelyet a szerver végül nem küld el.

== Hibakezelési elvek

=== A hibák csoportjai

A kapcsolat kiszolgálása közben felmerülő hibákat egy belső `Error` enum írja le, amely nem része a könyvtár publikus felületének.
Az ilyen hibák sosem jutnak el a szerver hívójáig: mindig az adott kapcsolat lezárásával végződnek, a többi kapcsolatot pedig nem érintik.

A belső hibákat a `client_status` metódus két csoportra osztja: minden hibaváltozathoz vagy egy HTTP-státuszkódot rendel, vagy üres értéket ad vissza.
- *Protokollhibák:* A kliens hibás formátumú vagy a méretkorlátokat túllépő kérést küldött, maga a hálózati kapcsolat azonban még él.
  Ilyenkor a szerver egy törzs nélküli státuszválaszt küld, hogy a kliens értesüljön az elutasítás okáról: a korlátok és a törzs hossza miatti elutasításoknál a @tbl:korlatok. és a @tbl:hossz. táblázatban szereplő kódot, a hibás formátumú kérésre `400 Bad Request`-et.
  A hibaüzenet elküldése után a szerver lezárja a kapcsolatot, hiszen egy hibásan keretezett kérés után már nem állapítható meg biztosan, hol kezdődik a következő.
- *Átviteli hibák:* Ha a hálózati művelet hiúsul meg, vagy a kliens a kérés közben bontja a kapcsolatot, már nincs kinek választ küldeni, így a szerver csendben lezárja a kapcsolatot.

=== Programhibák és pánik

Azt is el kellett döntenem, hogyan kezelem azokat az állapotokat, amelyek helyes működés mellett elvileg nem fordulhatnak elő.
Ahol ezt a helyi logika vagy egy külső könyvtár dokumentált garanciája biztosítja, `unwrap` hívást használok, mellette egy rövid megjegyzéssel az indoklásról.
Ilyen például a memóriában lévő `Vec` pufferbe történő írás, amely nem hiúsulhat meg, vagy a `httparse` sikeres elemzése, amely garantáltan kitölti a metódust, az útvonalat és a verziót.
Ezzel szemben ahol a feltétel teljesülése egy másik függvény viselkedésén múlik -- és egy későbbi módosítás észrevétlenül elronthatja --, ott a `?` operátorral továbbadom a hibát.
Így kezelem például a fejléc második elemzésének hibáját is: ez elvileg nem fordulhat elő, hiszen a hívó pontosan az első elemzés által kimért bájtokat vágta le, de ha egy későbbi változtatás miatt az elemző mégis hibát jelezne, a kliens szabályos `400`-as választ kap.
A `?` operátort viszont nem használom gépiesen mindenhol.
Olyan elérhetetlen hibaágakat hozna létre, amelyeket egy teszt sem tudna lefedni, ráadásul egy valódi programhibát ártalmatlannak tűnő kliensoldali hibaválaszként rejtene el.
Az `unwrap` ezzel szemben azonnal és egyértelműen jelzi, ha a program egy belső invariánsa sérült.

#pagebreak()

// ---------- Az adatbázisréteg ----------
// terjedelem: kb. 7 oldal

= Az adatbázisréteg

== Követelmények és tervezési szempontok

A HTTP-szerverhez hasonlóan az adatbázisréteget is önálló, alkalmazásfüggetlen könyvtárként írtam meg, és `tiny-database` néven a crates.io-n közzétettem (@tiny-database).
A könyvtár típusos rekordokat tárol egyetlen fájlban, mindegyiket egy `u64` azonosító alatt, amelyet a hívó választ meg.
A rekordok az azonosítójuk mellett másodlagos indexeken keresztül is lekérdezhetők: egy index egyenlőségre, értéktartományra és sztringek esetén előtagra is kereshető.
A tárolást a `redb` beágyazott kulcs--érték tároló (@redb), a rekordok bájtokká alakítását az `rkyv` (@rkyv) végzi.

Szándékosan kimaradt minden, ami egy általános adatbázis-kezelőt jellemez, de egy kis alkalmazáshoz nem szükséges: nincs lekérdezőnyelv, táblák közötti összekapcsolás (join), egyediségi megkötés és sémaverzió sem.
Ha egy lekérdezés több feltételt tartalmaz, a hívó egy indexből kéri le a jelölteket, a többi feltételt pedig a visszakapott rekordokon ellenőrzi.

A `Database` típus egyetlen mezője a `redb` adatbázis-objektuma, saját állapota nincs.
Az író metódusok is csak megosztott referenciát (`&self`) kérnek, mert az író tranzakciók sorba állításáról a `redb` gondoskodik.
Így a `Database` szálak között `Mutex` nélkül megosztható, és közvetlenül a HTTP-szerver kezelőjének állapotába tehető, amelyet a szerver összes munkaszála párhuzamosan használ.

== Rekordok és indexek

=== A táblák felépítése

A `redb` adatbázisfájljában minden rekordtípushoz egy sortábla és indexenként egy-egy indextábla tartozik.
A sortábla kulcsa a rekord azonosítója, értéke pedig a rekord `rkyv`-vel szerializált bájtjai.
Az indextáblák neve a sortábla és az index nevéből áll össze, ponttal elválasztva (például `users.name`), és fordított leképezést valósítanak meg: a mező kódolt értékéhez az azt tartalmazó rekordok azonosítóit rendelik.
Mivel egy érték több rekordban is előfordulhat, az indextáblák a `redb` multimap tábláira épülnek.

A @tbl:tablak. táblázat egy `User` típus négy rekordját mutatja a név, az életkor és a címkék szerinti indexekkel.
Egy indexelt lekérdezés két lépésben zajlik: a könyvtár először az indextáblából kikeresi a kulcshoz tartozó azonosítókat, majd ezek alapján a sortáblából betölti a rekordokat.

#figure(
  stack(
    spacing: 1em,
    table(
      columns: 4,
      table.header[`users` (id)][name][age][tags],
      [1], [Alice], [30], [admin, staff],
      [2], [Bob], [18], [--],
      [3], [Carol], [30], [admin, dev],
      [4], [Alice], [65], [--],
    ),
    grid(
      columns: 3,
      column-gutter: 1em,
      table(
        columns: 2,
        table.header[`users.name`][azonosítók],
        [Alice], [1, 4],
        [Bob], [2],
        [Carol], [3],
      ),
      table(
        columns: 2,
        table.header[`users.age`][azonosítók],
        [18], [2],
        [30], [1, 3],
        [65], [4],
      ),
      table(
        columns: 2,
        table.header[`users.tag`][azonosítók],
        [admin], [1, 3],
        [dev], [3],
        [staff], [1],
      ),
    ),
  ),
  placement: auto,
  caption: [Négy rekord a sortáblában és három indextáblájuk (a kulcsok a kódolás előtti értékükkel)],
) <tbl:tablak>

=== A `Record` trait

Egy tárolható típus és az adatbázisréteg közötti szerződést a `Record` trait rögzíti.
A @lst:user. kódrészlet a @tbl:tablak. táblázat `User` típusának megvalósítását mutatja.
A `TABLE` konstans a sortábla nevét adja meg.
Azért asszociált konstans és nem metódus, mert a tábla nevére példány nélkül is szükség van: egy `get::<User>(1)` hívásnál még nincs rekord, a könyvtárnak mégis tudnia kell, honnan olvasson.
Az `id` a rekord azonosítóját adja vissza; ezt mindig a hívó választja meg, automatikusan növekvő azonosítót a könyvtár nem generál.
Az `index_keys` a rekord indexbejegyzéseit adja vissza index és kódolt kulcs párokként, egy többértékű mező (mint a címkék) minden értékéhez egy-egy párt.
A kulcsok kódolását a következő alfejezet tárgyalja.
A trait szupertraitjei az `rkyv` szerializáló és validáló traitjei, ezeket a `derive` makró adja.

#figure(
  ```rust
  #[derive(Archive, Serialize, Deserialize)]
  struct User { id: u64, name: String, age: u8, tags: Vec<String> }

  enum UserIndex { Name, Age, Tag, NameAge }

  impl Index for UserIndex {
      fn name(&self) -> &'static str {
          match self {
              Self::Name => "name",
              Self::Age => "age",
              Self::Tag => "tag",
              Self::NameAge => "name_age",
          }
      }
  }

  impl Record for User {
      const TABLE: &'static str = "users";
      type Index = UserIndex;

      fn id(&self) -> u64 { self.id }

      fn index_keys(&self) -> Vec<(UserIndex, Vec<u8>)> {
          let mut keys = vec![
              (UserIndex::Name, key::enc(&self.name)),
              (UserIndex::Age, key::enc(self.age)),
              (UserIndex::NameAge, key::enc((&self.name, self.age))),
          ];
          for tag in &self.tags {
              keys.push((UserIndex::Tag, key::enc(tag)));
          }
          keys
      }
  }
  ```,
  placement: auto,
  caption: [A `User` rekordtípus és indexei],
) <lst:user>

Magát a rekordtípust nem a `Database` struktúrán, hanem az egyes műveleteken (`get::<User>`, `insert::<T>`) helyeztem el típusparaméterként.
Így egy adatbázisfájlban többféle rekordtípus is tárolható, és minden művelet a típus `TABLE` konstansa alapján választja ki a táblát.

=== Az indexek típusa

Egy típus indexeit egy `Index` traitet megvalósító enum fogja össze, indexenként egy változattal.
Ha az indexeket sztringek azonosítanák, egy elgépelt név csak futásidőben derülne ki, így viszont fordítási hibát okoz.
Más rekordtípus indexe sem adható át véletlenül: a `find::<User>` csak a `User` saját indextípusát fogadja el.
Mivel a `redb` a táblákat név szerint azonosítja, az `Index` trait `name` metódusa minden változathoz nevet rendel, és ebből képződik az indextábla neve.
Ezt szándékosan kézzel írt `match` adja, és nem a változat nevéből származik: így egy átnevezés a kódban nem változtatja meg észrevétlenül a fájlban tárolt táblanevet, a `match` kimerítő vizsgálata pedig garantálja, hogy új változat sem maradhat név nélkül.
Az index nélküli típusokhoz a könyvtár egy változatok nélküli `NoIndex` enumot ad.

A pont elválasztó szerepe miatt sem a tábla, sem az index neve nem tartalmazhat pontot, különben két különböző index táblája azonos nevet kaphatna.
A táblanevet a könyvtár fordítási időben ellenőrzi, az index nevét futásidőben, minden használatkor, így egy hibás név már az első használatkor `InvalidIndexName` hibát ad.

== Rendezéstartó kulcskódolás

Az indextáblák kulcsai nyers bájtsorozatok, amelyeket a `redb` bájtról bájtra, balról jobbra haladva hasonlít össze.
Egyenlőségkereséshez elég lenne, ha azonos érték mindig azonos bájtokat adna, a tartománylekérdezés viszont az indextábla egy összefüggő szakaszát járja be, ezért a bájtok sorrendjének meg kell egyeznie az értékek természetes sorrendjével.
A rekordok `rkyv`-vel szerializált bájtjai ezt nem teljesítik, ezért a kulcsokat a `key` modul `enc` függvénye külön kódolja; ezt használja az `index_keys` metódus és a lekérdezések is.
A kódolás a fájlformátum része, így bármilyen későbbi módosítása érvénytelenítené a meglévő indextáblákat.

=== Számok

Az egész számok natív -- a legtöbb architektúrán little-endian -- ábrázolása önmagában nem rendezéstartó, mivel ebben a legkisebb helyiértékű bájt áll elöl.
A @tbl:endian. táblázat bal oldalán látható, hogy egy `u16` mező 18, 256 és 300 értékei a natív bájtjaik alapján 256, 18, 300 sorrendbe kerülnének, így egy 0 és 100 közötti tartománylekérdezés mindhárom rekordot visszaadná.
Az `enc` ezért az előjel nélküli egészeket big-endian sorrendben kódolja, ahol a legnagyobb helyiértékű bájt kerül előre, így a bájtok sorrendje megegyezik a számok nagyságrendjével.
#figure(
  table(
    columns: 4,
    table.header[Natív bájtok][Érték][`enc` bájtjai][Érték],
    [`00 01`], [256], [`00 12`], [18],
    [`12 00`], [18], [`01 00`], [256],
    [`2C 01`], [300], [`01 2C`], [300],
  ),
  caption: [Egy `u16` mező értékei a bájtjaik szerint rendezve],
) <tbl:endian>

Az előjeles egészeknél a kettes komplemens ábrázolás jelent akadályt: mivel a negatív számok legfelső bitje 1, bájtként összehasonlítva a pozitív számok mögé kerülnének.
Ennek kiküszöbölésére az `enc` a big-endian bájtokban megfordítja az előjelbitet, így például a `-1i8` kódja `7F`, a `0i8` kódja pedig `80` lesz.
A lebegőpontos számoknál más a gond: az IEEE 754 előjelbitből és abszolút értékből álló ábrázolásában a pozitív számok bitmintái már helyes sorrendben vannak, a negatívaké viszont fordítottban, mert ott a nagyobb abszolút értékhez nagyobb bitminta tartozik.
Ezért pozitív számnál csak az előjelbitet fordítom meg, negatívnál az összes bitet, így a negatív számok a pozitívak elé, egymás között pedig helyes sorrendbe kerülnek.

A kódolás hossza és formátuma a típustól függ: az `enc(18u8)` egyetlen bájtot, míg az `enc(18u32)` négy bájtot eredményez.
Ha az `index_keys` és a lekérdezés eltérő típusként kódolja ugyanazt az értéket, a keresés hibaüzenet nélkül üres eredménnyel tér vissza, ezért a számliterálokat mindig típusutótaggal kell írni (`18u8`).
A `usize` és az `isize` típusokhoz szándékosan nem tartozik kódolás: a méretük platformfüggő, így egy 64 bites rendszeren írt adatbázisfájl kulcsai egy 32 bites gépen nem egyeznének az újonnan kódoltakkal.

=== Sztringek

A sztringek és a bájtszeletek változó hosszúságúak, ezért a kódolásuknak azt is jeleznie kell, hol érnek véget.
Erre akkor van szükség, ha egy összetett kulcs több egymás után fűzött mezőből áll: végjel nélkül például a `("a", "bc")` és az `("ab", "c")` pár ugyanazt a `61 62 63` bájtsorozatot adná.
A hossz előreírása sem megoldás, mert akkor az határozná meg a rendezést, így a `"b"` az `"ab"` elé kerülne.
Az `enc` ezért minden sztring végére `00 01` lezárót ír.
A `00` a legkisebb bájtérték, így a rövidebb sztring mindig megelőzi a folytatását (az `"a"` az `"ab"` elé kerül).
Egy Rust-sztring viszont maga is tartalmazhat `00` bájtot, amely hamis végjelnek látszana, ezért ezeket `00 FF` sorozatra cserélem.
A `00` után így mindig a következő bájt dönti el, hogy a sztring véget ért (`01`), vagy valódi nulla bájt következik (`FF`).
Mivel a `01` kisebb az `FF`-nél, a lezárt sztring itt is a folytatódó elé kerül (@tbl:sztring. táblázat).

#figure(
  table(
    columns: 2,
    table.header[Érték][`enc` bájtjai],
    [`"a"`], [`61 00 01`],
    [`"a\0"`], [`61 00 FF 00 01`],
    [`"ab"`], [`61 62 00 01`],
    [`"b"`], [`62 00 01`],
  ),
  caption: [Sztringek kódolása a bájtjaik szerint rendezve],
) <tbl:sztring>

=== Összetett kulcsok és előtagok

Mivel a számok kódolása rögzített hosszúságú, a sztringeké pedig végjellel zárul, egyetlen érték kódolása sem lehet egy másik, azonos típusú érték kódolásának előtagja.
Ezért több mező kódolása egyszerűen egymás után fűzhető: az `enc` legfeljebb négyelemű tuple-öket is elfogad, és a tagok kódolását összefűzve összetett kulcsot képez.
Az `("Alice", 30u8)` kódja például `41 6C 69 63 65 00 01 1E`, amelyben a név lezárója után közvetlenül az életkor bájtja áll.
Egy ilyen index először az első, azon belül a második mező szerint rendezett, és egy tartománylekérdezés ebben a sorrendben járja be a két határ közötti kulcsokat (@lst:osszetett. kódrészlet).
Ha az első mező mindkét határon azonos, a lekérdezés egy név rekordjait szűri életkor szerint.
Ha eltér, a két határ közötti összes kulcsot visszaadja, név, azon belül életkor szerint rendezve.

#figure(
  ```rust
  // "Alice", 18 és 30 év között
  let range = key::enc(("Alice", 18u8))..=key::enc(("Alice", 30u8));
  db.range::<User>(UserIndex::NameAge, range)?;

  // "Alice", bármilyen életkorral
  let range = key::enc(("Alice", u8::MIN))..=key::enc(("Alice", u8::MAX));
  db.range::<User>(UserIndex::NameAge, range)?;

  // ("Alice", 18)-tól ("Carol", 30)-ig, a köztes nevek
  // (például "Bob") minden életkorával együtt
  let range = key::enc(("Alice", 18u8))..=key::enc(("Carol", 30u8));
  db.range::<User>(UserIndex::NameAge, range)?;
  ```,
  caption: [Lekérdezések a `NameAge` összetett indexen],
) <lst:osszetett>

A sztringek kódolási módja az előtagra történő keresést is lehetővé teszi, amelyet a `prefix_range` függvény valósít meg.
A tartomány alsó határa a kódolt előtag lezáró nélkül, a felső határa pedig ugyanez egy `FF` bájttal kiegészítve: a `prefix_range("Al")` például a `41 6C`-tól a `41 6C FF`-ig tart, az utóbbit már nem tartalmazva.
Egy ilyen előtaggal kezdődő sztring kódolásában az előtag után UTF-8 bájt, kódolt nulla bájt (`00 FF`) vagy lezáró (`00 01`) következik.
Ezek első bájtja mind kisebb az `FF`-nél, amely érvényes UTF-8 szövegben sosem fordul elő, így a tartományba az `"Al"` és az `"Alice"` kódolása beleesik, a `"Bob"` és az `"A"` kódolása viszont nem.

== Írás és törlés <sec:iras>

=== Tranzakciók

Rekordokat az `insert` és az `insert_many` metódussal lehet menteni: az előbbi egy rekordot, az utóbbi tetszőleges számút ír ki egyetlen tranzakcióban, az indexbejegyzéseikkel együtt.
Az `insert` csak egy egyelemű tömbbel hívja meg az `insert_many`-t, így a beszúrás logikája egy helyen van.
Külön frissítő művelet (update) nincs: ha az azonosító már foglalt, az új rekord felülírja a régit.
Törölni a `delete` és a `delete_many` metódussal lehet, az utóbbi azt is visszaadja, hogy a megadott azonosítók közül hány létezett.

Az `insert_many` létjogosultságát a tranzakciók lezárásának költsége adja.
A `redb` a `commit` hívásakor lemezre szinkronizálja a fájlt, hogy a véglegesített adatok egy áramszünetet is túléljenek, és ez az írás leglassabb lépése.
Ha a hívó sok rekordot egyesével szúr be, minden rekord után külön szinkronizálás történik, az `insert_many` viszont az egész köteget egyetlen `commit` hívással véglegesíti.

Minden író metódus pontosan egy író tranzakciót nyit, így a módosítások vagy mind érvényre jutnak, vagy egyik sem.
Ehhez nem kellett külön visszagörgetést (rollback) írni: ha egy részművelet hibát ad, a `?` operátor még a `commit` előtt kilép a függvényből, a tranzakció véglegesítés nélkül megsemmisül, és a `redb` eldobja a függőben lévő módosításokat.
Így a fájlban nem maradhat indexbejegyzések nélküli rekord, és egy félbeszakadt `insert_many` sem hagy maga után részleges állapotot.

=== Az indexek frissítése

Felülíráskor az indexeket is naprakészen kell tartani.
Ha a könyvtár csak a sortábla bejegyzését cserélné le, egy névváltozás után a `users.name` táblában a régi név alatt is ott maradna a rekord azonosítója, és a keresések hibás találatot adnának.
A régi rekord indexbejegyzéseit sehol nem tárolom külön: a `redb` beszúráskor visszaadja a felülírt sort, a könyvtár ezt dekódolja, és az `index_keys` metódusából állapítja meg a régi kulcsokat.
Ezután összeveti a régi és az új kulcslistát, és csak a különbséget hajtja végre: a csak a régiben szereplő bejegyzéseket törli, az újakat beszúrja, a közöseket érintetlenül hagyja.
Mivel egy módosítás jellemzően egy-két mezőt érint, az indextáblák nagy része változatlan marad.
Ha például a @tbl:tablak. táblázat 1-es rekordjában az életkor 30-ról 31-re változik, a `users.age` és a `users.name_age` táblában egy-egy bejegyzés törlődik és egy új keletkezik, a `users.name` és a `users.tag` táblához pedig hozzá sem kell nyúlni.

Törléskor ugyanígy a törölt sort kell dekódolni, mert csak az `index_keys` metódusából derül ki, mely indexbejegyzéseket kell vele együtt eltávolítani.
Ennek két következménye van: egyrészt minden felülírás és törlés a régi rekord validálásával és deszerializálásával jár, másrészt egy megsérült sort a publikus API-n keresztül sem felülírni, sem törölni nem lehet, mert a dekódolása `Corrupt` hibát ad.

== Olvasás

=== Lekérdezések

Az olvasó műveletek közül a `get` azonosító alapján kér le egy rekordot, az `all` pedig a típus összes rekordját adja vissza, azonosító szerint növekvő sorrendben.
A `contains` és a `count` a rekordok betöltése nélkül válaszol: az előbbi azt ellenőrzi, létezik-e sor a megadott azonosítóval, az utóbbi a sortábla elemszámát kérdezi le.
Az indextáblákon a `find` egy kulcsra, a `range` egy kulcstartományra keres.
A `find` valójában olyan tartománylekérdezés, amelynek alsó és felső határa megegyezik, ezért a két metódus ugyanazt az indexbejárást használja, amely három lépésből áll:
1. *Azonosítók gyűjtése:* A könyvtár összegyűjti az indextábla megadott tartományába eső azonosítókat, elsődlegesen a kulcs, azon belül az azonosító szerint rendezve.
2. *Ismétlődések kiszűrése:* Többértékű mezőknél ugyanaz a rekord több kulcs alatt is szerepelhet, ezért a duplikátumokat el kell távolítani.
  A @tbl:tablak. táblázat példájánál maradva egy „a”-tól „e”-ig terjedő tartománylekérdezés a `users.tag` indexen az `admin` és a `dev` kulcs alatt is megtalálja a 3-as rekordot, a végeredményben azonban csak egyszer, a legkisebb kulcsánál jelenik meg.
  Egyetlen kulcson belül a `redb` multimap táblája eleve garantálja az azonosítók egyediségét, ezért a `find` ezt a lépést kihagyja.
3. *Rekordok betöltése:* A könyvtár a megmaradt azonosítók sorrendjében kiolvassa és deszerializálja a sorokat a sortáblából.

Minden lekérdezés egyetlen olvasó tranzakcióban fut, amely a `redb` pillanatkép-izolációja miatt az adatbázis egy rögzített állapotát látja, így az indextábla és a sortábla a bejárás alatt végig összhangban van.
Ha egy indexbejegyzés ennek ellenére nem létező rekordra mutat, az nem egy egyidejű törlés következménye, hanem sérült fájlé vagy elmaradt index-újraépítésé (lásd a @sec:sema alfejezetet), ezért a könyvtár ilyenkor `Corrupt` hibát ad.

A lekérdezések egy kész `Vec`-et adnak vissza, nem iterátort.
Egy iterátornak ugyanis kölcsönöznie kellene az olvasó tranzakciót, így a hívónak a feldolgozás végéig életben kellene tartania azt, és a tranzakció élettartam-paramétere a publikus API-ban is megjelenne.
Ennek ára, hogy a teljes találati lista egyszerre kerül a memóriába, és beépített lapozás sincs.

=== Zero-copy olvasás

Az eddigi olvasó metódusok minden találatot saját tulajdonú rekorddá deszerializálnak, vagyis minden sztringjét és vektorát új memóriaterületre másolják akkor is, ha a hívónak csak egy mezőre van szüksége.
Az `rkyv` ezt elkerülhetővé teszi: a tárolt bájtok archivált formában (például `ArchivedUser` típusként) közvetlenül olvashatók, és ebben egy sztring mező `&str`-ként érhető el.
Ezért a `get`, a `find`, a `range` és az `all` mellett mindegyiknek van egy zero-copy változata is (`view`, `view_find`, `view_range`, `view_all`), amely az archivált rekordot adja át a hívónak (@tbl:view. táblázat).

Az archivált rekord a `redb` lapjának bájtjaira mutat, ezért csak addig érvényes, amíg az olvasó tranzakció nyitva van.
A `view*` metódusok ezért egy closure-t várnak, és azt még a nyitott tranzakción belül hívják meg az archivált rekorddal.
A `view` a closure visszatérési értékét adja vissza: a `db.view::<User, _>(1, |user| user.name.to_string())` hívás csak a nevet másolja ki a sorból, a többi mezőt fel sem építi.
A `view_find`, a `view_range` és a `view_all` a hagyományos változatokkal azonos sorrendben, rekordonként hívja meg a closure-t, amelynek nincs visszatérési értéke, így az eredményt a hívó egy saját változóba gyűjti:

```rust
let mut names = Vec::new();
db.view_all::<User>(|user| names.push(user.name.to_string()))?;
```

Belül mindkét metóduscsalád ugyanarra a három függvényre épül (`read_row`, `scan_index`, `scan_rows`): a hagyományos változatok egy olyan closure-t adnak át, amely a teljes deszerializálást végzi, így a bejárás logikája csak egyszer szerepel a kódban.

#figure(
  table(
    columns: 3,
    table.header[][`get`, `find`, `range`, `all`][`view`, `view_*`],
    [Eredmény], [saját tulajdonú rekordok], [a closure által kimásolt értékek],
    [Validálás], [igen], [igen],
    [Másolás, foglalás], [minden mező], [csak amit a closure kimásol],
    [A rekord élettartama], [független a tranzakciótól], [csak a closure-ön belül],
  ),
  caption: [A hagyományos és a zero-copy olvasás összehasonlítása],
) <tbl:view>

Az `rkyv` alapértelmezés szerint igazított memóriacímen várja az archivált adatot, a `redb` viszont a lap tetszőleges eltolásáról adja vissza a sor bájtjait, így minden sort előbb egy igazított pufferbe kellene másolni.
Ezért a könyvtár bekapcsolja az `rkyv` `unaligned` feature-jét, amellyel az archivált típusok bármilyen címről olvashatók, így a `view` valóban a `redb` lapjáról olvas.
A Cargo a feature-öket a teljes fordításra egyesíti, ezért ez a beállítás az alkalmazás többi `rkyv`-használatára is érvényes.
Ez fordítva is igaz: a bájtsorrendet és a mutatók szélességét a könyvtár nem rögzíti, így ha az alkalmazás egy másik függősége ezeket átállítja (`big_endian`, `pointer_width_64`), azzal a könyvtár fájlformátuma is megváltozik.

=== Validálás

A lemezről olvasott bájtok nem feltétlenül érvényesek: a fájl megsérülhet, vagy a rekordtípus szerkezete megváltozhatott a kiírás óta.
Ellenőrzés nélkül egy hibás belső eltolás vagy egy érvénytelen UTF-8 sztring memóriahibához vezetne, ezért az `rkyv` validáló `access` függvényét használom, amely a `bytecheck` segítségével minden olvasáskor ellenőrzi, hogy a bájtok érvényes archivált rekordot alkotnak-e.
Hiba esetén a könyvtár a tábla nevét és a sor azonosítóját tartalmazó `Corrupt` hibát ad, így egy sérült rekord kezelhető hibát okoz, nem pedig nem definiált viselkedést.
Ennek ára, hogy a `view*` metódusok is végigellenőrzik a teljes sort (például minden sztring UTF-8 érvényességét): ezek sem ingyenesek, csak a memóriafoglalást és a másolást takarítják meg.

== Sémaváltozás <sec:sema>

A validálás csak a bájtok fizikai felépítését ellenőrzi, a jelentésüket nem.
Ha egy rekordtípus megváltozik, a régi bájtok az új elrendezésben is érvényesnek bizonyulhatnak, és a program hibaüzenet nélkül hibás adatot olvasna.
Mivel a könyvtár sémaverziót nem tárol, a változást a hívónak kell jeleznie, erre két metódus szolgál.

Ha csak az `index_keys` változik, például egy új index kerül a típusba, a meglévő indextáblák még a régi kulcsokat tartalmazzák.
Ilyenkor a `rebuild_indexes` metódust kell meghívni, amely egy tranzakcióban eldobja a típus összes indextábláját, majd a tárolt rekordokból újraépíti őket.
Ezt a típus minden további írása előtt meg kell tenni, mert a felülírás és a törlés a régi bejegyzéseket az aktuális `index_keys` alapján keresi meg (lásd a @sec:iras alfejezetet).
Enélkül a könyvtár az új kulcsokat próbálná törölni, a régiek pedig árva bejegyzésként a fájlban maradnának: hibás találatot adnának, vagy ha a rekordjuk közben törlődött, `Corrupt` hibát okoznának.

Ha a rekordtípus szerkezete változik, a `migrate::<Old, New>` metódust kell lefuttatni.
Az `Old` a típus korábbi definíciója, amelyet a hívó a migráció idejére megtart a kódjában.
A metódus a tárolt rekordokat `Old`-ként olvassa be, a hívó átalakító függvényével `New` típusúvá alakítja, majd az új indexbejegyzésekkel együtt visszaírja őket.
Ez is egy tranzakcióban zajlik, így vagy minden rekord átalakul, vagy egyik sem.

== Hibakezelés

A könyvtár minden művelete a saját, a `thiserror` makrójával definiált `Error` típusával tér vissza.
A redb különféle hibái egy-egy változatba csomagolva jutnak el a hívóhoz, a könyvtár saját hibái pedig a `Corrupt`, amely a sérült sor tábláját és azonosítóját tartalmazza, az `InvalidIndexName`, ha egy index neve pontot tartalmaz, és az `Encode`, ha egy rekord nem szerializálható.
Az enum `#[non_exhaustive]`, így egy későbbi alverzióban új változat is felvehető anélkül, hogy a hívók kódja eltörne.

Egy esetet szándékosan nem kezelek hibaként.
A `redb` egy táblát csak akkor hoz létre, amikor egy író tranzakció először megnyitja, így egy friss adatbázisban az olvasás még nem létező táblát próbál megnyitni.
Ez egy új fájlnál vagy egy még nem használt indexnél normális állapot, ezért a könyvtár csak ezt a hibát alakítja üres eredménnyé: a `get` ilyenkor `None`-t, a `contains` hamisat, a listázó lekérdezések üres vektort, a `count` pedig nullát ad.
Minden más táblanyitási hiba, például ha a név alatt más típusú tábla szerepel, változatlanul jut el a hívóhoz.

#pagebreak()

// ---------- A bemutató alkalmazás ----------
// terjedelem: kb. 5,5 oldal

= A bemutató alkalmazás

== Az alkalmazás célja és felépítése

=== Cél és útvonalak

A két könyvtár használhatóságát a `repub` nevű alkalmazással mutatom be (@repub).
Ez egy publikus weboldal, amely egy könyvtár (mappa) EPUB-fájljait teszi kereshetővé és letölthetővé: a könyvek között metaadataik, például cím, szerző vagy kiadási év szerint lehet keresni, mindegyiknek saját oldala van a borítójával és a részleteivel, és innen maga a fájl is letölthető.
Az oldal útvonalait a @tbl:utvonalak. táblázat foglalja össze.
Minden oldal kétféle formában érhető el: a böngésző HTML-t kap, minden más kliens, például a curl vagy egy szkript, ugyanazon az útvonalon JSON-t.

#figure(
  table(
    columns: (1fr, 1fr),
    table.header[Útvonal][Válasz],
    [`GET /`], [a keresőűrlap],
    [`GET /search?title=…&author=…`], [a feltételeknek megfelelő könyvek listája],
    [`GET /book?id=<id>`], [egy könyv oldala],
    [`GET /cover?id=<id>`], [egy könyv borítóképe],
    [`GET /download?id=<id>`], [egy könyv EPUB-fájlja],
    [`GET /style.css`], [az oldalak közös stíluslapja],
    [`GET /health`], [a szerver állapota],
  ),
  caption: [A bemutató alkalmazás útvonalai],
) <tbl:utvonalak>

Az alkalmazás az egyetlen rész, amely az EPUB formátumhoz kötődik: a HTTP-szerver és az adatbázisréteg semmit sem tud a könyvekről.
Az alkalmazáson belül is csak egyetlen modul olvas EPUB-fájlt, a többi már az adatbázisban tárolt rekordokkal dolgozik.

=== Modulok és a kérés útja

#par(first-line-indent: 0em)[Az alkalmazást a következő modulokra bontottam:]

- `app`: a parancssori kapcsolók, a naplózás és az indítás;
- `library`: az EPUB-fájlok beolvasása és indexelése az adatbázisba;
- `router`: az útvonalak, vagyis minden útvonal és a hozzá tartozó oldal egy helyen;
- `pages`: az oldalak, amelyeknek HTML és JSON formájuk is van;
- `files`: a borítókép, a letöltés és a stíluslap, amelyeknek csak egy formájuk van;
- `reply`: a végpontok eredményét a `Reply` trait alakítja válasszá: a `None`-ból 404-es oldal, a hibából naplózás után 500-as oldal lesz, így minden hiba egy helyen végződik.

#h(1.5em)

Induláskor az `app` modul először a `library` segítségével felépíti az adatbázist, majd elindítja a szervert.
A szerver kezelője maga a `Router` típus, amely a @lst:handler. kódrészletben bemutatott `Handler` traitet valósítja meg, és állapotként az adatbázist és a könyvek mappájának útvonalát tárolja.
A `handle` metódus az `Accept` fejlécből meghatározza a válasz formáját, majd a metódus, az útvonal és az `id` paraméter hármasára illesztve kiválasztja a végpontot.
Ha a metódus nem `GET`, az útvonal ismeretlen, vagy egy könyvhöz kötött útvonalon hiányzik az érvényes `id`, a kliens a „nem található” oldalt kapja.

== A könyvtár indexelése

=== A metaadatok kinyerése

Induláskor, még a szerver elindítása előtt az alkalmazás a könyvek mappájában közvetlenül található összes EPUB-fájlból egy `Book` rekordot készít, és ha a könyvnek van borítóképe, mellé egy `Cover` rekordot is.
A fájlokat az `epub` könyvtár nyitja meg és elemzi, az alkalmazás pedig a könyv szövegét nem olvassa, csak a metaadatai közül veszi át a címet, a szerzőket, a fordítókat, a kiadót, a kiadás évét, a nyelvet, a témaköröket, a leírást és a borítóképet.

Néhány mezőt nem lehet változatlanul átvenni.
A szerzőt és a fordítót ugyanolyan metaadatelem írja le, ezeket egy MARC-szerepkód különbözteti meg (`aut` a szerző, `trl` a fordító), az évet pedig a fájl dátumai közül a kiadáshoz tartozóból veszem.
A cím nélküli könyv sem marad ki, ilyenkor a fájl neve lesz a címe.
A leírás gyakran HTML-kódot tartalmaz, ebből csak a szöveget tartom meg: a címkéket eltávolítom, a felesleges szóközöket pedig összevonom.

=== Az azonosító

A könyv azonosítója a fájlnevének 64 bites FNV-1a hash-e, 53 bitre csonkolva.
Mivel csak a fájlnévtől függ, egy könyv minden újraindításkor ugyanazt az azonosítót kapja, így a rá mutató linkek (`/book?id=…`) is érvényesek maradnak.

Az 53 bites csonkolásra a JSON-válaszok miatt van szükség.
A JavaScript minden számot lebegőpontosan ábrázol, ezért a `Number.MAX_SAFE_INTEGER` ($2^53 - 1$) értéknél nagyobb egészeket már nem tudja pontosan beolvasni, így egy JavaScript-kliens hibás azonosítóval dolgozna.
Ha két fájlnév mégis ugyanazt az azonosítót kapja, a második fájl kimarad, és erről figyelmeztetés kerül a naplóba, különben a második könyv felülírná az elsőt az adatbázisban.

=== Az adatbázis felépítése

A beolvasás előtt az alkalmazás törli az előző futásból megmaradt adatbázisfájlt, így az adatbázis minden induláskor üresen kezd, és teljes egészében a könyvek mappájából épül fel.
Ennek köszönhetően az adatok egyetlen hiteles forrása (single source of truth) maga a fájlrendszer, az adatbázis pedig csak gyorsítótárként szolgál.
Nem kell nyomon követni, hogy az előző futás óta mely fájlok kerültek be, változtak meg vagy törlődtek, és a `Book` típus szerkezetének változásakor sem kell migrációt végrehajtani (lásd a @sec:sema alfejezetet).
Egy sérült vagy olvashatatlan fájl sem akadályozza meg az indulást: az alkalmazás átugorja, és figyelmeztetést ír róla a naplóba.

A rekordok csak a mappa bejárása után kerülnek az adatbázisba, két `insert_many` hívással: egyszer a könyvek, egyszer a borítóképek.
Így a teljes indexelés két tranzakcióból és két fájlszinkronizálásból áll, és nem könyvenként kell egy-egy tranzakciót lezárni.

Végül a `Book` típus kereshetőségét az indexbejegyzései biztosítják.
A szöveges mezők -- a cím, a szerzők, a fordítók, a témakörök és a kiadó -- szavanként kerülnek a saját indexükbe: az alkalmazás minden nem alfanumerikus karakter mentén szavakra bontja az értékeket, majd az egyes szavakat kisbetűsítve és ékezetmentesítve, külön kulcsként tárolja.
A nyelv indexébe csak a nyelvi címke elsődleges része kerül (például `en-US` helyett `en`), az év indexébe pedig maga az évszám.

== Keresés

#todo[a szövegek normalizálása (kisbetű, ékezetek elhagyása) indexeléskor és kereséskor ugyanúgy; szó eleji egyezés a `prefix_range`-dzsel; a jelöltek a legszelektívebb feltétel indexéből jönnek, a többi feltételt memóriában szűri]

== Borítóképek és letöltés

#todo[a borító az EPUB-ból jön, nincs futásidejű képfeldolgozás; külön `Cover` tábla, hogy a listázás ne olvassa a képeket; engedélyezett képtípusok (SVG nem), `nosniff`; a letöltésnél a `view` csak a fájlnevet másolja ki a sorból; `Content-Disposition` (RFC 6266 és 5987)]

== A felhasználói felület

#todo[szerveroldali renderelés JavaScript nélkül; a `Page` trait: a serde adja a JSON-t, a trait a HTML-t, az `Accept` fejléc dönt; a build_html builder mintája, minden EPUB-ból jövő szöveg escape-elve (XSS); saját, osztály nélküli stíluslap a programba fordítva, miért nem Pico.css vagy Simple.css]

== Üzemeltetés

#todo[parancssori kapcsolók; naplózás fájlba és a standard kimenetre; az állapotoldal (`/health`); a release profil]

#pagebreak()

// ---------- Mérések ----------
// terjedelem: kb. 5,5 oldal

= Mérések és kiértékelés

== A mérések módja

#todo[a két könyvtár saját, egyszerű mérőprogramja (egy minimális szerver és egy adatbázis-benchmark), a bemutató alkalmazást nem mérem külön; mérőkörnyezet (gép, OS, Rust verzió); eszközök (wrk, a memóriához RSS); ismétlések száma; a mérések korlátai (egy gép, loopback)]

== A HTTP-szerver

=== A futtatható állomány mérete

#todo[a minimális szerver mérete a fordítási beállítások szerint, halmozva (alap release -> `opt-level` 3/s/z -> LTO -> `codegen-units=1` -> `panic=abort` -> `strip`), táblázat; mely crate-ek mennyit tesznek ki; a méretre optimalizált változat sebessége]

=== Áteresztőképesség és késleltetés

#todo[wrk a kapcsolatok és a szálak számának függvényében; kis és nagy (pl. 1 MiB) válasz]

=== Memóriahasználat

#todo[indításkor, terhelés alatt és tétlen kapcsolatonként]

== Az adatbázisréteg

=== Írás

#todo[`insert` rekordonként és `insert_many` egy tranzakcióban (a commit, vagyis a fájlszinkronizálás költsége)]

=== Olvasás

#todo[a zero-copy `view` és a teljes deszerializálás (`get`) összevetése kis és nagy rekordon; keresés indexszel (`find`, `range`) és a teljes tábla szűrésével (`all` + `filter`)]

#pagebreak()

// ---------- Összefoglalás ----------
// terjedelem: kb. 1,5 oldal

= Összefoglalás

== Elért eredmények

#todo[a kitűzött célok teljesülése a mérések alapján]

== Korlátok

#todo[nincs TLS (reverse proxy mögé való), nincs streamelés (a letöltött fájl is egészben a memóriában), nincs chunked törzs, nincs kapcsolatszám-korlát; az adatbázis lekérdezései teljes listát adnak, lapozás nélkül; a keresés nem rangsorol]

== Továbbfejlesztési lehetőségek

#todo[streamelt válasz nagy fájlokhoz, kapcsolatszám-korlát, HTTP/2, a `view` bejárás idő előtti megállítása, rangsoroló teljes szöveges keresés, ...]

#pagebreak()

// ---------- Irodalomjegyzék ----------

= Irodalomjegyzék

#bibliography("refs.yml", title: none, full: true)

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

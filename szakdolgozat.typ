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
A kérések elemzését az httparse, a protokoll típusait a http könyvtár biztosítja.
Az adattárolásért egy saját adatbázisréteg felel, amely a redb beágyazott kulcs--érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül, amelynek köszönhetően a tárolt rekordok beolvasáskor elemzés, deszerializálás és újabb memóriafoglalás nélkül, közvetlenül Rust-struktúraként használhatók.
A felhasználói felület szerveroldalon renderelődik: az oldalakat builder-mintán alapuló HTML-generátor állítja elő, a formázást egy saját stíluslap végzi, így kliensoldali JavaScriptre pedig nincs is szükség.

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

#todo[a beágyazott és a kliens--szerver adatbázis különbsége; a redb (copy-on-write B-fa, ACID tranzakciók, egyetlen író és párhuzamos olvasók pillanatképpel; név szerinti táblák és multimap táblák); miért nem SQLite (FFI, C függőség, fordítás és méret, SQL helyett típusos Rust API)]

=== Zero-copy szerializáció és az rkyv

#todo[a zero-copy szerializáció fogalma; az rkyv archivált típusai (relatív eltolások abszolút mutatók helyett, `ArchivedString`, `ArchivedVec`, fix bájtsorrendű egészek); validálás (bytecheck); igazítás és az `unaligned` feature]

== További felhasznált könyvtárak

#todo[a http (közös típusok I/O nélkül) és a httparse (allokáció nélküli fejlécelemző, `Complete`/`Partial`); a bytes (`Bytes`, `BytesMut`, referenciaszámlált szeletek); a build_html (builder minta, saját fork az űrlapelemek miatt); az epub; a serde és a serde_json; a unicode-normalization]

#pagebreak()

// ---------- A HTTP-szerver ----------
// terjedelem: kb. 7 oldal

= A HTTP-szerver

== Hatókör és programozói felület

A HTTP-szervert önálló, alkalmazásfüggetlen könyvtárként írtam meg, és `tiny-http-server` néven a crates.io-n is közzétettem (@tiny-http-server).
A könyvtár csak a protokollkezelésért felel: a TCP-kapcsolaton érkező bájtokból HTTP-kéréseket állít elő, átadja őket a kezelőnek, a kapott választ pedig visszaírja a hálózati kapcsolatra.
Támogatja a HTTP/1.0 és HTTP/1.1 szabványokat, egy kapcsolaton több kérést is képes egymás után kiszolgálni (keep-alive), és azokat a kéréseket is helyesen dolgozza fel, amelyeket a kliens az előző válasz megvárása nélkül küld el (pipelining).

Ami nem tartozik szorosan a protokollhoz, azt szándékosan a környező rétegekre bíztam: az útvonalválasztás (routing), a köztes rétegek (middleware) és a naplózás a hívó alkalmazás felelőssége, a titkosításról (TLS) pedig a szerver elé állított fordított proxy (reverse proxy) gondoskodhat.
A darabolt (chunked) átvitelt és a törzsek streamelését sem támogatja a szerver: a kérések és a válaszok törzsét teljes egészében a memóriában tartja.

A szerver és az alkalmazás közötti hidat a `Handler` trait jelenti (@lst:handler. kódrészlet).
Ennek egyetlen metódusa egy `Request`-ből aszinkron módon állít elő egy `Response`-t.
Mindkét típus a szabványos `http` könyvtárból (@http) származik, így a szerver nem saját adatstruktúrákat kényszerít a fejlesztőre, hanem a Rust-ökoszisztémában megszokott típusokra épít.
A traiten szereplő `Send + Sync + 'static` megkötésre azért van szükség, mert a kezelő egyetlen példányát a szerver összes munkaszála párhuzamosan használja.
Mivel a traithez tartozik egy általános implementáció minden olyan függvényre és lezárásra (closure), amely kérést fogad és egy válaszra váró `Future`-t ad vissza, egy egyszerűbb alkalmazáshoz elég egy `async fn` megadása.
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
Mivel ez egy referenciaszámlált bájtszelet, a kérés törzse másolás nélkül (zero-copy) vágható ki a szerver olvasási pufferéből, a válasz törzseként pedig akár a binárisba fordított statikus adatok -- például egy stíluslap -- is közvetlenül átadhatók.
A kezelő metódusa `Result` helyett egyszerű `Response`-t ad vissza: a szerver nem kényszerít ki saját hibatípust, így az alkalmazásra bízza, hogyan kezeli a hibákat, és milyen HTTP-választ küld róluk.

A szerver kétféleképpen indítható el: a `Server::bind` az alapértelmezett paraméterekkel köti a szervert a megadott címhez, míg a `ServerBuilder` segítségével ezek a beállítások indítás előtt testreszabhatók, így a hívónak csak az eltéréseket kell megadnia.
A működés három fő paraméterrel szabályozható:
- `max_head_bytes`: a kéréssor és a fejlécek együttes maximális mérete,
- `max_body_bytes`: a kérés törzsének maximális mérete,
- `threads`: a kapcsolatokat kiszolgáló munkaszálak száma (alapértelmezés szerint a processzormagok száma).

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
  caption: [Egy kis szerver a tiny-http-server könyvtárral],
) <lst:pelda>

== Szálak és kapcsolatok

A `run` metódusban a feladatokat két szerepkörre bontottam.
A hívó szál csak az új kapcsolatokat fogadja egy végtelen ciklusban, és mindegyikhez elindít egy aszinkron feladatot (task).
A kiszolgálást a `threads` darab munkaszál végzi, amelyek egy közös `Executor`-on osztoznak (@async-executor), így bármelyik szál bármelyik kapcsolat kérését feldolgozhatja.
Ennek előnye, hogy ha egy kezelő blokkoló műveletet végez, csak azt a munkaszálat tartja fel, amelyen éppen fut: a többi szál zavartalanul tovább dolgozik, és az új kapcsolatok fogadása sem akad meg.

A munkaszálakat a szabványos könyvtár `thread::scope` függvényével hozom létre.
Mivel a fordító garantálja, hogy a hatókör végéig minden elindított szál befejeződik, ezek közvetlenül kölcsönözhetik a szervert és az executort, így egyiket sem szükséges `Arc`-ba csomagolni.
Ha a kapcsolatok fogadása valamilyen hiba miatt leáll, a hívó szál lezár egy vezérlőcsatornát, amelyre a munkaszálak várakoznak.
Ennek hatására a szálak szabályosan kilépnek, a `run` metódus pedig csak ezután adja vissza a hibát.

Minden kapcsolathoz egy task tartozik, amely a kapcsolat élettartama alatt egymás után olvassa be és szolgálja ki a kéréseket.
Hogy a kapcsolat egy válasz után nyitva marad-e, azt a kérés verziója és `Connection` fejléce dönti el: HTTP/1.1 esetén nyitva marad, hacsak a kliens nem küld `close` jelzést, HTTP/1.0 esetén pedig csak akkor, ha a kliens `keep-alive` jelzéssel kéri.
Az olvasó és író adatfolyamok a task saját, lokális változói, így a szerver oldalán a párhuzamos kapcsolatok között nincs semmilyen megosztott, zárolást igénylő állapot.

Az újonnan elfogadott kapcsolatokon bekapcsolom a `TCP_NODELAY` opciót, amivel letiltom a Nagle-algoritmust (@rfc9293).
Ez az algoritmus a kisebb csomagokat visszatartja, amíg a korábban elküldött adatokra meg nem érkezik a nyugta, hogy több apró írást egy szegmensbe vonjon össze.
A szerver azonban minden választ egy írással küld el, így nincs mit összevonni, a várakozás csak késleltetést okozna.
Ha az opció beállítása mégsem sikerül, a kapcsolat ettől még működik, ezért ezt a hibát figyelmen kívül hagyom.

== A kérés beolvasása

=== A kérés határai és a pufferelés

A TCP-kapcsolat egy folyamatos bájtfolyam, amelyben nincs beépített „kérés vége” jelölés.
Egy-egy hálózati olvasás pontosan annyi bájtot ad vissza, amennyi addig megérkezett: emiatt egy HTTP-kérés több olvasásra is széteshet, de az is előfordulhat, hogy egy olvasás már a következő kérés elejét is magával hozza (@fig:olvasasok. ábra).
A kérések határait ezért csak a tartalmuk alapján lehet megállapítani (@rfc9112): a fejléc végét egy üres sor (`\r\n\r\n`) jelzi, a törzs pontos hosszát pedig a `Content-Length` fejléc adja meg.
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

A beérkezett, de még fel nem dolgozott bájtokat kapcsolatonként egy `BytesMut` puffer tárolja, amely nem csak egy kérésig, hanem a kapcsolat végéig él.
Amikor egy kérés feldolgozása befejeződik, a szerver leválasztja a fejlécet és a törzset a puffer elejéről, a fennmaradó rész -- a következő kérés már megérkezett darabja -- pedig érintetlenül benne marad.
Így a pipelining külön logika nélkül működik: a következő kérés beolvasása pontosan ott folytatódik, ahol az előző véget ért.

Ennek viszont feltétele, hogy a szerver mindig először a pufferben már meglévő adatokat vizsgálja meg, és csak akkor olvasson a hálózatról, ha azok nem elegendőek.
Ha ugyanis az előző kérés egy teljes újabb kérést hagyott maga után a pufferben, egy felesleges hálózati olvasás olyan adatra várna, amelyet a kliens már rég elküldött -- így a kapcsolat a tétlenségi időkorlát lejártával tévesen bezárulna.
Ugyanez az ellenőrzési sorrend teszi lehetővé a kapcsolat tiszta lezárásának felismerését is: ha a kliens bontja a kapcsolatot (EOF), és a puffer üres, akkor két kérés között, szabályosan lépett ki; ha viszont maradt még feldolgozatlan adat a pufferben, akkor egy kérés közepén szakadt meg a kapcsolat, ami hibának számít.

Az új adatok közvetlenül a puffer végére kerülnek.
Mivel az `AsyncRead` csak inicializált memóriába enged írni, a puffert előbb 8 KiB-tal megnövelem -- az új területet nullákkal feltöltve --, ebbe olvasok a kapcsolatból, végül visszavágom a ténylegesen megérkezett bájtok végéig.
A 8 KiB csak egy olvasás felső határa, maga a kérés ennél jóval nagyobb is lehet.
Ennek költsége az új terület nullázása minden olvasásnál, cserébe nincs szükség külön átmeneti pufferre és adatmozgatásra, és az `unsafe` kód is teljesen elkerülhető.
A puffer így mindig csak érvényes, megérkezett bájtokat tartalmaz, amelyekből a fejléc és a törzs később másolás nélkül vágható ki.

=== A fejléc elemzése és a zero-copy

A zero-copy megközelítés előnye akkor látszik igazán, amikor a fejléc mezői a `http` könyvtár típusaiba kerülnek.
A `slice_ref` metódus a `Bytes` belsejébe mutató bájtszeletből egy újabb, csak arra a tartományra korlátozódó `Bytes` nézetet hoz létre, amely ugyanarra a memóriaterületre mutat, csupán a referenciaszámlálót növeli meg.
Az URI-t és az összes fejlécértéket ilyen részszeletekből építem fel (`from_maybe_shared`), tehát ezek sem önálló másolatok, hanem a beolvasott fejléc egy-egy szakaszai.
A HTTP-metódusok és a szabványos fejlécnevek esetében a `http` könyvtár előre definiált konstansokat használ, így új memóriafoglalásra legfeljebb az egyedi fejlécneveknél kerülhet sor.
Ugyanakkor amíg a kérés bármelyik része -- például egy elmentett fejlécérték -- életben marad, addig a mögötte álló eredeti memóriaterület sem szabadul fel.

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

A zero-copy nézetek miatt a `httparse` kétszer fut le ugyanazon a fejlécen.
Az első futás az előző alfejezetben leírt módon a még módosítható `BytesMut` pufferen ellenőrzi, hogy teljes-e már a fejléc, és mekkora a hossza.
Mivel maga a `httparse` sem másol, az eredményében kapott metódus, útvonal és fejlécértékek mind olyan szeletek, amelyek közvetlenül az elemzett pufferbe mutatnak.
Ezeket azonban nem lehet megtartani: a későbbi `split_to` hívás módosítja a puffert, amit a borrow checker megakadályoz, ráadásul a `slice_ref` is kifejezetten a végleges `Bytes` példányba mutató szeletet vár.
A második elemzés ezért már a leválasztott és befagyasztott fejlécen fut le, az így kapott szeletekből pedig gond nélkül kialakíthatók a referenciaszámlált `Bytes` példányok.

== Korlátok és védelmek

A szerver semmit nem feltételez a kliens megbízhatóságáról: a beérkező kérésben szereplő minden adat csupán egy ellenőrizetlen állítás, amelyet hitelesíteni kell, mielőtt a program erőforrást szánna rá, ezért minden kapcsolatra méret- és időkorlátok vonatkoznak (@tbl:korlatok. táblázat).
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

A szabályok a HTTP request smuggling támadások ellen védenek.
Ha egy kérés kétértelműen értelmezhető, és két fél -- például egy fordított proxy és a mögötte álló alkalmazásszerver -- eltérő helyen látja a végét, akkor a törzs lemaradó részéből az egyik fél szemében egy új, ellenőrizetlen kérés születhet.
A szerver ezért kétértelmű helyzetben nem választ a lehetséges értelmezések közül, hanem elutasítja a kérést.
A `Transfer-Encoding` fejlécet ugyanezért nem hagyhatja figyelmen kívül, bár nem kezeli: ha nem venné észre, rossz helyen látná a kérés végét.
A méretkorlát ellenőrzése még a törzs beolvasása előtt megtörténik, így a túl nagy méretet bejelentő kérés azonnal választ kap, és a szerver egyetlen bájtot sem vár meg a törzsből.

=== Időkorlátok

Egy kliens úgy is lekötheti a szerver erőforrásait, hogy egyáltalán nem küld adatot, vagy csak rendkívül lassan csepegteti azt, ezen alapulnak a Slowloris típusú támadások.
A kapcsolatot kiszolgáló ciklus ezért minden hálózati várakozást időkorláttal futtat: a művelet és egy időzítő versenyez egymással, és ha az utóbbi jár le előbb, a szerver válasz nélkül lezárja a kapcsolatot.
A rövid tétlenségi időkorlát (`IDLE_TIMEOUT`) a következő kérés első bájtjára való várakozásra, a hosszabb kapcsolati időkorlát (`CONNECTION_TIMEOUT`) a már megkezdett kérés beolvasására és a válasz kiírására vonatkozik.

A két állapotot a `wait_for_request` metódus választja el egymástól.
Ez megvárja a következő kérés első bájtjának megérkezését -- vagy pipelining esetén azonnal visszatér, ha a pufferben már van feldolgozatlan adat --, és csak ezután indul el a kérés beolvasása.
Tétlen várakozás két helyzetben fordul elő: közvetlenül a kapcsolat felépülése után (mivel a modern böngészők gyakran előre nyitnak tartalék kapcsolatokat, amelyeket később nem feltétlenül használnak fel), valamint keep-alive működésnél két egymást követő kérés között.
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

A bejelentett törzshosszt a memóriafoglalás során sem veszem készpénznek.
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

A válaszok hálózatra írásáról a kérések olvasójának párja, a kapcsolatonként egy példányban létező `ResponseWriter` gondoskodik.
A kimenet egy `Vec<u8>` pufferben áll össze, amely a bejövő pufferhez hasonlóan a kapcsolat végéig él.
Minden új válasz összeállítása előtt kiürítem, ami lenullázza a tárolt adatok hosszát, de megőrzi a már lefoglalt kapacitást -- így egy keep-alive kapcsolaton az első válasz után jellemzően már nincs szükség újabb memóriafoglalásra.
Az összeállítás elején a puffert egyszerre bővítem a várható méretre (a törzs hosszára, valamint a státuszsor és a fejlécek becsült keretére), elkerülve ezzel a többszöri újrafoglalást írás közben.

A kimeneti bájtfolyamba sorban bekerül a státuszsor, a kezelő által visszaadott fejlécek, a szerver által generált `Content-Length` és `Connection` mezők, az elválasztó üres sor, végül pedig maga a törzs.
Az üzenet keretezését meghatározó fejléceket (`Content-Length`, `Transfer-Encoding`) és a `Connection` fejlécet a kezelő nem bírálhatja felül: ha ezek szerepelnek a visszaadott válaszban, a szerver kihagyja őket.
A `Content-Length` értékét mindig a törzs tényleges hosszából, a `Connection` fejlécet pedig a kapcsolat megtartásáról hozott saját döntéséből állítja elő.
Így kizárható, hogy a kezelő más méretet jelentsen be, mint amennyit a szerver valójában elküld, és a kliens emiatt rossz helyen vágja el a választ.

A teljes üzenet egyetlen írási művelettel jut ki a hálózatra, ezért a törzs is bemásolódik a pufferbe.
Ez válaszonként egy másolással jár, és a puffer kapacitása a kapcsolat végéig akkora marad, amekkorát a legnagyobb addigi válasz megkövetelt.

A `HEAD` kérésekre a szervernek pontosan ugyanazt a fejlécet kell küldenie, mint a megfelelő `GET` kérésre.
Ennek biztosításához a kezelő meghívása előtt a kérés metódusát `GET`-re cserélem, a válasz kiírásakor pedig egyszerűen elhagyom a törzset, miközben a `Content-Length` fejlécben meghagyom annak valódi hosszát.
Így az alkalmazásnak nem kell külön foglalkoznia a `HEAD` metódussal, és garantált, hogy a két válasz fejléce sosem tér el egymástól.
Hátulütője, hogy a kezelő a `HEAD` kéréseknél is előállítja a teljes törzset, amelyet a szerver végül nem küld el.

== Hibakezelési elvek

A kapcsolat kiszolgálása közben felmerülő hibákat egy belső `Error` enum írja le, amely nem része a könyvtár publikus felületének.
Az ilyen hibák sosem jutnak el a szerver hívójáig: mindig az adott kapcsolat lezárásával végződnek, a többi kapcsolatot pedig nem érintik.

A belső hibákat a `client_status` metódus két csoportra osztja: minden hibaváltozathoz vagy egy HTTP-státuszkódot rendel, vagy üres értéket ad vissza.

- *Protokollhibák:* A kliens hibás formátumú vagy a méretkorlátokat túllépő kérést küldött, maga a hálózati kapcsolat azonban még él.
  Ilyenkor a szerver egy törzs nélküli státuszválaszt küld, hogy a kliens értesüljön az elutasítás okáról.
  A hibaüzenet elküldése után a szerver lezárja a kapcsolatot, hiszen egy hibásan keretezett kérés után már nem állapítható meg biztosan, hol kezdődik a következő.
- *Átviteli hibák:* Ha a hálózati művelet hiúsul meg, vagy a kliens a kérés közben bontja a kapcsolatot, már nincs kinek választ küldeni, így a szerver csendben lezárja a kapcsolatot.

Azt is el kellett döntenem, hogyan kezelem azokat az állapotokat, amelyek helyes működés mellett elvileg nem fordulhatnak elő.
Ahol ezt a helyi logika vagy egy külső könyvtár dokumentált garanciája biztosítja, `unwrap` hívást használok, mellette egy rövid megjegyzéssel az indoklásról.
Ilyen például a memóriában lévő `Vec` pufferbe történő írás, amely nem hiúsulhat meg, vagy a `httparse` sikeres elemzése, amely garantáltan kitölti a metódust, az útvonalat és a verziót.
Ezzel szemben ahol a feltétel teljesülése egy másik függvény viselkedésén múlik -- és egy későbbi módosítás észrevétlenül elronthatja --, ott a `?` operátorral továbbadom a hibát.
Így kezelem például a fejléc második elemzését is: ez elvileg nem bukhat el, hiszen a hívó pontosan az első elemzés által kimért bájtokat vágta le, de ha egy későbbi változtatás ezt mégis elrontaná, a kliens szabályos `400`-as választ kap.
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
A tárolást a redb beágyazott kulcs--érték tároló (@redb), a rekordok bájtokká alakítását az rkyv (@rkyv) végzi.

Szándékosan kimaradt minden, ami egy általános adatbázis-kezelőt jellemez, de egy kis alkalmazáshoz nem szükséges: nincs lekérdezőnyelv, táblák közötti összekapcsolás (join), egyediségi megkötés és sémaverzió sem.
Ha egy lekérdezés több feltételt tartalmaz, a hívó egy indexből kéri le a jelölteket, a többi feltételt pedig a visszakapott rekordokon ellenőrzi.

A `Database` típus egyetlen mezője a redb adatbázis-objektuma, saját állapota nincs.
Az író metódusok is csak megosztott referenciát (`&self`) kérnek, a zárolásról pedig a redb gondoskodik: egyszerre csak egy író tranzakció futhat, a többi megvárja annak végét.
Így a `Database` szálak között `Mutex` nélkül megosztható, és közvetlenül a HTTP-szerver kezelőjének állapotába tehető, amelyet a szerver összes munkaszála párhuzamosan használ.

== A tárolt adatok modellje

=== Rekordok és indexek

Egy tárolható adattípus és az adatbázisréteg közötti szerződést a `Record` trait rögzíti (@lst:record. kódrészlet).
Ebben a `TABLE` konstans adja meg annak a táblának a nevét, amelybe az adott típus rekordjai kerülnek.
Azért asszociált konstansként és nem metódusként definiáltam, mert a tábla nevére példányosított rekord nélkül is szükség van: egy `get::<User>(1)` híváskor még nincs kéznél konkrét objektum, a könyvtárnak mégis tudnia kell, honnan olvasson.
A rekord egyedi azonosítóját az `id` metódus szolgáltatja; ezt mindig a hívó fél választja meg, automatikusan növekvő azonosítókat az adatbázisréteg nem generál.
Az `index_keys` metódus pedig a rekordhoz tartozó indexbejegyzéseket adja vissza index és kódolt kulcs párok formájában – a kulcsok kódolási elveit a következő alfejezet tárgyalja.

#figure(
  ```rust
  pub trait Record: Sized + /* rkyv traitek */ {
      const TABLE: &'static str;
      type Index: Index;

      fn id(&self) -> u64;
      fn index_keys(&self) -> Vec<(Self::Index, Vec<u8>)>;
  }

  pub trait Index {
      fn name(&self) -> &'static str;
  }
  ```,
  caption: [A `Record` és az `Index` trait (egyszerűsítve)],
) <lst:record>

Magát a rekordtípust nem a `Database` struktúrán, hanem az egyes műveleteken (`get::<User>`, `insert::<T>`) helyeztem el típusparaméterként.
Ennek köszönhetően egyetlen adatbázisfájlban többféle rekordtípus is tárolható egymás mellett, a meghívott metódus pedig az adott típus `TABLE` konstansa alapján választja ki a megfelelő táblát.

Az egyedileg definiált indexeket egy `Index` traitet megvalósító enum fogja össze, minden indexhez egy-egy változatot rendelve.
Ha az indexeket egyszerű karakterláncok azonosítanák, egy elgépelt név csak futásidőben okozna hibát, így viszont az ilyen tévedés már fordítási időben kiszűrhető.
Ráadásul más rekordtípus indexe sem adható át véletlenül, hiszen például a `find::<User>` hívás kizárólag a `User` saját indextípusát fogadja el.
Mivel a `redb` motor futásidőben név szerint azonosítja a táblákat, a `name` metódus minden enum-változathoz hozzárendel egy nevet, amelyből a tárolt indextábla neve képződik.
Ezt a leképezést szándékosan egy kézzel írt `match` kifejezéssel kell megvalósítani, ahelyett, hogy automatikusan a változat nevéből származtatnánk: így egy későbbi átnevezés (refaktorálás) nem változtatja meg észrevétlenül a fájlban tárolt táblanevet.
A `match` kimerítő vizsgálata pedig garantálja, hogy egyetlen új indexváltozat sem maradhat név nélkül.
Az indexet nem használó rekordtípusokhoz a könyvtár egy előre definiált, változatok nélküli `NoIndex` típust biztosít.

A `redb` adatbázisfájljában minden rekordtípushoz egy elsődleges sortábla, valamint indexenként egy-egy külön indextábla tartozik.
A sortábla nevét a `TABLE` konstans határozza meg: a kulcs a rekord egyedi azonosítója, az érték pedig maga a rekord az `rkyv` által szerializált bájtformátumban.
Az indextáblák neve a sortábla és az adott index nevéből áll össze, egy ponttal elválasztva (például `users.name`), és fordított leképezést valósítanak meg: a mező kódolt értékéhez rendelik hozzá az azt tartalmazó rekordok azonosítóit.
Mivel egy érték több rekordban is előfordulhat, az indextáblák a `redb` multimap tábláira épülnek, amelyekben egyetlen kulcshoz azonosítók halmaza tartozik.
A pont elválasztó szerepe miatt sem a tábla, sem az index neve nem tartalmazhat pont karaktert, különben két eltérő index táblája névütközést okozhatna.
Ennek megelőzésére a könyvtár a táblanevet már fordítási időben ellenőrzi, az index nevét pedig futásidőben, annak első használatakor validálja.

A @tbl:tablak. táblázat egy `User` típus négy rekordját szemlélteti, a név, az életkor és a címkék szerinti indexekkel együtt.
Egy indexelt lekérdezés mindig két lépésben zajlik: először a könyvtár kikeresi a kulcshoz tartozó azonosítókat az indextáblából, majd ezek alapján betölti magukat a rekordokat a sortáblából.

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
  caption: [Négy rekord a sortáblában és a három indextábla (a kulcsok a kódolás előtti értékükkel)],
) <tbl:tablak>

=== Rendezéstartó kulcskódolás

Az indextáblák kulcsai nyers bájtsorozatok, amelyeket a `redb` bájtról bájtra, balról jobbra haladva hasonlít össze.
Egyenlőségkereséshez elég lenne, ha azonos érték mindig azonos bájtokat adna, a tartománylekérdezés viszont az indextábla egy összefüggő szakaszát járja be, ezért a bájtok sorrendjének meg kell egyeznie az értékek természetes sorrendjével.
A rekordok `rkyv`-vel szerializált bájtjai ezt nem teljesítik, ezért a kulcsokat a `key` modul `enc` függvénye külön kódolja; ezt használja az `index_keys` metódus és a lekérdezések is.

Az egész számok natív – a legtöbb architektúrán _little-endian_ – ábrázolása önmagában nem rendezéstartó, mivel ebben a legkisebb helyiértékű bájt áll elöl.
A @tbl:endian. táblázat bal oldalán látható, hogy egy `u16` mező 18, 256 és 300 értékei a natív bájtjaik alapján 256, 18, 300 sorrendbe kerülnének, így egy 0 és 100 közötti tartománylekérdezés mindhárom rekordot visszaadná (a határok natív bájtjai `00 00` és `64 00`, és mindhárom kulcs e kettő közé esik).
Az `enc` ezért az előjel nélküli egészeket _big-endian_ sorrendben kódolja, ahol a legnagyobb helyiértékű bájt kerül előre, így a bájtok sorrendje megegyezik a számok nagyságrendjével.
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
Ennek kiküszöbölésére az `enc` a _big-endian_ bájtokban megfordítja az előjelbitet, így például a `-1i8` kódja `7F`, a `0i8` kódja pedig `80` lesz.
A lebegőpontos számoknál más a gond: az IEEE 754 előjelbitből és abszolút értékből álló ábrázolásában a pozitív számok bitmintái már helyes sorrendben vannak, a negatívaké viszont fordítottban, mert ott a nagyobb abszolút értékhez nagyobb bitminta tartozik.
Ezért pozitív számnál csak az előjelbitet fordítom meg, negatívnál az összes bitet, így a negatív számok a pozitívak elé, egymás között pedig helyes sorrendbe kerülnek.

A kódolás hossza és formátuma szigorúan a típustól függ: az `enc(18u8)` egyetlen bájtot, míg az `enc(18u32)` négy bájtot eredményez.
Ha az `index_keys` és a lekérdezés eltérő típusként kódolja ugyanazt az értéket, a keresés hibaüzenet nélkül üres eredménnyel tér vissza, ezért a számliterálokat mindig típusutótaggal kell írni (`18u8`).

A sztringek és a bájtszeletek változó hosszúságúak, ezért a kódolásuknak azt is jeleznie kell, hol érnek véget.
Erre akkor van szükség, ha egy összetett kulcs több egymás után fűzött mezőből áll: végjel nélkül például a `("a", "bc")` és az `("ab", "c")` pár pontosan ugyanazt a bájtsorozatot adná.
A hossz előreírása sem megoldás, mert akkor az határozná meg a rendezést, így a `"b"` az `"ab"` elé kerülne.
Az `enc` ezért minden sztring végére `00 01` lezárót ír.
A `00` a legkisebb bájtérték, így a rövidebb szó mindig megelőzi a folytatását (az `"a"` az `"ab"` elé kerül).
Egy Rust-sztring viszont maga is tartalmazhat `00` bájtot, amely hamis végjelnek látszana, ezért ezeket `00 FF` sorozatra cserélem.
A `00` után így mindig a következő bájt dönti el, hogy a sztring véget ért (`01`), vagy valódi nulla bájt következik (`FF`).
Mivel a `01` kisebb az `FF`-nél, a lezárt sztring itt is a folytatódó elé kerül.

Mivel a számok kódolása rögzített hosszúságú, a sztringeké pedig végjellel zárul, egyetlen érték kódolása sem lehet egy másik, azonos típusú érték kódolásának előtagja.
Ezért több mező kódolása egyszerűen egymás után fűzhető, és a bájtsorozatból mindig kiderül, hol ér véget az egyik mező.
Az `enc` legfeljebb négyelemű tuple típusokat is elfogad, és a tagok kódolását összefűzve összetett kulcsot képez.
Egy ilyen index először az első, azon belül a második mező szerint rendezett, és egy tartománylekérdezés ebben a sorrendben járja be a két határ közötti kulcsokat (@lst:osszetett. kódrészlet).
Ha az első mező mindkét határon azonos, a lekérdezés egy név rekordjait szűri életkor szerint.
Ha eltér, a két határ közötti összes kulcsot visszaadja, név, azon belül életkor szerint rendezve.

#figure(
  ```rust
  // index_keys: (UserIndex::NameAge, key::enc((&self.name, self.age)))

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
  caption: [Lekérdezések egy (név, életkor) összetett indexen],
) <lst:osszetett>

A sztringek kódolási módja az előtagra történő keresést is lehetővé teszi, amelyet a `prefix_range` függvény valósít meg.
A keresési tartomány alsó határa maga a kódolt előtag lezáró végjel nélkül, a felső határa pedig ugyanez egy `FF` bájttal kiegészítve.
Egy ilyen előtaggal kezdődő sztring kódolásában az előtag után UTF-8 bájt, kódolt nulla bájt (`00 FF`) vagy lezáró végjel (`00 01`) következik.
Ezek első bájtja mind kisebb az `FF`-nél, amely érvényes UTF-8 szövegben sosem fordul elő.
Így például a `prefix_range("Al")` tartományba az `"Al"` és az `"Alice"` kódolása beleesik, míg a `"Bob"` vagy az `"A"` kódolása már kívül esik rajta.

A kulcskódolás a fájlformátum része, így bármilyen későbbi módosítása érvénytelenítené a már meglévő indextáblákat.
Ugyanezért a `usize` és az `isize` típusokhoz szándékosan nem tartozik kódolás: a méretük platformfüggő, így egy 64 bites rendszeren írt adatbázisfájl kulcsai egy 32 bites gépen nem egyeznének az újonnan generáltakkal.

== Írás és törlés

#todo[`insert` és `insert_many` egy tranzakcióban (egy commit = egy fájlszinkronizálás); csak a változott indexbejegyzések íródnak; a visszagörgetés a `commit` elmaradásából jön; a törlés a régi rekordot dekódolja, hogy tudja, mely indexbejegyzéseket kell törölni]

== Olvasás

=== Lekérdezések

#todo[`get`, `find`, `range`, `all`, valamint `contains` és `count`; a `find` egy egykulcsú tartomány; az indexbejárás menete (azonosítók gyűjtése, ismétlődés szűrése, sorok betöltése); egy olvasó tranzakció pillanatképe; `Vec` az iterátor helyett, mert az a tranzakciót kölcsönözné]

=== Zero-copy olvasás és validálás

#todo[a `view*` metódusok lezárásnak adják az archivált rekordot (a referencia nem élheti túl a tranzakciót); az `unaligned` feature-rel a redb lapjáról, másolás nélkül, és ennek ára; minden olvasás ellenőrzi a bájtokat, sérült sorból `Corrupt` hiba lesz memóriahiba helyett; nincs `unsafe`]

== Sémaváltozás és hibakezelés

#todo[`rebuild_indexes` az `index_keys` megváltozása után, `migrate::<Old, New>` a rekordtípus megváltozása után; a publikus `Error` (`#[non_exhaustive]`, `Corrupt`, `InvalidIndexName`); a még nem létező tábla nem hiba, hanem üres eredmény]

#pagebreak()

// ---------- A bemutató alkalmazás ----------
// terjedelem: kb. 5,5 oldal

= A bemutató alkalmazás

== Az alkalmazás célja és felépítése

#todo[a repub: publikus EPUB-kereső és -letöltő oldal; az útvonalak (táblázat); ez az egyetlen rész, amely az EPUB formátumhoz kötődik; a modulok és a kérés útja: a `Router` maga a szerver `Handler`-e; a `Reply` trait: `None` -> 404, hiba -> naplózás és 500, így minden hiba egy helyen végződik]

== Az EPUB formátum

#todo[felépítése (ZIP, OPF, Dublin Core metaadatok, finomítások: szerep és esemény, borítókép); mit nyerünk ki belőle]

== A könyvtár indexelése

#todo[a `Book` rekord és a metaadatok kinyerése (cím hiányában a fájlnév, az év, a leírás szövege); az azonosító a fájlnév FNV-1a hash-e 53 bitre vágva (stabil linkek, pontos JSON szám); az adatbázis minden induláskor újraépül; egy-egy `insert_many` a könyvekre és a borítókra; a szöveges mezők szavanként, normalizálva kerülnek az indexbe]

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

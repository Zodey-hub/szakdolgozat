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
#show raw.where(block: true): set text(size: 9pt)
#show raw.where(block: true): set align(left)
#show raw.where(block: true): block.with(width: 100%, inset: 1em, stroke: 0.5pt + gray)

#set table(stroke: (_, y) => if y == 0 { (bottom: 0.5pt) }, align: left)
#show table: box.with(stroke: (y: 1pt))
#show table.cell.where(y: 0): set text(weight: "bold")

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
Az adattárolásért egy saját adatbázisréteg felel, amely a redb beágyazott kulcs–érték tárolóra és az rkyv zero-copy szerializációs keretrendszerre épül, amelynek köszönhetően a tárolt rekordok beolvasáskor elemzés, deszerializálás és újabb memóriafoglalás nélkül, közvetlenül Rust-struktúraként használhatók.
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
A könyvtár kizárólag a protokollkezelésért felel: a TCP-kapcsolaton érkező bájtokból HTTP-kéréseket állít elő, átadja őket a kezelőnek, a kapott választ pedig visszaírja a hálózati kapcsolatra.
Támogatja a HTTP/1.0 és HTTP/1.1 szabványokat, egy kapcsolaton több kérést is képes egymás után kiszolgálni (keep-alive), és azokat a kéréseket is helyesen dolgozza fel, amelyeket a kliens az előző válasz megvárása nélkül küld el (pipelining).
A `HEAD` kéréseket a kezelő egyszerű `GET`-ként kapja meg, a válaszból pedig a szerver automatikusan csak a fejlécet küldi vissza.

A tervezésnél szándékosan törekedtem arra, hogy a könyvtárban csak az maradjon, ami szorosan a protokollhoz tartozik.
Minden más feladatot a környező rétegekre bíztam: az útvonalválasztás (routing), a köztes rétegek (middleware) és a naplózás a hívó alkalmazás felelőssége, míg a titkosításról (TLS) a szerver elé állított fordított proxy (reverse proxy) gondoskodhat.
Emellett a szerver nem támogatja a darabolt (chunked) adatátvitelt és a törzsek folyamatos streamelését sem, a kérések és válaszok törzsét teljes egészében a memóriában tartja.

A szerver és az alkalmazás közötti hidat a `Handler` trait jelenti (@lst:handler. kódrészlet).
Ennek egyetlen metódusa egy `Request`-ből aszinkron módon állít elő egy `Response`-t.
Mindkét típus a szabványos `http` könyvtárból származik, így a szerver nem saját adatstruktúrákat kényszerít a fejlesztőre, hanem a Rust-ökoszisztémában megszokott típusokra épít.
A traiten szereplő `Send + Sync + 'static` megkötésre azért van szükség, mert a kezelő egyetlen példányát a szerver összes munkaszála párhuzamosan használja.
Mivel a traithez tartozik egy általános implementáció minden olyan függvényre és lezárásra (closure), amely kérést fogad és egy válaszra váró `Future`-t ad vissza, egy egyszerűbb alkalmazáshoz elég egyetlen `async fn` megadása.
Ha viszont a kezelőnek belső állapotra – például egy adatbázis-kapcsolatra – is szüksége van, akkor a traitet egy saját struktúrán kell megvalósítani, ahogyan azt a bemutató alkalmazás `Router` típusa is teszi.

#figure(
  ```rust
  pub trait Handler: Send + Sync + 'static {
      fn handle(&self, request: Request<Body>)
          -> impl Future<Output = Response<Body>> + Send;
  }
  ```,
  caption: [A `Handler` trait],
) <lst:handler>

A kérés és a válasz törzsét a `Body` típus reprezentálja, amely a `bytes` könyvtár `Bytes` típusának álneve (type alias).
Mivel ez egy referenciaszámlált bájtszelet, a kérés törzse másolás nélkül (zero-copy) vágható ki a szerver olvasási pufferéből, a válasz törzseként pedig akár a binárisba fordított statikus adatok – például egy stíluslap – is közvetlenül átadhatók.
A kezelő metódusa `Result` helyett egyszerű `Response`-t ad vissza: a szerver nem kényszerít ki saját hibatípust, így az alkalmazásra bízza, hogyan kezeli a hibákat, és milyen HTTP-választ küld róluk.

A szerver kétféleképpen indítható el: a `Server::bind` az alapértelmezett paraméterekkel köti a szervert a megadott címhez, míg a `ServerBuilder` segítségével ezek a beállítások indítás előtt testreszabhatók, így a hívónak csak az eltéréseket kell megadnia.
A működés három fő paraméterrel szabályozható:
- `max_head_bytes`: a kéréssor és a fejlécek együttes maximális mérete (alapértelmezés szerint 16 KiB),
- `max_body_bytes`: a kérés törzsének méretkorlátja (alapértelmezés szerint 1 MiB),
- `threads`: a kapcsolatokat kiszolgáló munkaszálak száma (alapértelmezés szerint a processzormagok számával egyezik meg).

A szálak számát a típusrendszer a `NonZeroUsize` típussal védi, így nulla szálas szerver már fordítási időben sem hozható létre, ami feleslegessé teszi a futásidejű ellenőrzést.
Maga a `run` metódus sikeres működés esetén végtelen ciklusban fut, és kizárólag hiba esetén tér vissza – ezt fejezi ki az `io::Result<Infallible>` visszatérési típus is.

A @lst:pelda. kódrészlet egy teljes példán mutatja be a használatot: itt a kezelő egyetlen `async fn`, amely maga végzi az útvonalválasztást, a szerver pedig négy munkaszálon, 64 MiB-os törzskorláttal indul el.

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

A `run` metódusban a feladatokat két külön szerepkörre bontottam.
A hívó szál kizárólag az új bejövő kapcsolatokat fogadja egy végtelen ciklusban, és mindegyikhez elindít egy-egy aszinkron feladatot (task).
Magát a kiszolgálást a `threads` darab munkaszál végzi, amelyek egyetlen közös `Executor`-on osztoznak (@async-executor), így bármelyik szál képes bármelyik kliens kérését feldolgozni.
Ennek előnye, hogy ha egy kezelő blokkoló műveletet végez, csak a saját munkaszálát tartja fel: a többi szál zavartalanul tovább dolgozik, és az új kapcsolatok fogadása sem akad meg.

A munkaszálakat a szabványos könyvtár `thread::scope` függvényével hozom létre.
Mivel a fordító garantálja, hogy a hatókör végéig minden elindított szál befejeződik, ezek közvetlenül kölcsönözhetik a szervert és az executort, így egyiket sem szükséges `Arc`-ba csomagolni.
Ha a kapcsolatok fogadása valamilyen hiba miatt leáll, a hívó szál lezár egy vezérlőcsatornát, amelyre a munkaszálak várakoznak.
Ennek hatására a szálak szabályosan kilépnek, a `run` metódus pedig csak ezután adja vissza a hibát.

Minden elfogadott kapcsolathoz egyetlen task tartozik, amely a kapcsolat teljes élettartama alatt egymás után olvassa be és szolgálja ki a beérkező kéréseket.
Az olvasó és író adatfolyamok a task saját, lokális változói, így a szerver oldalán a párhuzamos kapcsolatok között nincs semmilyen megosztott, zárolást igénylő állapot.

Az újonnan elfogadott kapcsolatokon bekapcsolom a `TCP_NODELAY` opciót, amivel letiltom a Nagle-algoritmust (@rfc9293).
Ez az algoritmus visszatartaná a kisebb adatcsomagokat mindaddig, amíg a korábban elküldött adatokra meg nem érkezik a nyugta, hogy több apró írást egyetlen szegmensbe vonjon össze.
Mivel azonban a szerver minden választ egyetlen pufferben állít össze, és egy lépésben ír ki a hálózatra, nincs mit összevonni – a várakozás csak felesleges késleltetést okozna.
Ha az opció beállítása valamiért mégsem sikerül, a kapcsolat ettől még működőképes marad, ezért ezt a hibát figyelmen kívül hagyom.

== A kérés beolvasása

=== A kérés határai és a pufferelés

A TCP-kapcsolat egy folyamatos bájtfolyam, amelyben nincs beépített „kérés vége” jelölés.
Egy-egy hálózati olvasás pontosan annyi bájtot ad vissza, amennyi addig megérkezett: emiatt egyetlen HTTP-kérés több olvasási műveletre is széteshet, de az is előfordulhat, hogy egy olvasás már a következő kérés elejét is magával hozza (@fig:olvasasok. ábra).
A kérések határait ezért kizárólag a tartalmuk alapján lehet megállapítani (@rfc9112): a fejléc végét egy üres sor (`\r\n\r\n`) jelzi, a törzs pontos hosszát pedig a `Content-Length` fejléc adja meg.
Ebből adódóan a szerver az olvasással párhuzamosan végzi az elemzést, és három egymást követő szakaszban halad: először addig olvas, amíg a teljes fejléc össze nem áll, ezután meghatározza belőle a törzs méretét, végül addig folytatja az olvasást, amíg a törzs összes bájtja meg nem érkezik.
A fejléc teljességét a `httparse` könyvtár ellenőrzi, amely a puffer aktuális tartalmára vagy a teljes fejléc hosszát adja vissza, vagy jelzi, hogy még hiányoznak adatok.

#figure(
  ```
  1. olvasás:  POST /a HTTP/1.1\r\nHost: x\r\nCont
  2. olvasás:  ent-Length: 5\r\n\r\nhel
  3. olvasás:  loGET /b HTTP/1.1\r\n...
  ```,
  kind: image,
  caption: [Egy kérés három olvasásra szétesve, a harmadikban már a következő kérés eleje],
) <fig:olvasasok>

A beérkezett, de még fel nem dolgozott bájtokat kapcsolatonként egyetlen `BytesMut` puffer tárolja, amely nemcsak egyetlen kérésig, hanem a kapcsolat teljes élettartamáig él.
Amikor egy kérés feldolgozása befejeződik, a szerver leválasztja a fejlécet és a törzset a puffer elejéről, a fennmaradó rész – a következő kérés már megérkezett darabja – pedig érintetlenül benne marad.
Ennek köszönhetően a pipelining minden külön logika nélkül, természetes módon működik: a következő kérés beolvasása pontosan ott folytatódik, ahol az előző véget ért.

Ennek azonban szigorú feltétele, hogy a szerver minden lépésben először a pufferben már meglévő adatokat vizsgálja meg, és csak akkor olvasson újra a hálózatról, ha azok nem elegendőek.
Ha ugyanis az előző kérés egy teljes újabb kérést hagyott maga után a pufferben, egy felesleges hálózati olvasás olyan adatra várna, amelyet a kliens már rég elküldött – így a kapcsolat a tétlenségi időkorlát lejártával tévesen bezárulna.
Ugyanez az ellenőrzési sorrend teszi lehetővé a kapcsolat tiszta lezárásának felismerését is: ha a kliens bontja a kapcsolatot (EOF), és a puffer üres, akkor két kérés között, szabályosan lépett ki; ha viszont maradt még feldolgozatlan adat a pufferben, akkor egy kérés közepén szakadt meg a kapcsolat, ami hibának számít.

Az új adatok beolvasása közvetlenül a puffer végére történik.
Mivel az `AsyncRead` csak inicializált memóriaterületbe enged írni, a puffert előbb 8 KiB-tal megnövelem – az új területet nullákkal feltöltve –, majd ebbe a szakaszba olvasok a kapcsolatból, végül pedig visszavágom a ténylegesen megérkezett bájtok végéig.
A 8 KiB csupán egyetlen olvasási művelet felső határa, maga a kérés mérete ennél jóval nagyobb is lehet.
Ennek a megoldásnak az ára a memóriaterület nullázása olvasásonként, cserébe viszont nincs szükség külön átmeneti pufferre és felesleges adatmozgatásra, és teljes egészében elkerülhető az `unsafe` kód használata.
A puffer így minden pillanatban kizárólag az érvényes, megérkezett bájtokat tartalmazza, amelyekből a fejléc és a törzs később másolás nélkül vágható ki.

=== A fejléc elemzése és a zero-copy

#todo[a `split_to` és a `freeze`, a `slice_ref` ablakok az URI-ra és a fejlécértékekre; a kétszeri elemzés indoklása (az első a változó pufferre mutat)]

== Korlátok és védelmek

#todo[a `content_length` szabályai (táblázat: `Transfer-Encoding` -> 501, nincs -> 0, több -> 400, nem szám -> 400, túl nagy -> 413) és a smuggling elleni védelem; nincs előzetes memóriafoglalás a `Content-Length` alapján (slowloris); a kezelő nem állíthat keretező fejlécet; a fejléc (16 KiB), a fejlécek száma (64) és a törzs (1 MiB) alapértéke, összevetve az nginx, az Apache és a Node.js értékeivel (táblázat)]

== Időkorlátok és kapcsolatkezelés

#todo[tétlenségi (5 s) és kérésolvasási (30 s) időkorlát, a `wait_for_request` választja el a kettőt (idővonal egy keep-alive kapcsolaton); a kapcsolatszám-korlát hiánya és következménye]

== A válasz kiírása

#todo[a `ResponseWriter` újrahasznosított `Vec<u8>` puffere; a státuszsort és a keretező fejléceket a szerver írja; `HEAD`: a kezelő `GET`-ként kapja, a törzs nem megy ki, a `Content-Length` igen]

== Hibakezelési elvek

#todo[a belső `Error` és a státuszkódok leképezése, protokollhiba után státuszválasz, I/O hiba után csendes lezárás; `unwrap` + komment az invariánsokra, `?` ott, ahol a garancia nem helyi]

#pagebreak()

// ---------- Az adatbázisréteg ----------
// terjedelem: kb. 7 oldal

= Az adatbázisréteg

== Követelmények és tervezési szempontok

#todo[az adatbázisréteg önálló, alkalmazásfüggetlen könyvtár (tiny-database, crates.io); mit ad (típusos rekordok `u64` azonosítóval egy fájlban, másodlagos indexek egyenlőségre, tartományra és előtagra) és mit nem (lekérdezőnyelv, join, egyediségi megkötés); elv: a könyvtár kódja legyen egyszerű, a kényelmi réteget (pl. makró) a felhasználó megírhatja; a `Database` állapot nélküli, szálak között `Mutex` nélkül megosztható]

== A tárolt adatok modellje

=== Rekordok és indexek

#todo[a `Record` trait (`TABLE`, `Index`, `id`, `index_keys`) és a supertraitek; a típus a metódusokon van, nem a `Database`-en, így egy fájl több rekordtípust tárol; az `Index` trait: enum az indexnevek helyett, az elírás fordítási hiba, a `name()` adja a tárolt táblanevet; `NoIndex`; indexenként egy multimap tábla, példa táblákkal (`users`, `users.name`, `users.age`); többértékű mező és hiányzó érték]

=== Rendezéstartó kulcskódolás

#todo[a `key::enc`: a redb bájtonként hasonlít, ezért a kódolásnak az értékek sorrendjét kell megőriznie; big-endian egészek, előjelbit-csere, lebegőpontos számok; sztringek: `00 01` lezáró és `00 FF` csere; tuple mint összetett kulcs; `prefix_range`; a kódolás a fájlformátum része]

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

// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}




#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  place(
    top,
    float: true,
    scope: "parent",
    clearance: 4mm,
    block(below: 1em, width: 100%)[

      #if title != none {
        align(center, block(inset: 2em)[
          #set par(leading: heading-line-height) if heading-line-height != none
          #set text(font: heading-family) if heading-family != none
          #set text(weight: heading-weight)
          #set text(style: heading-style) if heading-style != "normal"
          #set text(fill: heading-color) if heading-color != black

          #text(size: title-size)[#title #if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }]
          #(if subtitle != none {
            parbreak()
            text(size: subtitle-size)[#subtitle]
          })
        ])
      }

      #if authors != none and authors != () {
        let count = authors.len()
        let ncols = calc.min(count, 3)
        grid(
          columns: (1fr,) * ncols,
          row-gutter: 1.5em,
          ..authors.map(author =>
              align(center)[
                #author.name \
                #author.affiliation \
                #author.email
              ]
          )
        )
      }

      #if date != none {
        align(center)[#block(inset: 1em)[
          #date
        ]]
      }

      #if abstract != none {
        block(inset: 2em)[
        #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
        ]
      }
    ]
  )

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

#set text(lang: "id") 
#set page(
  // Set page size and margins
  paper: "a4",
  margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
)
#set text(
  // Set default font
  font: "New Computer Modern",
  size: 12pt,
)

// Add the title at the top, horizontally centered
#align(horizon)[
  #text(size: 24pt, weight: "bold")[
    Your Document Title
  ]
  #v(1em) // Vertical spacing
  #text(size: 16pt)[
    A Wonderful Subtitle
  ]
]

// Move to the bottom left for author and date
#align(bottom + left)[
  #text(weight: "bold")[
    Author Name
  ]
  #v(0.5em)
  #datetime.today().display() // Current date
]

// Ensure this content is placed on its own page
#pagebreak()

#outline()
#pagebreak()
#image("STEI/pg_0007.pdf")
#pagebreak()
= 1. RINGKASAN PROPOSAL
<ringkasan-proposal>
Rekayasa sistem multidisiplin modern tengah beralih dari optimasi artefak fisik menuju perancangan sistem sosio-teknis (#emph[Socio-Technical Systems]) yang kompleks. Paradigma tradisional gagal mengakomodasi elemen kesejahteraan psikologis manusia dan kompresi nilai secara bersamaan. Riset ini mengusulkan evolusi paradigma #emph[Triune-Intelligence Smart Engineering] (TISE) menuju #strong[TISE 3.0], sebuah Meta-Artefak autopoietik yang dirancang untuk menjawab #emph[Research Question]: #emph["Bagaimana menyatukan termodinamika penciptaan nilai fisik (Sistem ENERGON/PSKVE), orkestrasi agen otonom (Siklus PUDAL), dan pemberdayaan Identitas Naratif pemangku kepentingan ke dalam satu meta-arsitektur rekursif berbasis prompt?"].

Riset ini akan membangun platform TISE 3.0 menggunakan integrasi #emph[Multi-Agent System] (MAS) berbasis #emph[Large Language Models] (LLMs) yang bertindak sebagai #emph[Meta-Architect, Generative Engineer], dan #emph[Critic]. Sistem ini akan secara otomatis mendekomposisi #emph[prompt] bahasa alami berentropi tinggi menjadi spesifikasi arsitektur SysML v2 berentropi rendah, lalu mengeksekusinya untuk menghasilkan artefak TISE 2.0. Artefak yang dihasilkan dirancang secara khusus untuk memfasilitasi "Siklus Reflektif" yang memberdayakan manusia sebagai #emph[Protagonis-Penulis] atas narasi hidup mereka. Validasi framework akan dilakukan menggunakan model W-Model yang mengintegrasikan lapisan ASTF (#emph[Application, System, Technology, Fundamental]) dengan matriks evaluasi PICOC. Hasil akhir dari riset ini adalah bukti konsep kompresi nilai ($V = U \/ C$) yang akan dipublikasikan di jurnal internasional bereputasi Q1, memperkuat target ITB dalam QS WUR 150.

= 2. PENDAHULUAN
<pendahuluan>
Proposal ini mempresentasikan meta-arsitektur dari #strong[Triune-Intelligence Smart Engineering (TISE 3.0)], sebuah kerangka kerja berbasis #emph[prompt] yang dirancang untuk sistem multidisiplin yang diperkuat oleh narasi. Materi ini merupakan bagian dari Proposal Riset PPMI STEI ITB 2026 yang diajukan oleh Peneliti Utama, Prof.~Ir. Armein Z. R. Langi, M.Sc., Ph.D..

== 2.1 Latar belakang masalah
<latar-belakang-masalah>
Sebagaimana diperlihatkan pada #ref(<fig-masalah>, supplement: [Figure]), rekayasa tradisional saat ini telah mencapai batas asimtotiknya dalam hal efektivitas sistem. Terdapat krisis fundamental di mana:

- Paradigma lama memisahkan komputasi teknis dari kondisi psikologis manusia.

- Manusia direduksi menjadi sekadar operator mekanis.

- Sistem modern gagal beroperasi lebih jauh karena tidak mengakomodasi peran manusia sebagai #strong[#emph[Homo Narrans]]---pencari makna dan pencerita atas kehidupannya sendiri.

#figure([
#image("pdfs/pg_0002.pdf")
], caption: figure.caption(
position: bottom, 
[
Rekayasa tradisional telah mencapai batas asimptotiknya.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-masalah>


Selanjutnya sebagaimana diperlihatkan pada #ref(<fig-evolusi>, supplement: [Figure]), evolusi paradigma rekayasa terbagi menjadi tiga fase utama:

- #strong[SE Dasar:] Berfokus pada optimasi fisik menggunakan mekanisme model PSKVE dan mesin ENERGON untuk mengubah potensi menjadi kerja kinetik.

- #strong[TISE 1.0 & 2.0:] Berfokus pada sistem sosio-teknis dengan mekanisme agen otonom (siklus PUDAL) dan ko-kreasi naratif, di mana manusia diberdayakan sebagai protagonis.

- #strong[Krisis Saat Ini:] Membangun ekosistem TISE 2.0 secara manual terbukti sangat mahal, lambat, dan memiliki kompleksitas kognitif yang tinggi, sehingga membatasi skalabilitas.

#figure([
#image("pdfs/pg_0003.pdf")
], caption: figure.caption(
position: bottom, 
[
Evolusi paradigma rekayasa: menuju sistem sosio-teknis.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-evolusi>


Evolusi TISE dibangun untuk menutup kesenjangan ini secara bertahap. Model dasar #emph[Smart Engineering] (SE) memodelkan realitas dalam ruang 5 dimensi PSKVE (Produk, Servis, #emph[Knowledge], #emph[Value], #emph[Environment]) yang digerakkan oleh "Mesin ENERGON" (mengubah potensi menjadi kerja kinetik). TISE 1.0 mengintegrasikan siklus PUDAL (#emph[Perceive, Understand, Decision, Act, Learning]) untuk mengubah artefak statis menjadi agen otonom. Selanjutnya, TISE 2.0 melakukan pergeseran radikal dari "orkestrasi tugas" menjadi "ko-kreasi naratif," di mana Naskah (#emph[Script]) sistem tidak lagi sekadar #emph[prompt] instruksi, melainkan Epik Personal yang memberdayakan #emph[Identitas Naratif] (Agensi dan Penebusan) dari #emph[stakeholder].

Namun, membangun ekosistem TISE 2.0 secara manual sangat mahal dan kompleks. Oleh karena itu, muncul #strong[The Great Question]: #emph["Bagaimana kita merekayasa sistem yang mampu merekayasa sistem tersebut secara mandiri (autopoietik) sekaligus memadukan ENERGON, PUDAL, dan Pemberdayaan Naratif?"]. (Lihat #ref(<fig-questions>, supplement: [Figure]).) Kebutuhan ini mendasari urgensi TISE 3.0 sebagai "Meta-Artefak" berbasis #emph[prompt] yang beroperasi sebagai Konstruktor Universal untuk melakukan "Kompresi Nilai Termodinamika" ($V = U \/ C$).

#figure([
#image("pdfs/pg_0004.pdf")
], caption: figure.caption(
position: bottom, 
[
Pertanyaan besar dari TISE 3.0.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-questions>


Pertanyaan besar dalam TISE 3.0 adalah bagaimana menyatukan termodinamika fisik, identitas naratif, dan orkestrasi otonom ke dalam satu meta-arsitektur rekursif yang mampu membangun dirinya sendiri.(Lihat #ref(<fig-meta_tise>, supplement: [Figure]))

#figure([
#image("meta-tise.png")
], caption: figure.caption(
position: bottom, 
[
Konsep TISE 3.0: sebuah meta sistem.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-meta_tise>


Sebagaimana diperlihatkan pada #ref(<fig-prompt>, supplement: [Figure]), TISE 3.0 beroperasi sebagai #strong[Konstruktor Universal Berbasis Prompt] dengan proses sebagai berikut:

+ #strong[High-Entropy Prompt:] Input berupa niat dan narasi bahasa alami manusia.

+ #strong[TISE 3.0 Meta-Artifact:] Melakukan kompresi nilai termodinamika berdasarkan formula $V = U \/ C$.

+ #strong[Low-Entropy SysML v2:] Menghasilkan spesifikasi arsitektur sistem yang terstruktur.

+ #strong[TISE 2.0 Artifact:] Terciptanya sistem sosio-teknis yang siap memberdayakan naratif manusia.

#figure([
#image("pdfs/pg_0005.pdf")
], caption: figure.caption(
position: bottom, 
[
TISE 3.0: Konstruktor uniuversal berbasis prompt.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-prompt>


== 2.2 Tujuan riset
<tujuan-riset>
+ Memformulasikan landasan teoritis dan arsitektural TISE 3.0 sebagai Meta-Artefak Rekayasa berbasis Sistem Multi-Agen (MAS).
+ Membangun dan mensimulasikan purwarupa TISE 3.0 yang mengonversi #emph[prompt] entropi tinggi menjadi artefak TISE 2.0 (melalui spesifikasi SysML v2).
+ Mempublikasikan penemuan ini sebagai #emph[The Great Answer] di Jurnal Internasional Bereputasi Q1 (Target: IEEE Transactions).

Sebagaimana digambarkan pada #ref(<fig-MAS>, supplement: [Figure]), Implementasi ini menggunakan sistem multi-agen berbasis #emph[Large Language Model] (LLM) yang terdiri dari:

- #strong[Meta-Architect Agent:] Menggunakan #emph[Chain-of-Thought] untuk memecah #emph[prompt] menjadi rancangan arsitektur berstandar SysML v2.

- #strong[Generative Engineer Agent:] Mengeksekusi rancangan menjadi naskah teknis dan kode algoritma (Partitur Generatif).

- #strong[Critic Agent:] Menguji desain secara ketat terhadap batasan hukum alam atau #emph[Natural Intelligence].

#figure([
#image("pdfs/pg_0006.pdf")
], caption: figure.caption(
position: bottom, 
[
Orketrasi Sistem Multi-Agen (MAS) berbasis LLM.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-MAS>


= 3. METODOLOGI
<metodologi>
Penelitian ini menggunakan #strong[W-Model TISE] sebagai kerangka kerja validasi berkelanjutan (lihat #ref(<fig-W_Model>, supplement: [Figure])):

- #strong[Dekomposisi ASTF:] Kompresi semantik niat pengguna ke dalam logika ontologi empat level: #emph[Application, System, Technology,] dan #emph[Fundamental].

- #strong[Validasi PICOC:] Penentuan kriteria pengujian untuk mengukur efektivitas katalisator naratif pengguna melalui integrasi dan eksekusi FTSA.

Untuk mencapai klaim kompresi nilai, metodologi riset ini akan dieksekusi menggunakan kerangka kerja #strong[TISE W-Model] (Evolusi dari V-Model). W-Model menjamin validasi berkelanjutan di seluruh lapisan arsitektur sosio-teknis:

+ #strong[Outer Left Leg (Dekomposisi ASTF):] Proses dimulai dengan kompresi semantik. Membangun sistem yang menerjemahkan niat #emph[stakeholder] (bahasa alami) menjadi spesifikasi logis menggunakan ontologi PSKVE pada 4 level: #emph[Application, System, Technology, Fundamental] (ASTF).
+ #strong[Inner Left Leg (Desain Internal MAS):] Rekayasa agen AI berbasis LLM (Kecerdasan Rasional) yang bertindak sebagai:
  - #emph[Meta-Architect Agent:] Menggunakan #emph[Chain-of-Thought] untuk menghasilkan arsitektur SysML v2.
  - #emph[Generative Engineer Agent:] Mengeksekusi SysML v2 menjadi kode algoritma (naskah dan partitur).
  - #emph[Critic Agent:] Menguji desain terhadap batasan hukum alam (#emph[Natural Intelligence]).
+ #strong[Inner Right Leg (Persiapan Validasi PICOC):] Mendefinisikan kriteria validasi berbasis #emph[Population, Intervention, Control, Outcome, Context] (PICOC) untuk mengukur keberhasilan kompresi nilai dan efektivitas katalisator naratif (#emph[Prompts 2.0]) dalam membangun Agensi pengguna.
+ #strong[Outer Right Leg (Integrasi dan Pengujian FTSA):] Melakukan eksekusi sistem dari Fundamental ke Aplikasi. Purwarupa akan diuji dalam skenario #emph[Digital Twin]. Evaluasi akhir akan mengukur metrik Rasio Kompresi ($C R = K_(p e r s y a r a t a n) \/ K_(s o l u s i)$) dan tingkat koherensi naratif yang dihasilkan oleh instrumen TISE 2.0.

#figure([
#image("pdfs/pg_0007.pdf")
], caption: figure.caption(
position: bottom, 
[
Kerangka kerja validasi berkelanjutan.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-W_Model>


= 4. DAFTAR PUSTAKA
<daftar-pustaka>
+ Langi, A. Z. R., "Meta-TISE: Arsitektur Rekursif Kompresi Nilai dalam Sistem Rekayasa Cerdas Triune-Intelligence", TISE Whitepaper, 2026.
+ Langi, A. Z. R., "Konsep TISE 2.0: Pemberdayaan Naratif Stakeholder", TISE Whitepaper, 2026.
+ Albrecht, K. "The Triune Intelligence Model." Psychology Today.
+ McAdams, D. P. "Narrative Identity." Wikipedia/Psychological Research.
+ Shannon, C. E. "A Mathematical Theory of Communication." The Bell System Technical Journal, 1948.

= 5. INDIKATOR KEBERHASILAN (TARGET CAPAIAN)
<indikator-keberhasilan-target-capaian>
Target utama riset ini adalah publikasi pada jurnal #strong[IEEE Transactions on Systems, Man, and Cybernetics: Systems] yang direncanakan untuk submisi pada 30 November 2026.(#ref(<fig-ROI>, supplement: [Figure]).) Secara institusional, riset ini bertujuan membuktikan konsep efisiensi kompresi nilai termodinamika dan mendukung pencapaian target reputasi akademik ITB menuju #strong[QS WUR 150].

Sesuai mandat PPMI, target minimal adalah 1 publikasi Q1.

#table(
  columns: (20.55%, 24.66%, 34.25%, 20.55%),
  align: (auto,auto,auto,auto,),
  table.header([No.], [Nama Jurnal Q1 (Target)], [Judul (Tentatif)], [Rencana Submit],),
  table.hline(),
  [1.], [IEEE Transactions on Systems, Man, and Cybernetics: Systems (Q1)], [#emph[Meta-Architecture of Triune-Intelligence Smart Engineering (TISE 3.0): A Prompt-Based Framework for Narrative-Empowered Multidisciplinary Systems]], [30 Nov 2026],
)
#emph[Publikasi akan mencantumkan acknowledgement yang diwajibkan: "This research is funded by Riset PPMI STEI 2026 - Riset Guru Besar…"]

#figure([
#image("pdfs/pg_0010.pdf")
], caption: figure.caption(
position: bottom, 
[
Tujuan dan Impak riset ini
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ROI>


= 6. JADWAL PELAKSANAAN
<jadwal-pelaksanaan>
Sebagaimana di perloihatkan pada #ref(<fig-Jadwal>, supplement: [Figure]), Proyek ini direncanakan berjalan dari #strong[April hingga Desember 2026]. Tahapan mencakup spesifikasi ASTF, pengembangan MAS, desain #emph[Digital Twin], hingga finalisasi manuskrip untuk jurnal Q1 pada bulan ke-9.

Penelitian dilaksanakan selama 9 bulan (April -- Desember 2026).

- #strong[Bulan 1-2 (April-Mei):] Outer Left W-Model (Spesifikasi ASTF & Model Konseptual PSKVE/Energon).
- #strong[Bulan 3-4 (Juni-Juli):] Inner Left W-Model (Pengembangan #emph[Multi-Agent System] & Integrasi SysML v2).
- #strong[Bulan 5-6 (Ags-Sep):] Inner Right W-Model (Desain Skenario Validasi PICOC & #emph[Digital Twin]).
- #strong[Bulan 7-8 (Okt-Nov):] Outer Right W-Model (Pengujian Kompresi Nilai $V = U \/ C$, Evaluasi Naskah TISE 2.0). Penulisan Draf Jurnal dengan #emph[Backward Strategy].
- #strong[Bulan 9 (Desember):] Finalisasi #emph[Manuscript], #emph[Submit] ke Jurnal IEEE (Q1), dan Pelaporan PPMI.

#figure([
#image("pdfs/pg_0008.pdf")
], caption: figure.caption(
position: bottom, 
[
Jadwal eksekusi terukur.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-Jadwal>


= 7. PETA JALAN (ROAD MAP) RISET
<peta-jalan-road-map-riset>
Berdasarkan rancangan proposal dan landasan konseptual dari sumber yang ada, berikut adalah rincian Peta Jalan (Road Map) Penelitian TISE (Triune-Intelligence Smart Engineering) yang menggambarkan evolusi sistem dari optimasi teknis hingga rekayasa meta-artefak autopoietik:

#figure([
#image("evolusi.png")
], caption: figure.caption(
position: bottom, 
[
Peta jalan riset TISE.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-peta>


#strong[Tahap 1: Formulasi Fondasi #emph[Smart Engineering] (Selesai)] \* #strong[Fokus Utama:] Pemodelan Hukum ENERGON dan Ruang PSKVE. \* #strong[Deskripsi:] Tahap ini meletakkan dasar fundamental bagi TISE dengan mendefinisikan realitas ke dalam ruang 5 dimensi PSKVE: #emph[Product] (Kapasitas kerja fisik), #emph[Service] (Kapasitas pelayanan pemenuhan kebutuhan), #emph[Knowledge] (Kapasitas intelektual/algoritma), #emph[Value] (Kapasitas nilai ekonomi/sosial), dan #emph[Environment] (Kapasitas lingkungan dan keberlanjutan). Sistem dimodelkan sebagai "Mesin ENERGON" (sebuah sistem yang mengubah potensi menjadi kerja kinetik) melalui siklus termodinamika tertutup: #emph[Input, Encoder, Core Storage/Flywheel, Decoder,] dan #emph[Exhaust].

#strong[Tahap 2: TISE 1.0 - Orkestrasi Agen Cerdas (Selesai)] \* #strong[Fokus Utama:] Integrasi #emph[Triune Intelligence] dan Siklus Otonom PUDAL. \* #strong[Deskripsi:] Tahap ini mengubah sistem pasif menjadi sistem cerdas dan agentik. Penelitian memadukan tiga kecerdasan (#emph[Natural, Artificial, Social]) untuk menjalankan mesin operasional bernama siklus adaptif PUDAL: #emph[Perceive] (sensor), #emph[Understand] (diagnosis), #emph[Decision] (alokasi sumber daya), #emph[Act] (eksekusi gaya), dan #emph[Learning] (pembaruan arsitektur). TISE 1.0 sangat berorientasi pada penyelesaian tugas teknis dan penutupan kesenjangan objektif dari Titik A ke Titik B.

#strong[Tahap 3: TISE 2.0 - Paradigma Ko-Kreasi Naratif (Selesai)] \* #strong[Fokus Utama:] Pemberdayaan Identitas Naratif Stakeholders dan Partitur Generatif. \* #strong[Deskripsi:] Memasukkan dimensi psikologi manusia yang mendalam, di mana manusia bukan sekadar eksekutor tugas, melainkan #emph[homo narrans] (organisme pencerita). Pada tahap ini: \* #emph[Naskah (Script)] tidak lagi berupa instruksi kaku dari insinyur, melainkan representasi Identitas Naratif dinamis dari pengguna. \* #emph[Prompts] berubah dari sekadar instruksi tugas menjadi "katalisator reflektif" (seperti pertanyaan: "Apa artinya ini bagi Anda?") yang mendorong Penalaran Otobiografis. \* Insinyur TISE bertransformasi menjadi "Arsitek Lingkungan Naratif" yang merancang ruang seperti "Stasiun Penebusan" dan "Jalan Agensi" untuk memfasilitasi pertumbuhan pengguna.

#strong[Tahap 4: TISE 3.0 - Meta-Artefak Rekursif (Fokus Riset PPMI 2026)] \* #strong[Fokus Utama:] Orkestrasi #emph[Multi-Agent System] (MAS) berbasis LLM dan Kompresi Semantik SysML v2. \* #strong[Deskripsi:] Inilah fokus penelitian Anda saat ini. Karena membangun ekosistem TISE 2.0 secara manual sangat kompleks, tahap ini bertujuan membangun #emph[Meta-Artefak], yaitu sistem autopoietik ("mesin yang membangun mesin"). Agen AI dibagi menjadi peran spesifik (seperti #emph[Meta-Architect], #emph[Generative Engineer], dan #emph[Critic]). Meta-sistem ini menerima #emph[prompt] (keinginan bahasa alami) dari pengguna dan memadatkannya (#emph[Value Compression]) menjadi arsitektur formal untuk mencetak artefak TISE 2.0 secara otonom dan optimal secara komputasi.

#strong[Tahap 5: Masa Depan - Skalabilitas Sosio-Teknis & #emph[Crowdsourced Engineering]] \* #strong[Fokus Utama:] Desain partisipatif #emph[Crowdsourced Engineering] untuk tantangan berskala besar seperti #emph[Smart City]. \* #strong[Deskripsi:] Setelah TISE 3.0 matang, peta jalan akan mengarah pada penyelesaian tantangan di level masyarakat (#emph[Social Intelligence]). Sistem ini akan mengintegrasikan #emph[CrowdRE] (Rekayasa Persyaratan Berbasis Kerumunan), di mana masyarakat bertindak sebagai "sensor entropi" (melaporkan masalah) dan "filter nilai" (memvalidasi solusi etis). Tujuannya adalah memperluas TISE untuk merekayasa tata kelola kota pintar, ekosistem kesehatan publik, dan jaringan energi yang berkelanjutan, menyelaraskan kinerja algoritma secara masif dengan nilai-nilai dan ekologi umat manusia.

Sebagai summary: 1. #strong[Tahap 1 (Selesai):] Formulasi #emph[Smart Engineering] dasar (Model PSKVE dan Hukum ENERGON). 2. #strong[Tahap 2 (Selesai):] TISE 1.0 (Integrasi Kecerdasan Triune & Siklus Otonom PUDAL). 3. #strong[Tahap 3 (Selesai):] TISE 2.0 (Pemberdayaan Identitas Naratif, Partitur Generatif). 4. #strong[Tahap 4 (Fokus Riset Ini - 2026):] TISE 3.0 (Meta-Artefak Rekursif, Orkestrasi #emph[Multi-Agent] LLM, Kompresi Semantik SysML v2). 5. #strong[Tahap 5 (Masa Depan):] Desain partisipatif #emph[Crowdsourced Engineering] massal untuk penyelesaian tantangan #emph[Smart City] & Keberlanjutan Sosio-Teknis.

= 8. USULAN BIAYA RISET
<usulan-biaya-riset>
Total pagu anggaran adalah #strong[Rp 150.000.000,-]. Sebagaimana diperlihatkan pada #ref(<fig-budget>, supplement: [Figure]), Total alokasi anggaran adalah sebesar #strong[Rp 150.000.000], dengan rincian:

- #strong[30% Belanja Pegawai:] Untuk Peneliti Utama dan Asisten.

- #strong[28,3% Belanja Barang:] Langganan API LLM dan lisensi simulasi SysML v2.

- #strong[41,7% Belanja Jasa:] Investasi luaran untuk publikasi jurnal Q1 (APC), #emph[proofreading], serta komputasi awan/GPU.

#figure([
#image("pdfs/pg_0009.pdf")
], caption: figure.caption(
position: bottom, 
[
Rasionalitas anggaran.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-budget>


== 8.1 Belanja Pegawai (Maksimum 30%)
<belanja-pegawai-maksimum-30>
#table(
  columns: (4.88%, 26.83%, 4.88%, 26.83%, 4.88%, 4.88%, 26.83%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([No.], [Pelaksana Kegiatan], [Jml Orang], [Honor per jam], [Jml Jam/Bulan], [Jml Bulan], [Jumlah Biaya (Rp)],),
  table.hline(),
  [1.], [Peneliti Utama], [1], [150.000], [16], [9], [21.600.000],
  [2.], [Asisten Peneliti (Mhs S3/Postdoc)], [1], [100.000], [26], [9], [23.400.000],
  [], [#strong[Jumlah total biaya honor (Rp)]], [], [], [], [], [#strong[45.000.000]],
)
== 8.2 Belanja Barang
<belanja-barang>
#table(
  columns: (5.26%, 39.47%, 5.26%, 15.79%, 15.79%, 18.42%),
  align: (auto,auto,auto,auto,auto,auto,),
  table.header([No.], [Peralatan/Bahan], [Volume], [Satuan], [Biaya Satuan (Rp)], [Jumlah Biaya (Rp)],),
  table.hline(),
  [1.], [Langganan API #emph[Large Language Models] (Prototyping MAS)], [9], [Bulan], [2.500.000], [22.500.000],
  [2.], [Lisensi Software Simulasi Sistem (SysML v2/MBSE)], [1], [Paket], [15.000.000], [15.000.000],
  [3.], [Bahan habis pakai & ATK Riset], [1], [Paket], [5.000.000], [5.000.000],
  [], [#strong[Jumlah total biaya barang (Rp)]], [], [], [], [#strong[42.500.000]],
)
== 8.3 Belanja Jasa
<belanja-jasa>
#emph[Sesuai ketentuan, komponen ini memuat biaya APC Jurnal Q1 (minimal Rp 30.000.000 ditambah beban pajak 31%).] #strong[c.~Sewa Alat, Jasa Layanan dan Lain-lain]

#table(
  columns: (5%, 47.5%, 5%, 20%, 22.5%),
  align: (auto,auto,auto,auto,auto,),
  table.header([No.], [Nama Alat/Jasa Layanan], [Volume], [Biaya Satuan (Rp)], [Jumlah Biaya (Rp)],),
  table.hline(),
  [1.], [Jasa APC Publikasi Jurnal Q1 (IEEE Open Access)], [1], [42.000.000], [42.000.000],
  [2.], [Jasa Proofreading & English Editing Professional], [1], [8.500.000], [8.500.000],
  [3.], [Jasa Cloud Server / GPU Compute Computing], [6], [2.000.000], [12.000.000],
  [], [#strong[Jumlah total biaya sewa alat, jasa layanan, dll. (Rp)]], [], [], [#strong[62.500.000]],
)
#strong[TOTAL ANGGARAN KESELURUHAN = Rp. 150.000.000,-]

= 9. CV TIM PENELITI
<cv-tim-peneliti>
#emph[\(Sesuai lampiran terpisah)]

#horizontalrule

#emph[Catatan: Dokumen proposal ini telah disesuaikan tepat dengan kerangka acuan yang ditetapkan pada Surat Nomor: 1513/IT1.C12/KU/2026. Seluruh komponen mulai dari persentase honorarium (maks 30%), pengalokasian dana jasa APC yang memperhitungkan pajak 31%, serta target publikasi (submitted by Dec 2026) telah terpenuhi.]

B

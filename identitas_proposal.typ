#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 2.2cm, right: 2.2cm),
)

#set text(
  font: "Times New Roman",
  size: 11pt,
)

#set par(justify: true)

#let dots(n: 34) = "." * n
#let fillline(width: 100%) = box(width: width, inset: 0pt)[#h(0pt)]
#let sigline(width: 6cm) = box(
  width: width,
  height: 1.2em,
  stroke: (bottom: 0.8pt),
  inset: 0pt,
)[]

#align(center)[
  #text(weight: "bold", 13pt)[IDENTITAS PROPOSAL]
]

#v(0.6em)

#table(
  columns: (0.7cm, 4.8cm, 0.4cm, 1fr),
  inset: 0pt,
  stroke: none,
  column-gutter: 0.1cm,
  row-gutter: 0.15cm,
)[
  [1.], [Judul], [:], [Armein Z Langi],

  [2.], [Tim Riset], [], [],

  [], [2.1 Ketua Tim], [:], [],

  [], [#h(0.6cm) a.\ \ Nama Lengkap], [:], [#h(100%)],
  [], [#h(0.6cm) b.\ \ Jabatan Fungsional/Golongan], [:], [#h(100%)],
  [], [#h(0.6cm) c.\ \ NIP], [:], [#h(100%)],
  [], [#h(0.6cm) d.\ \ Fakultas/Sekolah/Pusat], [:], [#h(100%)],
  [], [#h(0.6cm) e.\ \ Kelompok Keahlian], [:], [#h(100%)],
  [], [#h(0.6cm) f.\ \ Alamat /Telp/Fax/E-mail], [:], [#h(100%)],
]

#v(0.5em)

#table(
  columns: (0.7cm, 4.8cm, 0.4cm, 1fr),
  inset: 0pt,
  stroke: none,
  column-gutter: 0.1cm,
)[
  [], [2.2 Anggota Tim Riset:], [], [],
]

#v(0.3em)

#table(
  columns: (0.8cm, 4.3cm, 3.1cm, 3.0cm, 1.5cm, 1.2cm),
  align: center + horizon,
  stroke: 0.6pt,
  inset: 4pt,
)[
  [*No.*],
  [*Nama dan Gelar* \ *Akademik*],
  [*Bidang Keahlian*],
  [*Unit Kerja / Lembaga*],
  [*Alokasi Waktu Jam/mg*],
  [*bulan*],

  [1.], [], [], [], [], [],
  [2.], [], [], [], [], [],
]

#v(1.1em)

#table(
  columns: (0.7cm, 4.8cm, 0.4cm, 1fr),
  inset: 0pt,
  stroke: none,
  column-gutter: 0.1cm,
  row-gutter: 0.25cm,
)[
  [3.], [Biaya yang diusulkan], [:], [Rp. 150.000.000,-],

  [4.], [
    Target keluaran Riset \
    (minimum 1 jurnal internasional bereputasi Q1)
  ], [:], [],
]

#v(0.4em)

#table(
  columns: (0.8cm, 4.2cm, 4.6cm, 4.0cm),
  align: center + horizon,
  stroke: 0.6pt,
  inset: 4pt,
)[
  [*No.*],
  [*Judul*],
  [*Nama Jurnal/Publikasi*],
  [*Keterangan* \
   #text(size: 9pt)[(Isikan dengan Q1/Q2/Q3/Q4/Konferensi)]],

  [1.], [], [], [],
  [2.], [], [], [],
]

#v(1.2em)

Proposal ini belum pernah didanai oleh atau diusulkan ke sumber lain. Apabila target
luaran penelitian sebagaimana disebutkan di atas tidak tercapai, maka saya bersedia
mengambil langkah-langkah korektif dan bertanggung jawab penuh atas segala
konsekuensi penggunaan dana penelitian tersebut.

#v(2.8cm)


// Define the signature line function
#let sigline(text_content, width: 5cm) = {
  stack(dir: ltr, spacing: 0.5em,
    text_content + ":",
    box(width: width, line(length: 100%))
  )
}

// Usage Example
#v(2cm) // Space for signature
#sigline[Signed] #h(2em) #sigline[Date]

// Another example for Name/Date
#v(1cm)
#grid(
  columns: (auto, 1fr, auto, 1fr),
  rows: 2,
  gutter: 1em,
  [Name:], [#line(length: 100%)],
  [Date:], [#line(length: 100%)]
)


#align(right)[
  Bandung,

  Ketua Tim Riset

  #v(2.8cm)

  #sigline[Armein]

  NIP. #sigline[12345678]
]
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "liberation sans", size: 11pt)
// Title
#align(center)[
  #upper(text(weight: "bold")[Identitas Proposal])
]

#v(1em)

// Section 1 & 2.1 Header
#grid(
  columns: (20pt, 20pt, 150pt, 5pt, 1fr),
  gutter: 0.6em,
  grid.cell(colspan: 3)[1. Judul], [:], [Meta-Architecture of Triune-Intelligence Smart Engineering (TISE 3.0): A Prompt-Based Framework for Narrative-Empowered Multidisciplinary Systems], 
  grid.cell(colspan: 3)[2. Tim Riset], [], [], 
  [], grid.cell(colspan: 2)[2.1 Ketua Tim], [],[], 
  [], [], [a. Nama Lengkap],[:], [Prof. Ir. Armein Z. R. Langi, M.Sc., Ph.D.], 
  [], [], [b. Jabatan Fungsional/Golongan],[:], [Guru besar / IV e], 
  [], [], [c. NIP],[:], [], 
  [], [], [d. Fakultas/Sekolah/Pusat],[:], [Sekolah Teknik Elektro dan Informatika (STEI)], 
  [], [], [e. Kelompok Keahlian],[:], [Teknologi Informasi], 
  [], [], [f. Alamat /Telp/Fax/E-mail],[:], [],
)

#v(0.5em)

// Section 2.2 Table
#h(20pt) 2.2 Anggota Tim Riset:
#v(0.5em)

#table(
  columns: (30pt, 1fr, 1fr, 1fr, 45pt, 45pt),
  align: (center + horizon),
  inset: 5pt,
  table.header(
    [No.],
    [Nama dan Gelar\ Akademik],
    [Bidang Keahlian],
    [Unit Kerja/\ Lembaga],
    table.cell(colspan: 2)[Alokasi Waktu],
    [], [], [], [], [Jam/mg], [bulan],
  ),
  [1.], [], [], [], [], [],
  [2.], [], [], [], [], [],
)

#v(1em)

// Section 3 & 4
#grid(
  columns: (20pt, 150pt, 5pt, 1fr),
  gutter: 0.6em,
  [3.], [Biaya yang diusulkan], [:], [Rp. 150.000.000,-],
  [4.], [Target keluaran Riset], [:], [],
)
#h(25pt) #text(style: "italic")[(minimum 1 jurnal internasional bereputasi Q1)]

#v(0.5em)

// Section 4 Table
#table(
  columns: (30pt, 1fr, 1fr, 100pt),
  align: (center + horizon),
  inset: 5pt,
  table.header([No.], [Judul], [Nama Jurnal/Publikasi], [Keterangan]),
  [1.], [Meta-Architecture of Triune-Intelligence Smart Engineering (TISE 3.0): A Prompt-Based Framework for Narrative-Empowered Multidisciplinary Systems], [IEEE Systems], [Q1],
  [2.], [], [], [],
)

#v(2em)

// Declaration and Signature
#block(width: 100%)[
  Proposal ini belum pernah didanai oleh atau diusulkan ke sumber lain.

  Apabila target luaran penelitian sebagaimana disebutkan di atas tidak tercapai, maka saya bersedia mengambil langkah-langkah korektif dan bertanggung jawab penuh atas segala konsekuensi penggunaan dana penelitian tersebut.
]

#v(1em)

#align(right)[
  #block(width: 200pt)[
    #align(left)[
      Bandung, ......................... \
      Ketua Tim Riset \
      #v(4em)
      (.......................................) \
      NIP.
    ]
  ]
]

#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "linux libertine", size: 11pt)

// Title
#align(center)[
  #upper(text(weight: "bold")[Identitas Proposal])
]

#v(1em)

// Section 1 & 2.1 Header
#grid(
  columns: (20pt, 150pt, 5pt, 1fr),
  gutter: 0.6em,
  [1.], [Judul], [:], [],
  [2.], [Tim Riset], [:], [],
  [], [2.1 Ketua Tim], [], [],
  [], [a. Nama Lengkap], [:], [],
  [], [b. Jabatan Fungsional/Golongan], [:], [],
  [], [c. NIP], [:], [],
  [], [d. Fakultas/Sekolah/Pusat], [:], [],
  [], [e. Kelompok Keahlian], [:], [],
  [], [f. Alamat /Telp/Fax/E-mail], [:], []
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
    [], [], [], [], [Jam/mg], [bulan]
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
  table.header(
    [No.], [Judul], [Nama Jurnal/Publikasi], [Keterangan]
  ),
  [], [], [], text(size: 8pt)[(Isikan dengan\ Q1/Q2/Q3/Q4/Konferensi)],
  [1.], [], [], [],
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

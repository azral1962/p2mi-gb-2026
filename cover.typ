
#set text(lang: "id")
#set page(
  // Set page size and margins
  paper: "a4",
  margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
)
#set text(
  // Set default font
  font: "New Computer Modern",
  size: 14pt,
)


// Add the title at the top, horizontally centered
#align(top + center)[
  #text(size: 16pt, weight: "bold")[
    PROPOSAL
    RISETs
  ]
  #v(1em) // Vertical spacing
  #text(size: 16pt, weight: "bold")[
    RISET PPMI STEI 2026 - RISET GURU BESAR
  ]
  #image("images/typst-logo.jpg", width: 1.5in)
]

#align(horizon + center)[
  #block(
  stroke: black,
  inset: 8pt,
  radius: 4pt,
  "Meta-Architecture of Triune-Intelligence Smart Engineering (TISE 3.0): A Prompt-Based Framework for Narrative-Empowered Multidisciplinary Systems"
  )
]

// Move to the bottom left for author and date
#align(bottom + center)[
  #text(weight: "bold")[
  Ketua Tim Peneliti:

  Prof. Ir. Armein Z. R. Langi, M.Sc., Ph.D. 

  KK: Teknologi Informasi

  ]
  #v(0.5em)
    #text(weight: "bold")[

SEKOLAH TEKNIK ELEKTRO DAN INFORMATIKA

 INSTITUT TEKNOLOGI BANDUNG

  MARET 2026

  ]
]

// Ensure this content is placed on its own page
#pagebreak()

#include "proposal.typ"
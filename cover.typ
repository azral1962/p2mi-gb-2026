
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

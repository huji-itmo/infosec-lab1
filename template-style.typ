// Локальная копия настроек оформления из ~/dev/report-template/report.typ.

#let report(body) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 1.5cm, top: 2cm, bottom: 2cm),
    numbering: (..n) => if n.pos().at(0) == 1 { none } else { numbering("1", n.pos().at(0)) },
    number-align: center,
  )
  set text(font: ("Liberation Serif", "Libertinus Serif", "Noto Serif"), size: 14pt, lang: "ru", region: "RU")
  set par(justify: true, leading: 1.5em - 0.6548em, spacing: 1.5em - 0.6548em, first-line-indent: (amount: 1.25cm, all: true))
  set heading(numbering: "1.1")
  show heading: set par(justify: false)
  show heading.where(level: 1): set text(size: 1.2em, weight: "bold")
  show heading.where(level: 2): set text(size: 1.1em, weight: "bold")
  show heading.where(level: 3): set text(size: 1em, weight: "bold")
  show heading.where(level: 1): set block(above: 18.9pt, below: 12.4pt)
  show heading.where(level: 2): set block(above: 17.6pt, below: 8.1pt)
  show heading.where(level: 3): set block(above: 17.6pt, below: 8.1pt)
  show link: it => if type(it.dest) == str { text(fill: rgb("#0000ff"), it.body) } else { text(fill: black, it.body) }
  show ref: set ref(supplement: none)
  set list(marker: ([•], [–], [∗]))
  set enum(numbering: "1.")
  set table(stroke: none, inset: (x: 6pt, y: 4pt))
  show raw: set text(font: ("DejaVu Sans Mono", "Liberation Mono"), size: 0.9em)
  set outline(depth: 3)
  body
}

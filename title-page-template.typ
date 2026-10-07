// Локальная копия титульной страницы из ~/dev/report-template.

#let title-page(
  subject: "Компьютерные сети",
  work-type: "Лабораторная работа",
  work-number: "1",
  student-name: "Фамилия И.О.",
  student-group: "Р3315",
  reviewer-name: "Преподаватель",
  city: "Санкт-Петербург",
  year: "2026",
  ministry-line: "Министерство образования и науки Российской Федерации",
  university: "федеральное государственное автономное образовательное учреждение высшего образования",
  university-short: "НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ УНИВЕРСИТЕТ ИТМО",
  faculty: "Факультет «Программной инженерии и компьютерной техники»",
) = {
  set text(hyphenate: false)
  set par(leading: 0.55em, spacing: 0.55em)
  block(height: 100%)[
    #align(center)[#ministry-line \ #university \ #university-short
      #v(1.5em)
      #faculty]
    #v(3cm)
    #align(center)[#subject #v(1em) #work-type №#work-number]
    #v(4cm)
    #align(right)[#text(weight: "bold")[Выполнил:] \ #student-name \ Группа: #student-group
      #v(1.5em)
      #text(weight: "bold")[Проверил:] \ #reviewer-name]
    #v(1fr)
    #align(center)[#city, #year]
  ]
}

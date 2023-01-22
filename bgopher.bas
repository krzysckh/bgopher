#include "bgopher.bi"

#include "crt/stdio.bi"

function getnl(text as string) as integer
  dim as integer nl = 0, i = 0
  while (i < len(text))
    if mid(text, i, 1) = !"\n" then nl += 1
    i += 1
  wend

  return nl
end function

function t_pseudoparse(text as string) as page ptr
  dim as integer nl = getnl(text)
  dim lines(nl) as string
  dim as page ptr ret = new page

  redim as obj ret->l(nl)

  for i as integer = 0 to nl
    ret->l(i).display = left(text, instr(text, !"\n") - 1)
    text = right(text, len(text) - instr(text, !"\n"))
    ret->l(i).t = info
  next
  ret->sz = nl

  return ret
end function

function parse(text as string) as page ptr
  dim as integer nl = getnl(text)
  dim lines(nl) as string
  dim as page ptr ret = new page
  dim _eot as integer = 0

  redim as obj ret->l(nl)
  ' i've spent a lot of time looking for that syntax

  for i as integer = 0 to nl
    lines(i) = left(text, instr(text, !"\n"))
    text = right(text, len(text) - instr(text, !"\n"))
  next

  for i as integer = 0 to nl
    select case left(lines(i), 1)
      case "0": ret->l(i).t = text_file
      case "1": ret->l(i).t = submenu
      case "2": ret->l(i).t = nameserver
      case "3": ret->l(i).t = ecode
      case "4": ret->l(i).t = binhex
      case "5": ret->l(i).t = dosf
      case "6": ret->l(i).t = uuf
      case "7": ret->l(i).t = fulltexts
      case "8": ret->l(i).t = telnet
      case "9": ret->l(i).t = binf
      case "+": ret->l(i).t = mirror
      case "g": ret->l(i).t = gif
      case "I": ret->l(i).t = image
      case "T": ret->l(i).t = telnet
      case ":": ret->l(i).t = bitmap
      case ";": ret->l(i).t = movie
      case "<": ret->l(i).t = audio
      case "d": ret->l(i).t = document
      case "h": ret->l(i).t = html
      case "i": ret->l(i).t = info
      case "p": ret->l(i).t = pngimage
      case "r": ret->l(i).t = rtffile
      case "s": ret->l(i).t = wavfile
      case "p": ret->l(i).t = pdffile
      case "X": ret->l(i).t = xmlfile
      case ".": _eot = 1
      case else: ret->l(i).t = unknown
    end select

    if _eot = 1 then
      exit for
    end if

    lines(i) = right(lines(i), len(lines(i)) - 1)

    ret->l(i).display = left(lines(i), instr(lines(i), !"\t") - 1)
    lines(i) = right(lines(i), len(lines(i)) - instr(lines(i), !"\t"))

    ret->l(i).selector = left(lines(i), instr(lines(i), !"\t") - 1)
    lines(i) = right(lines(i), len(lines(i)) - instr(lines(i), !"\t"))

    ret->l(i).hostname = left(lines(i), instr(lines(i), !"\t") - 1)
    lines(i) = right(lines(i), len(lines(i)) - instr(lines(i), !"\t"))

    ret->l(i).port = right(lines(i), len(lines(i)) - instr(lines(i), !"\n"))
    if len(ret->l(i).port) = 0 then ret->l(i).port = "70"
  next

  ret->sz = nl

  return ret
end function

function main as integer
  ui_init
  dim as page ptr p = parse(g_get(command(1), "/", "70"))

  ui_run(p)

  ui_end
  return 0
end function

main

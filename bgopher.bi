enum line_t
  text_file
  submenu
  nameserver
  ecode
  binhex
  dosf
  uuf
  fulltexts
  telnet
  binf
  mirror
  gif
  image
  bitmap
  movie
  audio
  document
  html
  info
  pngimage
  rtffile
  wavfile
  pdffile
  xmlfile
  unknown
end enum

type obj
  t as line_t
  display as string
  selector as string
  hostname as string
  port as string
end type

type page
  l(any) as obj
  sz as integer
end type

declare function parse(text as string) as page ptr
declare function g_get(addr as string, file as string, port as string) as string

declare sub ui_run(p as page ptr)
declare sub ui_init
declare sub ui_end

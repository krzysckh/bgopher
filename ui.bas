#include "bgopher.bi"

#include "curses.bi"

sub ui_init
  dim as integer row, col
  'dim as chtype ls = asc("│"), rs = asc("│"), ts = asc("─"), bs = asc("─")
  'dim as chtype tl = asc("┌"), tr = asc("┐"), bl = asc("└"), br = asc("┘")

  initscr()
  cbreak()
  noecho()
  keypad(stdscr, true)
  curs_set(0)

  'border(ls, rs, ts, bs, tl, tr, bl, br)
end sub

sub ui_end
  endwin()
end sub

function t_str (t as line_t) as string
  select case t
    case text_file : return " [txt] "
    case submenu   : return " [sub] "
    case nameserver: return " [srv] "
    case ecode     : return " [err] "
    case binhex    : return " [bih] "
    case dosf      : return " [dos] "
    case uuf       : return " [uue] "
    case fulltexts : return " [src] "
    case telnet    : return " [tel] "
    case binf      : return " [bin] "
    case mirror    : return " [mir] "
    case gif       : return " [gif] "
    case image     : return " [img] "
    case bitmap    : return " [img] "
    case movie     : return " [mov] "
    case audio     : return " [aud] "
    case document  : return " [doc] "
    case html      : return " [htm] "
    case info      : return "       "
    case pngimage  : return " [img] "
    case rtffile   : return " [rtf] "
    case wavfile   : return " [wav] "
    case pdffile   : return " [pdf] "
    case xmlfile   : return " [xml] "
    case unknown   : return " [???] "
  end select
end function

function link_handler(o as obj ptr) as integer
  select case o->t
    case text_file, submenu:
      ui_run(parse(g_get(o->hostname, o->selector, o->port)))
    case binhex, dosf, uuf, binf, gif, image, bitmap, movie, audio, document, _
         html, pngimage, rtffile, wavfile, pdffile, xmlfile:


    case nameserver:
    case ecode     :
    case fulltexts :
    case telnet    :
    case mirror    :
    case info      :
    case unknown   :
  end select
end function

sub ui_run(p as page ptr)
  dim as integer x = 0, y = 0, cur = 0
  dim as obj ptr curs = @(p->l(0))
  dim as string c

  for i as integer = 0 to p->sz
    if len(p->l(i).display) = 0 then p->l(i).display = " "
  next

drawp:
  'clear_()
  for i as integer = 0 to p->sz
    mvprintw(y, x, t_str(p->l(i).t))
    if @(p->l(i)) = curs then attron(A_UNDERLINE)
    mvprintw(y, x + 7, "%s", p->l(i).display)
    if @(p->l(i)) = curs then attroff(A_UNDERLINE)
    y = y + 1
  next

  refresh()
  c = wchr(getch())

  select case c
    case "j":
      if cur < p->sz then
        curs += 1
        cur  += 1
      end if
    case "k":
      if cur > 0 then
        curs -= 1
        cur  -= 1
      end if
    case "q":
      ui_end
      end 0
    case !"\n"
      clear_()
      link_handler(curs)
  end select

  y = 0
  goto drawp
end sub
